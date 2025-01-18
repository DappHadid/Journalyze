import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class AppSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      childWidget: SizedBox(
        height: 500,
        width: 500,
        child: Image.asset("assets/img/logo.png", fit: BoxFit.cover),
      ),
      onAnimationEnd: () {
        Navigator.pushReplacementNamed(context, 'welcome_screen');
      },
    );
  }
}
