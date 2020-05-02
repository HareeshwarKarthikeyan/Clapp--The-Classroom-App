import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import './startpage.dart';


class DropOutAsAdmin extends StatefulWidget {
  DropOutAsAdmin({this.connection,this.classId});

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
  _DropOutAsAdminState createState() => _DropOutAsAdminState();
}

class _DropOutAsAdminState extends State<DropOutAsAdmin> {
  String profile;
  // state variable
  int _radioValue = 0;
  String selected;
  List<String> memberids = new List<String>();
  List<String> names = new List<String>();

  @override
  void initState() {
    super.initState();
    // get list of members from database
        getdata();

  }
  void getdata() async {
    String id = widget.classId;
    List<List<dynamic>> results = await widget.connection
        .query(
      "SELECT s.student_name,s.user_id FROM \"member\" m,\"student\" s WHERE m.class_id='$id' AND m.user_id=s.user_id and m.admin=0",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });  
    print(results);
    setState(() {
       for(int i=0;i<results.length;i++){
      memberids.add(results[i][1]);
      names.add(results[i][0]);
    }
    });
  }

  void updateUserData() async {
    //Writing data to database
    String cid = widget.classId;
    //appointing new admin
    await widget.connection.transaction((ctx) async {
      await ctx.query(
          "update \"member\" set admin=1 where user_id='$selected' and class_id='$cid'");
    });
    //dropping out as admin
    String userid = Start.uid;
    await widget.connection.transaction((ctx) async {
      await ctx.query(
          "update \"member\" set admin=0 where user_id='$userid' and class_id='$cid'");
    });
    Navigator.pop(context);
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
      //handle selected member data here
      selected = memberids[value - 1];

    });
  }

  void checkvalidity(BuildContext context) {
    if (_radioValue == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Select a member to Proceed")));
    } else {
      updateUserData();
      Navigator.pop(context);
    }
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
                      child: SafeArea(
                        child: Container(
                          height: 600.0,
                          width: 350.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Select A New Admin\n   To fill your Place',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SafeArea(
                                child: Container(
                                  height: 450,
                                  width: 300,
                                  child: ListView.builder(
                                    itemCount: names.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Card(
                                        child: Container(
                                          height: 60,
                                          padding: EdgeInsets.all(5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                padding: EdgeInsets.only(left: 10),
                                                child: Text(
                                                  names[index],
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Radio(
                                                  value: index + 1,
                                                  groupValue: _radioValue,
                                                  onChanged:
                                                      _handleRadioValueChange,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .padded,
                                                  activeColor: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              Padding(padding: EdgeInsets.only(top: 15.0)),
                              Builder(
                                  builder: (context) => RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      onPressed: () {
                                        checkvalidity(context);
                                      },
                                      child: Text(
                                        'Appoint Admin and Dropout ! ',
                                        textAlign: TextAlign.center,
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
              ],
            )));
  }
}
