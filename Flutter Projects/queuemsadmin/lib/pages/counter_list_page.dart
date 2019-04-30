import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/pages/counter_new_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:queuemsadmin/pages/more_page.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:queuemsadmin/logger.dart';

class CounterListPage extends StatefulWidget {

  final CompanyData company;

  CounterListPage({this.company});

  @override
  createState() => new CounterListPageState();
}

class CounterListPageState extends State<CounterListPage> {

  static const String TAG = "CounterListPage";

  DatabaseReference _counterRef;
  bool _anchorToBottom = false;
  String uid;

  @override
  void initState() {
    super.initState();
    currentUser().then((user) {
      Logger.log(TAG, message: 'user is ' + user.uid);
      this.uid = user.uid;
    });
    _counterRef = FirebaseDatabase.instance.reference().child('counter-'+widget.company.key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(AppLocalizations.of(context).counterList),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.push(context, new MaterialPageRoute(
                builder: (BuildContext context) => new MorePage(company: widget.company),
              ));
            }
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          tooltip: AppLocalizations.of(context).createCounter,
          backgroundColor: Colors.blue,
          child: new Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CounterNewPage(company: widget.company, counterKey: null)
              ),
            );
          },
        ),
        body: new Container(
            margin: EdgeInsets.all(20.0),
            child: new Column(children: <Widget>[
              new Flexible(
                child: new FirebaseAnimatedList(
                  key: new ValueKey<bool>(_anchorToBottom),
                  query: _counterRef,
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
            ])));
  }

  Widget _item(DataSnapshot snapshot) {
    bool enable = snapshot.value['enable'];
    return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new ListTile(
            leading: new Switch(
              value: (enable==null)?false:enable,
              onChanged: (bool value) {
                _counterRef.child(snapshot.key).update({
                  'enable': value
                });
            }),
            title: new Text(snapshot.value['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CounterNewPage(company:widget.company, counterKey: snapshot.key)),
              );
            },
          ));
  }
}
