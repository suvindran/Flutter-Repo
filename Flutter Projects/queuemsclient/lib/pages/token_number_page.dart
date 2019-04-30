import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:simple_moment/simple_moment.dart';

class TokenNumberPage extends StatelessWidget {

  static const String TAG = "TokenNumberPage";

  final globalKey = new GlobalKey<ScaffoldState>();

  final String tokenLetter;
  final int tokenNumber;
  final String depName;
  final String counterName;
  final double distanceInMeters;
  final int distanceCreatedDate;
  final FirebaseUser user;
  final BuildContext ctx;

  TokenNumberPage({this.user, this.tokenLetter, this.tokenNumber, this.depName, this.counterName, this.distanceInMeters, this.distanceCreatedDate, this.ctx});

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;
    final String s = tokenLetter+'-'+tokenNumber.toString();
    Moment moment = Moment.fromMillisecondsSinceEpoch(distanceCreatedDate);

    String text = (counterName==null)?'':'Counter '+ counterName;
    String distance = (distanceInMeters==0.0)?'':'You are '+ distanceInMeters.toStringAsFixed(2)+' meter away';
    String distanceDate = (distanceCreatedDate==0)?'':'captured '+moment.fromNow()+' ago';
    return Scaffold(
      body: new Container(
        margin: EdgeInsets.all(20.0),
        child: new Center (
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(s, style: textTheme.display3), 
              new Text(depName, style: textTheme.display1),
              new Text(text, style: textTheme.display1),
              const SizedBox(height: 20.0,),
              new Text(distance, style: textTheme.caption),
              new Text(distanceDate, style: textTheme.caption),
              const SizedBox(height: 20.0,),
              new FlatButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/HomePage');
                },
                color: Colors.grey,
                icon: new Icon(Icons.home, color: Colors.white,),
                label: new Text(AppLocalizations.of(ctx).home, style: TextStyle(color: Colors.white)),
              ),
            ]
          )
        )
      ));
  }
}