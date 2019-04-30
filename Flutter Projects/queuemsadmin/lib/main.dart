import 'package:queuemsadmin/pages/countrycode_page.dart';
import 'package:queuemsadmin/pages/hours_list_page.dart';
import 'package:queuemsadmin/pages/report_compare_page.dart';
import 'package:queuemsadmin/pages/report_week_page.dart';
import 'package:queuemsadmin/pages/report_pie_page.dart';
import 'package:queuemsadmin/pages/ways_page.dart';
import 'package:queuemsadmin/pages/token_next_page.dart';
import 'package:queuemsadmin/pages/token_issue_page.dart';
import 'package:queuemsadmin/pages/token_list_page.dart';
import 'package:queuemsadmin/pages/more_page.dart';
import 'package:flutter/material.dart';
import 'package:queuemsadmin/pages/department_list_page.dart';
import 'package:queuemsadmin/pages/counter_list_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:queuemsadmin/localizations.dart';

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
      home: new WaysPage(),
      routes: <String, WidgetBuilder> {
        '/WaysPage': (BuildContext context) => new WaysPage(),
        '/CountrycodePage': (BuildContext context) => new CountrycodePage(),
        '/TokenNextPage': (BuildContext context) => new TokenNextPage(),
        '/TokenIssuePage': (BuildContext context) => new TokenIssuePage(),
        '/TokenListPage': (BuildContext context) => new TokenListPage(),
        '/MorePage': (BuildContext context) => new MorePage(),
        '/DepartmentListPage': (BuildContext context) => new DepartmentListPage(),
        '/CounterListPage': (BuildContext context) => new CounterListPage(),
        '/ReportWeekPage': (BuildContext context) => new ReportWeekPage(),
        '/ReportPiePage': (BuildContext context) => new ReportPiePage(),
        '/ReportComparePage': (BuildContext context) => new ReportComparePage(),
        '/HoursListPage': (BuildContext context) => new HoursListPage(),
      }
    );
  }
}

