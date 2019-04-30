import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/pages/home_page.dart';
import 'package:queuemsclient/pages/store_info_page.dart';
import 'package:queuemsclient/pages/token_issue_page.dart';

class StoreListPage extends StatefulWidget {

  final FirebaseUser user;
  final BuildContext ctx;

  StoreListPage({this.user, this.ctx});

  @override
  createState() => new StoreListPageState();
}

class StoreListPageState extends State<StoreListPage> {

  static const String TAG = "StoreListPage";

  DatabaseReference _companyRef;
  bool _anchorToBottom = false;

  @override
  void initState() {
    super.initState();
    _companyRef = FirebaseDatabase.instance.reference().child('company');
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new HomePage(),
        ));
      },
      child: Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(widget.ctx).availableStore),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.of(context).pop();
          }
        ),
      ),      
      body: new Container(
        margin: EdgeInsets.all(20.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
                child: new FirebaseAnimatedList(
                  key: new ValueKey<bool>(_anchorToBottom),
                  query: _companyRef.orderByChild('selected').equalTo(true),
                  reverse: _anchorToBottom,
                  sort: _anchorToBottom
                      ? (DataSnapshot a, DataSnapshot b) =>
                          b.key.compareTo(a.key)
                      : null,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    return new SizeTransition(
                      sizeFactor: animation,
                      child: _item(snapshot),
                    );
                  },
                ),
              )
          ]
        )
      )
    ));
  }

   Widget _item(DataSnapshot snapshot) {
    return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new ListTile(
            leading: Image.network(snapshot.value['logo'], height: 20.0,),
            title: new Text(snapshot.value['name']),
            subtitle: new Text('${snapshot.value['address']}\n${snapshot.value['timezoneText']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TokenIssuePage(user: widget.user, companyKey: snapshot.value['key'], ctx: widget.ctx)
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StoreInfoPage(storeKey: snapshot.value['key'])
                  ),
                );
              },
            ),
          ));
  }
}