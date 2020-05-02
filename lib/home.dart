import 'package:flutter/material.dart';
import 'package:fab_menu/fab_menu.dart';
import 'classroom.dart';
import 'joinexistingclass.dart';
import './createnewclass.dart';
import './auth.dart';
import './startpage.dart';
import 'selectprofile.dart';
import './enteruserdetails.dart';
import 'package:postgres/postgres.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //postgre connection
  static var connection;
  String userID;
  //class data variables
  String selectedClassId;
  String selectedClassName;
  var classes;

  //For menu
  List<MenuData> menuDataList;
  Map<String, dynamic> profile;
  AuthService authService = new AuthService();

  void join() {
    //navigation logic
    if (profile['profile'] == null)
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Select(
                  connection: connection,
                )),
      );
    else if (profile['name'] == null || profile['contact'] == null)
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Details(
                  connection: connection,
                )),
      );
    else
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Join(
                  connection: connection,
                )),
      ).then((value) {
        setState(() {
          getclasses();
        });
      });
  }

  void create() {
    //navigation logic
    if (profile['profile'] == null)
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Select(
                  connection: connection,
                )),
      );
    else if (profile['name'] == null || profile['contact'] == null)
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Details(
                  connection: connection,
                )),
      );
    else
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateClass(
                  connection: connection,
                )),
      ).then((value) {
        setState(() {
          getclasses();
        });
      });
  }

  void display(context) {
    //navigation logic
    if (profile['profile'] == null)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Select()),
      );
    else if (profile['name'] == null || profile['contact'] == null)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Details()),
      );
    else
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: Text(profile['profile'] +
              '\n' +
              profile['name'] +
              '\n' +
              profile['contact'] +
              '\n' +
              profile['email'])));
  }

  void getclasses() async {
    //get list of classes(ids and their names)for the given user id
    print('getclasses called on return');
    List<List<dynamic>> classresults = await connection
        .query(
      "SELECT \"member\".\"class_id\",\"class\".\"class_name\" FROM \"member\",\"class\" WHERE \"member\".\"user_id\"='$userID' and \"member\".\"class_id\" = \"class\".\"class_id\"",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    //rebuild
    print('classes obtained');
    classes = classresults;
    print(classes);
    setState(() {});
  }

  void connectToDB() async {
    connection = PostgreSQLConnection("localhost", 5432, "harry",
        username: "harry", password: "clapp");
    print('Awaiting for Connection..');
    await connection.open();
    print('This is the connection!!!!');
    print(connection.isClosed);
    print(ConnectionState.active);
    getclasses();
  }

  @override
  void initState() {
    super.initState();
    userID = Start.uid;
    authService.profile.listen((state) => setState(() => profile = state));
    connectToDB();
    menuDataList = [
      MenuData(Icons.group_add, (context, menuData) {
        join();
      }, labelText: 'Join an Existing Class'),
      MenuData(Icons.create_new_folder, (context, menuData) {
        // menuData.enable = !menuData.enable;
        // menuData.icon = menuData.enable? Icons.sync:Icons.sync_disabled;
        // Scaffold.of(context).showSnackBar(new SnackBar(
        //     content: new Text('You have pressed ${menuData.labelText}')));
        create();
      }, labelText: 'Create a new Class'),
      MenuData(Icons.exit_to_app, (context, menuData) {
        authService.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Start()),
        );
      }, labelText: 'Logout'),
      //   MenuData(Icons.create_new_folder, (context, menuData) {
      //     display(context);
      //   }, labelText: 'Display Data'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          new Container(
            child: new Image.asset('assets/wallpaper.jpg'),
          ),
          Scaffold(
            appBar: AppBar(
              title: Center(
                  child: new Text(
                'CLAPP',
                style: TextStyle(
                  fontSize: 20,
                ),
              )),
            ),
            floatingActionButton: FabMenu(
              menus: menuDataList,
              maskColor: Colors.black,
            ),
            floatingActionButtonLocation: fabMenuLocation,
            //condition to check whether list of classes is null
            body: (classes != null)
                ? ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: Ink.image(
                                  image: AssetImage('assets/group.png'),
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.cover,
                                  child: InkWell(
                                    onTap: () {
                                      selectedClassId = classes[index][0];
                                      selectedClassName = classes[index][1];
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Clapp(
                                                  connection: connection,
                                                  classId: selectedClassId,
                                                  className: selectedClassName,
                                                )),
                                      );
                                    },
                                    child: null,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                                  child: Text(
                                    classes[index][1],
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                onTap: () {
                                  selectedClassId = classes[index][0];
                                  selectedClassName = classes[index][1];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Clapp(
                                              connection: connection,
                                              classId: selectedClassId,
                                              className: selectedClassName,
                                            )),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : null,
          )
        ],
      ),
    );
  }
}
