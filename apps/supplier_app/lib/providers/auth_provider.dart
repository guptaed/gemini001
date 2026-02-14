import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vietfuel_shared/vietfuel_shared.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  int? _supId;
  Supplier? _supplierProfile;
  bool _isLoading = true;

  User? get user => _user;
  int? get supId => _supId;
  Supplier? get supplierProfile => _supplierProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _supId != null;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadSupplierProfile(user.email ?? '');
    } else {
      _supId = null;
      _supplierProfile = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSupplierProfile(String email) async {
    try {
      // Look up supId from Smartphoneaccess collection by loginName
      final accessSnapshot = await FirebaseFirestore.instance
          .collection('Smartphoneaccess')
          .where('LoginName', isEqualTo: email)
          .limit(1)
          .get();

      if (accessSnapshot.docs.isNotEmpty) {
        final data = accessSnapshot.docs.first.data();
        _supId = data['SupId'] as int;

        // Load full supplier profile
        final supplierSnapshot = await FirebaseFirestore.instance
            .collection('Suppliers')
            .where('SupId', isEqualTo: _supId)
            .limit(1)
            .get();

        if (supplierSnapshot.docs.isNotEmpty) {
          _supplierProfile =
              Supplier.fromFirestore(supplierSnapshot.docs.first);
        }
      }
    } catch (e) {
      logger.e('Error loading supplier profile: $e');
    }
  }

  Future<User?> signIn(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    _supId = null;
    _supplierProfile = null;
    notifyListeners();
  }
}
