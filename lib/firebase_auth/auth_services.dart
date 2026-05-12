import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthServices> authServices = ValueNotifier(AuthServices());

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String memberId,
    required String password,
  }) async {
    final memberEmail = '$memberId@yourdomain.com';
    return await _auth.signInWithEmailAndPassword(
      email: memberEmail,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String memberId,
    required String password,
  }) async {
    final memberEmail = '$memberId@yourdomain.com';
    return await _auth.createUserWithEmailAndPassword(
      email: memberEmail,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String memberId}) async {
    final memberEmail = '$memberId@yourdomain.com';
    await _auth.sendPasswordResetEmail(email: memberEmail);
  }

  Future<void> updateUserName(String name) async {
    await currentUser?.updateDisplayName(name);
    await currentUser?.reload();
  }
}
