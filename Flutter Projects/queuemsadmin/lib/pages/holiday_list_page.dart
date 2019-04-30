import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/pages/holiday_new_page.dart';

class HolidayListPage extends StatefulWidget {

  final String companyKey;

  HolidayListPage({this.companyKey});

  @override
  createState() => new HolidayListState();
}

class HolidayListState extends State<HolidayListPage> {

  static const String TAG = "HolidayListState";
  bool _anchorToBottom = false; 
  DatabaseReference _holidayRef;

  @override
  void initState() {
    super.initState();
    _holidayRef = FirebaseDatabase.instance.reference().child('company').child(widget.companyKey).child('holiday'); 
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).holidayList),
      ),
      floatingActionButton: new FloatingActionButton(
          tooltip: AppLocalizations.of(context).createHoliday,
          backgroundColor: Colors.blue,
          child: new Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    new HolidayNewPage(storeKey: widget.companyKey, holidayKey: null)
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
                  query: _holidayRef,
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
            ])),  
    );
  }

  Widget _item(DataSnapshot snapshot) {
    String key = snapshot.key;
    String name = snapshot.value['name'];
    int milliseconds = snapshot.value['date'];
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String s = DateFormat.yMMMd().format(date);
    return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new ListTile(
            leading: new Switch(
              value: snapshot.value['enable'],
              onChanged: (bool value) {
                _holidayRef.child(snapshot.key).update({
                  'enable': value
                });
            }),
            title: new Text(name),
            subtitle: new Text(s),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HolidayNewPage(storeKey: widget.companyKey, holidayKey: snapshot.key)),
              );
            },
            trailing: new Column(
              children: <Widget>[
                  new FlatButton(
                  padding: EdgeInsets.all(10.0),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          title: new Text(AppLocalizations.of(context).remove),
                          content: new Text(AppLocalizations.of(context).wantRemove),
                          actions: <Widget>[ 
                            new FlatButton(
                              child: new Text(AppLocalizations.of(context).ok),
                              onPressed: () {
                                _holidayRef.child(key).remove();
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
                      new Icon(Icons.delete),
                      new Text(AppLocalizations.of(context).remove)
                    ],
                  ),
                ),
              ],
            ),
          ));
  }
}