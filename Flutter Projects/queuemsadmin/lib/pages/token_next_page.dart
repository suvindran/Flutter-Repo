import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:queuemsadmin/utils/constants.dart';
import 'package:queuemsadmin/pages/token_number_page.dart';
import 'package:geolocator/geolocator.dart';

class TokenNextPage extends StatefulWidget {

  final CompanyData company;

  TokenNextPage({this.company});


  @override
  createState() => new TokenNextState();
}

class TokenNextState extends State<TokenNextPage> {

  static const String TAG = "TokenNextState";

  final globalKey = new GlobalKey<ScaffoldState>();
  CollectionReference _tokenIssuedRef;
  DatabaseReference _currentTokenRef;
  DatabaseReference _counterRef;
  DatabaseReference _departmentRef;
  bool _anchorToBottom = false;
  FirebaseUser _user;
  
  String _selectedDep = '';
  String _selectedCounter = '';
  String _selectedCounterName = '';

  @override
  void initState() {
    super.initState();
    currentUser().then((user) {
      Logger.log(TAG, message: 'user is ' + user.uid);
      this._user = user;
    });
    _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
    _counterRef = FirebaseDatabase.instance.reference().child('counter-'+widget.company.key);
    _departmentRef = FirebaseDatabase.instance.reference().child('department-'+widget.company.key);
    _currentTokenRef = FirebaseDatabase.instance.reference().child('currentToken').child(widget.company.key);

  }

  @override
  void dispose() {
    if (_tokenIssuedRef != null) {
      _tokenIssuedRef = null;
    }
    if (_counterRef != null) {
      _counterRef = null;
    }
    if (_departmentRef != null) {
      _departmentRef = null;
    }
    if (_currentTokenRef != null) {
      _currentTokenRef = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: globalKey,
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).nextToken),
      ),
      body: new Stack(
        children: <Widget>[
          _formContainer(),
        ],
      ),
    );
  }

  Widget _formContainer() {
    return new Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: new Center(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.network(widget.company.logo, height: 20.0,),
                  const SizedBox(width: 10.0,),
                  new Text(widget.company.name, style: TextStyle(fontSize: 20.0, color: Colors.black)),
              ],),
              Divider(height: 20.0),
              new Text(AppLocalizations.of(context).selectDepartment),
              new Flexible(
                  child: new FirebaseAnimatedList(
                    padding: EdgeInsets.all(20.0),
                key: new ValueKey<bool>(_anchorToBottom),
                query: _departmentRef.orderByChild('enable').equalTo(true),
                reverse: _anchorToBottom,
                sort: _anchorToBottom
                    ? (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key)
                    : null,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                      return new Container(
                        child: new Center(
                          child: new Column(
                            children: <Widget>[
                              new ChoiceChip(
                                key: new ValueKey<String>(snapshot.key),
                                backgroundColor: Colors.blue,
                                selectedColor: Colors.red,
                                label: new Text(snapshot.value['name'], style: TextStyle(color: Colors.white, fontSize: 30.0)),
                                padding: EdgeInsets.all(10.0),
                                selected: _selectedDep == snapshot.key,
                                onSelected: (bool value) {
                                  setState(() {
                                    _selectedDep = value ? snapshot.key : '';
                                  });
                                  _handleSubmit();
                                },
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        )
                      );
                    }
                  
                )
              ),
              
              const Divider(),
              new Text(AppLocalizations.of(context).selectCounter),
              SizedBox(height: 20.0),
              new Flexible(
                  child: new FirebaseAnimatedList(
                key: new ValueKey<bool>(_anchorToBottom),
                query: _counterRef.orderByChild('enable').equalTo(true),
                reverse: _anchorToBottom,
                sort: _anchorToBottom
                    ? (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key)
                    : null,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                      return new Container(
                        child: new Center(
                          child: new Column(
                            children: <Widget>[
                              new ChoiceChip(
                                key: new ValueKey<String>(snapshot.key),
                                backgroundColor: Colors.blue,
                                selectedColor: Colors.red,
                                label: new Text('Counter '+ snapshot.value['name'], style: TextStyle(color: Colors.white, fontSize: 30.0)),
                                padding: EdgeInsets.all(10.0),
                                selected: _selectedCounter == snapshot.key,
                                onSelected: (bool value) {
                                  setState(() {
                                    _selectedCounter = value ? snapshot.key : '';
                                    _selectedCounterName = value ? snapshot.value['name']: '';
                                  });
                                  _handleSubmit();
                                },
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        )
                      );
                    }
                  
                )
              ),
              
            ],
          ),
        ));
  }

  _handleSubmit(){
    if (_selectedDep != '' && _selectedCounter !=''){
      Logger.log(TAG, message: _selectedDep +', '+ _selectedCounter);
      String _letter;
      int _tokenNumber;
      String _depName;
      DateTime _now = new DateTime.now().toLocal();

      
      // update Status is COMPLETED
      _tokenIssuedRef.where('isOnQueue', isEqualTo: true)
        .where('depKey', isEqualTo: _selectedDep)
        .where('reset', isEqualTo: false)
        .where('companyKey', isEqualTo: widget.company.key)
        .orderBy('assignedDate', descending: false).limit(1)
        .getDocuments().then((snapshot) {
          snapshot.documents.forEach((doc){
            String key = doc.documentID;
            if (_selectedCounter == doc['counterKey']){
              _tokenIssuedRef.document(key).updateData({
                'assignedByUid': _user.uid,
                'status': Status.COMPLETED,
                'statusCode': StatusCode.COMPLETED,
                'isOnWait': false,
                'isOnQueue': false,
                'isRecall': false,
                'isCompleted': true,
                'completedDate': _now.millisecondsSinceEpoch,
              });
            }
          });
          //
           // Update Status is ONQUEUE
          _tokenIssuedRef.where('isOnWait', isEqualTo: true)
            .where('depKey', isEqualTo: _selectedDep)
            .where('reset', isEqualTo: false)
            .where('companyKey', isEqualTo: widget.company.key)
            .orderBy('createdDate', descending: false)
            .limit(1)
            .getDocuments().then((snapshot) {
            snapshot.documents.forEach((doc){
              String key = doc.documentID;
              _letter = doc['tokenLetter'];
              _tokenNumber = doc['tokenNumber'];
              _depName = doc['depName'];
              String userPhone = doc['userPhone'];
              double comLat = doc['company']['lat'];
              double comLng = doc['company']['lng'];

              // SET current token
              _currentTokenRef.set({
                'companyKey':widget.company.key,
                'depKey': _selectedDep, 
                'counterKey': _selectedCounter, 
                'companyName':doc['company']['name'],
                'companyLogo':doc['company']['logo'],
                'depName':doc['depName'],
                'counterName':_selectedCounterName,
                'letter': _letter, 
                'tokenNumber': _tokenNumber,
              });

              Logger.log(TAG, message: key);
              DateTime now = new DateTime.now().toLocal();
              _tokenIssuedRef.document(key).updateData({
                'assignedByUid': _user.uid,
                'status': Status.ONQUEUE,
                'statusCode': StatusCode.ONQUEUE,
                'isOnWait': false,
                'isOnQueue': true,
                'isRecall': false,
                'isCompleted': false,
                'counterKey': _selectedCounter, 
                'counterName': _selectedCounterName,
                'assignedDate': now.millisecondsSinceEpoch,
                'assignedYear': now.year.toString(),
                'assignedMonth': now.month.toString(),
                'assignedDay': now.day.toString(),
                'assignedHour': now.hour.toString(),
                'assignedMin': now.minute.toString(),
              });

              DatabaseReference profileGPSHistoryRef;
              String formatted = getYYYYMMDD(now);
              profileGPSHistoryRef = FirebaseDatabase.instance.reference().child('/profileGPSHistory-'+formatted); 
              profileGPSHistoryRef.orderByChild('phone').equalTo(userPhone).limitToLast(1).once().then((snapshot) {
                double distanceInMeters = 0.0;
                int distanceCreatedDate = 0;
                 if (snapshot.value != null){
                   snapshot.value.forEach((d, e) async{
                    double lat = e['lat'];
                    double lng = e['lng'];
                    distanceCreatedDate = e['localCreatedDate'];
                    Logger.log(TAG, message: lat.toString()+','+lng.toString());
                    distanceInMeters = await Geolocator().distanceBetween(comLat, comLng, lat, lng);
                    Logger.log(TAG, message: 'distanceInMeters is '+distanceInMeters.toString());
                   });
                 } 
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TokenNumberPage(user: _user, tokenLetter: _letter, 
                          tokenNumber: _tokenNumber, 
                          depName: _depName,
                          counterName: _selectedCounterName, 
                          distanceInMeters: distanceInMeters, 
                          distanceCreatedDate: distanceCreatedDate)
                  ),
                );
              }); 

              
            });

            (snapshot.documents.length == 0)? 
              showDialog(
                context: context,
                builder: (BuildContext context) { 
                                    
                 
                  return new AlertDialog(
                    title: new Text(AppLocalizations.of(context).nextToken),
                    content: new Text(AppLocalizations.of(context).noMoreNextToken),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(AppLocalizations.of(context).ok),
                        onPressed: () {
                          setState(() {
                            _selectedDep = '';
                            _selectedCounter = '';
                            _selectedCounterName = '';                  
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                }
              )
            : new Container();
          });
      });

     
    }
  }
}



