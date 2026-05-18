import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
import 'add_product.dart';
import 'profile.dart';
import 'wishlist.dart';

class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/add': (context) => const AddProductPage(),
        '/profile': (context) => const ProfilePage(),
        '/wishlist': (context) => const WishlistPage(),
      },
      theme: ThemeData.light(useMaterial3: true).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8D8686), // Muted grey from slide
          foregroundColor: Colors.white,      // White text
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
      ),
    );
  }
}
