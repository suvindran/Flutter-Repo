import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:queuemsadmin/common_widgets/input_dropdown.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:queuemsadmin/models/holiday_data.dart';
import 'package:queuemsadmin/utils/functions.dart';

class HolidayNewPage extends StatefulWidget {

  final String storeKey;
  final String holidayKey;

  HolidayNewPage({this.storeKey, this.holidayKey});

  @override
  createState() => new HolidayNewPageState();
}

class HolidayNewPageState extends State<HolidayNewPage> {

  static const String TAG = "HolidayNewPage";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = new TextEditingController();
  DatabaseReference _holidayRef;
  bool _switchValue = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Logger.log(TAG, message: widget.storeKey);
    _holidayRef = FirebaseDatabase.instance.reference().child('company').child(widget.storeKey).child('holiday');

    if (widget.holidayKey != null) {
      loadHoliday(widget.storeKey, widget.holidayKey).then((holiday){
        _nameController.text = holiday.name;
        _switchValue = holiday.enable;
        _selectedDate = new DateTime.fromMillisecondsSinceEpoch(holiday.date);

        setState(() {
          _switchValue = holiday.enable;       
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final TextStyle valueStyle = Theme.of(context).textTheme.title;

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).holidayForm),
        actions: [
          new FlatButton(
              onPressed: () {                
                HolidayData holiday = new HolidayData();
                holiday.name = _nameController.text;
                holiday.enable = _switchValue;
                holiday.date = _selectedDate.millisecondsSinceEpoch;

                if (_formKey.currentState.validate()) {
                  _handleSubmit(holiday);
                  Navigator
                    .of(context)
                    .pop();
                }            
              },
              child: Text(AppLocalizations.of(context).save,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: new Container(
        margin: EdgeInsets.all(20.0),
        child: new SingleChildScrollView(
          child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                const SizedBox(height: 20.0),
                new Text(AppLocalizations.of(context).enableHolidayText),
                const SizedBox(height: 20.0),
                new Switch(
                  value: _switchValue,
                  onChanged: (bool value) async{
                    setState(() {
                      _switchValue = value;
                  });
                }),
                const SizedBox(height: 20.0),
                new TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterSomeText;
                    }
                  },
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: const UnderlineInputBorder(),
                    icon: const Icon(Icons.text_fields),
                    hintText: 'What is the holiday name?',
                    labelText: 'Name *',
                  ),
                ),            
                const SizedBox(height: 20.0), 
                new InputDropdown(
                  labelText: AppLocalizations.of(context).holidayDate,
                  valueText: DateFormat.yMMMd().format(_selectedDate),
                  valueStyle: valueStyle,
                  onPressed: () { _selectDate(context); },
                ),               
              ],
            ),
          ),
        )
      ));
  }

  _handleSubmit(HolidayData holiday){
    Logger.log(TAG, message: 'SAVE '+holiday.toString());

    if (widget.holidayKey == null){
      DatabaseReference pushed = _holidayRef.push();
      String key = pushed.key;
      pushed.set({
        'key': key,
        'name': holiday.name,
        'date': holiday.date,
        'enable': holiday.enable,
        'serverTimestamp': ServerValue.timestamp,
      });
    } else {
      _holidayRef.child(widget.holidayKey).update({
        'name': holiday.name,
        'date': holiday.date,
        'enable': holiday.enable,
        'serverTimestamp': ServerValue.timestamp,
      });
    }    
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101)
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
         _selectedDate = picked;     
      });
  }

}