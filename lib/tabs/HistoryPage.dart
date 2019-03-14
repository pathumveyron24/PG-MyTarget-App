import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var formatter = new DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      height: MediaQuery.of(context).size.height - 135,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('collections').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return new ListView(
                children:
                    snapshot.data.documents.map((DocumentSnapshot document) {
                  String tid = document["target_id"];
                  return Dismissible(
                    key: Key(document.documentID),
                    onDismissed: (direction) {
                      final DocumentReference targetRef = Firestore.instance
                          .document('targets/' + document["target_id"]);
                      Firestore.instance.runTransaction((Transaction tx) async {
                        DocumentSnapshot targeSnapshot =
                            await tx.get(targetRef);
                        if (targeSnapshot.exists) {
                          await tx.update(targetRef, <String, dynamic>{
                            'complete': targeSnapshot.data['complete'] -
                                document["amount"]
                          });
                        }
                      });
                      Firestore.instance
                          .document("collections" + '/${document.documentID}')
                          .delete();
                      snapshot.data.documents.remove(document);
                    },
                    background: new Container(
                      color: Colors.redAccent,
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[new Text("Delete?")],
                      ),
                    ),
                    child: new ListTile(
                        title: getName(tid),
                        subtitle: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(formatter.format(document['date'])),
                            new Text(document['amount'].toString()),
                          ],
                        )),
                  );
                }).toList(),
              );
          }
        },
      ),
    ));
  }

  Widget getName(String tid) {
    return StreamBuilder(
      stream: Firestore.instance.collection("targets").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('...');
        return new Row(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            if (document.documentID == tid) {
              return new Text(document['title']);
            } else {
              return new Container();
            }
          }).toList(),
        );
      },
    );
  }
}

// print("Target Id=" + tid);
// final DocumentReference targetRef =
//     Firestore.instance.document('targets/' + tid);

// print("DR=" + targetRef.toString());

// String name = "";
// targetRef.get().then((querySnapShot) {
//   name = querySnapShot.data["title"];
//   print("Name=" + name);
// });
