import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';

/// The main gallery app widget.
class ReportComparePage extends StatefulWidget {

  final String companyKey;

  ReportComparePage({this.companyKey});

  @override
  ReportCompareState createState() => new ReportCompareState();
}

class ReportCompareState extends State<ReportComparePage> {

  static const String TAG = "ReportCompareState";
  CollectionReference _tokenIssuedRef;
  DatabaseReference _counterRef;
  DateTime _now;
  bool _hasTodayData = false;  
  bool _hasYesterdayData = false;
  List<TokenChart> _todayData = new List();
  List<TokenChart> _yesterdayData = new List();

  @override
  void initState() {
    super.initState();
    _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
    _counterRef = FirebaseDatabase.instance.reference().child('counter-'+widget.companyKey);
    _now = new DateTime.now().toLocal();

    // Get counterName
    _counterRef.once().then((snapshot){
      snapshot.value.forEach((d, e){
        String counterKey = d;//e['key'];
        String counterName = 'Counter '+ e['name'];
        Logger.log(TAG, message: counterKey+', '+ counterName);
        // TODAY
        DateTime _today = new DateTime(_now.year, _now.month, _now.day, 23, 59);
        _tokenIssuedRef
          .where('counterKey', isEqualTo: counterKey)
          .where('createdYear', isEqualTo: _today.year.toString())
          .where('createdMonth', isEqualTo: _today.month.toString())
          .where('createdDay', isEqualTo: _today.day.toString())
          .where('companyKey', isEqualTo: widget.companyKey)
          .getDocuments().then((snapshot){
            int count = snapshot.documents.length;
            Logger.log(TAG, message: '_todayData is '+ counterName+', count is '+count.toString());
            _todayData.add(new TokenChart(counterName, count));
            _todayData.sort((a, b) => a.name.compareTo(b.name));
            setState(() {
              _hasTodayData = true;
            });
        });
        // YESTERDAY
        DateTime _yesterday = _today.subtract(Duration(days: 1));
        _tokenIssuedRef
          .where('counterKey', isEqualTo: counterKey)
          .where('createdYear', isEqualTo: _yesterday.year.toString())
          .where('createdMonth', isEqualTo: _yesterday.month.toString())
          .where('createdDay', isEqualTo: _yesterday.day.toString())
          .where('companyKey', isEqualTo: widget.companyKey)
          .getDocuments().then((snapshot){
            int count = snapshot.documents.length;
            Logger.log(TAG, message: '_yesterdayData is '+ counterName+', count is '+count.toString());
            _yesterdayData.add(new TokenChart(counterName, count));
            _yesterdayData.sort((a, b) => a.name.compareTo(b.name));
            setState(() {
              _hasYesterdayData = true;
            });
        });
      });
    });
  }
 
  @override
  Widget build(BuildContext context) {

    var series = [
      
      new charts.Series<TokenChart, String>(
        domainFn: (TokenChart tokenChart, _) => tokenChart.name,
        measureFn: (TokenChart tokenChart, _) => tokenChart.count,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        id: AppLocalizations.of(context).yesterday,
        data: _yesterdayData,
      ),
      new charts.Series<TokenChart, String>(
        domainFn: (TokenChart tokenChart, _) => tokenChart.name,
        measureFn: (TokenChart tokenChart, _) => tokenChart.count,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        id: AppLocalizations.of(context).today,
        data: _todayData,
      ),
    ];

    var chart = new charts.BarChart(
      series,
      animate: true,
      barGroupingType: charts.BarGroupingType.grouped,
      behaviors: [new charts.SeriesLegend()],
    );

    var chartWidget = new Padding(
      padding: new EdgeInsets.all(32.0),
      child: new SizedBox(
        height: 200.0,
        child: chart,
      ),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).reportCompare),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (_hasTodayData && _hasYesterdayData)? chartWidget: new Container()
          ],
        ),
      ),
    );
  }
}

class TokenChart {
  final String name;
  final int count;

  TokenChart(this.name, this.count);
}