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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/diamond.png',
                  width: 50,
                  height: 50,
                  color: Colors.black87,
                ),
                const SizedBox(height: 16),
                const Text(
                  'SHRINE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 80),
                
                // Google Sign-in Button
                GestureDetector(
                  onTap: _signInWithGoogle,
                  child: Container(
                    width: 280,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            color: const Color(0xFFC53929),
                            alignment: Alignment.center,
                            child: const Text(
                              'G',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: const Color(0xFFF08F8F),
                              alignment: Alignment.center,
                              child: const Text(
                                'GOOGLE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Guest Button
                GestureDetector(
                  onTap: _signInAnonymously,
                  child: Container(
                    width: 280,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: const Text(
                              '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: const Color(0xFFBDC1C6),
                              alignment: Alignment.center,
                              child: const Text(
                                'Guest',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
