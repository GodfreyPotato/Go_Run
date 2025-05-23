import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_run/screen/homeScreen.dart';
import 'package:go_run/screen/loginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController bgController;

  bool run = false;
  bool logo = false;
  bool collide = false;
  bool fade = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      run = !run;
      logo = !logo;
      setState(() {});
    }).then((_) {
      Future.delayed(Duration(seconds: 2), () {
        collide = !collide;

        setState(() {});
      }).then((_) {
        Future.delayed(Duration(seconds: 3), () {
          run = !run;
          fade = !fade;
          setState(() {});
        }).then((_) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        curve: Easing.legacy,
        duration: Duration(seconds: 2),
        decoration: BoxDecoration(
          color: run ? Color(0xFF4554D2) : Colors.white,
        ),
        child: Stack(
          children: [
            Positioned(
              child: AnimatedSlide(
                offset: run ? Offset.zero : Offset(4, 0),
                duration: Duration(seconds: 2),
                child: Image.asset('assets/images/pink.png'),
                curve: Curves.bounceOut,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                offset: run ? Offset.zero : Offset(4, 0),
                duration: Duration(seconds: 2),
                child: Image.asset('assets/images/blue.png', width: 350),
                curve: Curves.bounceOut,
              ),
            ),
            Positioned(
              left: 0,
              top: 200,
              child: AnimatedSlide(
                offset: run ? Offset.zero : Offset(-4, 0),
                duration: Duration(seconds: 2),
                child: Image.asset('assets/images/green.png', width: 250),
                curve: Curves.bounceOut,
              ),
            ),
            Center(
              child: AnimatedScale(
                scale: collide ? 1.3 : 1,
                duration: Duration(seconds: 2),
                curve: Curves.bounceIn,
                child: AnimatedSlide(
                  offset: logo ? Offset.zero : Offset(-4, 0),
                  curve: Curves.elasticOut,
                  duration: Duration(seconds: 2),
                  child: AnimatedScale(
                    duration: Duration(seconds: 1),
                    scale: fade ? 0 : 1,
                    curve: Curves.bounceOut,
                    child: Image.asset(
                      'assets/images/GoRunLogo.png',
                      width: 200,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
