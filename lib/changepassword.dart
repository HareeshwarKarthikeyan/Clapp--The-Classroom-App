import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';


class ChangePassword extends StatefulWidget {
  ChangePassword({this.connection,this.classId});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  final PostgreSQLConnection connection;
  final String classId;
  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final password = TextEditingController(),
      confirmpassword = TextEditingController();

  void updateUserData() async {
    //Write data to Database
    String pw = password.text;
    String id = widget.classId;
    //update password here
      await widget.connection.transaction((ctx) async {
      await ctx.query("update \"class\" set password='$pw' where class_id='$id'");
    });
    Navigator.pop(context);


  }

  void checkvalidity(BuildContext context) {
    //check for empty fields
    if (password.text.length == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Please enter your new password")));
    } else if (confirmpassword.text.length == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Please confirm your new password")));
    } else if (!(password.text == confirmpassword.text)) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Passwords aren't matching!")));
    } else {
      updateUserData();
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    password.dispose();
    confirmpassword.dispose();
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
                              'New Password',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 2.5, 20, 5),
                            child: Text(
                              'Enter New Password',
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
                              controller: password,
                              keyboardType: TextInputType.text,
                              style: new TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                            child: Text(
                              'Confirm Password',
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
                              controller: confirmpassword,
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
                                    'Change Password !',
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
