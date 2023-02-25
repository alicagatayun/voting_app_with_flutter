import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:spl/actioning/model/rooms.dart';
import 'package:spl/room.dart';
import 'package:spl/splash_screen.dart';
import 'authService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var appbarHeight = AppBar().preferredSize.height;
    return MultiProvider(
      providers: [
        // 2
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        // 3
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Splash(),
          '/auth': (context) => const AuthenticationWrapper(),
          '/register_screen': (context) => RegistrationScreen(),
          '/login_screen': (context) => LoginScreen(),
          '/room_screen': (context) => RoomPage()
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseuser = context.watch<User?>();
    if (firebaseuser != null) {
      return RoomPage();
    }
    return LoginScreen();
  }
}

Future<bool> checkUserAvailable() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return true;
  }
  return false;
}

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Center(child: Text("Register Screen")),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'e-Mail',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () async {
                  final result = await context
                      .read<AuthenticationService>()
                      .signUp(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      )
                      .then((value) {
                    Navigator.pushReplacementNamed(context, ('/room_screen'));
                  });
                  //showSnackbar(context, result);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
                ),
                child: const Text("Register"),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login_screen');
                },
                child: const Text("I've already an account, let me login"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Center(child: Text("Login Screen")),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'e-Mail',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () async {
                  final result = await context
                      .read<AuthenticationService>()
                      .signIn(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      )
                      .then((value) {
                    if (value) {
                      Navigator.pushReplacementNamed(context, ('/room_screen'));
                    } else {
                      const snackBar = SnackBar(
                        content: Text('Password or username is wrong'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  });
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
                ),
                child: const Text("Login"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register_screen');
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
                ),
                child: const Text("Register"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RoomPage extends StatefulWidget {
  RoomPage({Key? key}) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  var _currentIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const RoomList(),
    const UserDetail()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("Rooms")),

          ),
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              /// Home
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text("Home"),
                selectedColor: Colors.purple,
              ),

              /// Profile
              SalomonBottomBarItem(
                icon: const Icon(Icons.person),
                title: const Text("Profile"),
                selectedColor: Colors.teal,
              ),
            ],
          ),
          body: _widgetOptions.elementAt(_currentIndex)),
    );
  }
}

class RoomList extends StatefulWidget {
  const RoomList({Key? key}) : super(key: key);

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          final double screenWidth = MediaQuery.of(context).size.width;
          final double radius = screenWidth * 0.01;
          return Scaffold(
            body: ListView.separated(
              separatorBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16),
                  child: Divider(),
                );
              },
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final data = docs[i].data();
                return GestureDetector(
                  onTap: () async {
                    await context
                        .read<AuthenticationService>()
                        .getUserDetail()
                        .then((value) {
                      if (value.name != '') {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            GlobalKey<FormState> _globalFormKey = GlobalKey();
                            TextEditingController password =
                                TextEditingController();
                            bool hasError = false;
                            return Form(
                              key: _globalFormKey,
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)),
                                elevation: 16,
                                title: Center(
                                    child: Text(
                                  data['name'] + " Room Password",
                                  style: const TextStyle(fontSize: 16),
                                )),
                                content: TextFormField(
                                  controller: password,
                                  obscureText: true,
                                  validator: (value) {
                                    if (data['pw'] != password.text) {
                                      return 'Wrong Password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    errorText:
                                        hasError ? 'Wrong Password' : null,
                                    hintText: "Password",
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.green),
                                    ),
                                    disabledBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.orange),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.green),
                                    ),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                          width: 1,
                                        )),
                                    errorBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.black)),
                                    focusedErrorBorder:
                                        const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.red)),
                                  ),
                                ),
                                actions: <Widget>[
                                  Center(
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          if (_globalFormKey.currentState!
                                              .validate()) {
                                            Navigator.pop(dialogContext);
                                            await context
                                                .read<AuthenticationService>()
                                                .assignUserToARooom(
                                                    roomId: docs[i].id)
                                                .then((value) {
                                              if (value == "OK") {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RoomManagement(
                                                                docs[i].id)));
                                              } else if (value == "NOK") {
                                                const snackBar = SnackBar(
                                                  content: Text(
                                                      'You are already in a room, first leave from that'),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
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
                      } else {
                        const snackBar = SnackBar(
                          content: Text(
                              'You have to specify a valid name to enter a room'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    });
                    // if (!mounted) return;
                  },
                  child: ListTile(
                    title: Text(data['name']),
                    subtitle: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: radius,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(data['roomStatus']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class UserDetail extends StatefulWidget {
  const UserDetail({Key? key}) : super(key: key);

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    final result =
        context.read<AuthenticationService>().getUserDetail().then((value) {
      setState(() {
        isLoading = false;
      });
      nameController.text = value.name!;
      surnameController.text = value.surname!;
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseuser = context.watch<User?>();

    if (!isLoading) {
      return Column(
        //Center Column contents horizontally,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(child: Text("Your Name")),
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 12),
                      labelText: 'Enter your name correctly',
                      isDense: true,
                      contentPadding: EdgeInsets.all(12.0), // Added this
                    ),
                  ),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(child: Text("Surname")),
                Expanded(
                  child: TextField(
                    controller: surnameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your surname correctly',
                        labelStyle: TextStyle(fontSize: 12),
                        isDense: true,
                        contentPadding: EdgeInsets.all(12.0) // Added this
                        ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(top: 23.0),
            child: Center(child: Text(firebaseuser!.uid.toString())),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(15)),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: Colors.red)))),
                  onPressed: () async {
                    final result = await context
                        .read<AuthenticationService>()
                        .saveUserData(
                          name: nameController.text.trim(),
                          surname: surnameController.text.trim(),
                        )
                        .then((value) {
                      if (value == "OK") {
                        const SnackBar(
                          content: Text('User Data is saved successfully'),
                        );
                      }
                    });
                  },
                  child: Text("Save your user data".toUpperCase(),
                      style: const TextStyle(fontSize: 14))),
            ),
          )
        ],
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
