import 'dart:convert';

import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  Avatar({Key key, this.contactImage, this.color, this.onTap})
      : super(key: key);

  final String contactImage;
  final Color color;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return new Material(
      child: new InkWell(
        onTap: onTap,
        child: new Image.memory(
          base64.decode(contactImage),
          height: 100.0,
          width: 100.0,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
