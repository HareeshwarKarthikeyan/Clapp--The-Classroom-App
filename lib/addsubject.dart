import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class AddSubject extends StatefulWidget {
  AddSubject({this.connection, this.classId});

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
  AddSubjectState createState() => AddSubjectState();
}

class AddSubjectState extends State<AddSubject> {
  final name = TextEditingController();

  void updateUserData() async {
    //get count
    List<List<dynamic>> results = await widget.connection
        .query(
      "select count(subject_id) from \"subject\"",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    //Write data to Postgres
    String subjectID = name.text + results[0][0].toString();
    String subjectName = name.text;
    String className = widget.classId;
    await widget.connection.transaction((ctx) async {
      await ctx.query(
          "insert into \"subject\" values('$subjectID','$subjectName','$className')");
    });
    Navigator.pop(context);
  }

  void checkvalidity(BuildContext context) {
    //check for empty fields
    if (name.text.length == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Please enter Subject Name ")));
    } else {
      updateUserData();
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    name.dispose();
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
                      height: 225.0,
                      width: 300.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                            child: Text(
                              'New Subject',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 2.5, 20, 5),
                            child: Text(
                              'Subject Name',
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
                          Container(
                              padding: EdgeInsets.only(top: 5, bottom: 10),
                              child: Builder(
                                  builder: (context) => RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      onPressed: () {
                                        checkvalidity(context);
                                      },
                                      child: Text(
                                        'Add Subject!',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ))))
                        ],
                      ),
                    ),
                  )),
                ),
              ],
            )));
  }
}
