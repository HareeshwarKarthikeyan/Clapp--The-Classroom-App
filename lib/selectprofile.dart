import 'package:flutter/material.dart';
import 'enteruserdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './auth.dart';
import './startpage.dart';
import 'package:postgres/postgres.dart';

class Select extends StatefulWidget {
  Select({this.connection});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final PostgreSQLConnection connection;
  @override
  _SelectState createState() => _SelectState();
}

class _SelectState extends State<Select> {
  String profile;
  // state variable
  int _radioValue = 0;

  void updateUserData() async {
    
    //Writing data to Firestore
    Firestore _db = Firestore.instance;
    DocumentReference ref =
        _db.collection('Users').document(Start.uid);
    return ref.setData({
      'profile': profile,
    }, merge: true);
    
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      switch (value) {
        case 0:
          _radioValue = value;
          break;
        case 1:
          _radioValue = value;
          profile = 'student';
          break;
        case 2:
          _radioValue = value;
          profile = 'teacher';
          break;
      }
    });
  }

  void checkvalidity(BuildContext context) {
    if (_radioValue == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Select a Profile Option to Proceed")));
    } else {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text(Start.uid)));
      updateUserData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Details(
          connection: widget.connection,
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
            body: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/classroom.jpg'),
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
                          //DIALOG BOX
                          child: Dialog(
                        backgroundColor: Colors.white.withOpacity(0.85),
                        shape: RoundedRectangleBorder(
                            side: BorderSide.none,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Container(
                          height: 300.0,
                          width: 300.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'Select Profile Choice',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(78.5, 0, 20, 0),
                                child: Row(
                                  children: <Widget>[
                                    Radio(
                                      value: 1,
                                      groupValue: _radioValue,
                                      onChanged: _handleRadioValueChange,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.padded,
                                      activeColor: Colors.blue,
                                    ),
                                    Text(
                                      'Student',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(78.5, 0, 20, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Radio(
                                      value: 2,
                                      groupValue: _radioValue,
                                      onChanged: _handleRadioValueChange,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.padded,
                                      activeColor: Colors.blue,
                                    ),
                                    Text(
                                      'Teacher',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: 10.0)),
                              Builder(
                                  builder: (context) => RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      onPressed: () {
                                        checkvalidity(context);
                                      },
                                      child: Text(
                                        'Proceed!',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ))),
                            ],
                          ),
                        ),
                      )),
                    ),
                  ],
                )));
  }
}
