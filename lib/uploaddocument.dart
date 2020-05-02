import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:postgres/postgres.dart';

import 'package:firebase_storage/firebase_storage.dart';

class UploadDocument extends StatefulWidget {
  UploadDocument({this.connection, this.classId});

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
  UploadDocumentState createState() => UploadDocumentState();
}

class UploadDocumentState extends State<UploadDocument> {
  final name = TextEditingController();
  String url;
  String _filePath;
  File filetoupload;
  String selectedSubID;
  List<String> subjects = new List<String>();
  List<DropdownMenuItem<String>> dropDownMenuItems;
  String selected;
  List<String> subjectIds = new List<String>();

  void updateUserData(BuildContext context) async {
    List<List<dynamic>> results = await widget.connection
        .query(
      "select count(document_id) from \"document\"",
    )
        .timeout(Duration(seconds: 60), onTimeout: () {
      //timeout handling
      //executes after transaction fails due to timeout
    });

    //Write data to Postgres
    String title = name.text;
    String documentid = title + results[0][0].toString();
    String classid = widget.classId;

    await widget.connection.transaction((ctx) async {
      await ctx.query(
          "insert into \"document\" values('$classid','$documentid','$selectedSubID','$title','$url')");
    });

    Navigator.pop(context);
    Scaffold.of(context)
        .showSnackBar(new SnackBar(content: Text("Upload Successful")));

    setState(() {
      name.clear();
    });
  }

  void uploadtofirebase(BuildContext context) async {
    //upload file to firebase
    Uri uri = new Uri.file(_filePath);
    File _file = new File.fromUri(uri);
    // String name = uri.hasAbsolutePath.toString().substring(uri.hasAbsolutePath.toString().lastIndexOf("/")+1);
    print(_file.path);
    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(widget.classId)
        .child(selectedSubID)
        .child(name.text);
    final StorageUploadTask task = firebaseStorageRef.putFile(_file);
    final StorageTaskSnapshot downloadUrl = (await task.onComplete);
    url = (await downloadUrl.ref.getDownloadURL());
    print('URL Is $url');
    if (!task.isSuccessful) {
      Navigator.pop(context);
      Scaffold.of(context)
          .showSnackBar(new SnackBar(content: Text("Upload Failed")));
    }

    print('Uploaded to Firebase');
    updateUserData(context);
  }

  void getdocument(BuildContext context) async {
    try {
      String filePath = await FilePicker.getFilePath(type: FileType.ANY);
      if (filePath == '') {
        return null;
      }
      this._filePath = filePath;
      // print(_filePath);
      uploadtofirebase(context);

      //show uploading loading box
      showDialog(
        context: context,
        barrierDismissible: false,
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(
              side: BorderSide.none, borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 5,
                ),
                Text(
                  "   Uploading",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      );

      return null;
    } catch (e) {
      print("Error while picking the file: " + e.toString());
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
    for (int i = 0; i < results.length; i++) {
      subjectIds.add(results[i][0]);
      subjects.add(results[i][1]);
    }
    print(subjectIds);
    print(subjects);
    //build the drop down menu after receiving the subjects
    setState(() {
      dropDownMenuItems = buildAndGetDropDownMenuItems(subjects);
    });
  }

  void checkvalidity(BuildContext context) {
    //check for empty fields
    if (name.text.length == 0) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: Text("Please enter document title ")));
    } else if (selectedSubID == null) {
      Scaffold.of(context)
          .showSnackBar(new SnackBar(content: Text("Please select a subject")));
    } else {
      getdocument(context);
      // Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    name.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //get the subjects from the database
    getsubjects();
  }

  List<DropdownMenuItem<String>> buildAndGetDropDownMenuItems(List subjects) {
    List<DropdownMenuItem<String>> items = new List();
    for (String subject in subjects) {
      items.add(new DropdownMenuItem(value: subject, child: new Text(subject)));
    }
    return items;
  }

  void changedDropDownItem(String selectedsubject) {
    selectedSubID = subjectIds[subjects.indexOf(selectedsubject)];
    print(selectedSubID);
    setState(() {
      this.selected = selectedsubject;
    });
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
                      height: 350.0,
                      width: 300.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                            child: Text(
                              'Upload Document',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 2.5, 20, 5),
                            child: Text(
                              'Select Subject',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          //dropdownbox
                          Container(
                              padding: EdgeInsets.only(top: 5, bottom: 10),
                              child: Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 200,
                                  height: 40,
                                  child: DropdownButton(
                                    value: selected,
                                    items: dropDownMenuItems,
                                    onChanged: changedDropDownItem,
                                  ),
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
                            child: Text(
                              'Enter Document Title',
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
                              maxLength: 30,
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
                                        'Upload!',
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
