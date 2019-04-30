import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/pages/countrycode_page.dart';
import 'package:queuemsadmin/pages/loading_page.dart';
import 'package:queuemsadmin/pages/more_page.dart';
import 'package:queuemsadmin/pages/token_issue_page.dart';
import 'package:queuemsadmin/pages/token_list_page.dart';
import 'package:queuemsadmin/pages/token_next_page.dart';
import 'package:queuemsadmin/utils/constants.dart';
import 'package:queuemsadmin/utils/functions.dart';

class WaysPage extends StatefulWidget {

  @override
  createState() => new WaysPageState();
}

class WaysPageState extends State<WaysPage> {
  final globalKey = new GlobalKey<ScaffoldState>();
  static const String TAG = "WaysPageState";

  DatabaseReference _profileRef;
  DatabaseReference _profileHistoryRef;
  FirebaseUser _user;
  CompanyData _company;
  StreamSubscription<ConnectivityResult> _subscriptionConnect; 
  bool _resultConnect; 

  @override
  void initState() {
    super.initState();
    
    DateTime _now = new DateTime.now();
    _profileRef = FirebaseDatabase.instance.reference().child('/profile');
    String formatted = getYYYYMMDD(_now);
    _profileHistoryRef = FirebaseDatabase.instance.reference().child('/profileHistory-'+formatted); 

        
    assignLanguage(); 

    currentUser().then((user) { 
      setState(() {
        _user = user;
      });   
      if (user != null){
        Logger.log(TAG, message: user.phoneNumber);

        
        // save user phone prop
        getDeviceData().then((map) { 
          DatabaseReference pushed = _profileHistoryRef.push();
          String key = pushed.key;
          pushed.update({
            'key': key, 
            'uid': user.uid,
            'phone': user.phoneNumber,
            'platformQueue': PlatformQueue.ADMIN,
            'createdDate': _now.toLocal().millisecondsSinceEpoch, 
          });         
          pushed.update(map);
        });
        // end

        // save user online/offline
        _profileRef.child(user.phoneNumber).onDisconnect().update({
          'online': false,
          'disconnectDate': ServerValue.timestamp,
        });
        _profileRef.child(user.phoneNumber).update({
          'online': true,
        });
        // end 

        // check the current store
        FirebaseDatabase.instance.reference().child('company').orderByChild('phone').equalTo(user.phoneNumber).once().then((snapshot) {
          
          if (snapshot.value != null){
            snapshot.value.forEach((d, e){
              if (e['selected'] == true)  {
                Logger.log(TAG, message:'COMPANY KEY is ${e['key']}');
                loadCompany(d).then((company) {
                  setState(() {
                    _company = company;
                  }); 
                });                   
              }
            });
          }
        });  

        // check connectivity
        (Connectivity().checkConnectivity()).then((resultConnect){
          bool conn = false;
          if (resultConnect != null){
            if (resultConnect != ConnectivityResult.none){
              conn = (resultConnect == ConnectivityResult.wifi || 
                        resultConnect == ConnectivityResult.mobile);
            }
          } 
          setState(() {
            _resultConnect = conn; 
          });
        });
        _subscriptionConnect = Connectivity().onConnectivityChanged.listen((ConnectivityResult resultConnect) {
          Logger.log(TAG, message: 'result is $resultConnect');
          bool conn = false;
          if (resultConnect != null){
            if (resultConnect != ConnectivityResult.none){
              conn = (resultConnect == ConnectivityResult.wifi || 
                        resultConnect ==ConnectivityResult.mobile);
            }
          } 
          // save user online/offline
          updateUserOnlineStatus(_user);
          // end
          setState(() {
            _resultConnect = conn; 
          });
        });     
      } else {
        Navigator.pushReplacement(
          context,
          new MaterialPageRoute(builder: (context) => new CountrycodePage()),
        );
      }
    });


    

    
  }

  @override
  void dispose() {
    if (_subscriptionConnect != null) {
      _subscriptionConnect.cancel();
      _subscriptionConnect = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      body: 
        (_user!=null)?
        WillPopScope(
          onWillPop: (){
            return null;
          },
          child:_waysPage()): new LoadingPage(),
    );
  }

  Widget _waysPage() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            buildHeader(AppLocalizations.of(context).admin, _resultConnect, context),
            new Expanded ( 
              flex: 5, 
              child: new Container(
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _flexContainer(Icons.list, AppLocalizations.of(context).tokenList),
                    _flexContainer(Icons.center_focus_weak, AppLocalizations.of(context).issueToken),
                    // Text('www'),
                    // Text('www22')
                  ],
                ),
              ),
            ),
            new Expanded (  
              flex: 5, 
              child: new Container(
                  child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _flexContainer(Icons.skip_next, AppLocalizations.of(context).nextToken),
                  _flexContainer(Icons.more_horiz, AppLocalizations.of(context).more),
                ],
              ))
            ),
          ],
        ),
      ),
    );
  }

  Widget _flexContainer(IconData icon, String title) {
    return new Flexible(
        fit: FlexFit.tight,
        flex: 2,
        child: new GestureDetector(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Icon(
                icon,
                size: 125.0,
                color: Colors.blue[400],
              ),
              new Container(
                child: new Text(
                  title,
                  style: new TextStyle(
                      color: Colors.blueGrey[400],
                      fontWeight: FontWeight.normal,
                      fontSize: 26.0),
                ),
                margin: EdgeInsets.only(top: 5.0, bottom: 10.0),
              ),
            ],
          ),
          onTap: () {
            if (_company == null) {
              if (title == AppLocalizations.of(context).more) {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => MorePage(company: null)
                  ),
                );
              } else {
                showEmptyCompanyToast(context);
              }
            } else {
              if (title == AppLocalizations.of(context).issueToken) {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => TokenIssuePage(company: _company)
                  ),
                );
              } else if (title == AppLocalizations.of(context).nextToken) {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => TokenNextPage(company: _company)
                  ),
                );
              } else if (title == AppLocalizations.of(context).tokenList) {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => TokenListPage(company: _company)
                  ),
                );
              } else if (title == AppLocalizations.of(context).more) {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => MorePage(company: _company)
                  ),
                );
              } 
            }
          }
        ));
  }
}
