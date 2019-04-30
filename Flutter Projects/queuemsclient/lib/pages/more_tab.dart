import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/logger.dart';
import 'package:queuemsclient/pages/notification_list_page.dart';
import 'package:queuemsclient/pages/select_language_page.dart';
import 'package:queuemsclient/utils/constants.dart';
import 'package:queuemsclient/utils/functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class MoreTab extends StatefulWidget {

  final FirebaseUser user;
  final BuildContext ctx;
  final String companyKey;
  final bool resultConnect;

  MoreTab({this.user, this.ctx, this.companyKey, this.resultConnect});
  @override
  createState() => new MoreTabState();
}

class MoreTabState extends State<MoreTab> {

  static const String TAG = "MoreTab";

  DateTime _now = DateTime.now().toLocal();
  String _projectVersion = '';
  String _projectCode = '';
  String _projectAppID = '';
  String _projectName = '';
  StreamSubscription<Position> _positionStreamSubscription;
  StreamSubscription<ConnectivityResult> _subscriptionConnect; 

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
    if (_subscriptionConnect != null) {
      _subscriptionConnect.cancel();
      _subscriptionConnect = null;
    }
    super.dispose();    
  }

  @override
  Widget build(BuildContext context) {

    if (_positionStreamSubscription != null){
      if (_positionStreamSubscription.isPaused){
        _positionStreamSubscription.resume();
      }
    }

    final globalKey = new GlobalKey<ScaffoldState>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    return new MaterialApp(
      home: new Scaffold(
        key: globalKey,
        body: WillPopScope(
          onWillPop: (){
            return null;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white
            ),
            child: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  buildHeader(AppLocalizations.of(widget.ctx).more, widget.resultConnect, context),
                  new Container(
                    height: 10.0,
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.link),
                    title: new Text(AppLocalizations.of(widget.ctx).openWebSite, style: textTheme.title),
                    onTap: () {
                      _launchURL(MY_BASE_URL);
                    },
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.subscriptions),
                    title: new Text(AppLocalizations.of(widget.ctx).subscribe+'/'+AppLocalizations.of(widget.ctx).unsubscribe+' '+ AppLocalizations.of(widget.ctx).notification, style: textTheme.title),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationListPage(user: widget.user, ctx: widget.ctx)
                        ),
                      );
                    },
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.language),
                    title: new Text(AppLocalizations.of(widget.ctx).selectLanguage, style: textTheme.title),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectLanguagePage(user: widget.user, ctx: widget.ctx)
                        ),
                      );
                    },
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.info),
                    title: new Text(AppLocalizations.of(widget.ctx).name),
                    subtitle: new Text(_projectName),
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.info),
                    title: new Text(AppLocalizations.of(widget.ctx).versionName),
                    subtitle: Text((_projectVersion!=null)?_projectVersion:''),
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.info),
                    title: new Text(AppLocalizations.of(widget.ctx).versionCode),
                    subtitle: Text((_projectCode!=null)?_projectCode:''),
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.info),
                    title: new Text(AppLocalizations.of(widget.ctx).appId),
                    subtitle: Text((_projectAppID!=null)?_projectAppID:''),
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.access_time),
                    title: new Text(AppLocalizations.of(widget.ctx).localTime),
                    subtitle: new Text(_now.toIso8601String()),
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.info),
                    title: new Text(AppLocalizations.of(widget.ctx).myPhoneNumber),
                    subtitle: new Text(widget.user.phoneNumber),
                  ),
                  new Divider(
                    height: 20.0,
                  ),
                  new Center(
                  child: new RaisedButton(
                    child: new Text(AppLocalizations.of(widget.ctx).signout),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return new AlertDialog(
                            title: new Text(AppLocalizations.of(widget.ctx).signout),
                            content: new Text(AppLocalizations.of(widget.ctx).wantExit),
                            actions: <Widget>[ 
                              new FlatButton(
                                child: new Text(AppLocalizations.of(widget.ctx).ok),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  signOut().then((_){
                                    Logger.log(TAG, message: 'signOut');
                                    Navigator.of(context).pushReplacementNamed('/CountrycodePage');
                                  });
                                },
                              ),
                            ],
                          );
                        }
                      ); 
                    },
                  )
                ),
                new Divider(
                  height: 20.0,
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String projectName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String platformVersion = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    setState(() {
      _projectVersion = platformVersion;
      _projectCode = buildNumber;
      _projectAppID = packageName;
      _projectName = projectName;
    });
  }  
}