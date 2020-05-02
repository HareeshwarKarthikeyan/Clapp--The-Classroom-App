import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:postgres/postgres.dart';

class EditTimeTable extends StatefulWidget {
  EditTimeTable({
    this.subjects,
    this.subjectIds,
    this.connection,
    this.classId,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final List<String> subjects;
  final List<String> subjectIds;
  final PostgreSQLConnection connection;
  final String classId;
  @override
  EditTimeTableState createState() => EditTimeTableState();
}

class EditTimeTableState extends State<EditTimeTable> {
  var date;
  var datelimit;
  var selectedddate;

  List<DropdownMenuItem<String>> dropDownMenuItems;
  List<String> selected = new List<String>();

  void updateUserData(DateTime selectedDate) async {
    //Writing data to PostGres DB
    String classId = widget.classId;
    int day = selectedDate.weekday;
    int count;
    //check for existing records
    List<List<dynamic>> countresult = await widget.connection
        .query(
      "select count(hour) from \"timetable\" where class_id='$classId' and day='$day'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    count = countresult[0][0];
    //delete existing records
    if (count != 0) {
      List<List<dynamic>> delete = await widget.connection
          .query(
        "delete from \"timetable\" where day='$day' and class_id='$classId'",
      )
          .timeout(Duration(seconds: 60), onTimeout: () {
        //timeout handling
        //executes after transaction fails due to timeout
      });
    }
    //update new timetable
    for (int i = 0; i < 8; i++) {
      String subname = selected[i];
      String subId = widget.subjectIds[widget.subjects.indexOf(subname)];
      int hr = i;
      List<List<dynamic>> results = await widget.connection
          .query(
        "insert  into \"timetable\" values('$classId','$day','$hr','$subId')",
      )
          .timeout(Duration(seconds: 60), onTimeout: () {
        //timeout handling
        //executes after transaction fails due to timeout
      });
    }

    print(selected);
    Navigator.pop(context);
  }

  void gettimetable(DateTime selectedDate) async {
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
          ind = widget.subjectIds.indexOf(results[i][1]);
          selected[results[i][0]] = widget.subjects[ind];
        }
      } else {
        for (int i = 0; i < 8; i++) selected[i] = widget.subjects[0];
      }
      dropDownMenuItems = buildAndGetDropDownMenuItems(widget.subjects);
    });
  }

  @override
  void initState() {
    super.initState();
    //date values
    date = new DateTime.now();
    selectedddate = date;
    datelimit = date.add(Duration(days: 7));
    // selected = widget.subjects;
    print(widget.subjectIds);
    for (int i = 0; i < 8; i++) selected.add(widget.subjects[0]);
    print(selected);
    gettimetable(selectedddate);
  }

  List<DropdownMenuItem<String>> buildAndGetDropDownMenuItems(List subjects) {
    List<DropdownMenuItem<String>> items = new List();
    for (String subject in subjects) {
      items.add(new DropdownMenuItem(value: subject, child: new Text(subject)));
    }
    return items;
  }

  void changedDropDownItem(String selectedsubject, int index) {
    setState(() {
      this.selected[index] = selectedsubject;
    });
  }

  void setdate() async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(date.year, date.month, date.day),
        maxTime: DateTime(datelimit.year, datelimit.month, datelimit.day),
        onChanged: (date) {
      // print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      gettimetable(date);
      setState(() {
        selectedddate = date;
        //download the subjects for that date from the database
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
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
      child: Center(
        child: Container(
          //DIALOG BOX
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.85),
            shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(20.0)),
            child: SafeArea(
              child: Container(
                height: 525.0,
                width: 350.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Edit TimeTable',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 2.5)),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              child: GestureDetector(
                                  onTap: () {
                                    setdate();
                                  },
                                  child: Text(
                                    formatDate(
                                        DateTime(
                                            selectedddate.year,
                                            selectedddate.month,
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
                        ]),
                    SafeArea(
                      child: Container(
                        height: 400,
                        width: 300,
                        child: ListView.builder(
                          itemCount: 8,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                padding: EdgeInsets.all(2.5),
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Period ' + (index + 1).toString(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17),
                                        ),
                                        Container(
                                            child: Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: 200,
                                            height: 40,
                                            child: DropdownButton(
                                              value: selected[index],
                                              items: dropDownMenuItems,
                                              onChanged: (selected) {
                                                changedDropDownItem(
                                                    selected, index);
                                              },
                                            ),
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 12.5)),
                    Builder(
                        builder: (context) => RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            onPressed: () {
                              updateUserData(selectedddate);
                            },
                            child: Text(
                              'Apply Changes !',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
