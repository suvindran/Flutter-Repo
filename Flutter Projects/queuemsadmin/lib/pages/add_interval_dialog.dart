import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';

class AddIntervalDialog extends StatefulWidget {

  final String companyKey;

  AddIntervalDialog({this.companyKey});

  @override
  AddIntervalDialogState createState() => new AddIntervalDialogState();
}

class AddIntervalDialogState extends State<AddIntervalDialog> {

  static const String TAG = "AddIntervalDialog";
  TextEditingController _intervalController = TextEditingController();
  DatabaseReference _companyRef;
  int _interval = 0;
  
  @override
  void initState() {
    super.initState(); 

    Logger.log(TAG, message: 'Company Key is ${widget.companyKey}');
    _companyRef = FirebaseDatabase.instance.reference().child('company').child(widget.companyKey);  
    _companyRef.once().then((snapshot){
      _interval = snapshot.value['intervalTime'];
      if (_interval != null) { 
        _intervalController.text = _interval.toString(); 
      }     
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(AppLocalizations.of(context).timeIntervalToIssueToken),
        actions: [
          new FlatButton(
              onPressed: () {                
                Logger.log(TAG, message: _intervalController.text);
                Navigator
                    .of(context)
                    .pop(double.parse(_intervalController.text));
              },
              child: new Text(AppLocalizations.of(context).save,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: new Container(
        padding: EdgeInsets.only(top: 0.0, left: 70.0, right: 70.0),
        child: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              const SizedBox(height: 20.0),
              new Text(AppLocalizations.of(context).timeIntervalToIssueTokenText),
              const SizedBox(height: 20.0),
              new TextField(
                controller: _intervalController,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 24.0, color: Colors.blue),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).timeInterval,
                  hintText: AppLocalizations.of(context).timeIntervalHint,
                  hintStyle: TextStyle(color: Colors.grey[300], fontSize: 20.0)
                ),
              ),
            ],
          ),
        )
      ),
    );
  } 
}