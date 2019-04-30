import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/models/counter_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:queuemsadmin/pages/counter_list_page.dart';
import 'package:queuemsadmin/pages/loading_page.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:queuemsadmin/utils/validation_function.dart';

class CounterNewPage extends StatefulWidget {

  final String counterKey;
  final CompanyData company;

  CounterNewPage({this.company, this.counterKey});

  @override
  createState() => new CounterNewPageState();
}

class CounterNewPageState extends State<CounterNewPage> {

  static const String TAG = "CounterNewPage";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>(); 
  DatabaseReference _counterRef;
  bool _autovalidate = false;
  String _uid;
  CounterData _counter;

  CounterNewPageState();

  @override
  void initState() {
    super.initState();
    Logger.log(TAG, message: widget.counterKey);
    currentUser().then((user) {
      Logger.log(TAG, message: 'user is ' + user.uid);
      setState(() {
        _uid = user.uid;
      });      
    });
    _counterRef = FirebaseDatabase.instance.reference().child('counter-'+widget.company.key);

    if (widget.counterKey != null) {
       loadCounter(widget.company.key, widget.counterKey).then((counter) {
          setState(() {
            _counter = counter;
          });
       });
    } else {
      setState(() {
        _counter = new CounterData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).counterForm),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(context, new MaterialPageRoute(
              builder: (BuildContext context) => new CounterListPage(company: widget.company),
            ));
          }
        ),
      ),
      body: (_counter != null)?new Container(
        margin: EdgeInsets.all(20.0),
        child: new Form(
                key: _formKey,
                autovalidate: _autovalidate,
                child: new SingleChildScrollView(
                  child: new Column(
          children: <Widget>[
            new TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: const Icon(Icons.apps),
                      hintText: 'What is the counter name?',
                      labelText: 'Name *',
                    ),
                    initialValue: _counter.name,
                    onSaved: (String value) {
                      _counter.name = value;
                    },
                    validator: (value)=> validateInt(value),
                  ),
                  new Center(
                    child: new RaisedButton(
                      child: Text(AppLocalizations.of(context).submit),
                      onPressed: _handleSubmitted,
                    ),
                  ),
          ]
                  )
        )
        )
      ): new LoadingPage());
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      
      if (widget.counterKey == null) {
        DatabaseReference pushed = _counterRef.push();
        String key = pushed.key;
        pushed.set({
          'key': key,
          'name': _counter.name,
          'uid': _uid,
          'enable': false,
          'companyKey': widget.company.key,
          'createdDate': new DateTime.now().toLocal().millisecondsSinceEpoch
        });
      } else {
        _counterRef.child(widget.counterKey).update({
          'name': _counter.name,
          'uid': _uid,
          'enable': _counter.enable,
          'modifiedDate': new DateTime.now().toLocal().millisecondsSinceEpoch
        });
      }
      Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new CounterListPage(company: widget.company),
      ));
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}