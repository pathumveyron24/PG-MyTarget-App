import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TargetCreate extends StatefulWidget {
  @override
  _TargetCreateState createState() => _TargetCreateState();
}

class _TargetCreateState extends State<TargetCreate> {

  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtAmount = TextEditingController();
  TextEditingController txtDate = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: new Card(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              new SizedBox(height: 10.0,),
              new Text("ADD TARGET", textScaleFactor: 2.0,),
              new SizedBox(height: 25.0,),
              new Text("Target Name"),
              new TextFormField(controller: txtTitle,),
              new SizedBox(height: 20.0,),
              new Text("Target Amount"),
              new TextFormField(controller: txtAmount,),
              new SizedBox(height: 20.0,),
              new Text("Target Date"),
              new TextFormField(controller: txtDate,),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(child: new Text("CLEAR"),),
                  RaisedButton(
                    child: new Text("SAVE"), 
                    color: Colors.amberAccent, 
                    onPressed: (){
                      String title = txtTitle.text;
                      String amount = txtAmount.text;
                      String date = txtDate.text;
                      Firestore.instance.collection('targets').document()
                      .setData({ 
                        'title': title, 
                        'amount': int.parse(amount), 
                        'date': date, 
                        'complete':0, 'stop': false, 
                        'created': new DateTime.now() 
                        });

                        txtTitle.text = '';
                        txtAmount.text = '';
                        txtDate.text = '';

                    }, 
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}