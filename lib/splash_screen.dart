import 'dart:async';

import 'package:flutter/material.dart';

const String LoggedInKey = 'LoggedIn';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final size = query.size;
    final itemWidth = size.width * 0.4;
    final itemHeight = itemWidth * (size.width / size.height);
    return const Scaffold(
        body: Center(child: Text("Super Splash Screen")));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacementNamed(
        context,
        '/auth',
      );
    });
  }
}
