import 'package:flutter/material.dart';
import 'options.dart';
import './documentslist.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:date_format/date_format.dart';

var date;
var datelimit;
var selectedddate;

class Clapp extends StatefulWidget {
  Clapp({this.connection, this.classId, this.className});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String classId;
  final String className;
  final PostgreSQLConnection connection;

  @override
  _ClappState createState() => _ClappState();
}

class _ClappState extends State<Clapp> {
  @override
  void initState() {
    super.initState();
    date = new DateTime.now();
    selectedddate = date;
    datelimit = date.add(Duration(days: 7));
    print(datelimit.year);
    print(datelimit.month);
    print(datelimit.day);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                widget.className,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              leading: BackButton(
                color: Colors.white,
              ),
              actions: <Widget>[
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Options(
                                  connection: widget.connection,
                                  classId: widget.classId,
                                  className: widget.className,
                                )),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Image.asset('assets/menu .png',
                          width: 27, height: 27, alignment: Alignment.center),
                    ))
              ],
              centerTitle: true,
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(
                      child: Text(
                    'Time Table',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )),
                  Tab(
                      child: Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )),
                ],
              ),
            ),
            body: TabBarView(
              children: <StatefulWidget>[
                Timetable(
                  classId: widget.classId,
                  connection: widget.connection,
                ),
                Documents(
                  classId: widget.classId,
                  connection: widget.connection,
                ),
              ],
            )));
  }
}

class Timetable extends StatefulWidget {
  Timetable({this.classId, this.connection});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String classId;
  final PostgreSQLConnection connection;

  @override
  TimetableState createState() => TimetableState();
}

class Documents extends StatefulWidget {
  Documents({this.classId, this.connection});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String classId;
  final PostgreSQLConnection connection;

  @override
  DocumentsState createState() => DocumentsState();
}

class TimetableState extends State<Timetable> {
  List<String> selected = new List<String>();
  List<String> AdditionalNotes;
  List<String> Locations;
  List<String> subjects = new List<String>();
  List<String> subjectIds = new List<String>();

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
    downloadTimeTable(selectedddate);
  }

  void setdate() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(date.year, date.month, date.day),
        maxTime: DateTime(datelimit.year, datelimit.month, datelimit.day),
        onChanged: (date) {
      // print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      downloadTimeTable(date);
      setState(() {
        selectedddate = date;
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  void downloadTimeTable(DateTime selectedDate) async {
    //Download Time Table For The Given day from PostGres
    String classId = widget.classId;
    int day = selectedDate.weekday;
    //download timetable for the given date - subject id and hour name
    List<List<dynamic>> results = await widget.connection
        .query(
      "select hour,subject_id from \"timetable\" where class_id='$classId' and day='$day'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });

    //assign the subjectnames
    setState(() {
      if (results.length != 0) {
        print('results fetched');
        //assign the subjects
        int i;
        int ind;
        for (i = 0; i < results.length; i++) {
          ind = subjectIds.indexOf(results[i][1]);
          selected[results[i][0]] = subjects[ind];
        }
      } else {
        for (int i = 0; i < 8; i++) selected[i] = subjects[0];
      }
    });
    //refresh the screen with the new TimeTable
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 8; i++) selected.add('Free/TBD');
    getsubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(padding: EdgeInsets.only(top: 10)),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Container(
            child: GestureDetector(
                onTap: () {
                  setdate();
                },
                child: Text(
                  formatDate(
                      DateTime(selectedddate.year, selectedddate.month,
                          selectedddate.day),
                      [d, ' ', M, ' ', yyyy]),
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold),
                ))),
        GestureDetector(
          onTap: () {
            setdate();
          },
          child: Container(
            padding: EdgeInsets.only(left: 2.5),
            child: Icon(Icons.arrow_drop_down),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15),
        ),
        GestureDetector(
          onTap: () {
            downloadTimeTable(selectedddate);
          },
          child: Icon(Icons.refresh),
        ),
      ]),
      Padding(
        padding: EdgeInsets.only(top: 5),
      ),
      Flexible(
          child: ListView.builder(
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding:
                  EdgeInsets.only(top: 2.5, bottom: 2.5, left: 5, right: 5),
              child: SafeArea(
                  child: Material(
                      shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0)),
                      color: Color(0xFF6100FF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 5, left: 7.5),
                            child: Text(
                              'Period ' + (index + 1).toString(),
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 2.5, left: 7.5),
                            child: Text(
                              selected[index],
                              style: TextStyle(
                                  fontSize: 18.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Container(
                          //   padding: EdgeInsets.only(top: 2.5, left: 7.5),
                          //   child: Text(
                          //     'Location ' + (index + 1).toString(),
                          //     style: TextStyle(
                          //         fontSize: 18,
                          //         color: Colors.white,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          // Container(
                          //   padding:
                          //       EdgeInsets.only(top: 5, bottom: 5, left: 7.5),
                          //   child: Text(
                          //     'Extra Note for the class ' +
                          //         (index + 1).toString(),
                          //     style:
                          //         TextStyle(fontSize: 18, color: Colors.white),
                          //   ),
                          // ),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                        ],
                      ))));
        },
      ))
    ]);
  }
}

class DocumentsState extends State<Documents> {
  List<String> subjects = new List<String>();
  List<String> subjectIds = new List<String>();

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
    setState(() {
      for (int i = 0; i < results.length; i++) {
        subjectIds.add(results[i][0]);
        subjects.add(results[i][1]);
      }
    });
    print(subjectIds);
    print(subjects);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getsubjects();
  }

  @override
  Widget build(BuildContext context) {
    return (subjects.length!=0)
        ? ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DocumentsList(
                                classId: widget.classId,
                                subjectId: subjectIds[index],
                                subjectname: subjects[index],
                                connection: widget.connection,
                              )),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Ink.image(
                            image: AssetImage('assets/folder.png'),
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DocumentsList(
                                            classId: widget.classId,
                                            subjectId: subjectIds[index],
                                            subjectname: subjectIds[index],
                                            connection: widget.connection,
                                          )),
                                );
                              },
                              child: null,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                          child: Text(
                            subjects[index],
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        : Container(
      alignment: Alignment.center,
      child :Text(
      'No Subjects',
      style: TextStyle(
        fontSize: 18,
      ),
    ));

    // return Container(
    //   alignment: Alignment.center,
    //   child :Text(
    //   'List of Materials here',
    //   style: TextStyle(
    //     fontSize: 18,
    //   ),
    // ));
  }
}
