import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetail {
  final String? name;
  final String? surname;

  UserDetail({required this.name, required this.surname});

  factory UserDetail.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) {
      return UserDetail(name: '', surname: '');
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserDetail(
      name: data['name'],
      surname: data['surname'],
    );
  }
}
