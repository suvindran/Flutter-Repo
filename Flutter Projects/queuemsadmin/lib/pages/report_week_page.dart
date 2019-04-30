import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/utils/functions.dart';


/// The main gallery app widget.
class ReportWeekPage extends StatefulWidget {

  final String companyKey;

  ReportWeekPage({this.companyKey});

  @override
  ReportWeekState createState() => new ReportWeekState();
}

class ReportWeekState extends State<ReportWeekPage> {

  static const String TAG = "ReportWeekState";
  CollectionReference _tokenIssuedRef;
  DateTime _now;
  List<TokenChart> _data = new List();
  bool _hasData = false;

  @override
    void initState() {
      super.initState();
      _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
      _now = new DateTime.now().toLocal();
      DateTime _oldDate = new DateTime(_now.year, _now.month, _now.day, 23, 59);

      // count total token
      for (var i=6; i>=0; i--){
        _oldDate = _oldDate.subtract(Duration(days: 1));
        String name = (_oldDate.day).toString();
        String date = getYYYYMMDD(_oldDate);
        _tokenIssuedRef
          .where('createdYear', isEqualTo: _oldDate.year.toString())
          .where('createdMonth', isEqualTo: _oldDate.month.toString())
          .where('createdDay', isEqualTo: _oldDate.day.toString())
          .where('companyKey', isEqualTo: widget.companyKey)
          .getDocuments().then((snapshot) {
            int count = snapshot.documents.length;
            Logger.log(TAG, message: name+', count is '+ count.toString());
            _data.add(new TokenChart(date, name, count, Colors.blueAccent));
            _data.sort((a, b) => a.date.compareTo(b.date));
            if (i == 0) {
              setState(() {
                _hasData = true;
              });
            }
            
        }); 
      }  

      
    }
 
  @override
  Widget build(BuildContext context) {

    var series = [
      new charts.Series(
        domainFn: (TokenChart tokenChart, _) => tokenChart.name,
        measureFn: (TokenChart tokenChart, _) => tokenChart.count,
        colorFn: (TokenChart tokenChart, _) => tokenChart.color,
        id: AppLocalizations.of(context).totalTokenCount,
        data: _data,
      ),     
    ];


    var chart = new charts.BarChart(
      series,
      animate: true,
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
        title: new Text(AppLocalizations.of(context).report7daysAgo),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (_hasData==true)? chartWidget: new Container(),
          ],
        ),
      ),
    );
  }
}


class TokenChart {
  final String date;
  final String name;
  final int count;
  final charts.Color color;

  TokenChart(this.date, this.name, this.count, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

