import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class AppSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.black,
      childWidget: SizedBox(
        height: 200,
        width: 200,
        child: Image.asset("assets/img/logo.png"),
      ),
      onAnimationEnd: () {
        Navigator.pushReplacementNamed(context, 'welcome_screen');
      },
      nextScreen: null,
    );
  }
}
