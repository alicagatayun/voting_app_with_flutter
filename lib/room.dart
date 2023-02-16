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
  var user;

  @override
  void initState() {
    setState(() {
      // 2
      user = context.read<AuthenticationService>().getUser();
    });
    var abc = 2;
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
          var data;
          if (docs.data().toString().contains('users')) data = docs['users'];
          const double runSpacing = 4;
          const double spacing = 4;
          const columns = 4;
          final w =
              (MediaQuery.of(context).size.width - runSpacing * (columns - 1)) /
                  columns;

          return Scaffold(
              appBar: AppBar(
                title: Text(docs['name']),
              ),
              body: LayoutBuilder(
                builder: (context, constraint) {
                  return SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                        child: data != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(docs['vote_status']),
                                  ),
                                  Wrap(
                                    spacing: spacing, //vertical spacing
                                    runSpacing: runSpacing, //horizontal spacing
                                    alignment: WrapAlignment.spaceEvenly,
                                    children: List<Widget>.generate(data.length,
                                        (index) {
                                      final userData = data[index];
                                      if (docs['vote_status'] != 'VOTING') {
                                        return SizedBox(
                                          width: w,
                                          height: w,
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                  backgroundColor:
                                                      Colors.indigo,
                                                  child: Text(
                                                    data[index]['sp'] == '-1'
                                                        ? '?'
                                                        : data[index]['sp'],
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  )),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  data[index][
                                                      'id'], // Use the fullName property of each item
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return SizedBox(
                                          width: w,
                                          height: w,
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child: Image.asset(data[index]
                                                            ['sp'] ==
                                                        '-1'
                                                    ? 'assets/images/thinking.png'
                                                    : 'assets/images/ready.png'),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  data[index][
                                                      'id'], // Use the fullName property of each item
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }),
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {},
                                              child: Text("0")),
                                          ElevatedButton(
                                              onPressed: () {},
                                              child: Text("1")),
                                          ElevatedButton(
                                              onPressed: () {},
                                              child: Text("2")),
                                          ElevatedButton(
                                              onPressed: () {},
                                              child: Text("3"))
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {},
                                              child: Text("5")),
                                          ElevatedButton(
                                              onPressed: () {},
                                              child: Text("8")),
                                          ElevatedButton(
                                              onPressed: () {},
                                              child: Text("13")),
                                          ElevatedButton(
                                              onPressed: () {},
                                              child: Text("21"))
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {},
                                                child: Text("34")),
                                            ElevatedButton(
                                                onPressed: () {},
                                                child: Text("55")),
                                            ElevatedButton(
                                                onPressed: () {},
                                                child: Text("89")),
                                            ElevatedButton(
                                                onPressed: () {},
                                                child: Text("144"))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text("There is no one around")),
                      ),
                    ),
                  );
                },
              ));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
