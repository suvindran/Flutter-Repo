import 'package:flutter/material.dart';

class MyBullet extends StatelessWidget{

  final Color color;

  MyBullet({this.color});

  @override
  Widget build(BuildContext context) {
    return new Container(
    height: 20.0,
    width: 20.0,
    decoration: new BoxDecoration(
    color: color,
    shape: BoxShape.circle,
  ),
  );
  }
}