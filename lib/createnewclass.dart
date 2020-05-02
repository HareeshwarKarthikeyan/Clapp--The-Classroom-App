import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'startpage.dart';

class CreateClass extends StatefulWidget {
  CreateClass({this.connection});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final PostgreSQLConnection connection;
  @override
  CreateClassState createState() => CreateClassState();
}

class CreateClassState extends State<CreateClass> {
  final name = TextEditingController(), password = TextEditingController();
  String pass,nam,uid;


  void writetodb() async {
    //generating classid
    //get the count of the number of classes in the db with the class title as the given name
    //append it to the string classname to get the id
    List<List<dynamic>> results = await widget.connection
        .query(
      "select count(class_id) from class",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    String classID = name.text + results[0][0].toString();
    // print(classID);
    // write the new class details to the class table
    await widget.connection.transaction((ctx) async {
      await ctx.query("INSERT INTO \"class\" values('$classID','$pass','$nam')");
    });
    //write this user's details to the members table
    List<List<dynamic>> profresults = await widget.connection
        .query(
      "select profile from \"user\" where user_id='$uid'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    print('The user profile is : ');
    print(profresults[0][0]);

    int isadmin = 1;
    if(profresults[0][0]=="teacher")
      isadmin = 2;
    //write the values to member table
     await widget.connection.transaction((ctx) async {
      await ctx.query("INSERT INTO \"member\" values('$classID','$uid','$isadmin')");
    });
    Navigator.pop(context);

  }

  void checkvalidity(BuildContext context) {
    if (name.text.length == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Please specify a Class ID")));
    } else if (password.text.length == 0) {
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: Text("Please specify a Password for the Class")));
    } else {
      nam = name.text;
      pass = password.text;
      writetodb();
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
                              'Create a New Class',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 2.5, 20, 5),
                            child: Text(
                              'Class ID',
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
                              obscureText:
                                  false, //password is kept visible here for creation of class
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
                                    ' Proceed ',
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
