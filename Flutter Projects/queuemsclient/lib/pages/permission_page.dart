import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/logger.dart';
import 'package:queuemsclient/pages/home_page.dart';
import 'package:queuemsclient/utils/functions.dart';

class PermissionPage extends StatefulWidget {

  final bool resultConnect;

  PermissionPage({this.resultConnect});

  @override
  createState() => new PermissionPageState();
}

class PermissionPageState extends State<PermissionPage> {

  static const String TAG = "PermissionPage";

  @override
  Widget build(BuildContext context) {
    

    return new Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      padding: EdgeInsets.all(20.0),
      child: Container(
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildHeader(AppLocalizations.of(context).title, widget.resultConnect, context),
              RaisedButton(
                child: Text('Go Setting'),
                onPressed: () async{
                  bool isOpened = await PermissionHandler().openAppSettings();
                  Logger.log(TAG, message: 'isOpened is $isOpened');
                },
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('To use the APP services, you should enable the GPS LOCATION permission.'),
                    SizedBox(height: 20.0),
                    Text('Click the button above to enable the Location permission setting.'),
                  ],
                ),
              ),
              
              RaisedButton(
                child: Text('Home'),
                onPressed: () async{
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                        HomePage()
                    )
                  );
                },
              )
            ],
          ),
        )
      ),
    );
  }

}