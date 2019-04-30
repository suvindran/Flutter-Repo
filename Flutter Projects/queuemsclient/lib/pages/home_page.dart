import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/logger.dart';
import 'package:queuemsclient/pages/countrycode_page.dart';
import 'package:queuemsclient/utils/constants.dart';
import 'package:queuemsclient/utils/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:queuemsclient/pages/loading_page.dart';
import 'package:queuemsclient/pages/home_tab.dart';
import 'package:queuemsclient/pages/more_tab.dart';

class HomePage extends StatefulWidget {

  @override
  createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {

  static const String TAG = "HomePage";
  
  FirebaseUser _user;
  int _currentIndex = 0;
  final globalKey = new GlobalKey<ScaffoldState>();
  DatabaseReference _profileHistoryRef;
  StreamSubscription<ConnectivityResult> _subscriptionConnect; 
  bool _resultConnect;
  StreamSubscription<Position> _positionStreamSubscription;

  @override
  void initState() {
    super.initState();  
    
    Logger.log(TAG, message: 'initState');

    DateTime _now = new DateTime.now();
    String formatted = getYYYYMMDD(_now);
    _profileHistoryRef = FirebaseDatabase.instance.reference().child('/profileHistory-'+formatted);

    assignLanguage(); 
    
    currentUser().then((user) { 
      if (user == null){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CountrycodePage()
          ),
        );
      } else {
        Logger.log(TAG, message: user.phoneNumber);
       
        // save user phone prop
        getDeviceData().then((map) { 
          DatabaseReference pushed = _profileHistoryRef.push();
          String key = pushed.key;
          pushed.update({
            'key': key, 
            'uid': user.uid,
            'phone': user.phoneNumber,
            'platformQueue': PlatformQueue.CLIENT,
            'createdDate': _now.toLocal().millisecondsSinceEpoch, 
          });         
          pushed.update(map);
        });
        // end

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
          bool conn = false;
          if (resultConnect != null){
            if (resultConnect != ConnectivityResult.none){
              conn = (resultConnect == ConnectivityResult.wifi || 
                        resultConnect == ConnectivityResult.mobile);
            }
          } 
          // save user online/offline
          updateUserOnlineStatus(user);
          // end
          setState(() {
            _resultConnect = conn; 
          });
        });
        // end
        
        // http://myhexaville.com/2018/04/09/flutter-push-notifications-with-firebase-cloud-messaging/
        updateMessageToken(user);
      }
      setState(() {
        _user = user;
      });   
    });

    
  }

  @override
  void dispose() {
    if (_subscriptionConnect != null) {
      _subscriptionConnect.cancel();
      _subscriptionConnect = null;
    }
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    if (this._user == null){
      return new LoadingPage();
    }
    
    if (_positionStreamSubscription != null){
      if (_positionStreamSubscription.isPaused){
        _positionStreamSubscription.resume();
      }
    } 

    final homeTab = new HomeTab(user: _user, ctx:context, resultConnect: _resultConnect);
    final moreTab = new MoreTab(user: _user, ctx:context, resultConnect: _resultConnect);

    final routes = [homeTab, moreTab];
        
    return Scaffold(
      key: globalKey,
      body: WillPopScope(
          onWillPop: (){
            return null;
          },
          child: new Container(
          child: routes[_currentIndex]
        ),
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) { 
          setState((){
             this._currentIndex = index; 
          }); 
       },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: new Icon(Icons.person),
            title: new Text(AppLocalizations.of(context).myQueue),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.more_horiz),
            title: new Text(AppLocalizations.of(context).more),
          ),
        ],
      ));
  }
}