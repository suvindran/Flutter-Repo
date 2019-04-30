import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:queuemsclient/pages/display_unit_page.dart';
import 'package:queuemsclient/pages/loading_page.dart';
import 'package:queuemsclient/pages/permission_page.dart';
import 'package:queuemsclient/pages/queue_history_page.dart';
import 'package:queuemsclient/pages/store_info_page.dart';
import 'package:queuemsclient/pages/store_list_page.dart';
import 'package:queuemsclient/utils/constants.dart';
import 'package:queuemsclient/utils/functions.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:vibration/vibration.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class HomeTab extends StatefulWidget {

  final FirebaseUser user;
  final BuildContext ctx;
  final bool resultConnect;

  HomeTab({Key key,this.user, this.ctx, this.resultConnect});

  @override
  createState() => new HomeTabState();
}

class HomeTabState extends State<HomeTab> {

  static const String TAG = "HomeTab";
  CollectionReference _tokenIssuedRef;
  DatabaseReference _notificationRef;
  DatabaseReference _currentTokenRef;
  DateTime _now = new DateTime.now().toLocal();
  StreamSubscription<Position> _positionStreamSubscription;
  StreamSubscription<Event> _qs;
  List<String> _companyKeyList = new List();
  var _queryMyToken;
  String _currentToken;
  String _currentTokenCompanyName;
  String _currentTokenDepName;
  String _currentTokenCounterName;
  bool _granted = true;

  @override
  void initState() {
    super.initState(); 

    Logger.log(TAG, message:'initState');

    _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
    _notificationRef = FirebaseDatabase.instance.reference().child('notification');
    _currentTokenRef = FirebaseDatabase.instance.reference().child('currentToken');

    _queryMyToken = _tokenIssuedRef
      .where('userPhone', isEqualTo: widget.user.phoneNumber)
      .where('createdYear', isEqualTo: _now.year.toString())
      .where('createdMonth', isEqualTo: _now.month.toString())
      .where('createdDay', isEqualTo: _now.day.toString())
      .orderBy('createdDate', descending: true);
    
    // handle GPS
    subscribeGPS(widget.user).then((positionStreamSubscription){
      if (positionStreamSubscription == null){
        setState(() {
          _granted = false; 
        });
      }
      setState(() {
        _positionStreamSubscription = positionStreamSubscription; 
      });
    });     

    // http://myhexaville.com/2018/04/09/flutter-push-notifications-with-firebase-cloud-messaging/
    updateMessageToken(widget.user);

    // Get all the token company key
    _queryMyToken.snapshots().listen((data){
      data.documents.forEach((doc) {
        String companyKey = doc['company']['key'];
        if (_companyKeyList.contains(companyKey) == false) {
          Logger.log(TAG, message: 'companyKey is $companyKey');
          _companyKeyList.add(companyKey);

          // Listen the change of the DB
          _qs = _currentTokenRef.orderByChild('companyKey').equalTo(companyKey).onChildChanged.listen((event){
            if (event.snapshot != null) {
              var value = event.snapshot.value;
              String token = '${value['letter']}-${value['tokenNumber']}';
              String depKey = value['depKey'];
              String formatted = getYYYYMMDD(_now);
              String phoneNformattedDateNdepKey = widget.user.phoneNumber+'|-|'+ formatted+'|-|'+depKey;

              _notificationRef.orderByChild('phoneNformattedDateNdepKey').equalTo(phoneNformattedDateNdepKey).once().then((snapshot){
                snapshot.value.forEach((d, e){
                  if (e['isSubscribed'] == true) {
                    setState(() {
                      _currentToken = token; 
                      _currentTokenCompanyName = value['companyName'];
                      _currentTokenDepName = value['depName'];
                      _currentTokenCounterName = value['counterName'];
                    });
                    Vibration.vibrate(pattern: [500, 500, 500, 500, 500, 500, 500, 500]);
                  }
                });
              });              
            }
          });
        }
      });  
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
    if (_qs != null){
      _qs.cancel();
      _qs = null;
    }
    
    super.dispose();
  }
    
  @override
  Widget build(BuildContext context) {    

    Logger.log(TAG, message: '_granted is $_granted');

    if (_positionStreamSubscription != null){
      if (_positionStreamSubscription.isPaused){
        _positionStreamSubscription.resume();
      }
    }    

    final globalKey = new GlobalKey<ScaffoldState>();
    
    return new Scaffold(
      key: globalKey,
      body: WillPopScope(
          onWillPop: (){
            return null;
          },
          child: (_currentToken==null && _granted)? Column(
            children: <Widget>[ 
              buildHeader(AppLocalizations.of(widget.ctx).myQueueToday, widget.resultConnect, context),         
              
              new Expanded(            
                child: new Container(
                  decoration: new BoxDecoration(
                  color: Colors.white 
                  ),
                  child: new Column(
                    children: <Widget>[
                      new Expanded( 
                        child: _listQueueMyTokenContainer(_queryMyToken, context),
                      ),
                    ],
                  )
                  
                )
              ),
            ],
          ): (!_granted)?PermissionPage(resultConnect: widget.resultConnect):new Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:50.0),
                  child: FlareGiffyDialog(
                    flarePath: 'assets/space_demo.flr',
                    flareAnimation: 'loading',
                    title: Text('CURRENT is \'$_currentToken\'',
                          style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w600),
                    ),
                    description: Text('Store is $_currentTokenCompanyName.\nDepartment is $_currentTokenDepName.\nProceed to counter $_currentTokenCounterName',
                          textAlign: TextAlign.center,
                          style: TextStyle(),
                        ),
                    onlyOkButton: true,
                    onOkButtonPressed: () {

                      setState(() {
                        _currentToken = null; 
                        _currentTokenCompanyName = null;
                        _currentTokenDepName = null;
                        _currentTokenCounterName = null;
                      });
                    },
                  )
                ),
                
              ],
            ),
          ), 
      ),     
      floatingActionButton: (_granted)?new FloatingActionButton(
        onPressed: () async {
          ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);
          PermissionStatus permission = await requestPermission();

          if (permission == null){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                  PermissionPage(resultConnect: widget.resultConnect)
              )
            );
          }

          // Check enable GPS
          if (permission == PermissionStatus.granted && serviceStatus == ServiceStatus.enabled) {
            Logger.log(TAG, message: 'PermissionStatus is granted');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    StoreListPage(user: widget.user, ctx: widget.ctx)
              ),
            );
          } else if (serviceStatus == ServiceStatus.disabled) {
                Logger.log(TAG, message: 'ServiceStatus is disabled');
                showDialog(
                  context: context,
                  builder: (BuildContext ctx){
                    return new SimpleDialog(
                      title: new Text('GPS'),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Please turn on GPS service...'),
                        )
                      ]
                    );
                  }
                );
          } else if (permission != PermissionStatus.granted) {
              Logger.log(TAG, message: 'PermissionStatus is not granted');
              Map<PermissionGroup, PermissionStatus> permissionRequestResult  = await PermissionHandler().requestPermissions([PermissionGroup.location]);
                
              Logger.log(TAG, message: 'result is $permissionRequestResult');
          }
          
        },
        tooltip: AppLocalizations.of(context).issueToken,
        child: const Icon(Icons.add),
      ):null,
    );
  }  

  
  // get user token list
  Widget _listQueueMyTokenContainer(var query, BuildContext context) {

    return new StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return new LoadingPage();
        } else {
          if (snapshot.data.documents.length==0) {
            return new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('assets/queue_board.png'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }

          final int messageCount = snapshot.data.documents.length;
          Logger.log(TAG, message: 'count card is $messageCount');
          return new ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: messageCount,
            itemBuilder: (_, int index) {
              final DocumentSnapshot document = snapshot.data.documents[index];
              return _listQueueContainer(context, document, index);
            },
          );
        }
      }
    );
  }

  // get Current Token
  Widget _listQueueContainer(BuildContext context, DocumentSnapshot myDoc, int index) {
    Logger.log(TAG, message: '_listQueueContainer key is ${myDoc['key']} ,index is $index');

    var queryOnQueue = _tokenIssuedRef
      .where('depKey', isEqualTo: myDoc['depKey'])
      .where('reset', isEqualTo: false)
      .where('isOnQueue', isEqualTo: true)
      .where('createdYear', isEqualTo: _now.year.toString())
      .where('createdMonth', isEqualTo: _now.month.toString())
      .where('createdDay', isEqualTo: _now.day.toString())
      .limit(1)
      .orderBy('assignedDate', descending: true);

    return new StreamBuilder<QuerySnapshot>(
      stream: queryOnQueue.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        String currentDepToken;
        String currentDepTokenCounter;
        String status = ((myDoc['reset']!=null && myDoc['reset']==true) || myDoc['reset']==null)?'RESET':myDoc['status'];
        Color statusColor = (status==Status.ONWAIT)?Colors.yellow:(status==Status.ONQUEUE)?Colors.green:(status==Status.COMPLETED)?Colors.blue:Colors.red;

        if (snapshot.hasData == true) {
          snapshot.data.documents.forEach((doc){
            currentDepToken = '${doc['tokenLetter']}-${doc['tokenNumber']}'; 
            currentDepTokenCounter =  '${AppLocalizations.of(context).counter} ${doc['counterName']}';          
          });
        }
        Logger.log(TAG, message: 'key is ${myDoc['key']} $currentDepToken');

        String _counterText = '- -';
        if (myDoc['counterKey'].toString().isNotEmpty) {
          _counterText = myDoc['counterName'];
        }
        
        Moment _moment = Moment.fromMillisecondsSinceEpoch(myDoc['createdDate']);
        double cardWidth = MediaQuery.of(context).size.width * .8;
        return Padding(
          padding: EdgeInsets.all(3.0),
            child: new Container(
            width: (cardWidth > 300)? 300: cardWidth,  
            margin: EdgeInsets.symmetric(vertical: 10.0),
            decoration: new BoxDecoration(
              color: coolColors.elementAt(index%8),
              borderRadius: new BorderRadius.circular(12.0),
            ),
            child: new SingleChildScrollView(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Banner(
                    message: '$status',
                    location: BannerLocation.topEnd,
                    color: statusColor,
                  ),
                  Column(
                    children: <Widget>[
                      new SizedBox(height: 10.0),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.network(myDoc['company']['logo'], height: 20.0,),
                          const SizedBox(width: 10.0,),
                          new Text(myDoc['company']['name'], style: TextStyle(fontSize: 20.0, color: Colors.white)),
                      ],),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(AppLocalizations.of(widget.ctx).peopleWait+": ", style: TextStyle(fontSize: 20.0, color: Colors.white)),
                          _nonCompletedList(myDoc),
                      ],),
                      new SizedBox(height: 12.0),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(Icons.person, color: Colors.black),
                          new Icon(Icons.more_horiz, color: Colors.white),
                          new Icon(Icons.person, color: Colors.white),
                          new Icon(Icons.person, color: Colors.white),
                          new Icon(Icons.person, color: Colors.white),
                          new Icon(Icons.account_box, color: Colors.yellow),
                        ],
                      ),
                      new SizedBox(height: 12.0),
                      new Text(AppLocalizations.of(widget.ctx).tokenNumber, style: TextStyle(fontSize: 30.0, color: Colors.white)),
                      new Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.white),
                          color: Colors.white,
                        ),
                        child: new InkWell(
                            child: new Text(myDoc['tokenLetter']+'-'+myDoc['tokenNumber'].toString(), style: TextStyle(fontSize: 50.0, color: coolColors[index%8])),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return new SimpleDialog(
                                    title: new Text(AppLocalizations.of(context).options),
                                    children: <Widget>[
                                      DialogActionItem(
                                        icon: Icons.store,
                                        color: Colors.blue,
                                        text: AppLocalizations.of(context).store,
                                        onPressed: () { 
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                StoreInfoPage(storeKey: myDoc['companyKey'])
                                            )
                                          );
                                        }
                                      ),
                                      DialogActionItem(
                                        icon: Icons.tv,
                                        color: Colors.blue,
                                        text: AppLocalizations.of(context).openDisplayUnit,
                                        onPressed: () { 
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                DisplayUnitPage(companyKey: myDoc['companyKey'])
                                            )
                                          );
                                        }
                                      ),
                                      DialogActionItem(
                                        icon: Icons.history,
                                        color: Colors.blue,
                                        text: AppLocalizations.of(context).showWaitingQueueHistory,
                                        onPressed: () { 
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                QueueHistoryPage(companyKey: myDoc['companyKey'], depKey: myDoc['depKey'], ctx: context)
                                            )
                                          );
                                        }
                                      ),
                                    ],
                                  );
                                }
                              );
                            },
                        )
                      ),
                      new Text(myDoc['depName'], style: TextStyle(color: Colors.white)),
                      new Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.white)
                        ),
                        child: new Text(AppLocalizations.of(widget.ctx).proceedTo+" "+ AppLocalizations.of(widget.ctx).counter +" "+_counterText, style: TextStyle(fontSize: 20.0, color: Colors.white)),
                      ),
                      new SizedBox(height: 5.0),
                      new Text(AppLocalizations.of(widget.ctx).createdDate+' '+ _moment.fromNow()+' '+AppLocalizations.of(widget.ctx).ago, style: TextStyle(color: Colors.white)),
                      new Text(AppLocalizations.of(widget.ctx).statusQueue+': '+ myDoc['status'], style: TextStyle(color: Colors.white)),
                      new SizedBox(height: 5.0),
                      (myDoc['reset'] == false && currentDepToken!=null)? new Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.white)
                        ),
                        child: Column(
                          children: <Widget>[
                            new Text('${AppLocalizations.of(widget.ctx).currentToken}: $currentDepToken', style: TextStyle(fontSize: 20.0, color: Colors.white)),
                            new Text('$currentDepTokenCounter', style: TextStyle(fontSize: 20.0, color: Colors.white)),
                          ],
                        )
                      ): const Text(''),
                  

                    ]
                  ),
                ],
              ),
            )
          )
        
        );
      },
    );
  }

  Widget _nonCompletedList(myDoc)  {
    if (myDoc['reset'] == false){
      var queryNonCompleted = _tokenIssuedRef
        .where('depKey', isEqualTo: myDoc['depKey'])
        .where('reset', isEqualTo: false)
        .where('isCompleted', isEqualTo: false)
        .where('isOnWait', isEqualTo: true)
        .where('createdYear', isEqualTo: _now.year.toString())
        .where('createdMonth', isEqualTo: _now.month.toString())
        .where('createdDay', isEqualTo: _now.day.toString())
        .orderBy('assignedDate', descending: true);
      return new StreamBuilder<QuerySnapshot>(
          stream: queryNonCompleted.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return _buildMessageCount(0);
            int messageCount = snapshot.data.documents.length;
            return _buildMessageCount(messageCount);
          }       
      );
    } else {
      return _buildMessageCount(-1);
    }
  }

  Widget _buildMessageCount(int messageCount){

    String text = '0';
    if (messageCount != null) {
      if (messageCount<0) {
        text = 'RESET';
      } else {
        text = messageCount.toString();
      }
    }

    return new Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(5.0),
        decoration: new BoxDecoration(

            border: new Border.all(color: Colors.white)
        ),
        child: new Column(
          children: <Widget>[
            new Text(text,
                style: TextStyle(fontSize: 12.0, color: Colors.white))
          ],
        )
    );
  }
}



class DialogActionItem extends StatelessWidget {
  const DialogActionItem({ Key key, this.icon, this.color, this.text, this.onPressed }) : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}