import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'models/product.dart';

class AddProductPage extends StatefulWidget {
  final Product? productToEdit;
  const AddProductPage({Key? key, this.productToEdit}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toString();
      _descController.text = widget.productToEdit!.description;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToStorage() async {
    final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}.png');
    if (_imageFile != null) {
      final uploadTask = await storageRef.putFile(_imageFile!);
      return await uploadTask.ref.getDownloadURL();
    } else {
      final response = await http.get(Uri.parse('http://handong.edu/site/handong/res/img/logo.png'));
      final uploadTask = await storageRef.putData(response.bodyBytes, SettableMetadata(contentType: 'image/png'));
      return await uploadTask.ref.getDownloadURL();
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      String imageUrl;
      if (widget.productToEdit != null && _imageFile == null) {
        imageUrl = widget.productToEdit!.imageUrl;
      } else {
        imageUrl = await _uploadImageToStorage();
      }

      final currentUser = FirebaseAuth.instance.currentUser!;
      final data = {
        'name': _nameController.text,
        'price': int.parse(_priceController.text),
        'description': _descController.text,
        'imageUrl': imageUrl,
        'creatorUid': currentUser.uid,
        'updateTime': FieldValue.serverTimestamp(),
      };

      if (widget.productToEdit == null) {
        data['creationTime'] = FieldValue.serverTimestamp();
        data['likes'] = 0;
        data['likedBy'] = [];
        await FirebaseFirestore.instance.collection('products').add(data);
      } else {
        await FirebaseFirestore.instance.collection('products').doc(widget.productToEdit!.id).update(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Save Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving product')));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 90.0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ),
        title: Text(widget.productToEdit == null ? 'Add' : 'Edit'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : widget.productToEdit != null
                              ? Image.network(widget.productToEdit!.imageUrl, fit: BoxFit.cover)
                              : Image.network('http://handong.edu/site/handong/res/img/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter price';
                      if (int.tryParse(v) == null) return 'Price must be a valid number';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) => v!.isEmpty ? 'Enter description' : null,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
