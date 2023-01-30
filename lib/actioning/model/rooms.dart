import 'package:spl/actioning/model/users.dart';

class Room {
  String? roomId;
  List<User>? users;
  String? pw;
  String? roomStatus;
  String? adminId;

  Room({this.roomId, this.users, this.pw, this.roomStatus, this.adminId});

  Room.fromJson(Map<String, dynamic> json) {
    roomId = json['roomId'];
    //TODO: Fix here
    users = json['users'];
    pw = json['pw'];
    roomStatus = json['voteStatus'];
    adminId = json['adminId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roomId'] = roomId;
    //TODO: Fix here as well.
    data['users'] = users;
    data['pw'] = pw;
    data['voteStatus'] = roomStatus;
    data['adminId'] = adminId;

    return data;
  }
}
