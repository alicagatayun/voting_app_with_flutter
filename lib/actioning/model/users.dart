import 'dart:core';

class User {
  String? userId;
  String? sp;

  User({this.userId, this.sp});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    sp = json['sp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['sp'] = sp;

    return data;
  }
}
