import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'startpage.dart';

class Join extends StatefulWidget {
  Join({this.connection});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final PostgreSQLConnection connection;
  @override
  JoinState createState() => JoinState();
}

class JoinState extends State<Join> {
  final name = TextEditingController(), password = TextEditingController();
  String classId, pass;
  String uid;

  void writetodb() async {
    List<List<dynamic>> results = await widget.connection
        .query(
      "select profile from \"user\" where user_id='$uid'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    print('The user profile is : ');
    print(results[0][0]);

    int isadmin = 0;
    if (results[0][0] == "teacher") isadmin = 2;
    //write the values to member table
    await widget.connection.transaction((ctx) async {
      await ctx
          .query("INSERT INTO \"member\" values('$classId','$uid','$isadmin')");
    });
    Navigator.pop(context);
  }

  void checkcredentials(BuildContext context) async {
    //check if the id exists
    List<List<dynamic>> results = await widget.connection
        .query(
      "select class_id,password from \"class\" where class_id='$classId'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    if (results.length == 0) {
      Scaffold.of(context)
          .showSnackBar(new SnackBar(content: Text("Invalid Class Id")));
    }
    //check if password is right
    else if (results[0][1] != pass) {
      Scaffold.of(context)
          .showSnackBar(new SnackBar(content: Text("Invalid Password!")));
    }
    //then write to member table
    else
      writetodb();
  }

  void checkvalidity(BuildContext context) {
    if (name.text.length == 0) {
      Scaffold.of(context)
          .showSnackBar(new SnackBar(content: Text("Please Enter Class ID ")));
    } else if (password.text.length == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Enter Password to join the class")));
    } else {
      classId = name.text;
      pass = password.text;
      checkcredentials(context);
    }
  }

  @override
  void initState() {
    super.initState();
    uid = Start.uid;
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    name.dispose();
    password.dispose();
    super.dispose();
  }

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
                              'Join an Existing Class',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 2.5, 20, 5),
                            child: Text(
                              'Class Id',
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
                              maxLength: 20,
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
                              'Password',
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
                              obscureText: true, //asterixes for password
                              maxLength: 15,
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
                              controller: password,
                              keyboardType: TextInputType.text,
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
                                    'Join Class!',
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
