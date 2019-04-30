import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TimezoneNotmatchPage extends StatefulWidget {
  @override
  createState() => new TimezoneNotmatchPageState();
}

class TimezoneNotmatchPageState extends State<TimezoneNotmatchPage> {
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        title: Text('Timezone'),
      ),
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/timezone_page.png'), 
            fit: BoxFit.cover,
          ),
        ),
      )
    );
  }
}