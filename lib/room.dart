import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spl/auth/UserDetailWithId.dart';

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
  bool isLoading = false;
  String averageValue = "Calculating..";
  int selectedItem = 0;

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
      stream: FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).snapshots(),
      builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');
        if (snapshot.hasData) {
          final docs = snapshot.data!;
          var data;
          if (docs.data().toString().contains('users')) data = docs['users'];
          const double runSpacing = 4;
          const double spacing = 4;
          const columns = 4;
          final w = (MediaQuery.of(context).size.width - runSpacing * (columns - 1)) / columns;

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
                body: isLoading
                    ? const CircularProgressIndicator()
                    : LayoutBuilder(
                        builder: (context, constraint) {
                          return SingleChildScrollView(
                            physics: const ScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraint.maxHeight),
                              child: IntrinsicHeight(
                                child: data != null
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              docs['adminId'] == user?.uid
                                                  ? ElevatedButton(
                                                      onPressed: () async {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        changeState();
                                                      },
                                                      child: const Text("Change State"))
                                                  : Container(),
                                              Padding(
                                                padding: const EdgeInsets.all(24.0),
                                                child: Text(
                                                  docs['vote_status'],
                                                  style: const TextStyle(fontSize: 17),
                                                ),
                                              ),
                                              docs['adminId'] == user?.uid
                                                  ? TextButton(
                                                      onPressed: () async {
                                                        BuildContext parentContext = context;

                                                        await context
                                                            .read<AuthenticationService>()
                                                            .getAllUserInRoom(
                                                              roomId: widget.roomId,
                                                            )
                                                            .then((value) {
                                                          if (value != null) {
                                                            showDialog(
                                                              context: parentContext,
                                                              builder: (parentContext) {
                                                                return AlertDialog(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(40),
                                                                  ),
                                                                  elevation: 16,
                                                                  title: const Text("Choose one of them"),
                                                                  content: StatefulBuilder(
                                                                    builder: (BuildContext context, StateSetter setState) {
                                                                      return SizedBox(
                                                                        width: double.maxFinite,
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Expanded(
                                                                              child: ListView.builder(
                                                                                padding: const EdgeInsets.all(8),
                                                                                itemCount: value.length,
                                                                                itemBuilder: (BuildContext context, int index) {
                                                                                  print('rebuilding item $index with selected item $selectedItem');
                                                                                  return Container(
                                                                                    color: selectedItem == index ? Colors.blue.withOpacity(0.5) : Colors.transparent,
                                                                                    child: ListTile(
                                                                                      title: Text(value[index].username!),
                                                                                      onTap: () {
                                                                                        if (!(selectedItem == index)) {
                                                                                          setState(() {
                                                                                            selectedItem = (index);
                                                                                          });
                                                                                        }
                                                                                        print(selectedItem);
                                                                                      },
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                            ElevatedButton(
                                                                                onPressed: () {
                                                                                  setAdmin(userId: value[selectedItem].id!, roomId: widget.roomId);
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: const Text("Set As Admin"))
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            const snackBar = SnackBar(
                                                              content: Text('You have to specify a valid name to enter a room'),
                                                            );
                                                            ScaffoldMessenger.of(parentContext).showSnackBar(snackBar);
                                                          }
                                                        });
                                                      },
                                                      child: const Text("Set admin"),
                                                    )
                                                  : Container(),
                                              docs['adminId'] == user?.uid
                                                  ? TextButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (dialogContext) {
                                                            GlobalKey<FormState> _globalFormKey = GlobalKey();
                                                            TextEditingController password = TextEditingController();
                                                            bool hasError = false;
                                                            return Form(
                                                              key: _globalFormKey,
                                                              child: AlertDialog(
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                                                elevation: 16,
                                                                title: const Center(
                                                                    child: Text(
                                                                  " Room Password",
                                                                  style: TextStyle(fontSize: 16),
                                                                )),
                                                                content: TextFormField(
                                                                  controller: password,
                                                                  obscureText: true,
                                                                  validator: (value) {
                                                                    if ("" == password.text) {
                                                                      return 'At least one char';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  decoration: InputDecoration(
                                                                    errorText: hasError ? 'Wrong Password' : null,
                                                                    hintText: "Password",
                                                                    focusedBorder: const OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                      borderSide: BorderSide(width: 1, color: Colors.green),
                                                                    ),
                                                                    disabledBorder: const OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                      borderSide: BorderSide(width: 1, color: Colors.orange),
                                                                    ),
                                                                    enabledBorder: const OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                      borderSide: BorderSide(width: 1, color: Colors.green),
                                                                    ),
                                                                    border: const OutlineInputBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                        borderSide: BorderSide(
                                                                          width: 1,
                                                                        )),
                                                                    errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(width: 1, color: Colors.black)),
                                                                    focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(width: 1, color: Colors.red)),
                                                                  ),
                                                                ),
                                                                actions: <Widget>[
                                                                  Center(
                                                                    child: ElevatedButton(
                                                                        onPressed: () async {
                                                                          if (_globalFormKey.currentState!.validate()) {
                                                                            Navigator.pop(dialogContext);
                                                                           await context.read<AuthenticationService>().setPassword(roomId: widget.roomId,
                                                                           pw:password.text).then((value) {
                                                                              if (value == "OK") {
                                                                                const snackBar = SnackBar(
                                                                                  content: Text('Password has been changed successfully.'),
                                                                                );
                                                                              } else if (value == "NOK") {
                                                                                const snackBar = SnackBar(
                                                                                  content: Text('Failed, successfully :)'),
                                                                                );
                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                              }
                                                                            });
                                                                          }
                                                                        },
                                                                        child: const Text("Confirm")),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Text("Set Pw"),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                          Wrap(
                                            spacing: spacing, //vertical spacing
                                            runSpacing: runSpacing, //horizontal spacing
                                            alignment: WrapAlignment.spaceEvenly,
                                            children: List<Widget>.generate(data.length, (index) {
                                              final userData = data[index];
                                              if (docs['vote_status'] != 'VOTING') {
                                                return SizedBox(
                                                  width: w,
                                                  height: w,
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                          backgroundColor: Colors.indigo,
                                                          child: Text(
                                                            data[index]['sp'] == '-1' ? '?' : data[index]['sp'],
                                                            style: const TextStyle(color: Colors.white),
                                                          )),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          docs['adminId'] == user?.uid ? "ADMIN " : data[index]['name'], // Use the fullName property of each item
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
                                                        child: Image.asset(data[index]['sp'] == '-1' ? 'assets/images/thinking.png' : 'assets/images/ready.png'),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          docs['adminId'] == user?.uid ? "ADMIN " : data[index]['name'], //e the fullName property of each item
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
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                  padding: const EdgeInsets.only(bottom: 16.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [const Text("Average : "), Text(docs['average'])],
                                                )
                                              ],
                                            ),
                                          Spacer(),
                                        ],
                                      )
                                    : const Center(child: Text("There is no one around")),
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

  Future<void> setAdmin({required String userId, required String roomId}) async {
    isLoading = true;

    await context.read<AuthenticationService>().setAdmin(roomId: roomId, userId: userId);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> changeState() async {
    isLoading = true;
    setState(() {
      if (currentState == "VOTING") {
        currentState = "REVEALED";
      } else {
        currentState = "VOTING";
      }
    });

    await context.read<AuthenticationService>().changeState(roomId: widget.roomId, state: currentState);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> setVote(String vote) async {
    await context.read<AuthenticationService>().setUserVote(roomId: widget.roomId, sp: vote);
  }

  Future<void> leaveFromRoom() async {
    setState(() {
      isLoading = true;
    });
    await context.read<AuthenticationService>().leftFromARoom(roomId: widget.roomId).then((value) {
      if (value == "OK") {
        Navigator.pop(context);
      } else {
        const snackBar = SnackBar(
          content: Text('An error occured while leaving from the room'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
    setState(() {
      isLoading = false;
    });
  }
}
