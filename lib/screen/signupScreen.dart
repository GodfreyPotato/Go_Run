import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_run/screen/loginScreen.dart';
import 'package:quickalert/quickalert.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var userCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var passCtrl = TextEditingController();

  bool hidePass = true;

  var formKey = GlobalKey<FormState>();

  var firstnameCtrl = TextEditingController();

  var lastnameCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Container(
            child: Image.asset(
              'assets/images/GoRunLogo.png',
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
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
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Color(0xFF86B6FF),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Text(
                            "Go run outside human!",
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
                              return "*Username is required!";
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.white),
                          controller: userCtrl,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE8B601)),
                            ),
                            border: OutlineInputBorder(),
                            label: Text(
                              "Username",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "*Firstname is required!";
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.white),
                          controller: firstnameCtrl,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE8B601)),
                            ),
                            border: OutlineInputBorder(),
                            label: Text(
                              "Firstname",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "*Lastname is required!";
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.white),
                          controller: lastnameCtrl,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE8B601)),
                            ),
                            border: OutlineInputBorder(),
                            label: Text(
                              "Lastname",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
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
                                  .createUserWithEmailAndPassword(
                                    email: emailCtrl.text,
                                    password: passCtrl.text,
                                  );

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(usercreds.user!.uid)
                                  .set({
                                    'username': userCtrl.text,
                                    'firstname': firstnameCtrl.text,
                                    'lastname': lastnameCtrl.text,
                                    'email': emailCtrl.text,
                                    'longestRun': 0,
                                    'fastestRun': 0,
                                  });

                              Navigator.of(context).pop();
                              await QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                barrierDismissible: false,
                                title: "Account Created!",
                                text: "You can now login your account!",
                              );
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
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
                            "Register",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),

                        Row(
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Login",
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
