import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authService.dart';

class RoomManagement extends StatefulWidget {
  const RoomManagement(this.roomId, {Key? key}) : super(key: key);
  final String roomId;

  @override
  State<RoomManagement> createState() => _RoomManagementState();
}

class _RoomManagementState extends State<RoomManagement> {
  User? user;

  @override
  void initState() {
    setState(() {
      // 2
      user = context.read<AuthenticationService>().getUser();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .snapshots(),
      builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');
        if (snapshot.hasData) {
          final docs = snapshot.data!;
          final data = docs['users'];
          return Scaffold(
            appBar: AppBar(
              title: Text(docs['name']),
            ),
            body: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(docs['vote_status']),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      primary: false,
                      children: List<Widget>.generate(data.length, (index) {
                        final userData = data[index];
                        return Column(
                          children: [
                            CircleAvatar(
                              child: Text("AA"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                docs['vote_status'] == "VOTING"
                                    ? ("Voting")
                                    : data[index][
                                        'sp'], // Use the fullName property of each item
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
