import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/pages/loading_page.dart';
import 'package:queuemsadmin/pages/profile_page.dart';
import 'package:queuemsadmin/utils/constants.dart';
import 'package:simple_moment/simple_moment.dart';

class TokenListPage extends StatefulWidget {

  final CompanyData company;

  TokenListPage({this.company});

  @override
  createState() => new TokenListState();
}

class TokenListState extends State<TokenListPage> {
  static const String TAG = "TokenListPage";

  final globalKey = new GlobalKey<ScaffoldState>();
  CollectionReference _tokenIssuedRef;

  @override
  void initState() {
    super.initState();    

    _tokenIssuedRef = Firestore.instance.collection('tokenIssued');

  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      key: globalKey,
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).tokenList),
      ),
      body: _listQueueContainer()
    );
  }

  Widget _listQueueContainer() {

    final TextTheme textTheme = Theme.of(context).textTheme;
    
    return new StreamBuilder<QuerySnapshot>(
            stream: _tokenIssuedRef.orderBy('assignedDate', descending: true)
              .where('reset', isEqualTo: false)
              .where('companyKey', isEqualTo: widget.company.key).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return new LoadingPage();
              final int messageCount = snapshot.data.documents.length;
              Logger.log(TAG, message: messageCount.toString());
              return new ListView.builder(
                itemCount: messageCount,  
                itemBuilder: (_, int index) {
                  final DocumentSnapshot document = snapshot.data.documents[index];
                  int assignedDate = document['assignedDate'];
                  String status = document['status'];
                  double comLat = document['company']['lat'];
                  double comLng = document['company']['lng'];
                  String statusAcronym = '';
                  if (status == Status.ONWAIT){
                    statusAcronym = StatusAcronym.ONWAIT;
                  } else if (status == Status.ONQUEUE){
                    statusAcronym = StatusAcronym.ONQUEUE;
                  } else if (status == Status.COMPLETED){
                    statusAcronym = StatusAcronym.COMPLETED;
                  } else if (status == Status.RECALL){
                    statusAcronym = StatusAcronym.RECALL;
                  }
                  var moment = (assignedDate==null)?null:Moment.fromMillisecondsSinceEpoch(assignedDate);
                  String _counterText = (document['counterName'].toString().isEmpty)?'':'${AppLocalizations.of(context).counter} '+document['counterName'];
                  String _momentText = (moment==null)?null:moment.fromNow();

                  return new ListTile(
                    leading: new Container(
                      height: 70.0,
                      width: 70.0,
                      decoration: new BoxDecoration(
                        color: coolColors.elementAt(index%8),
                        borderRadius: new BorderRadius.circular(8.0),
                      ),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(statusAcronym, style: TextStyle(fontSize: 35.0, color: Colors.white)),
                          (_momentText!=null)?new Text(_momentText, style: TextStyle(fontSize: 10.0, color: Colors.white)):const SizedBox(height: 0.0),
                        ]
                      )
                    ),
                    onTap:  () {Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(comLat:comLat, comLng: comLng, phone: document['userPhone'])
                      ),
                    );},
                    trailing: new Column(
                      children: <Widget>[
                        (_counterText.isNotEmpty)?new FlatButton(
                          padding: EdgeInsets.all(10.0),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                  title: new Text(AppLocalizations.of(context).recall),
                                  content: new Text(AppLocalizations.of(context).doYouWantRecall),
                                  actions: <Widget>[ 
                                    new FlatButton(
                                      child: new Text(AppLocalizations.of(context).ok),
                                      onPressed: () {
                                        document.reference.updateData({
                                          'status': Status.RECALL,
                                          'statusCode': StatusCode.RECALL,
                                          'isOnWait': false,
                                          'isOnQueue': true,
                                          'isRecall': true,
                                          'isCompleted': false,
                                          'assignedDate': new DateTime.now().toLocal().millisecondsSinceEpoch
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              }
                            );                            
                          },
                          child: new Column(
                            children: <Widget>[
                              new Icon(Icons.refresh),
                              new Text(AppLocalizations.of(context).recall)
                            ],
                          ),
                        ): new Text('')       
                      ],
                    ),
                    isThreeLine: true,
                    title: new Text(document['tokenLetter']+'-'+document['tokenNumber'].toString(), style: textTheme.title,),
                    subtitle: new Text(_counterText +'\n'+document['userPhone']),
                  );
                },
              );
            },
    );
  }

}
