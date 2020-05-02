import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import './auth.dart';
import 'dart:async';
import './home.dart';

checkIfAuthenticated() async {
  await Future.delayed(Duration(
      seconds: 5)); // could be a long running task, like a fetch from keychain
  return true;
}

FirebaseAuth auth;
FirebaseUser user;


class Start extends StatefulWidget {
  Start({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;
  static String uid;

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  static AuthService authService = AuthService();
  Map<String, dynamic> profile;
  bool logging = false;
  bool isbuttondisabled = false;

  void toggleLogginState() {
    setState(() {
      isbuttondisabled = !logging;
      logging = !logging;
    });
  }

  void navigate() {
    checkIfAuthenticated().then((success) {
      if (!success) {
        Navigator.pop(context); //pop loggin in dialog
        Scaffold.of(context)
            .showSnackBar(new SnackBar(content: Text("Login Failed.")));
      } 
    });
  }

  @override
  void initState() {
    super.initState();
    authService.profile.listen((state) => setState(() => profile = state));
    auth = FirebaseAuth.instance;
    auth.onAuthStateChanged.firstWhere((user) => user != null).then((user) {
      Start.uid = user.uid;
      //pop loggin in dialog
      Navigator.pop(context); 
      //navigation for an already signed in user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
     });
  }

  @override
  Widget build(BuildContext context) {
    // author not signed in
    return MaterialApp(
        home: Scaffold(
            body: Container(
                child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/classroom.jpg',
                        ),
                        fit: BoxFit.cover,
                        colorFilter: new ColorFilter.mode(
                            Colors.black.withOpacity(0.975), BlendMode.dstATop),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          child: Container(
                            padding: EdgeInsetsDirectional.only(top: 110),
                            child: Text(
                              'CLAPP',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        Align(
                          child: Container(
                            child: Text(
                              'Collaborate.The Right Way.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: Dialog(
                                backgroundColor: Colors.white.withOpacity(0.85),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide.none,
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        strokeWidth: 5,
                                      ),
                                      Text(
                                        "   Logging You In",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );

                            // toggleLogginState();
                            Future.delayed(Duration(seconds: 2), () {
                              authService.googleSignIn();
                              navigate();
                            });
                            // .timeout(new Duration(seconds: 3),
                            //     onTimeout: () {
                            //   Scaffold.of(context).showSnackBar(new SnackBar(
                            //       content: Text("Login Failed.")));
                            // });
                          },
                          child: Container(
                            padding: EdgeInsetsDirectional.only(top: 10),
                            child: Image.asset(
                              'assets/googlesignin.png',
                              width: 275,
                              height: 75,
                            ),
                          ),
                        ),
                      ],
                    )))));
  }
}
