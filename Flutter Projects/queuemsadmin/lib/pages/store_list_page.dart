import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:queuemsadmin/common_widgets/dialog_action_item.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/pages/more_page.dart';
import 'package:queuemsadmin/pages/store_new_page.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/utils/functions.dart';

class StoreListPage extends StatefulWidget {

  final FirebaseUser user;

  StoreListPage({this.user});

  @override
  createState() => new StoreListPageState();
}

class StoreListPageState extends State<StoreListPage> {

  static const String TAG = "StoreListPage";

  DatabaseReference _companyRef;
  bool _anchorToBottom = false;
  String uid;
  CompanyData _checkedStore;

  @override
  void initState() {
    super.initState();
    Logger.log(TAG, message: 'user is ' + widget.user.uid);
    _companyRef = FirebaseDatabase.instance.reference().child('company');

    // set the selected default company
    _companyRef.orderByChild('phone').equalTo(widget.user.phoneNumber).once().then((snapshot) {
      String selected = '';
      if (snapshot.value != null) {
        snapshot.value.forEach((d, e){
          if (e['selected'] == true){
            selected = d;
          }
        });
      }

      loadCompany(selected).then((data){
        setState(() {
          _checkedStore = data;
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new MorePage(company: _checkedStore),
        ));
      },
      child: Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).storeList),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(context, new MaterialPageRoute(
              builder: (BuildContext context) => new MorePage(company: _checkedStore),
            ));
          }
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Create Store',
        backgroundColor: Colors.blue,
        child: new Icon(Icons.add),
        onPressed: (){
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StoreNewPage(user: widget.user, storeKey: null)),
          );
        },
      ),
      body: new Container(
        margin: EdgeInsets.all(20.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
                child: new FirebaseAnimatedList(
                  key: new ValueKey<bool>(_anchorToBottom),
                  query: _companyRef.orderByChild('phone').equalTo(widget.user.phoneNumber),
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
            leading: (_checkedStore != null && _checkedStore.key==snapshot.value['key'])?Icon(Icons.radio_button_checked):Icon(Icons.radio_button_unchecked),
            title: new Text(snapshot.value['name']),
            subtitle: new Text(snapshot.value['address']),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx){
                  return SimpleDialog(
                    title: Text('Options'),
                    children: <Widget>[
                      DialogActionItem(
                          icon: Icons.check,
                          color: Colors.blue,
                          text: AppLocalizations.of(context).enableThisStore,
                          onPressed: () async{
                            String key = snapshot.value['key'];
                            Logger.log(TAG, message: 'Check me KEY  is $key');
                            _companyRef.orderByChild('phone').equalTo(widget.user.phoneNumber).once().then((snapshot) {
                              snapshot.value.forEach((d, e){
                                _companyRef.child(d).update({
                                  'selected': false,
                                  'modifiedDate': new DateTime.now().toLocal().millisecondsSinceEpoch
                                });
                              });

                              _companyRef.child(key).update({
                                'selected': true,
                                'modifiedDate': new DateTime.now().toLocal().millisecondsSinceEpoch
                              });
                            });

                            loadCompany(snapshot.value['key']).then((data){
                              setState(() {
                                _checkedStore = data;
                              });
                            });
                            
                            Navigator.of(ctx).pop();
                          }
                      ),
                      DialogActionItem(
                          icon: Icons.edit,
                          color: Colors.blue,
                          text: AppLocalizations.of(context).edit,
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StoreNewPage(user: widget.user, storeKey: snapshot.value['key'])),
                            );
                          }
                      ),
                    ],
                  );
                }
              );
            },
          ));
  }
}