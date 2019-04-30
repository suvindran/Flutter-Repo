import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/logger.dart';
import 'package:queuemsclient/models/holiday_data.dart';
import 'package:queuemsclient/models/office_hours_data.dart';
import 'package:queuemsclient/pages/loading_page.dart';
import 'package:queuemsclient/pages/timezone_notmatch_page.dart';
import 'package:queuemsclient/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:queuemsclient/pages/token_number_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:queuemsclient/utils/functions.dart';

class TokenIssuePage extends StatefulWidget {

  final FirebaseUser user;
  final BuildContext ctx;
  final String companyKey;
  TokenIssuePage({this.user, this.companyKey, this.ctx});
  
  @override
  createState() => new TokenIssueState();
}

class TokenIssueState extends State<TokenIssuePage> {

  static const String TAG = "TokenIssuePage";
  String _depKeySelected;
  String _status = '';
  bool _timeInRange = false;
  bool _holidayInRange = false;
  String _companyKey;
  String _companyName;
  String _companyLogo;
  double _companyTimezone;
  String _companyTimezoneAbbr;

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance.reference().child('company').orderByChild('key').equalTo(widget.companyKey).once().then((snapshot) {
      snapshot.value.forEach((d, e){
        setState(() {
          _companyKey = d; 
          _companyName = e['name'] ;
          _companyLogo = e['logo'] ;
          _companyTimezone =  (e['timezone'] is int)?e['timezone'] + .0: e['timezone'];
          _companyTimezoneAbbr = e['timezoneAbbr'];
        });
      });
    });
  
  }

  @override
  Widget build(BuildContext context) {

    if (_companyKey == null){
      return new LoadingPage();
    }
    DateTime now = new DateTime.now().toLocal();
    double d = (now.timeZoneOffset.inMinutes is int)?now.timeZoneOffset.inMinutes + .0: now.timeZoneOffset.inMinutes;
    double nowTimezone = (now.timeZoneOffset.isNegative)?((d/60) * -1.0): d/60;
    Logger.log(TAG, message: 'NOW is ${now.timeZoneName} , SETTING is $_companyTimezoneAbbr');
    Logger.log(TAG, message: 'NOW is $nowTimezone , SETTING is $_companyTimezone');
    if (nowTimezone != _companyTimezone) {

      return new TimezoneNotmatchPage();
    }

    Logger.log(TAG, message: _companyKey);
    
    final globalKey = new GlobalKey<ScaffoldState>();
    final bool _anchorToBottom = false;  
    final DatabaseReference _departmentRef = FirebaseDatabase.instance.reference().child('department-'+ _companyKey);

    return Scaffold(
      appBar: new AppBar(
        key: globalKey,
        centerTitle: true,
        title: new Text(AppLocalizations.of(widget.ctx).issueToken),
      ),
      body: new Container(
        margin: EdgeInsets.all(20.0),
        child: new Column(
          children: <Widget>[
            (_status != '')? new Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                border: new Border.all(color: Colors.red),
                color: Colors.yellow,
                borderRadius: new BorderRadius.circular(8.0),
              ),
              child: new Center(
                  child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Text(_status, style: TextStyle(fontSize: 16.0, color: Colors.red)),
                  ],
                ),
              )              
            ): const SizedBox(height: 0.0), 
            new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(_companyLogo, height: 20.0,),
                      const SizedBox(width: 10.0,),
                      new Text(_companyName, style: TextStyle(fontSize: 20.0, color: Colors.black)),
                  ],),
            new Flexible(
                child: new FirebaseAnimatedList(
              key: new ValueKey<bool>(_anchorToBottom),
              query: _departmentRef.orderByChild('enable').equalTo(true),
              reverse: _anchorToBottom,
              sort: _anchorToBottom
                  ? (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key)
                  : null,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new SizeTransition(
                    sizeFactor: animation,
                    child: new Column(children: <Widget>[
                      new Padding(padding: EdgeInsets.all(20.0)),
                      new Center(
                        child: new CupertinoButton(
                            child: new Text(snapshot.value['name']),
                            color: (this._depKeySelected == null)?CupertinoColors.activeBlue:CupertinoColors.inactiveGray,
                            onPressed: () {
                              Logger.log(TAG, message: '_depKeySelected is $_depKeySelected');
                              if (_depKeySelected == null) {
                                String _depKey = snapshot.value['key'];
                                String _depName = snapshot.value['name'];
                                int _start = snapshot.value['start'];
                                String _letter = snapshot.value['letter'];
                                setState(() {
                                  _depKeySelected= _depKey;
                                });
                                _handleSubmitted(context, _depKey, _depName, _start, _letter);
                              } 
                            }),
                      ),
                    ]));
              },
            )),
            const SizedBox(height: 20.0),                      
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(BuildContext context, String _depKey, String _depName, int _start, String _letter) {

    Logger.log(TAG, message: '_companyKey is $_companyKey, _depKey is $_depKey, _depName is $_depName, _start is $_start, _letter is $_letter');

    CollectionReference _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
    int _runningNumber = _start;
    DateTime now = new DateTime.now().toLocal();
    // search company
    loadCompany(_companyKey).then((company){
      int intervalTime = (company.intervalTime == null)?0:company.intervalTime;

      //check holiday
      List<HolidayData> holidayList = company.holidayList;
        String holidayName = '';
        if (holidayList != null) {
        holidayList.forEach((holiday){
          holidayName = holiday.name;
          DateTime holidayDate = new DateTime.fromMillisecondsSinceEpoch(holiday.date);
          bool holidayInRange = holiday.enable && (holidayDate.year==now.year && holidayDate.month==now.month && holidayDate.day==now.day);

          if (holidayInRange == true){
            setState(() {
              _holidayInRange = holidayInRange;          
            });
            return;
          }
        });
        if (holidayList.length>0 && _holidayInRange == true){
          setState(() {
            _status = AppLocalizations.of(widget.ctx).cannotIssueTokenHoliday+' '+ holidayName;             
          });
          return;
        }
      }
      //end

      // check office hours
      List<OfficeHoursData> hoursList = company.officeHoursList;
      var formatter = new DateFormat('jm');
      Map<int, Object> map = new Map();
      if (hoursList != null) {
        hoursList.forEach((officeHours){
          
          DateTime startTime = new DateTime(now.year, now.month, now.day, officeHours.startHour,officeHours.startMinute);
          DateTime endTime = new DateTime(now.year, now.month, now.day, officeHours.endHour,officeHours.endMinute);

          List<String> days = new List();
          days.add((officeHours.mon)?'MON':null);
          days.add((officeHours.tues)?'TUES':null);
          days.add((officeHours.wed)?'WED':null);
          days.add((officeHours.thurs)?'THURS':null);
          days.add((officeHours.fri)?'FRI':null);
          days.add((officeHours.sat)?'SAT':null);
          days.add((officeHours.sun)?'SUN':null);
          days.removeWhere((item) => item == null);
          String officeHoursText = days.join('|')+'\n'+formatter.format(startTime) +' to '+ formatter.format(endTime)+'\n\n';
          map[officeHours.orderNum] = officeHoursText;

          bool timeInRange = officeHours.enable && (now.millisecondsSinceEpoch >= startTime.millisecondsSinceEpoch && now.millisecondsSinceEpoch <= endTime.millisecondsSinceEpoch);
        
          bool weekInRange = ((officeHours.mon && DateTime.monday==now.weekday) || 
            (officeHours.tues && DateTime.tuesday==now.weekday) || 
            (officeHours.wed && DateTime.wednesday==now.weekday) || 
            (officeHours.thurs && DateTime.thursday==now.weekday) || 
            (officeHours.fri && DateTime.friday==now.weekday) || 
            (officeHours.sat && DateTime.saturday==now.weekday) || 
            (officeHours.sun && DateTime.sunday==now.weekday) );

          if ((timeInRange && weekInRange) == true){
            setState(() {
              _timeInRange = true;          
            });
            return;
          }
        });
      }

      if (hoursList != null && hoursList.length > 0 && _timeInRange == false){
        String officeHoursText = '';
        var sortedKeys = map.keys.toList()..sort();
        sortedKeys.forEach((v){
          officeHoursText += map[v];
        });
        setState(() {
          _status = AppLocalizations.of(widget.ctx).mustIssueTokenOfficeHours+'\n\n'+officeHoursText;             
        });
        return;
      }
      // end

      _tokenIssuedRef.where('depKey', isEqualTo: _depKey)
        .where('reset', isEqualTo: false)
        .orderBy('serverTimestamp', descending: true)
        .where('companyKey', isEqualTo: widget.companyKey).limit(1)
        .getDocuments().then((result){

        if (result.documents.length > 0){
          DocumentSnapshot doc = result.documents[0];

          // Check intervalTime before issue token
          if (intervalTime != null){
            Logger.log(TAG, message: 'intervalTime is $intervalTime');
            double i = doc['createdDate'] + (intervalTime * 60 * 1000).toDouble();
            double i2 = now.millisecondsSinceEpoch + .0;
            Logger.log(TAG, message: 'i is $i, i2 is $i2');
            if (i > i2) {
              Logger.log(TAG, message: 'Cannot create Token');

              setState(() {
                _status = AppLocalizations.of(widget.ctx).notMeetTimeInterval;             
              });
              return;
            } else {
              Logger.log(TAG, message: 'Can create Token');
            }
          } 

          // increase token number
          int tokenNumber = doc['tokenNumber'];

          if (doc['reset'] == null || doc['reset'] == false) {  
            _runningNumber = tokenNumber + 1;
          }
        }
        Logger.log(TAG, message: _runningNumber.toString());
        int nowTimezone = (now.timeZoneOffset.isNegative)?(now.timeZoneOffset.inHours * -1): now.timeZoneOffset.inHours;

        // save token
        DocumentReference ref =  _tokenIssuedRef.document();
        ref.setData({
          'key': ref.documentID,
          'uid': widget.user.uid,
          'userPhone': widget.user.phoneNumber,
          'tokenLetter': _letter,
          'tokenNumber': _runningNumber,
          'depName': _depName,
          'depKey': _depKey,
          'counterName': '',
          'counterKey': '',
          'status': Status.ONWAIT,
          'statusCode': StatusCode.ONWAIT,
          'isOnWait': true,
          'isOnQueue': false,
          'isRecall': false,
          'isCompleted': false,
          'assignedDate': null, 
          'assignedYear': null,
          'assignedMonth': null,
          'assignedDay': null,
          'assignedHour': null,
          'assignedMin': null,
          'serverTimestamp': FieldValue.serverTimestamp(),
          'createdDate': now.millisecondsSinceEpoch,    
          'createdYear': now.year.toString(),
          'createdMonth': now.month.toString(),
          'createdDay': now.day.toString(),
          'createdHour': now.hour.toString(),
          'createdMin': now.minute.toString(),
          'timeZoneName': now.timeZoneName,
          'timeZoneOffset': nowTimezone,
          'issuedFrom': PlatformQueue.CLIENT,
          'companyKey': company.key,
          'company': company.toMap(),
          'reset': false
        });

        // subscribe topic
        String formatted = getYYYYMMDD(now);
        FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
        String topic = formatted+'-'+ _depKey;
        _firebaseMessaging.subscribeToTopic(topic);
        Logger.log(TAG, message: topic);
        
        // save the topic detail on DB
        String phoneNformattedDate =  widget.user.phoneNumber+'|-|'+ formatted;
        String phoneNformattedDateNdepKey =  widget.user.phoneNumber+'|-|'+ formatted+'|-|'+_depKey;
        DatabaseReference _notificationRef = FirebaseDatabase.instance.reference().child('notification');
        _notificationRef.orderByChild('phoneNformattedDateNdepKey').equalTo(phoneNformattedDateNdepKey).once().then((snapshot){
          
          if (snapshot.value == null){
            DatabaseReference pushed = _notificationRef.push();
            String key = pushed.key;
            pushed.set({
              'key': key,
              'uid': widget.user.uid,
              'userPhone': widget.user.phoneNumber,
              'depKey':  _depKey,
              'depName': _depName,
              'formattedDate': formatted,
              'phoneNformattedDate': phoneNformattedDate,
              'phoneNformattedDateNdepKey': phoneNformattedDateNdepKey,
              'topic': topic,
              'isSubscribed': true,
              'createdDate': now.millisecondsSinceEpoch,  
              'issuedFrom': PlatformQueue.CLIENT, 
              'companyKey': company.key,              
              'company': company.toMap(),
            });
          } else {
            // enable subscribe is true
            snapshot.value.forEach((d, e){
              Logger.log(TAG, message: 'notificationKey is '+ d);
              _notificationRef.child(d).update({
                'isSubscribed': true
              });
            }); 
          }
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
              TokenNumberPage(user: widget.user, tokenLetter: _letter, tokenNumber: _runningNumber, depName: _depName, counterName: null, distanceInMeters: 0.0, distanceCreatedDate: 0, ctx:widget.ctx)
          ),
        );
      });
    });
  }
}
