import 'package:flutter/material.dart';
import './selectadmin.dart';
import './removemember.dart';
import 'package:share/share.dart';
import './dropoutasadmin.dart';
import './changepassword.dart';
import './memberslist.dart';
import './facultylist.dart';
import './addsubject.dart';
import './uploaddocument.dart';
import 'package:postgres/postgres.dart';
import './edittimetable.dart';
import './startpage.dart';

class Options extends StatefulWidget {
  Options({this.connection, this.classId, this.className});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final PostgreSQLConnection connection;
  final String classId;
  final String className;

  @override
  _OptionsState createState() => _OptionsState();
}

class Constants {
  static const String option1 = 'Remove Member';
  static const String option2 = 'Add Admin';
  static const String option3 = 'Drop Out As Admin';
  static const String option4 = 'Change Password';
  static const String option5 = 'Edit Timetable';
  static const List<String> choices = <String>[
    option1,
    option2,
    option3,
    option4,
    option5
  ];
}

class _OptionsState extends State<Options> {
  BuildContext snackbarcontext;
  String copiedmessage;
  String password, id, admin1, admin2, cname;
  List<String> subjects = new List<String>();
  List<String> subjectIds = new List<String>();
  int admin;
  int admincount;
  int faculty;

  void menuchoiceoption(String choice) {
    if (choice == Constants.option1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RemoveMember(
                  connection: widget.connection,
                  classId: widget.classId,
                )),
      );
    } else if (choice == Constants.option2) {
      if(admincount==2)
      Scaffold.of(snackbarcontext).showSnackBar(
            new SnackBar(content: Text("Two Admins Already Exist!")));
      else{
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectAdmin(
                  connection: widget.connection,
                  classId: widget.classId,
                )),
      ).then((value) {
        setState(() {
          getdata();
        });
      });
      }
    } else if (choice == Constants.option3) {
      if(faculty==1)
      Scaffold.of(snackbarcontext).showSnackBar(
            new SnackBar(content: Text("Faculty Can't Drop Out As Admin!")));
      else{
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DropOutAsAdmin(
                  connection: widget.connection,
                  classId: widget.classId,
                )),
      ).then((value) {
        setState(() {
          getdata();
        });
      });
      }
    } else if (choice == Constants.option4) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChangePassword(
                  connection: widget.connection,
                  classId: widget.classId,
                )),
      ).then((value) {
        getdata();
      });
    } else if (choice == Constants.option5) {
      if (subjects.length == 0) {
        Scaffold.of(snackbarcontext).showSnackBar(
            new SnackBar(content: Text("Please add subjects first")));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditTimeTable(
                    subjects: this.subjects,
                    subjectIds: this.subjectIds,
                    connection: widget.connection,
                    classId: widget.classId,
                  )),
        );
      }
    }
  }

  void getsubjects() async {
    String classId = widget.classId;
    //get subjects list here
    List<List<dynamic>> results = await widget.connection
        .query(
      "select subject_id, subject_name from \"subject\" where class_id='$classId'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    print(results);
    subjects.add('Free/TBD');
    subjectIds.add('Free01');
    for (int i = 0; i < results.length; i++) {
      subjectIds.add(results[i][0]);
      subjects.add(results[i][1]);
    }
    print(subjectIds);
    print(subjects);
  }

  void getdata() async {
    String id = widget.classId;
    //get the class' password
    List<List<dynamic>> pwresults = await widget.connection
        .query(
      "SELECT password FROM \"class\" WHERE class_id='$id'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });

    //get the class' admin data
    List<List<dynamic>> adminresults = await widget.connection
        .query(
      "SELECT s.student_name,s.user_id FROM \"member\" m,\"student\" s WHERE m.class_id='$id' AND m.admin=1 AND m.user_id=s.user_id",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    print(pwresults);
    print(adminresults);
    admincount = adminresults.length;
    faculty = 0;
    print('Is User Admin?');
    print('');
    setState(() {
      password = pwresults[0][0];
      admin1 = adminresults[0][0];
      if (adminresults.length == 2) {
        if (adminresults[0][1] == Start.uid ||
            adminresults[1][1] == Start.uid) {
          admin = 1;
        } else
          admin = 0;
        admin2 = adminresults[1][0];
      } else {
        if (adminresults[0][1] == Start.uid) {
          admin = 1;
        } else
          admin = 0;
        admin2 = 'Admin 2 not selected';
      }
    });
    String cid = widget.classId;
    String userid = Start.uid;
    //get the class' admin data
    List<List<dynamic>> isfaculty = await widget.connection
        .query(
      "select admin from member where user_id='$userid' and class_id='$cid'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    print("Is Faculty ? ");
    print(isfaculty[0][0]);
    if (isfaculty[0][0] == 2){
      print("Yes");
      faculty = 1;
      setState(() {
        admin = 1;
      });
    }
    getsubjects();
  }

  @override
  void initState() {
    super.initState();
    id = widget.classId;
    cname = widget.className;
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
          ),
          title: Text(widget.className),
          centerTitle: true,
          actions: (admin == 1)
              ? <Widget>[
                  PopupMenuButton<String>(
                    icon: Icon(Icons.settings),
                    padding: EdgeInsets.fromLTRB(0, 5, 7, 0),
                    onSelected: menuchoiceoption,
                    itemBuilder: (BuildContext context) {
                      return Constants.choices.map((String choice) {
                        snackbarcontext = context;
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  )
                ]
              : null,
        ),
        body: Column(
          children: [
            Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(0.0),
                  child: Image.asset('assets/wallpaper.jpg'),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 40),
                      alignment: Alignment(0, 0),
                      child: Text(
                        'Class Id\n$id',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment(0, 0),
                      child: Text(
                        'Password\n$password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      alignment: Alignment(0, 0),
                      child: Text(
                        'Admins\n$admin1,\n$admin2',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                //Navigate to add subject
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddSubject(
                            connection: widget.connection,
                            classId: widget.classId,
                          )),
                ).then((value) {
                  setState(() {
                    getsubjects();
                  });
                });
              },
              child: Container(
                  margin: EdgeInsets.only(top: 15, left: 10),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/addfolder.png',
                          width: 35, height: 35),
                      Text(
                        '  Add Subject',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  )),
            ),
            GestureDetector(
              onTap: () {
                //Navigate to upload Materials
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadDocument(
                            connection: widget.connection,
                            classId: widget.classId,
                          )),
                );
              },
              child: Container(
                  margin: EdgeInsets.only(top: 15, left: 10),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/upload.png', width: 35, height: 35),
                      Text(
                        '  Upload Materials',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  )),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MembersList(
                            connection: widget.connection,
                            classId: widget.classId,
                          )),
                );
              },
              child: Container(
                  margin: EdgeInsets.only(top: 20, left: 10),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/members.png', width: 35, height: 35),
                      Text(
                        '  View Members Info',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  )),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FacultyList(
                            connection: widget.connection,
                            classId: widget.classId,
                          )),
                );
              },
              child: Container(
                  margin: EdgeInsets.only(top: 20, left: 10),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/teacher.png', width: 35, height: 35),
                      Text(
                        '  View Faculty Info',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  )),
            ),
            GestureDetector(
              onTap: () {
                //copied message
                copiedmessage =
                    'Hi! Use these credentials to join our class in Clapp!\nClass Name: $cname\nClass Id: $id\nPassword: $password';
                //share
                Share.share(copiedmessage);
                //display snackbar
                // Scaffold.of(context)
                //     .showSnackBar(new SnackBar(content: Text(copiedmessage)));
              },
              child: Container(
                  margin: EdgeInsets.only(top: 20, left: 10),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/addmember.png',
                          width: 35, height: 35),
                      Text(
                        '  Invite to Class',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}
