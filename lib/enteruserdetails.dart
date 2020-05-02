import 'package:flutter/material.dart';
import './auth.dart';
import './startpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postgres/postgres.dart';

class Details extends StatefulWidget {
  Details({this.connection});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final PostgreSQLConnection connection;
  @override
  DetailsState createState() => DetailsState();
}

class DetailsState extends State<Details> {
  AuthService authService = new AuthService();
  Map<String, dynamic> profile;

  final name = TextEditingController(), contactnum = TextEditingController();

  void writedata() async {
    //Write data to PostGres
    String uid = profile['uid'];
    String prof = profile['profile'];
    String nam = name.text;
    int contact = int.parse(contactnum.text);

    String mail = profile['email'];
    String email;
    
    int index;
    for(int i=0;i<mail.length;i++){
      if(mail[i]=='@')
      {
          index=i;
      }
    }

    email= mail.substring(0,index);
    email = email+' '+mail.substring(index+1,mail.length);
    

    print('From Enter Details');
    print(ConnectionState.active);


    //write uid,prof,contact,mail to user
    await widget.connection.transaction((ctx) async {
      await ctx.query("INSERT INTO \"user\" values('$uid','$contact','$prof','$email')");

    });
      
    //write to uid,name student/teacher tables
    if (prof=="student") {
      await widget.connection.transaction((ctx) async {
      await ctx.query("INSERT INTO \"student\" values('$nam','$uid')");
    });
    } else {
      await widget.connection.transaction((ctx) async {
      await ctx.query("INSERT INTO \"teacher\" values('$nam','$uid')");
    }); 
    }

    updateUserData();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    authService.profile.listen((state) {
      setState(() {
        profile = state;
      });
    });
  }

  void updateUserData() async {
    //Writing data to Firestore
    Firestore _db = Firestore.instance;
    DocumentReference ref = _db.collection('Users').document(Start.uid);
    return ref.setData({
      'name': name.text,
      'contact': contactnum.text,
    }, merge: true);
  }

  void checkvalidity(BuildContext context) {
    //check for empty fields
    if (name.text.length == 0) {
      Scaffold.of(context)
          .showSnackBar(new SnackBar(content: Text("Please enter your name")));
    } else if (contactnum.text.length == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Please enter your contact number")));
    } else {
      writedata();
    }
  }

  // @override
  // void dispose() {
  //   // Clean up the controller when the Widget is disposed
  //   name.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                            child: Text(
                              'Enter Details',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 2.5, 20, 5),
                            child: Text(
                              'Name',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          //TextBox
                          Container(
                            width: 200,
                            child: TextFormField(
                              maxLength: 30,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 7.5),
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(),
                                ),
                                //fillColor: Colors.green
                              ),
                              validator: (val) {},
                              controller: name,
                              keyboardType: TextInputType.text,
                              style: new TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                            child: Text(
                              'Contact Number',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          //TextBox
                          Container(
                            width: 200,
                            child: TextFormField(
                              maxLength: 10,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 7.5),
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(),
                                ),
                                //fillColor: Colors.green
                              ),
                              validator: (val) {},
                              controller: contactnum,
                              keyboardType: TextInputType.phone,
                              style: new TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Builder(
                              builder: (context) => RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  onPressed: () {
                                    checkvalidity(context);
                                  },
                                  child: Text(
                                    'Enter Clapp!',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )))
                        ],
                      ),
                    ),
                  )),
                ),
              ],
            )));
  }
}
