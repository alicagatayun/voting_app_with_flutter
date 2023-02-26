import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailWithId {
  final String? username;
  final String? id;

  UserDetailWithId({required this.username, required this.id});

  factory UserDetailWithId.fromFirestore(Map<String,dynamic> json) {

    return UserDetailWithId(
      id: json['id'],
      username: json['name']
    );
  }
}
