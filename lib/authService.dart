import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth/UserDetail.dart';

class AuthenticationService {
  // 1
  final FirebaseAuth _firebaseAuth;
  final firestoreInstance = FirebaseFirestore.instance;

  AuthenticationService(this._firebaseAuth);

  // 2
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // 3
  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

  // 4
  Future<String> signUp(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "Signed up";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

  Future<String> saveUserData(
      {required String name, required String surname}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(getUser()?.uid)
          .set({'name': name, 'surname': surname});
      return "OK";
    } on FirebaseException catch (e) {
      return e.message!;
    }
  }

  // 5
  Future<String> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return "Signed out";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

// 6
  User? getUser() {
    try {
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<UserDetail> getUserDetail() async {
    DocumentSnapshot documentSnapshot = await firestoreInstance
        .collection("users")
        .doc(getUser()?.uid)
        .get();

    return UserDetail.fromFirestore(documentSnapshot);
  }
}
