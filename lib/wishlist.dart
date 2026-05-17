import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'state/wishlist_provider.dart';
import 'models/product.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          final wishlistIds = wishlistProvider.wishlistIds;

          if (wishlistIds.isEmpty) {
            return const Center(child: Text('Wishlist is empty'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Error'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final products = snapshot.data!.docs
                  .map((doc) => Product.fromFirestore(doc))
                  .where((p) => wishlistIds.contains(p.id))
                  .toList();

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(product.name),
                    subtitle: Text('\$${product.price}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        wishlistProvider.removeFromWishlist(product.id);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
