import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:queuemsadmin/pages/add_phone_dialog.dart';
import 'package:queuemsadmin/pages/token_number_page.dart';
import 'package:queuemsprinter/queuemsprinter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenIssuePage extends StatefulWidget {

  final CompanyData company;

  TokenIssuePage({this.company});

  @override
  createState() => new TokenIssueState();
}

class TokenIssueState extends State<TokenIssuePage> {
  static const String TAG = "TokenIssuePage";

  final globalKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  CollectionReference _tokenIssuedRef;
  DatabaseReference _departmentRef;
  bool _anchorToBottom = false;
  String _depKey;
  String _depName;
  int _start;
  String _letter;
  int _runningNumber = 1;
  FirebaseUser _user;
  String phone;
  String _printerStatus = '';

  @override
  void initState() {
    super.initState();
    _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
    _departmentRef = FirebaseDatabase.instance.reference().child('department-'+widget.company.key);
    currentUser().then((user) {
      Logger.log(TAG, message: 'user is ' + user.uid);
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: new AppBar(
        key: globalKey,
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).issueToken),
      ),
      body: new Container(
        margin: EdgeInsets.all(20.0),
        child: new Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(widget.company.logo, height: 20.0,),
                const SizedBox(width: 10.0,),
                new Text(widget.company.name, style: TextStyle(fontSize: 20.0, color: Colors.black)),
            ],),
            SizedBox(height: 30.0),
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
                            color: (this.phone == null)?CupertinoColors.activeBlue:CupertinoColors.inactiveGray,
                            onPressed: () {
                              if (this.phone == null) {
                                this._depKey = snapshot.value['key'];
                                this._depName = snapshot.value['name'];
                                this._start = snapshot.value['start'];
                                this._letter = snapshot.value['letter'];
                                _openAddPhoneDialog();
                              }
                            }),
                      )
                    ]));
              },
            )),
            new Container(
              child: new Center(
                child: new Column(
                  children: <Widget>[
                    new Text(_printerStatus),
                  ],
                ),
              )
            ) 
          ],
        ),
      ),
    );
  }


  void showInputDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  Future  _openAddPhoneDialog() async{
    String phone = await Navigator.of(context).push(new MaterialPageRoute<String>(
      builder: (BuildContext context) {
        return new AddPhoneDialog();
      },
      fullscreenDialog: true
    ));
    if (phone != null){
      Logger.log(TAG, message: phone);
      setState(() {
        this.phone = phone;
      });
      _handleSubmitted(phone);
    }
  }

  void _handleSubmitted(phone) {
    _runningNumber = this._start;

    _tokenIssuedRef.where('depKey', isEqualTo: _depKey)
      .where('reset', isEqualTo: false)
      .orderBy('serverTimestamp', descending: true)
      .where('companyKey', isEqualTo: widget.company.key).limit(1)
      .getDocuments().then((result){
      DateTime now = new DateTime.now().toLocal();
      if (result.documents.length > 0){
        DocumentSnapshot doc = result.documents[0];
        int tokenNumber = doc['tokenNumber'];

        if (doc['reset'] == null || doc['reset'] == false) {  
          _runningNumber = tokenNumber + 1;
        }
      }
      Logger.log(TAG, message: _runningNumber.toString());

      DocumentReference ref =  _tokenIssuedRef.document();
      ref.setData({
        'key': ref.documentID,
        'uid': _user.uid,
        'userPhone': phone,
        'tokenLetter': this._letter,
        'tokenNumber': _runningNumber,
        'depName': this._depName,
        'depKey': this._depKey,
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
        'issuedFrom': PlatformQueue.ADMIN,
        'companyKey': widget.company.key,
        'company': widget.company.toMap(),
        'reset': false
      });

      // subscribe topic
      String formatted = getYYYYMMDD(now);
      String topic = formatted+'-'+ _depKey;
      Logger.log(TAG, message: topic);
      
      // save the topic detail on DB
      String phoneNformattedDate =  phone+'|-|'+ formatted;
      String phoneNformattedDateNdepKey =  phone+'|-|'+ formatted+'|-|'+_depKey;
      DatabaseReference _notificationRef = FirebaseDatabase.instance.reference().child('notification');
      _notificationRef.orderByChild('phoneNformattedDateNdepKey').equalTo(phoneNformattedDateNdepKey).once().then((snapshot){
        
        if (snapshot.value == null){
          DatabaseReference pushed = _notificationRef.push();
          String key = pushed.key;
          pushed.set({
            'key': key,
            'uid': '',
            'userPhone': phone,
            'depKey':  _depKey,
            'depName': _depName,
            'formattedDate': formatted,
            'phoneNformattedDate': phoneNformattedDate,
            'phoneNformattedDateNdepKey': phoneNformattedDateNdepKey,
            'topic': topic,
            'isSubscribed': true,
            'createdDate': now.millisecondsSinceEpoch,  
            'issuedFrom': PlatformQueue.ADMIN, 
            'companyKey': widget.company.key,              
            'company': widget.company.toMap(),
          });
        }
      });

      // printing
      SharedPreferences.getInstance().then((prefs){
        bool enable = prefs.getBool('enablePrinting');
        if (enable){
          Queuemsprinter.checkConnection().then((connected){
            Queuemsprinter.printToken(_letter, '$_runningNumber');
          });
        }
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            TokenNumberPage(user: _user, tokenLetter: _letter, tokenNumber: _runningNumber, depName: _depName, counterName: null, distanceInMeters: 0.0, distanceCreatedDate: 0)
        ),
      );
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
