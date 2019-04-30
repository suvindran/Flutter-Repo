import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/pages/hours_new_page.dart';

class HoursListPage extends StatefulWidget {

  final String companyKey;

  HoursListPage({this.companyKey});

  @override
  createState() => new HoursListState();
}

class HoursListState extends State<HoursListPage> {

  static const String TAG = "HoursListState";
  bool _anchorToBottom = false; 
  DatabaseReference _officeHoursRef;

  @override
  void initState() {
    super.initState();
    _officeHoursRef = FirebaseDatabase.instance.reference().child('company').child(widget.companyKey).child('officeHours'); 
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).officeHoursList),
      ),
      floatingActionButton: new FloatingActionButton(
          tooltip: AppLocalizations.of(context).createOfficeHours,
          backgroundColor: Colors.blue,
          child: new Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    new HoursNewPage(companyKey: widget.companyKey, officeHoursKey: null)
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
                  query: _officeHoursRef,
                  reverse: _anchorToBottom,
                  sort: (DataSnapshot a, DataSnapshot b) =>
                          a.value['orderNum'].compareTo(b.value['orderNum']),
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

    final TextTheme textTheme = Theme.of(context).textTheme;

    String key = snapshot.key;
    String name = snapshot.value['name'];
    TimeOfDay startTime = new TimeOfDay(hour: snapshot.value['startHour'], minute: snapshot.value['startMinute']);
    TimeOfDay endTime = new TimeOfDay(hour: snapshot.value['endHour'], minute: snapshot.value['endMinute']);

    List<String> days = new List();
    days.add((snapshot.value['mon'])?'MON':null);
    days.add((snapshot.value['tues'])?'TUES':null);
    days.add((snapshot.value['wed'])?'WED':null);
    days.add((snapshot.value['thurs'])?'THURS':null);
    days.add((snapshot.value['fri'])?'FRI':null);
    days.add((snapshot.value['sat'])?'SAT':null);
    days.add((snapshot.value['sun'])?'SUN':null);
    days.removeWhere((item) => item == null);
    String s = startTime.format(context) +' to '+ endTime.format(context)+'\n'+days.join('|');
    return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new ListTile(
            leading: new Switch(
              value: snapshot.value['enable'],
              onChanged: (bool value) {
                _officeHoursRef.child(snapshot.key).update({
                  'enable': value
                });
            }),
            title: new Text(name, style: textTheme.title),
            subtitle: new Text(s),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HoursNewPage(companyKey: widget.companyKey, officeHoursKey: snapshot.key)),
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
                                _officeHoursRef.child(key).remove();
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