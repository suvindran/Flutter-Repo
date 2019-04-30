import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/pages/ways_page.dart';
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

  TokenNumberPage({this.user, this.tokenLetter, this.tokenNumber, this.depName, this.counterName, this.distanceInMeters, this.distanceCreatedDate});

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;
    final String s = tokenLetter+'-'+tokenNumber.toString();
    Moment moment = Moment.fromMillisecondsSinceEpoch(distanceCreatedDate);

    String text = (counterName==null)?'':'${AppLocalizations.of(context).counter} $counterName';
    String distance = (distanceInMeters==0.0)?'':'${AppLocalizations.of(context).distance}: '+ distanceInMeters.toStringAsFixed(2)+' ${AppLocalizations.of(context).meter} ${AppLocalizations.of(context).away}';
    String distanceDate = (distanceCreatedDate==0)?'':'${AppLocalizations.of(context).captured} ${moment.fromNow()} ${AppLocalizations.of(context).ago}';
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
                  Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new WaysPage(),
                  ));
                },
                color: Colors.grey,
                icon: new Icon(Icons.home, color: Colors.white,),
                label: new Text(AppLocalizations.of(context).home, style: TextStyle(color: Colors.white),),
              ),
            ]
          )
        )
      ));
  }
}