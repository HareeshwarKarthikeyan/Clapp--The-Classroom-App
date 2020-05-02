import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';


class RemoveMember extends StatefulWidget {
  RemoveMember({this.connection,this.classId});

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
  _RemoveMemberState createState() => _RemoveMemberState();
}

class _RemoveMemberState extends State<RemoveMember> {
  String profile;
  // state variable
  int _checkvalue = 0;
  List<bool> _data = new List<bool>();

 List<String> memberids = new List<String>();
  List<String> selectedids = new List<String>();

  List<String> names = new List<String>();

  @override
  void initState() {
    //initialising the radio buttons
    for (int i = 0; i < 10; i++) _data.add(false);
    // get list of members from database
    getdata();
  }

  void getdata() async {
    String id = widget.classId;
    List<List<dynamic>> results = await widget.connection
        .query(
      "SELECT s.student_name,s.user_id FROM \"member\" m,\"student\" s WHERE m.class_id='$id' AND m.user_id=s.user_id",
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
    print(selectedids);
    String cid = widget.classId;
    for(int i=0;i<selectedids.length;i++){
      //drop query 
      String id = selectedids[i];
      await widget.connection.transaction((ctx) async {
      await ctx.query("delete from \"member\" where user_id='$id' and class_id='$cid'");
    });
    }
          Navigator.pop(context);

  }

  void onChange(bool value, int index) {
    setState(() {
      _data[index] = value;
      if(value){
        _checkvalue++;
        selectedids.add(memberids[index]);
      }
      else{
        _checkvalue--;
        selectedids.remove(memberids[index]);
      }
      //get selected member's data here
    });
  }

  void checkvalidity(BuildContext context) {
    if (_checkvalue == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Select atleast one member to proceed")));
    } else {
      updateUserData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return 
        Scaffold(
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
                                    padding: EdgeInsets.only(bottom:10.0),
                                    child: Text(
                                      'Select Members To Remove',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 2.5)),
                                  SafeArea(
                                    child: Container(
                                      height: 500,
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: CheckboxListTile(
                                                      title: Text(
                                                        names[index],
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      isThreeLine: false,
                                                      dense: false,
                                                      value: _data[index],
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
                                                      onChanged: (bool value) {
                                                        onChange(value, index);
                                                      },
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
                                  Padding(padding: EdgeInsets.only(top: 12.5)),
                                  Builder(
                                      builder: (context) => RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          onPressed: () {
                                            checkvalidity(context);
                                          },
                                          child: Text(
                                            'Remove !',
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
