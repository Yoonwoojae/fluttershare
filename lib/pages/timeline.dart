import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];

  @override
  void initState() {
    getUsers();
    //createUser();
    updateUser();
    //deleteUser();
    super.initState();
  }

  createUser() async {
    await usersRef.add({
      "username": "Jeff",
      "postsCount": 0,
      "isAdmin": false,
    });
  }

  updateUser() async {
    /*await usersRef
        .document("-M8P8Wz8UWAkodczonxV")
        .updateData({"postsCount": 1});*/

    final doc = await usersRef.document("-M8P8Wz8UWAkodczonxV").get();

    if (doc.exists) {
      doc.reference.updateData({"postsCount": 1});
    }
  }

  deleteUser() async {
    final doc = await usersRef.document("-M8P8Wz8UWAkodczonxV").get();

    if (doc.exists) {
      doc.reference.delete();
    }
  }

  getUsers() async {
    final QuerySnapshot snapshot = await usersRef.getDocuments();

    setState(() {
      users = snapshot.documents;
    });
    /*snapshot.documents.forEach((DocumentSnapshot doc) {


    });*/
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: usersRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }

            final List<Text> children = snapshot.data.documents
                .map((doc) => Text(doc['username']))
                .toList();

            return Container(
              child: ListView(
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }
}
