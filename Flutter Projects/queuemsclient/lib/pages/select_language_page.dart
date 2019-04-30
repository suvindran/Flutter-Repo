import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLanguagePage extends StatefulWidget {

  final FirebaseUser user;
  final BuildContext ctx;
  SelectLanguagePage({this.user, this.ctx});

  @override
  createState() => new SelectLanguagePageState(user: user);
}

class SelectLanguagePageState extends State<SelectLanguagePage> {

  static const String TAG = "SelectLanguagePage";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseUser user;

  SelectLanguagePageState({this.user});


  @override
  void initState() {
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(AppLocalizations.of(widget.ctx).selectLanguage),
        ),
        body: new Container(
            margin: EdgeInsets.all(20.0),
            child: new SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  new Container(
                  height: 10.0,
                ),
                new Divider(
                  height: 20.0,
                ),
                 new ListTile(
                  leading: new Icon(Icons.language),
                  title: new Text('English', style: textTheme.title),
                  onTap: () {
                    _language('en');
                    Navigator.pop(context);
                  },
                ),
                new Divider(
                  height: 20.0,
                ),
                 new ListTile(
                  leading: new Icon(Icons.language),
                  title: new Text('中文', style: textTheme.title),
                  onTap: () {
                    _language('zh');
                    Navigator.pop(context);
                  },
                ),
                new Divider(
                  height: 20.0,
                ),
                ],
              ),
            )
            
          )
      );
  }

  Future<Null> _language(String lang) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("lang", lang);
    AppLocalizations.load(new Locale(lang, ""));
  }
}
