import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_run/screen/homeScreen.dart';
import 'package:go_run/screen/signupScreen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailCtrl = TextEditingController();
  var passCtrl = TextEditingController();

  bool hidePass = true;
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),

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
              Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 20, right: 20),
                child: Center(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            'assets/images/GoRunLogo.png',
                            width: 200,
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Text(
                            "How's your day?",
                            style: TextStyle(
                              color: Color(0xFF86B6FF),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "*Email Address is required!";
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.white),
                          controller: emailCtrl,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE8B601)),
                            ),
                            border: OutlineInputBorder(),
                            label: Text(
                              "Email",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "*Password is required!";
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.white),
                          controller: passCtrl,
                          obscureText: hidePass,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE8B601)),
                            ),
                            border: OutlineInputBorder(),
                            label: Text(
                              "Password",
                              style: TextStyle(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                hidePass = !hidePass;
                                setState(() {});
                              },
                              icon: Icon(
                                color: Colors.white,

                                hidePass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE8B601),
                          ),
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.loading,
                              barrierDismissible: false,
                            );
                            try {
                              UserCredential usercreds = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                    email: emailCtrl.text,
                                    password: passCtrl.text,
                                  );

                              Navigator.of(context).pop();

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          HomeScreen(uid: usercreds.user!.uid),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              Navigator.of(context).pop();
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                barrierDismissible: false,
                                title: "Something went wrong!",
                                text: "${e.message}",
                              );
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),

                        Row(
                          children: [
                            Text(
                              "Need an account?",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Create one",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
