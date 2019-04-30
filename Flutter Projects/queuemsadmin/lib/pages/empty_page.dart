import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/pages/more_page.dart';

class EmptyPage extends StatefulWidget {
  @override
  createState() => new EmptyPageState();
}

class EmptyPageState extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        title: Text('Empty Page'),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                  MorePage(company: null)  
              ),
            );
          }
        ),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Center(
              child: Image.asset('assets/empty_page.png'),
            )
          ]
        )
      )
    );
  }
}