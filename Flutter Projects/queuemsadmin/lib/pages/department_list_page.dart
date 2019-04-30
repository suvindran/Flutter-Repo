import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/pages/department_new_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:queuemsadmin/pages/more_page.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:queuemsadmin/logger.dart';

class DepartmentListPage extends StatefulWidget {

  final CompanyData company;

  DepartmentListPage({this.company});

  @override
  createState() => new DepartmentListPageState();
}

class DepartmentListPageState extends State<DepartmentListPage> {

  static const String TAG = "DepartmentListPage";

  DatabaseReference _departmentRef;
  bool _anchorToBottom = false;
  String uid;

   @override
  void initState() {
    super.initState();
    currentUser().then((user) {
      Logger.log(TAG, message: 'user is ' + user.uid);
      this.uid = user.uid;
    });
    
    _departmentRef = FirebaseDatabase.instance.reference().child('department-'+widget.company.key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(AppLocalizations.of(context).departmentList),
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
          tooltip: AppLocalizations.of(context).createDepartment,
          backgroundColor: Colors.blue,
          child: new Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DepartmentNewPage(company:widget.company, depKey: null)),
            );
          },
        ),
        body: new Container(
            margin: EdgeInsets.all(20.0),
            child: new Column(children: <Widget>[
              new Flexible(
                child: new FirebaseAnimatedList(
                  key: new ValueKey<bool>(_anchorToBottom),
                  query: _departmentRef,
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
                _departmentRef.child(snapshot.key).update({
                  'enable': value
                });
            }),
            isThreeLine: true,
            title: new Text(snapshot.value['name']),
            subtitle: new Text('${AppLocalizations.of(context).letter}: '+snapshot.value['letter']+'\n${AppLocalizations.of(context).start}: '+ snapshot.value['start'].toString()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DepartmentNewPage(company:widget.company, depKey: snapshot.key)),
              );
            },
          ));
  }
}
