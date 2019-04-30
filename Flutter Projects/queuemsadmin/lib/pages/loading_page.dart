import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoadingPage extends StatefulWidget {
  @override
  createState() => new LoadingPageState();
}

class LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {

    return new Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: new Column(
          children: _listEmptyBoxWidgets(),
        ),
      ),
    );
  }

  List<Widget> _listEmptyBoxWidgets() {
    List<Widget> list = new List();
    list.add(_buildEmptyBox());
    list.add(_buildEmptyBox());
    list.add(_buildEmptyBox());
    list.add(_buildEmptyBox());
    list.add(_buildEmptyBox());
    return list;
  }

  Widget _buildEmptyBox(){
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: 100.0,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey[100]
            ),
          ),
          new Container(
            height: 10.0,
            decoration: BoxDecoration(
              color: Colors.white
            ),
          ),
          new Container(
            height: 30.0,
            width: 150.0,
            padding: EdgeInsets.all(50.0),
            decoration: BoxDecoration(
              color: Colors.grey[100]
            ),
          ),
          new Container(
            height: 30.0,
            decoration: BoxDecoration(
              color: Colors.white
            ),
          ),
        ],
      ),
    );
  }
}