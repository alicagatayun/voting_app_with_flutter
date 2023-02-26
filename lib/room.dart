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
  var currentState = "REVEALED";

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

          return WillPopScope(
            onWillPop: () async {
              // Show confirmation dialog and wait for user response
              bool confirm = await getConfirmation();
              if (confirm) {
                await leaveFromRoom();
              }
              // Return true to close the app if the user confirms
              return confirm ?? false;
            },
            child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(children: [
                    Text(docs['name']),
                    const Spacer(),
                    Transform.rotate(
                        angle: 3.14159, // 180 degrees in radians
                        child: IconButton(
                            onPressed: () async {
                              bool confirm = await getConfirmation();
                              if (confirm) {
                                await leaveFromRoom();
                              }
                            },
                            icon: const Icon(Icons.exit_to_app)))
                  ]),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        docs['adminId'] == user?.uid
                                            ? ElevatedButton(
                                                onPressed: () async {
                                                  await changeState();
                                                },
                                                child: Text("Change State"))
                                            : Container(),
                                        Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Text(
                                            docs['vote_status'],
                                            style: TextStyle(fontSize: 17),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      spacing: spacing, //vertical spacing
                                      runSpacing:
                                          runSpacing, //horizontal spacing
                                      alignment: WrapAlignment.spaceEvenly,
                                      children: List<Widget>.generate(
                                          data.length, (index) {
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
                                                        'name'], // Use the fullName property of each item
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
                                                        'name'], // Use the fullName property of each item
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }),
                                    ),
                                    const Spacer(),
                                    if (docs['vote_status'] == 'VOTING')
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setVote("0");
                                                  },
                                                  child: const Text("0")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setVote("1");
                                                  },
                                                  child: const Text("1")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setVote("2");
                                                  },
                                                  child: const Text("2")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setVote("3");
                                                  },
                                                  child: const Text("3"))
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setVote("5");
                                                  },
                                                  child: const Text("5")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setVote("8");
                                                  },
                                                  child: const Text("8")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setVote("13");
                                                  },
                                                  child: const Text("13")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setVote("21");
                                                  },
                                                  child: const Text("21"))
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setVote("34");
                                                    },
                                                    child: const Text("34")),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setVote("55");
                                                    },
                                                    child: const Text("55")),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setVote("89");
                                                    },
                                                    child: const Text("89")),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setVote("144");
                                                    },
                                                    child: const Text("144"))
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Container()
                                  ],
                                )
                              : const Center(
                                  child: Text("There is no one around")),
                        ),
                      ),
                    );
                  },
                )),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<bool> getConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm exit'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> changeState() async {
    setState(() {
      if (currentState == "VOTING") {
        currentState = "REVEALED";
      } else {
        currentState = "VOTING";
      }
    });

    await context
        .read<AuthenticationService>()
        .changeState(roomId: widget.roomId,state:currentState);
  }

  Future<void> setVote(String vote) async {
    await context
        .read<AuthenticationService>()
        .setUserVote(roomId: widget.roomId, sp: vote);
  }

  Future<void> leaveFromRoom() async {
    await context
        .read<AuthenticationService>()
        .leftFromARoom(roomId: widget.roomId)
        .then((value) {
      if (value == "OK") {
        Navigator.pop(context);
      } else {
        const snackBar = SnackBar(
          content: Text('An error occured while leaving from the room'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }
}
