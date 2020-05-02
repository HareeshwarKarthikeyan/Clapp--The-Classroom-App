import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class MembersList extends StatefulWidget {
  MembersList({this.connection,this.classId});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  // final var connection;


  final PostgreSQLConnection connection;
  final String classId;  @override
  _MembersListState createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  String id,sname,scontact,smail;
  List<String> memberids = new List<String>();
  List<String> names = new List<String>();

  void getdata() async {
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

  void getUserdata(BuildContext context,int index) async{
    String suid=memberids[index];
    //Get info about the user
     List<List<dynamic>> results = await widget.connection
        .query(
      "SELECT s.student_name,u.email,u.contact FROM \"student\" s, \"user\" u WHERE u.user_id='$suid' AND s.user_id=u.user_id;",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    print(results);
    setState(() {
      sname = results[0][0];
      scontact = results[0][2].toString();
      // scontact = '12345678';
      smail = results[0][1];
      int ind;
    for(int i=0;i<smail.length;i++){
      if(smail[i]==' ')
      {
          ind=i;
          break;
      }
    }  
    print(ind);
    String temp = smail.substring(0,ind)+'@'+smail.substring(ind+1,smail.length);  
    smail = temp; 
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
                      sname,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () => {}),
                ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(
                      scontact,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () => {}),
                ListTile(
                  leading: Icon(Icons.mail),
                  title: Text(
                    smail,
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
          'Members',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: (names != null)?ListView.builder(
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
                  // Flexible(
                  //   child: CheckboxListTile(
                  //     value: _data[index],
                  //     controlAffinity: ListTileControlAffinity.trailing,
                  //     onChanged: (bool value) {
                  //       onChange(value, index);
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ):null,
    );
  }
}
