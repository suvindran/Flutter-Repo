import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/pages/department_list_page.dart';
import 'package:queuemsadmin/pages/loading_page.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:queuemsadmin/models/department_data.dart';
import 'package:queuemsadmin/utils/validation_function.dart';

class DepartmentNewPage extends StatefulWidget {
  final String depKey;
  final CompanyData company;

  DepartmentNewPage({this.company, this.depKey});

  @override
  createState() => new DepartmentNewPageState();
}

class DepartmentNewPageState extends State<DepartmentNewPage> {
  static const String TAG = "DepartmentNewPage";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  DepartmentData _department;
  DatabaseReference _departmentRef;
  String uid;

  @override
  void initState() {
    super.initState();
    Logger.log(TAG, message: widget.depKey);
    currentUser().then((user) {
      Logger.log(TAG, message: 'user is ' + user.uid);
      this.uid = user.uid;
    });
    
    _departmentRef = FirebaseDatabase.instance.reference().child('department-'+widget.company.key);

    if (widget.depKey != null) {
       loadDepartment(widget.company.key, widget.depKey).then((department) {
          setState(() {
            _department = department;
          });
       });
    } else {
      setState(() {
        _department = new DepartmentData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(AppLocalizations.of(context).departmentForm),
          leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(context, new MaterialPageRoute(
              builder: (BuildContext context) => new DepartmentListPage(company: widget.company),
            ));
          }
        ),
        ),
        body: (_department != null)?new Container(
            margin: EdgeInsets.all(20.0),
            child: new Form(
                key: _formKey,
                autovalidate: _autovalidate,
                child: new SingleChildScrollView(
                    child: new Column(children: <Widget>[
                  new TextFormField(
                    keyboardType: TextInputType.text,  
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: const Icon(Icons.apps),
                      hintText: 'What is the department name?',
                      labelText: 'Name *',
                    ),
                    initialValue: _department.name,
                    onSaved: (String value) {
                      _department.name = value;
                    },
                    validator: (value)=>validateNotEmpty(value),
                  ),
                  const SizedBox(height: 24.0),
                  new TextFormField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: const Icon(Icons.apps),
                      hintText: 'What is the department letter?',
                      labelText: 'Letter *',
                    ),
                    initialValue: _department.letter,
                    onSaved: (String value) {
                      _department.letter = value;
                    },
                    validator: (value)=>validateStringMax(value, 2),
                  ),
                  const SizedBox(height: 24.0),
                  new TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: const Icon(Icons.apps),
                      hintText: 'What is the department start number?',
                      labelText: 'Start *',
                    ),
                    initialValue: _department.start.toString(),
                    onSaved: (String value) {
                      _department.start = int.parse(value);
                    },
                    validator: (value)=>validateInt(value),
                  ),
                  new Center(
                    child: new RaisedButton(
                      child: Text(AppLocalizations.of(context).submit),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                ])))):new LoadingPage());
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      
      if (widget.depKey == null) {
        DatabaseReference pushed = _departmentRef.push();
        String key = pushed.key;
        pushed.set({
          'key': key,
          'name': _department.name,
          'letter': _department.letter,
          'start': _department.start,
          'uid': this.uid,
          'enable': false,
          'companyKey': widget.company.key,
          'createdDate': new DateTime.now().toLocal().millisecondsSinceEpoch
        });
      } else {
        _departmentRef.child(widget.depKey).update({
          'name': _department.name,
          'letter': _department.letter,
          'start': _department.start,
          'uid': this.uid,
          'enable': _department.enable,
          'modifiedDate': new DateTime.now().toLocal().millisecondsSinceEpoch
        });
      }
      Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new DepartmentListPage(company: widget.company),
      ));
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  
}
