import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_run/firebase_options.dart';
import 'package:go_run/model/timerModel.dart';
import 'package:go_run/screen/homeScreen.dart';
import 'package:go_run/screen/detailScreen.dart';
import 'package:go_run/screen/loginScreen.dart';
import 'package:go_run/screen/splashScreen.dart';
import 'package:go_run/screen/test.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(GoRunApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class GoRunApp extends StatelessWidget {
  const GoRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Timermodel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
