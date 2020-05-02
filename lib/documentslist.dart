import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:url_launcher/url_launcher.dart';
import './startpage.dart';

class DocumentsList extends StatefulWidget {
  DocumentsList(
      {this.classId, this.subjectId, this.subjectname, this.connection});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String classId;
  final String subjectId;
  final String subjectname;
  final PostgreSQLConnection connection;

  @override
  _DocumentsListState createState() => _DocumentsListState();
}

class _DocumentsListState extends State<DocumentsList> {
  List<String> documents = new List<String>();
  List<String> documenttIds = new List<String>();
  List<String> downloadUrls = new List<String>();
  int selectedindex;
  int admin;
  BuildContext snackbarcontext;

  void getdocuments() async {
    String classId = widget.classId;
    String subId = widget.subjectId;
    //get subjects list here
    List<List<dynamic>> results = await widget.connection
        .query(
      "select document_id,download_title,download_url  from \"document\" where class_id='$classId' and subject_id ='$subId'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });

    //find if the user is an admin or not
    String userid = Start.uid;
    List<List<dynamic>> adminresults = await widget.connection
        .query(
      "SELECT admin FROM \"member\" WHERE class_id='$classId' AND user_id='$userid'",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });
    admin = 0;
    setState(() {
      if (adminresults[0][0] == 1 || adminresults[0][0] == 2) admin = 1;
    });

    setState(() {
      for (int i = 0; i < results.length; i++) {
        documenttIds.add(results[i][0]);
        documents.add(results[i][1]);
        downloadUrls.add(results[i][2]);
      }
    });
  }

  void launchURL(int index) async {
    String url = downloadUrls[index];
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    getdocuments();
  }

  void deletedocuments(context) async {
    print("Delete Document Called");
    print(documenttIds[selectedindex]);

    String cid = widget.classId;
    String docid = documenttIds[selectedindex];
    String subjectid = widget.subjectId;
    await widget.connection.transaction((ctx) async {
      await ctx.query(
          "delete from \"document\" where class_id='$cid' and document_id='$docid' and subject_id='$subjectid'");
    });
    Scaffold.of(context)
        .showSnackBar(new SnackBar(content: Text("Document Deleted")));
    setState(() {
      documenttIds.removeAt(selectedindex);
      documents.removeAt(selectedindex);
    });
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.only(left: 10),
                  title: Text(
                    "Are you sure you want to delete the document '" +
                        documents[selectedindex] +
                        "\' ?",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ),
                ListTile(
                    contentPadding: EdgeInsets.only(left: 10),
                    title: Text(
                      " DELETE ",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      deletedocuments(context);
                    }),
                ListTile(
                    contentPadding: EdgeInsets.only(left: 10),
                    title: Text(
                      " CANCEL ",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.green,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    }),
              ],
            ),
          );
        });
  }

  void showsnackbar(context) {
    final snackBar =
        SnackBar(content: Text('Admin can long press to delete files !'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.subjectname,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
              onTap: () {
                showsnackbar(context);
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: Image.asset('assets/info.png',
                    width: 27, height: 27, alignment: Alignment.center),
              ))
        ],
      ),
      body: (documents.length != 0)
          ? ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            launchURL(index);
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Ink.image(
                              image: AssetImage('assets/document.png'),
                              height: 30,
                              width: 30,
                              fit: BoxFit.cover,
                              child: InkWell(
                                onTap: () {
                                  launchURL(index);
                                },
                                onLongPress: () {
                                  if (admin == 1) {
                                    selectedindex = index;
                                    _settingModalBottomSheet(context);
                                  } else
                                    Scaffold.of(snackbarcontext).showSnackBar(
                                        new SnackBar(
                                            content: Text(
                                                "Only Admins can delete Documents !")));
                                },
                                child: null,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            launchURL(index);
                          },
                          onLongPress: () {
                            selectedindex = index;
                            _settingModalBottomSheet(context);
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                            child: Text(
                              documents[index],
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Container(
              alignment: Alignment.center,
              child: Text(
                'No Documents',
                style: TextStyle(
                  fontSize: 18,
                ),
              )),
    );
  }
}
