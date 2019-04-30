import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EmptyPage extends StatefulWidget {
  @override
  createState() => new EmptyPageState();
}

class EmptyPageState extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      body: Container(
        margin: EdgeInsets.all(20.0),
        child: new Column(
          children: <Widget>[
            new Center(
              child: new Text("Empty Page"),
            )
          ]
        )
      )
    );
  }
}