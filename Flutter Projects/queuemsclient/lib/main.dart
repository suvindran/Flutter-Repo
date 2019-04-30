
import 'package:queuemsclient/localizations.dart';
import 'package:flutter/material.dart';
import 'package:queuemsclient/pages/countrycode_page.dart';
import 'package:queuemsclient/pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
      routes: <String, WidgetBuilder> {
        '/CountrycodePage': (BuildContext context) => new CountrycodePage(),
        '/HomePage': (BuildContext context) => new HomePage(),
      }
    );
  }
}

