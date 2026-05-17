import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'models/product.dart';
import 'state/wishlist_provider.dart';
import 'add_product.dart';

class DetailPage extends StatefulWidget {
  final Product product;

  const DetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _listenToProductChanges();
  }

  void _listenToProductChanges() {
    FirebaseFirestore.instance
        .collection('products')
        .doc(_product.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        if (mounted) {
          setState(() {
            _product = Product.fromFirestore(snapshot);
          });
        }
      }
    });
  }

  bool get _isCreator => currentUser?.uid == _product.creatorUid;

  Future<void> _handleDelete() async {
    if (!_isCreator) return;
    await FirebaseFirestore.instance.collection('products').doc(_product.id).delete();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleLike() async {
    if (currentUser == null) return;
    
    final uid = currentUser!.uid;
    if (_product.likedBy.contains(uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only do it once !!')),
      );
    } else {
      await FirebaseFirestore.instance.collection('products').doc(_product.id).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([uid]),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('I LIKE IT!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          if (_isCreator)
            IconButton(
              icon: const Icon(Icons.create),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductPage(productToEdit: _product),
                  ),
                );
              },
            ),
          if (_isCreator)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(_product.imageUrl, fit: BoxFit.cover, height: 250, width: double.infinity),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(_product.name, style: Theme.of(context).textTheme.headlineSmall)),
                IconButton(
                  icon: const Icon(Icons.thumb_up),
                  onPressed: _handleLike,
                ),
                Text('${_product.likes}'),
              ],
            ),
            Text('\$${_product.price}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Divider(),
            Text(_product.description),
            const SizedBox(height: 16),
            const Divider(),
            Text('creator: ${_product.creatorUid}'),
            Text('${_product.creationTime.toDate()} Created'),
            Text('${_product.updateTime.toDate()} Modified'),
          ],
        ),
      ),
      floatingActionButton: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          final inWishlist = wishlistProvider.isInWishlist(_product.id);
          return FloatingActionButton(
            onPressed: () {
              wishlistProvider.toggleWishlist(_product.id);
            },
            child: Icon(inWishlist ? Icons.check : Icons.shopping_cart),
          );
        },
      ),
    );
  }
}
