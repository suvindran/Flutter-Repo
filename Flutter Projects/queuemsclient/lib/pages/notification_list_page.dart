import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/logger.dart';
import 'package:queuemsclient/utils/functions.dart';

class NotificationListPage extends StatefulWidget {

  final FirebaseUser user;
  final BuildContext ctx;
  NotificationListPage({this.user, this.ctx});

  @override
  createState() => new NotificationListPageState(user: user);
}

class NotificationListPageState extends State<NotificationListPage> {

  static const String TAG = "NotificationListPage";

  DatabaseReference _notificationRef;
  bool _anchorToBottom = false;
  FirebaseUser user;
  DateTime _now = new DateTime.now().toLocal();

  NotificationListPageState({this.user});


  @override
  void initState() {
    super.initState();
    _notificationRef = FirebaseDatabase.instance.reference().child('notification');
    
  }

  @override
  Widget build(BuildContext context) {

    String formatted = getYYYYMMDD(_now);
    String phoneNformattedDate = user.phoneNumber+'|-|'+ formatted;
    Logger.log(TAG, message: phoneNformattedDate);

    return Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(AppLocalizations.of(widget.ctx).subscribe+'/'+AppLocalizations.of(widget.ctx).unsubscribe),
        ),
        body: new Container(
            margin: EdgeInsets.all(20.0),
            child: new Column(children: <Widget>[
              new Flexible(
                child: new FirebaseAnimatedList(
                  key: new ValueKey<bool>(_anchorToBottom),
                  query: _notificationRef.orderByChild('phoneNformattedDate').equalTo(phoneNformattedDate),
                  reverse: _anchorToBottom,
                  sort: (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key),
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    return new SizeTransition(
                      sizeFactor: animation,
                      child: _item(snapshot),
                    );
                  },
                ),
              )
            ])));
  }

  Widget _item(DataSnapshot snapshot) {
    if (snapshot.value==null) {
      return new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/empty_page.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    bool _enabled = snapshot.value['isSubscribed'];
    String companyName = snapshot.value['company']['name'];
    String depName = snapshot.value['depName'];
    String topic = snapshot.value['topic'];
    FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
    
    return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new MergeSemantics(
          child: new ListTile(
            leading: const Icon(Icons.event_seat),
            title: new Text(companyName),
            subtitle: new Text(depName),
            trailing: new CupertinoSwitch(
              value: _enabled,
              onChanged: (bool value) { 
                setState(() { _enabled = value; }); 
                _notificationRef.child(snapshot.key).update({
                 'isSubscribed': value
               });  
               Logger.log(TAG, message: topic+' is '+ value.toString());
               if (value == true){
                 firebaseMessaging.subscribeToTopic(topic);
               } else {
                 firebaseMessaging.unsubscribeFromTopic(topic);
               }
              },
            ),
          ),
        )
    );
  }
}
