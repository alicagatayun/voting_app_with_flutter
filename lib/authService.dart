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

  Future<String> assignUserToARooom(
      {required String roomId, required String userId}) async {
    try {
      var userExistSnapshot = firestoreInstance
          .collection('rooms')
          .where('users', arrayContains: {'id': userId}).get();
      if (userExistSnapshot.toString().isEmpty) {
        DocumentReference documentReference =
            firestoreInstance.collection('rooms').doc(roomId);

        //Kullanıcının username'ini alır.
        DocumentReference documentReferenceForUserTable =
            firestoreInstance.collection('users').doc(userId);
        var userName;
        documentReferenceForUserTable.get().then((value) {
          Map<String, dynamic>? data = value.data() as Map<String, dynamic>?;
          if (value.exists && data != null) {
            userName = data['name'];
          }
        });

        //Kullanıcıyı selected odaya assign eder.
        documentReference.get().then((documentSnapshot) {
          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;

          //Users map'i exist
          if (documentSnapshot.exists &&
              data != null &&
              data['users'] != null) {
            Map<String, dynamic> newUser = {
              'id': userId,
              'name': userName,
              'sp': "-1",
            };

            documentReference.update(newUser);



          } else {
            //UserMapi not exist
            List<Map<String, String>> myArray = [
              {'id': userId, 'sp': "-1", 'name': userName},
            ];
            documentReference.set({
              'users': myArray,
            });
          }
        });
      } else {}

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
    DocumentSnapshot documentSnapshot =
        await firestoreInstance.collection("users").doc(getUser()?.uid).get();

    return UserDetail.fromFirestore(documentSnapshot);
  }
}
