import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_task/pages/signin_page.dart';
import 'package:firebase_task/service/log_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static bool isLoggedIn() {
    final User? firebaseUser = _auth.currentUser;

    return firebaseUser != null;
  }

  static Future<User?> signInUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final User? firebaseUser = _auth.currentUser;
      return firebaseUser;
    } catch (e) {
      LogService.e('Not found email');
      return null;
    }
  }

  static Future<User?> signUpUser(
      String fullName, String email, String password) async {
    var authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = _auth.currentUser;
    return user;
  }

  static void signOutUser(BuildContext context) {
    _auth.signOut();
    Navigator.pushReplacementNamed(context, SigninPage.id);
  }

 static Future<void> sendEmailVerificationLink()async{
    try{
      await _auth.currentUser?.sendEmailVerification();
      LogService.i('Link sent');
    }catch(e){
        LogService.e(e.toString());
    }
  }

}
