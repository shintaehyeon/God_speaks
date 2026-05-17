import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _checkAndCreateUser(User user, {bool isAnonymous = false}) async {
    final userDoc = _firestore.collection('user').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      if (isAnonymous) {
        await userDoc.set({
          'uid': user.uid,
          'status_message': 'I promise to take the test honestly before GOD.',
        });
      } else {
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? 'Unknown',
          'email': user.email ?? 'Unknown',
          'status_message': 'I promise to take the test honestly before GOD.',
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _checkAndCreateUser(userCredential.user!);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint('Google Sign-in Error: $e');
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        await _checkAndCreateUser(userCredential.user!, isAnonymous: true);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint('Anonymous Sign-in Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('SHRINE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: const Text('Google Sign-in'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInAnonymously,
                child: const Text('Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
