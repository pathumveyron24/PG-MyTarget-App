import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String id = '';

  @override
  Widget build(BuildContext context) {
    var formatter = new DateFormat('yyyy-MM-dd');

    return Container(
        padding: EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('targets').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return ListView(children: <Widget>[
                  ExpansionPanelList(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return new ExpansionPanel(
                          isExpanded: true,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return new Container(
                              padding: EdgeInsets.all(10.0),
                              child: new Text(
                                document["title"],
                                textScaleFactor: 1.8,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          },
                          body: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                          document["complete"].toString() +
                                              " / " +
                                              document["amount"].toString()),
                                    ),
                                    Expanded(
                                      child: Text(document["date"].toString() +
                                          "  (" +
                                          (document["complete"] /
                                                  document["amount"] *
                                                  100)
                                              .toString() +
                                          "%" +
                                          ")"),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        icon: Icon(Icons.attach_money),
                                        onPressed: () {
                                          id = document.documentID;
                                          _openDialog(context);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                LinearProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.redAccent),
                                  value:
                                      document["complete"] / document["amount"],
                                )
                              ],
                            ),
                          ));
                    }).toList(),
                  )
                ]);
            }
          },
        ));
  }

  Future<String> _openDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String amount = '';

        return AlertDialog(
          title: Text('Enter Collection'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration:
                    new InputDecoration(labelText: 'Amount', hintText: '1000'),
                onChanged: (text) {
                  amount = text;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Firestore.instance
                    .collection('collections')
                    .document()
                    .setData({
                  'target_id': id,
                  'amount': int.parse(amount),
                  'note': '',
                  'date': new DateTime.now()
                });

                final DocumentReference targetRef =
                    Firestore.instance.document('targets/' + id);
                Firestore.instance.runTransaction((Transaction tx) async {
                  DocumentSnapshot targeSnapshot = await tx.get(targetRef);
                  if (targeSnapshot.exists) {
                    await tx.update(targetRef, <String, dynamic>{
                      'complete':
                          targeSnapshot.data['complete'] + int.parse(amount)
                    });
                  }
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
