import 'package:flutter/material.dart';
import 'package:go_run/screen/signupScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignupScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xFF4554D2)),
        child: Stack(
          children: [
            Positioned(child: Image.asset('assets/images/pink.png')),

            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset('assets/images/blue.png', width: 350),
            ),
            Positioned(
              left: 0,
              top: 200,
              child: Image.asset('assets/images/green.png', width: 250),
            ),
            Center(
              child: Image.asset('assets/images/GoRunLogo.png', width: 200),
            ),
          ],
        ),
      ),
    );
  }
}
