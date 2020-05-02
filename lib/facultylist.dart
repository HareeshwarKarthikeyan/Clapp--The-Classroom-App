import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class FacultyList extends StatefulWidget {
  FacultyList({this.connection,this.classId});

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
  _FacultyListState createState() => _FacultyListState();
}

class _FacultyListState extends State<FacultyList> {
String id,tname,tcontact,tmail;
  List<String> facultyids = new List<String>();
  List<String> names = new List<String>();

  void getdata() async {
    List<List<dynamic>> results = await widget.connection
        .query(
      "SELECT t.teacher_name,t.user_id FROM \"member\" m,\"teacher\" t WHERE m.class_id='$id' AND m.user_id=t.user_id",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    print(results);
    setState(() {
       for(int i=0;i<results.length;i++){
      facultyids.add(results[i][1]);
      names.add(results[i][0]);
    }
    });
  }

  void getUserdata(BuildContext context,int index) async{
    String tuid=facultyids[index];
    //Get info about the user
     List<List<dynamic>> results = await widget.connection
        .query(
      "SELECT t.teacher_name,u.email,u.contact FROM \"teacher\" t, \"user\" u WHERE u.user_id='$tuid' AND t.user_id=u.user_id;",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    print(results);
    setState(() {
      tname = results[0][0];
      tcontact = results[0][2].toString();
      // tcontact = '12345678';
      tmail = results[0][1];
      int ind;
    for(int i=0;i<tmail.length;i++){
      if(tmail[i]==' ')
      {
          ind=i;
          break;
      }
    }  
    print(ind);
    String temp = tmail.substring(0,ind)+'@'+tmail.substring(ind+1,tmail.length);  
    tmail = temp; 
    });
    _settingModalBottomSheet(context);
  }


  @override
  void initState() {
   super.initState();
    id = widget.classId;
    getdata();
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: Text(
                      tname,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () => {}),
                ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(
                      tcontact,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () => {}),
                ListTile(
                  leading: Icon(Icons.mail),
                  title: Text(
                    tmail,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () => {},
                ),
              ],
            ),
          );
        });
  }

  // void onChange(bool value, int index) {
  //   setState(() {
  //     _data[index] = value;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Faculties',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: (names!=null)?ListView.builder(
        itemCount: names.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Container(
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                    child: Text(
                      names[index],
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.centerRight,
                    child: Ink.image(
                      image: AssetImage('assets/info.png'),
                      height: 20,
                      width: 20,
                      fit: BoxFit.cover,
                      child: InkWell(
                        onTap: () {
                          getUserdata(context,index);
                        },
                        child: null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ):null,
    );
  }
}
