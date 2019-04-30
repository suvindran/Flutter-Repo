import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:queuemsclient/logger.dart';
import 'package:queuemsclient/utils/constants.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = MY_BASE_QUEUE_URL + '#/queue/';

class DisplayUnitPage extends StatelessWidget {
  static const String TAG = "DisplayUnitPage";

  final String companyKey;

  DisplayUnitPage({this.companyKey});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    String url = selectedUrl + companyKey;
    Logger.log(TAG, message: url);

    return new WillPopScope(
      onWillPop: () async => false,
      child: new MaterialApp(
        routes: {
          "/": (_) => new WebviewScaffold(
                url: url,
                persistentFooterButtons: <Widget>[
                  new FlatButton(
                    child: new Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/HomePage');
                    },
                  )
                ],
              )
        },
      )
    );
    
    
  }
}
