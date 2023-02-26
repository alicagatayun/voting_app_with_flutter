import 'dart:ffi';

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
  Future<bool> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  User? getUser() {
    try {
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException {
      return null;
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
      {required String roomId, required String sp}) async {
    try {
      DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .get();

      Map<String, dynamic>? data = roomSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        dynamic users = data['users'];
        if (users is List) {
          for (var element in users) {
            if (element['id'] == getUser()?.uid) {
              return "OK";
            }
          }
        }
        DocumentReference documentReference =
            firestoreInstance.collection('rooms').doc(roomId);

        //Kullanıcının username'ini alır.
        DocumentReference documentReferenceForUserTable =
            firestoreInstance.collection('users').doc(getUser()?.uid);
        var userName;
        await documentReferenceForUserTable.get().then((value) {
          Map<String, dynamic>? data = value.data() as Map<String, dynamic>?;
          if (value.exists && data != null) {
            userName = data['name'][0].toString().toUpperCase() +
                data['surname'][0].toString().toUpperCase();
          }
        });

        //Kullanıcıyı selected odaya assign eder.
        await documentReference.get().then((documentSnapshot) async {
          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;

          //Users map'i exist
          if (documentSnapshot.exists &&
              data != null &&
              data['users'] != null) {
            Map<String, dynamic> newUser = {
              'id': getUser()?.uid,
              'name': userName,
              'sp': sp,
            };

            await documentReference.update({
              'users': FieldValue.arrayUnion([newUser])
            });
          } else {
            //UserMapi not exist
            List<Map<String, String?>> myArray = [
              {'id': getUser()?.uid, 'sp': sp, 'name': userName},
            ];
            await documentReference.update({
              'users': myArray,
            });
          }
        });
      }

      return "OK";
    } on FirebaseException catch (e) {
      return e.message!;
    }
  }

  Future<String> leftFromARoom({required String roomId}) async {
    try {
      DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .get();

      Map<String, dynamic>? data = roomSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        dynamic users = data['users'];
        if (users is List) {
          for (var element in users) {
            if (element['id'] == getUser()?.uid) {
              Map<String, String?> myArray = {
                'id': element['id'],
                'name': element['name'],
                'sp': element['sp']
              };
              DocumentReference documentReference =
                  firestoreInstance.collection('rooms').doc(roomId);
              await documentReference.update({
                'users': FieldValue.arrayRemove([myArray])
              });
              return "OK";
            }
          }
        }
      }
      return "NOK"; // moved outside the loop
    } catch (e) {
      return "NOK";
    }
  }

  Future<void> setUserVote({required String sp, required String roomId}) async {
    await leftFromARoom(roomId: roomId);
    await assignUserToARooom(roomId: roomId, sp: sp);
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

  Future<UserDetail> getUserDetail() async {
    DocumentSnapshot documentSnapshot =
        await firestoreInstance.collection("users").doc(getUser()?.uid).get();

    return UserDetail.fromFirestore(documentSnapshot);
  }

  Future<void> changeState(
      {required String state, required String roomId}) async {
    DocumentReference documentReference =
        firestoreInstance.collection('rooms').doc(roomId);
    if (state == "VOTING") {
      //CLEAR ALL DATA..
      DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .get();

      Map<String, dynamic>? data = roomSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        dynamic users = data['users'];
        if (users is List) {
          for (var element in users) {
            element['sp'] = "-1";
          }
        }
        await documentReference.update({'users': users});
      }
    }

    await documentReference.update({'vote_status': state});
  }
}
