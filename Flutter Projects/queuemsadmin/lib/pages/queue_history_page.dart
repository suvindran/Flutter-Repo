import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/pages/loading_page.dart';
import 'package:queuemsadmin/pages/profile_page.dart';
import 'package:queuemsadmin/utils/constants.dart';

class QueueHistoryPage extends StatefulWidget {

  final String companyKey;
  final String tokenStatus;

  QueueHistoryPage({this.companyKey, this.tokenStatus});

  @override
  createState() => new QueueHistoryPageState();
}

class QueueHistoryPageState extends State<QueueHistoryPage> {

  static const String TAG = "QueueHistoryPageState";
  CollectionReference _tokenIssuedRef;

  @override
  void initState() {
    super.initState();
    _tokenIssuedRef = Firestore.instance.collection('tokenIssued');
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).showQueueHistory),
      ),
      body: _listQueueContainer()
    );
  }

  Widget _listQueueContainer() {

    final TextTheme textTheme = Theme.of(context).textTheme;
    
    return new StreamBuilder<QuerySnapshot>(
            stream: _tokenIssuedRef.orderBy('assignedDate', descending: true)
              .where('status', isEqualTo: widget.tokenStatus)
              .where('reset', isEqualTo: false)
              .where('companyKey', isEqualTo: widget.companyKey).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return new LoadingPage();
              if (snapshot.data.documents.length==0) {
                return new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new AssetImage('assets/empty_page.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              final int messageCount = snapshot.data.documents.length;
              Logger.log(TAG, message: messageCount.toString());
              return new ListView.builder(
                itemCount: messageCount,  
                itemBuilder: (_, int index) {
                  final DocumentSnapshot document = snapshot.data.documents[index];
                  String tokenNumber = document['tokenLetter']+'-'+document['tokenNumber'].toString();
                  int createdDate = document['createdDate'];
                  String status = document['status'];
                  String companyName = document['company']['name'];
                  double comLat = document['company']['lat'];
                  double comLng = document['company']['lng'];
                  String userPhone = document['userPhone'];
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
                  DateTime dateStart = new DateTime.fromMillisecondsSinceEpoch(createdDate);
                  DateTime dateEnd = new DateTime.now().toLocal();
                  Logger.log(TAG, message: tokenNumber+ ' dateStart is '+ dateStart.toIso8601String());
                  Logger.log(TAG, message: tokenNumber+ ' dateEnd is '+ dateEnd.toIso8601String());

                  String _counterText = (document['counterName'].toString().isEmpty)?'':AppLocalizations.of(context).counter+' '+document['counterName'];
                  String _momentText = '';
                  int sec = dateEnd.difference(dateStart).inSeconds;
                  Logger.log(TAG, message: 'sec is '+sec.toString());
                  if (sec >= 0 && sec < 60) {
                    _momentText = sec.toString() +' seconds';
                  } else if (sec >= 60 && sec < 60*60){
                    _momentText = dateEnd.difference(dateStart).inMinutes.toString()+' minutes';
                  } else if (sec >= 60*60 && sec < 60*60*24){
                    _momentText = dateEnd.difference(dateStart).inHours.toString()+' hours';
                  } else {
                    _momentText = dateEnd.difference(dateStart).inDays.toString()+' days';
                  }

                  return new ListTile(
                    leading: new Container(
                      height: 60.0,
                      width: 60.0,
                      decoration: new BoxDecoration(
                        color: coolColors.elementAt(index%8),
                        borderRadius: new BorderRadius.circular(8.0),
                      ),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(statusAcronym, style: TextStyle(fontSize: 35.0, color: Colors.white)),
                        ]
                      )
                    ),
                    onTap: (){
                      Navigator.push(context, new MaterialPageRoute(
                        builder: (BuildContext context) => new ProfilePage(comLat: comLat, comLng: comLng, phone: userPhone),
                      ));
                    },
                    isThreeLine: true,
                    title: new Text(tokenNumber, style: textTheme.title,),
                    subtitle: new Text('$_counterText[$_momentText ${AppLocalizations.of(context).ago}]\n${AppLocalizations.of(context).currentStore}: $companyName'),
                    trailing: Text('${index + 1}'),
                  );
                },
              );
            },
    );
  }
}