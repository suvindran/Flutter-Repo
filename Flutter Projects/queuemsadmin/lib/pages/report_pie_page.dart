import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/utils/constants.dart';
import 'package:queuemsadmin/logger.dart';

/// The main gallery app widget.
class ReportPiePage extends StatefulWidget {

  final String companyKey;

  ReportPiePage({this.companyKey});

  @override
  ReportPieState createState() => new ReportPieState();
}

class ReportPieState extends State<ReportPiePage> {

  static const String TAG = "ReportPieState";
  CollectionReference _tokenIssuedRef;
  int _countOnWait = 0;
  int _countOnQueue = 0;
  int _countCompleted = 0;
  int _countRecall = 0;
  DateTime _startTime;
  DateTime _endTime;
  DateTime _now;

  @override
  void initState() {
    super.initState();
    _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
    
    _now = new DateTime.now().toLocal();
    _startTime = new DateTime(_now.year, _now.month, _now.day, 0, 00);
    _endTime = new DateTime(_now.year, _now.month, _now.day, 23, 59);
    Logger.log(TAG, message: _startTime.toIso8601String());
    Logger.log(TAG, message: _endTime.toIso8601String());

    // count status ONWAIT
    _tokenIssuedRef.where('status', isEqualTo: Status.ONWAIT)
      .where('createdDate', isGreaterThanOrEqualTo: _startTime.millisecondsSinceEpoch)
      .where('createdDate', isLessThanOrEqualTo: _endTime.millisecondsSinceEpoch)
      .where('companyKey', isEqualTo: widget.companyKey)
      .getDocuments().then((snapshot) {
      int count = snapshot.documents.length;
      setState(() {
        _countOnWait = count;
      });
    }); 

    // count status ONQUEUE
    _tokenIssuedRef.where('status', isEqualTo: Status.ONQUEUE)
      .where('createdDate', isGreaterThanOrEqualTo: _startTime.millisecondsSinceEpoch)
      .where('createdDate', isLessThanOrEqualTo: _endTime.millisecondsSinceEpoch)
      .where('companyKey', isEqualTo: widget.companyKey)
      .getDocuments().then((snapshot) {
      int count = snapshot.documents.length;
      setState(() {
        _countOnQueue = count;
      });
    }); 

    // count status COMPLETED
    _tokenIssuedRef.where('status', isEqualTo: Status.COMPLETED)
      .where('createdDate', isGreaterThanOrEqualTo: _startTime.millisecondsSinceEpoch)
      .where('createdDate', isLessThanOrEqualTo: _endTime.millisecondsSinceEpoch)
      .where('companyKey', isEqualTo: widget.companyKey)
      .getDocuments().then((snapshot) {
      int count = snapshot.documents.length;
      setState(() {
        _countCompleted = count;
      });
    }); 

    // count status RECALL
    _tokenIssuedRef.where('status', isEqualTo: Status.RECALL)
      .where('createdDate', isGreaterThanOrEqualTo: _startTime.millisecondsSinceEpoch)
      .where('createdDate', isLessThanOrEqualTo: _endTime.millisecondsSinceEpoch)
      .where('companyKey', isEqualTo: widget.companyKey)
      .getDocuments().then((snapshot) {
      int count = snapshot.documents.length;
      setState(() {
        _countRecall = count;
      });
    }); 

    
  }
 
  @override
  Widget build(BuildContext context) {

    var data = [
      (_countOnWait>0)?new TokenPie('${Status.ONWAIT} (${StatusAcronym.ONWAIT})', _countOnWait, Colors.orange[100]):null,
      (_countOnQueue>0)?new TokenPie('${Status.ONQUEUE} (${StatusAcronym.ONQUEUE})', _countOnQueue, Colors.green[100]):null,
      (_countCompleted>0)?new TokenPie('${Status.COMPLETED} (${StatusAcronym.COMPLETED})', _countCompleted, Colors.blue[100]):null,
      (_countRecall>0)?new TokenPie('${Status.RECALL} (${StatusAcronym.RECALL})', _countRecall, Colors.red[100]):null,
    ];    

    data.removeWhere((value) => value == null);

    var series = [
      new charts.Series(
        domainFn: (TokenPie tokenPie, _) => tokenPie.status,
        measureFn: (TokenPie tokenPie, _) => tokenPie.number,
        colorFn: (TokenPie tokenPie, _) => tokenPie.color,
        id: 'Token Count',
        data: data,
        labelAccessorFn: (TokenPie row, _) => '${row.number}:${row.status}',
      ),
    ];

    var pie = new charts.PieChart(
      series,
      animate: false,
      defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
          new charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.outside)
        ]),
        behaviors: [
          new charts.DatumLegend(
            position: charts.BehaviorPosition.end,
            horizontalFirst: false,
            showMeasures: true,
            legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
            measureFormatter: (num value) {
              return value == null ? '-' : '$value';
            },
          )
        ],
    );
    
    double width = MediaQuery.of(context).size.width - 15.0;

  var pieWidget = new SizedBox(
        width: width,
        height: width,
        child: pie,
  );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).reportPercentageToday),
      ),
      body: Container(
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              pieWidget, 
            ],
          ),
        ),
      ),
    );
  }
}


class TokenPie {
  final String status;
  final int number;
  final charts.Color color;

  TokenPie(this.status, this.number, Color color)
    : this.color = new charts.Color(r: color.red, g: color.green, b: color.blue, a: color.alpha);
}