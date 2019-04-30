import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/pages/add_interval_dialog.dart';
import 'package:queuemsadmin/pages/counter_list_page.dart';
import 'package:queuemsadmin/pages/department_list_page.dart';
import 'package:queuemsadmin/pages/holiday_list_page.dart';
import 'package:queuemsadmin/pages/hours_list_page.dart';
import 'package:queuemsadmin/pages/printer_setup_page.dart';
import 'package:queuemsadmin/pages/queue_history_page.dart';
import 'package:queuemsadmin/pages/report_compare_page.dart';
import 'package:queuemsadmin/pages/report_pie_page.dart';
import 'package:queuemsadmin/pages/report_week_page.dart';
import 'package:queuemsadmin/pages/select_language_page.dart';
import 'package:queuemsadmin/pages/store_list_page.dart';
import 'package:queuemsadmin/pages/ways_page.dart';
import 'package:queuemsadmin/utils/constants.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MorePage extends StatefulWidget {

  final CompanyData company;

  MorePage({this.company});

  @override
  createState() => new MorePageState();
}

class MorePageState extends State<MorePage> {

  static const String TAG = "MorePageState";

  CollectionReference _tokenIssuedRef;
  DatabaseReference _companyRef;
  FirebaseUser _user;
  DateTime _now = DateTime.now().toLocal();
  int _countOnWait = 0;
  int _countOnQueue = 0;
  int _countCompleted = 0;
  int _countRecall = 0;
  String _phoneNumber = '';
  String _projectVersion = '';
  String _projectCode = '';
  String _projectAppID = '';
  String _projectName = '';
  bool _loading = false;
  bool _enablePrinting;

  @override
  void initState() {
    super.initState();
    _initPlatformState();

    currentUser().then((user) {

      SharedPreferences.getInstance().then((prefs){
        setState(() {
          _enablePrinting = prefs.getBool('enablePrinting');
        });         
      });

      setState(() {
        _user = user;
        _phoneNumber = user.phoneNumber;
      });
    });

    _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
    _companyRef = FirebaseDatabase.instance.reference().child('company');

  }

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;

    initSummary();
    return new WillPopScope(
      onWillPop: () {
        Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new WaysPage(),
        ));
      },
      child: Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).more),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(context, new MaterialPageRoute(
              builder: (BuildContext context) => new WaysPage(),
            ));
          }
        ),
      ),
      body: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Container(
                height: 10.0,
              ),
              _buildSumamry01(),
              const SizedBox(height: 10.0),
              _buildSumamry02(),
              const SizedBox(
                height: 50.0,
              ),
              (_loading == true)?_getCenterLoadingContent():_buildReset(),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                title: new Text(AppLocalizations.of(context).currentStore, style: textTheme.title),
                subtitle: (widget.company==null)?Text('- - - - -'): Row(
                  children: <Widget>[
                    Image.network(widget.company.logo, width: 40.0),
                    SizedBox(width: 10.0),
                    Text('${widget.company.name}')
                  ],
                ),
              ),
              new Divider(
                height: 20.0,
              ),
              Card(
                margin: EdgeInsets.all(10.0),
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: new Text(AppLocalizations.of(context).title.toUpperCase(), style: textTheme.title),
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        leading: new Icon(Icons.link),
                        title: new Text(AppLocalizations.of(context).openWebSite, style: textTheme.title),
                        onTap: () {
                          _launchURL(MY_BASE_URL);
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        leading: new Icon(Icons.link),
                        title: new Text(AppLocalizations.of(context).openDisplayUnit, style: textTheme.title),
                        onTap: () {
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                  title: new Text(AppLocalizations.of(context).openDisplayUnit),
                                  content: new Text(AppLocalizations.of(context).wantConfirm),
                                  actions: <Widget>[ 
                                    new FlatButton(
                                      child: new Text(AppLocalizations.of(context).cancel),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    new FlatButton(
                                      child: new Text(AppLocalizations.of(context).ok),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _launchURL(MY_BASE_QUEUE_URL+'#/queue/'+widget.company.key);
                                      },
                                    ),
                                  ],
                                );
                              }
                            ); 
                          }
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        leading: new Icon(Icons.language),
                        title: new Text(AppLocalizations.of(context).selectLanguage, style: textTheme.title),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SelectLanguagePage(user: _user, ctx: context)
                            ),
                          );
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      ListTile(
                        leading: new Switch(
                          value: (_enablePrinting==null)?false:_enablePrinting,
                          onChanged: (bool value) async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setBool('enablePrinting', value);
                            setState(() {
                              _enablePrinting = value;
                            });
                        }),
                        title: Text(AppLocalizations.of(context).setupBluetoothPrinter, style: textTheme.title),
                        onTap: () async{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PrinterSetupPage()
                            ),
                          );
                        },
                      ),
            
                    ]
                  )
                )
              ),
              Card(
                margin: EdgeInsets.all(10.0),
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: new Text(AppLocalizations.of(context).storeSetting.toUpperCase(), style: textTheme.title),
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        dense: true,
                        leading: new Icon(Icons.store),
                        title: new Text(AppLocalizations.of(context).storeList, style: textTheme.title),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StoreListPage(user: _user)
                            ),
                          );
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        dense: true,
                        leading: new Icon(Icons.account_balance),
                        title: new Text(AppLocalizations.of(context).deparment, style: textTheme.title),
                        onTap: () {
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            Navigator.push(context, new MaterialPageRoute(
                              builder: (BuildContext context) => new DepartmentListPage(company: widget.company),
                            ));
                          }
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        dense: true,
                        leading: new Icon(Icons.developer_board),
                        title: new Text(AppLocalizations.of(context).counter, style: textTheme.title),
                        onTap: () {
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            Navigator.push(context, new MaterialPageRoute(
                              builder: (BuildContext context) => new CounterListPage(company: widget.company),
                            ));
                          }
                        },
                      ),   
                    ],
                  ),
                ),
              ),
              
               Card(
                margin: EdgeInsets.all(10.0),
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: new Text(AppLocalizations.of(context).insight.toUpperCase(), style: textTheme.title),
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        dense: true,
                        leading: new Icon(Icons.insert_chart),
                        title: new Text(AppLocalizations.of(context).insightCompare, style: textTheme.title),
                        onTap: () {
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            Navigator.push(context, new MaterialPageRoute(
                              builder: (BuildContext context) => new ReportComparePage(companyKey: widget.company.key),
                            ));
                          }
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        dense: true,
                        leading: new Icon(Icons.show_chart),
                        title: new Text(AppLocalizations.of(context).insightLast7days, style: textTheme.title),
                        onTap: () {
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            Navigator.push(context, new MaterialPageRoute(
                              builder: (BuildContext context) => new ReportWeekPage(companyKey: widget.company.key),
                            ));
                          }
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        dense: true,
                        leading: new Icon(Icons.pie_chart),
                        title: new Text(AppLocalizations.of(context).insightToday, style: textTheme.title),
                        onTap: () {
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            Navigator.push(context, new MaterialPageRoute(
                              builder: (BuildContext context) => new ReportPiePage(companyKey: widget.company.key),
                            ));
                          }
                        },
                      ),
                    ]
                  )
                )
               ),
              Card(
                margin: EdgeInsets.all(10.0),
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: new Text(AppLocalizations.of(context).otherSetting.toUpperCase(), style: textTheme.title),
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        leading: new Icon(Icons.timer),
                        title: new Text(AppLocalizations.of(context).timeIntervalToIssueToken, style: textTheme.title),
                        onTap: (){
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            _openAddIntervalDialog();
                          }
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        leading: new Icon(Icons.access_time),
                        title: new Text(AppLocalizations.of(context).officeHours, style: textTheme.title),
                        onTap: (){
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            Navigator.push(context, new MaterialPageRoute(
                              builder: (BuildContext context) => new HoursListPage(companyKey: widget.company.key),
                            ));
                          }
                        },
                      ),
                      new Divider(
                        height: 20.0,
                      ),
                      new ListTile(
                        leading: new Icon(Icons.calendar_today),
                        title: new Text(AppLocalizations.of(context).publicHolidays, style: textTheme.title),
                        onTap: (){
                          if (widget.company == null) {
                            showEmptyCompanyToast(context);
                          } else {
                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (context) => HolidayListPage(companyKey: widget.company.key)
                              ),
                            );
                          }
                        },
                      ),
                      
                    ]
                  )
                )
              ), 
              
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: Icon(Icons.info),
                title: Text(AppLocalizations.of(context).name),
                subtitle: Text((_projectName!=null)?_projectName:''),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: Icon(Icons.info),
                title: Text(AppLocalizations.of(context).versionName),
                subtitle: Text((_projectVersion!=null)?_projectVersion:''),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: Icon(Icons.info),
                title: Text(AppLocalizations.of(context).versionCode),
                subtitle: Text((_projectCode!=null)?_projectCode:''),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: Icon(Icons.info),
                title: Text(AppLocalizations.of(context).appId),
                subtitle: Text((_projectAppID!=null)?_projectAppID:''),
              ),
              new Divider(
                height: 20.0,
              ),              
              new ListTile(
                leading: Icon(Icons.access_time),
                title: Text(AppLocalizations.of(context).localTime),
                subtitle: Text(_now.toIso8601String()),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: Icon(Icons.info),
                title: Text(AppLocalizations.of(context).myPhoneNumber),
                subtitle: Text(_phoneNumber),
              ),              
              new Divider(
                height: 20.0,
              ),
              new Center(
                child: new RaisedButton(
                  child: new Text(AppLocalizations.of(context).signout),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context).signout),
                          content: Text(AppLocalizations.of(context).wantExit),
                          actions: <Widget>[ 
                            FlatButton(
                              child: Text(AppLocalizations.of(context).ok),
                              onPressed: () {
                                _signOut().then((_){      
                                  Navigator.of(context).pop();                            
                                  Navigator.of(context).pushNamed('/CountrycodePage');
                                });
                              },
                            ),
                          ],
                        );
                      }
                    );
                  },
                )
              ),
              new Divider(
                height: 20.0,
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildSumamry01(){

    int num = 500;
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[        
        GestureDetector(
          child: _buildInfoBox('${Status.ONWAIT.toUpperCase()} (${StatusAcronym.ONWAIT})', _countOnWait, Colors.orange[num]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QueueHistoryPage(companyKey: widget.company.key, tokenStatus: Status.ONWAIT)
              ),
            );
          },
        ),
        const SizedBox(width: 10.0),  
        GestureDetector(
          child: _buildInfoBox('${Status.ONQUEUE.toUpperCase()} (${StatusAcronym.ONQUEUE})', _countOnQueue, Colors.green[num]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QueueHistoryPage(companyKey: widget.company.key, tokenStatus: Status.ONQUEUE)
              ),
            );
          },
        ),
        const SizedBox(width: 10.0), 
      ],
    );
  }

  Widget _buildSumamry02(){

    int num = 500;
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: _buildInfoBox('${Status.COMPLETED.toUpperCase()} (${StatusAcronym.COMPLETED})', _countCompleted, Colors.blue[num]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QueueHistoryPage(companyKey: widget.company.key, tokenStatus: Status.COMPLETED)
              ),
            );
          },
        ),
        const SizedBox(width: 10.0),         
        GestureDetector(
          child: _buildInfoBox('${Status.RECALL.toUpperCase()} (${StatusAcronym.RECALL})', _countRecall, Colors.red[num]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QueueHistoryPage(companyKey: widget.company.key, tokenStatus: Status.RECALL)
              ),
            );
          },
        ),
        const SizedBox(width: 10.0), 
      ],
    );
  }

  Widget _buildInfoBox(text, count, color){
    return new Container(
          height: 100.0,
          width: 105.0,
          padding: EdgeInsets.all(8.0),
          decoration: new BoxDecoration(
            color: color,
            borderRadius: new BorderRadius.circular(8.0),
          ),
          child: new Center(child: 
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(text, style: TextStyle(color: Colors.white, fontSize: 10.0),),
                const SizedBox(height: 10.0 ),
                new Text('$count', style: TextStyle(color: Colors.white, fontSize: 24.0),),
              ],
            ),
          ),
        );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _initPlatformState() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String projectName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String platformVersion = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    Logger.log(TAG, message:'projectName is $projectName');

    setState(() {
      _projectVersion = platformVersion;
      _projectCode = buildNumber;
      _projectAppID = packageName;
      _projectName = projectName;
    });
  }  

  Widget _buildReset(){

    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            OutlineButton(
              padding: EdgeInsets.all(10.0),
              shape: new CircleBorder(side: BorderSide(width: 3.0)),
              child: Icon(Icons.settings_backup_restore, size: 50.0, color: Colors.black),
              onPressed: () {
                setState(() {
                  _loading = true; 
                });   
                showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          title: new Text(AppLocalizations.of(context).resetTokenNumber),
                          content: new Text(AppLocalizations.of(context).wantResetTokenNumber),
                          actions: <Widget>[ 
                            new FlatButton(
                              child: new Text(AppLocalizations.of(context).ok),
                              onPressed: () {
                                bool reset = false;
                                _tokenIssuedRef.where('companyKey', isEqualTo: widget.company.key).where('reset', isEqualTo: reset).getDocuments().then((result){
                                                                
                                  for (var i=0; i<result.documents.length; i++){
                                    DocumentSnapshot doc = result.documents[i];
                                    Logger.log(TAG, message: 'update ${doc['key']}');
                                    doc.reference.updateData({
                                      'reset': !reset
                                    });
                                  }
                                });
                                Navigator.of(context, rootNavigator: true).pop();
                              },
                            ),
                            new FlatButton(
                              child: Text(AppLocalizations.of(context).cancel),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).pop();
                              }
                            )
                          ],
                        );
                      }
                    ).then((value){
                      setState(() {
                        _loading = false; 
                      });
                    });
              },
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(AppLocalizations.of(context).resetTokenNumber),
                    Text(AppLocalizations.of(context).toStartNumber),
                  ],
                ),
              )
            ) 
          ],
        )
      )
    );
  }

  Future _openAddIntervalDialog() async {
    double interval = await Navigator.of(context).push(new MaterialPageRoute<double>(
      builder: (BuildContext context) {
        return new AddIntervalDialog(companyKey: widget.company.key);
      },
    fullscreenDialog: true
    ));
    if (interval != null){
      Logger.log(TAG, message: interval.toString() +' minutes');
      _companyRef.child(widget.company.key).update({
        'intervalTime': interval
      });
    }
  }
  

  Future<void> _signOut() async{
    await FirebaseAuth.instance.signOut();
  }

  void initSummary(){

    if (widget.company == null){
      return;
    }
    // count ONWAIT
    _tokenIssuedRef.where('status', isEqualTo: Status.ONWAIT)
      .where('reset', isEqualTo: false)
      .where('companyKey', isEqualTo: widget.company.key)
      .getDocuments().then((snapshot) {
        int count = snapshot.documents.length;
        setState(() {
          _countOnWait = count;
        });
    });

    // count ONQUEUE
    _tokenIssuedRef.where('status', isEqualTo: Status.ONQUEUE)
      .where('reset', isEqualTo: false)
      .where('companyKey', isEqualTo: widget.company.key)
      .getDocuments().then((snapshot) {
        int count = snapshot.documents.length;
        setState(() {
          _countOnQueue = count;
        });
    });

    // count COMPLETED
    _tokenIssuedRef.where('status', isEqualTo: Status.COMPLETED)
      .where('reset', isEqualTo: false)
      .where('companyKey', isEqualTo: widget.company.key)
      .getDocuments().then((snapshot) {
        int count = snapshot.documents.length;
        setState(() {
          _countCompleted = count;
        });
    });

    // count RECALL
    _tokenIssuedRef.where('status', isEqualTo: Status.RECALL)
      .where('reset', isEqualTo: false)
      .where('companyKey', isEqualTo: widget.company.key)
      .getDocuments().then((snapshot) {
        int count = snapshot.documents.length;
        setState(() {
          _countRecall = count;
        });
    });
  }

  Widget _getCenterLoadingContent() {

    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation(Colors.black))
        ],
      ),
    );
  }
}