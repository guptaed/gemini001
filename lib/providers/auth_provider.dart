import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/screens/login_screen.dart';
import 'package:gemini001/utils/logging.dart';
//import 'package:gemini001/screens/home_screen.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirestoreHelper().signOut();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
        logger.e('Error signing out user: ${_user?.email}', e);
      }
    }
  }
}