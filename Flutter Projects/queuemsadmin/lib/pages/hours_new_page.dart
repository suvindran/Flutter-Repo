import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:queuemsadmin/common_widgets/input_dropdown.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:queuemsadmin/models/office_hours_data.dart';
import 'package:queuemsadmin/pages/loading_page.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:flutter/src/material/dialog.dart' as Dialog;

class HoursNewPage extends StatefulWidget {

  final String officeHoursKey;
  final String companyKey;

  HoursNewPage({this.companyKey, this.officeHoursKey});

  @override
  createState() => new HoursNewPageState();
}

class HoursNewPageState extends State<HoursNewPage> {

  static const String TAG = "HoursNewPage";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final timeFormat = DateFormat("h:mm a");
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _orderNumController = new TextEditingController();
  
  DatabaseReference _officeHoursRef;
  int _startHour = 0;
  int _startMinute = 0;
  int _endHour = 0;
  int _endMinute = 0;
  bool _switchValue = false;
  String _startEndTimeText = 'Picker Start and End Time';
  bool _checkboxMon = true;
  bool _checkboxTues = true;
  bool _checkboxWed = true;
  bool _checkboxThurs = true;
  bool _checkboxFri = true;
  bool _checkboxSat = false;
  bool _checkboxSun = false;

  @override
  void initState() {
    super.initState();
    Logger.log(TAG, message: widget.companyKey);
    _officeHoursRef = FirebaseDatabase.instance.reference().child('company').child(widget.companyKey).child('officeHours');

    if (widget.officeHoursKey != null) {
      loadOfficeHours(widget.companyKey, widget.officeHoursKey).then((officeHours){
        _nameController.text = officeHours.name;
        _orderNumController.text = officeHours.orderNum.toString();
        TimeOfDay startTime = new TimeOfDay(hour: officeHours.startHour, minute: officeHours.startMinute);
        TimeOfDay endTime = new TimeOfDay(hour: officeHours.endHour, minute: officeHours.endMinute);
        setState(() {
          _switchValue = officeHours.enable;

          _startHour = officeHours.startHour;
          _startMinute = officeHours.startMinute;
          _endHour = officeHours.endHour;
          _endMinute = officeHours.endMinute;
          _checkboxMon = officeHours.mon;
          _checkboxTues = officeHours.tues;
          _checkboxWed = officeHours.wed;
          _checkboxThurs = officeHours.thurs;
          _checkboxFri = officeHours.fri;
          _checkboxSat = officeHours.sat;
          _checkboxSun = officeHours.sun;

          _startEndTimeText =  startTime.format(context)+' to '+ endTime.format(context);  
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).officeHoursForm),
        actions: [
          new FlatButton(
              onPressed: () {                
                OfficeHoursData timePair = new OfficeHoursData();
                timePair.name = _nameController.text;
                timePair.startHour = _startHour;
                timePair.startMinute = _startMinute;
                timePair.endHour = _endHour;
                timePair.endMinute = _endMinute;
                timePair.enable = _switchValue;
                timePair.mon = _checkboxMon;
                timePair.tues = _checkboxTues;
                timePair.wed = _checkboxWed;
                timePair.thurs = _checkboxThurs;
                timePair.fri = _checkboxFri;
                timePair.sat = _checkboxSat;
                timePair.sun = _checkboxSun;
                timePair.orderNum = int.parse(_orderNumController.text);

                if (_formKey.currentState.validate()) {
                  _handleSubmit(timePair);
                  Navigator
                    .of(context)
                    .pop();
                }            
              },
              child: new Text(AppLocalizations.of(context).save,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: (_switchValue != null)?new Container(
        margin: EdgeInsets.all(20.0),
        child: new SingleChildScrollView(
          child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                const SizedBox(height: 20.0),
                new Text(AppLocalizations.of(context).enableOfficeHours),
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
                    hintText: 'What is the office hours name?',
                    labelText: 'Name *',
                  ),
                ),
                const SizedBox(height: 20.0),
                new InputDropdown(
                  labelText: 'Time Range',
                  valueText: _startEndTimeText,
                  onPressed: () => showPickerDateRange(context),
                ),               
                const SizedBox(height: 20.0),
                _buildCheckbox(_checkboxMon, AppLocalizations.of(context).monday),
                _buildCheckbox(_checkboxTues, AppLocalizations.of(context).tuesday),
                _buildCheckbox(_checkboxWed, AppLocalizations.of(context).wednesday),
                _buildCheckbox(_checkboxThurs, AppLocalizations.of(context).thursday),
                _buildCheckbox(_checkboxFri, AppLocalizations.of(context).friday),
                _buildCheckbox(_checkboxSat, AppLocalizations.of(context).saturday),
                _buildCheckbox(_checkboxSun, AppLocalizations.of(context).sunday),
                new TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _orderNumController,
                  decoration: const InputDecoration(
                    border: const UnderlineInputBorder(),
                    icon: const Icon(Icons.text_fields),
                    hintText: 'What is the order number?',
                    labelText: 'Order Number',
                  ),
                ),
              ],
            ),
          ),
        )
      ): new LoadingPage());
  }

  Widget _buildCheckbox(bool checkboxValue, String text){

    return new Row(
      children: <Widget>[
        new Checkbox(        
          value: checkboxValue,
          onChanged: (bool value) {
            Logger.log(TAG, message: text +' '+value.toString());
            setState(() {
              if (text == AppLocalizations.of(context).monday) {
                _checkboxMon = value;
              }
              if (text == AppLocalizations.of(context).tuesday) {
                _checkboxTues = value;
              }
              if (text == AppLocalizations.of(context).wednesday) {
                _checkboxWed = value;
              }
              if (text == AppLocalizations.of(context).thursday) {
                _checkboxThurs = value;
              }
              if (text == AppLocalizations.of(context).friday) {
                _checkboxFri = value;
              }
              if (text == AppLocalizations.of(context).saturday) {
                _checkboxSat = value;
              }
              if (text == AppLocalizations.of(context).sunday) {
                _checkboxSun = value;
              }
            });
          },
        ),
        new Text(text)
    ]);
  }

  _handleSubmit(OfficeHoursData officeHours){
    Logger.log(TAG, message: 'SAVE '+officeHours.toString());

    if (widget.officeHoursKey == null){
      DatabaseReference pushed = _officeHoursRef.push();
      String key = pushed.key;
      pushed.set({
        'key': key,
        'name': officeHours.name,
        'startHour': officeHours.startHour,
        'startMinute': officeHours.startMinute,
        'endHour': officeHours.endHour,
        'endMinute': officeHours.endMinute,
        'enable': officeHours.enable,
        'mon': officeHours.mon,
        'tues': officeHours.tues,
        'wed': officeHours.wed,
        'thurs': officeHours.thurs,
        'fri': officeHours.fri,
        'sat': officeHours.sat,
        'sun': officeHours.sun,
        'orderNum': officeHours.orderNum,
        'serverTimestamp': ServerValue.timestamp,
      });
    } else {
      _officeHoursRef.child(widget.officeHoursKey).update({
        'name': officeHours.name,
        'startHour': officeHours.startHour,
        'startMinute': officeHours.startMinute,
        'endHour': officeHours.endHour,
        'endMinute': officeHours.endMinute,
        'enable': officeHours.enable,
        'mon': officeHours.mon,
        'tues': officeHours.tues,
        'wed': officeHours.wed,
        'thurs': officeHours.thurs,
        'fri': officeHours.fri,
        'sat': officeHours.sat,
        'sun': officeHours.sun,
        'orderNum': officeHours.orderNum,
        'serverTimestamp': ServerValue.timestamp,
      });
    }    
  }

 

  
  showPickerDateRange(BuildContext context) {
 
    DateTime now = new DateTime.now().toLocal();

    Picker ps = new Picker(
        hideHeader: true,
        adapter: new DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: new DateTime(now.year, now.month, now.day, _startHour, _startMinute)),
        onConfirm: (Picker picker, List value) {
          DateTime startDateTime = (picker.adapter as DateTimePickerAdapter).value;
          setState(() {
            _startHour = startDateTime.hour;         
            _startMinute = startDateTime.minute;
          });
        }
    );

    Picker pe = new Picker(
        hideHeader: true,
        adapter: new DateTimePickerAdapter(type: PickerDateTimeType.kHM, value: new DateTime(now.year, now.month, now.day, _endHour, _endMinute)),
        onConfirm: (Picker picker, List value) {
          DateTime startDateTime = (picker.adapter as DateTimePickerAdapter).value;
          setState(() {
            _endHour = startDateTime.hour;         
            _endMinute = startDateTime.minute;
          });
        }
    );

    List<Widget> actions = [
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text('Cancel')),
      FlatButton(
          onPressed: () {
            DateTime startDateTime = (ps.adapter as DateTimePickerAdapter).value;
            DateTime endDateTime = (pe.adapter as DateTimePickerAdapter).value;
            var f = new DateFormat.Hm();
            setState(() {
              _startEndTimeText =  f.format(startDateTime)+' to '+ f.format(endDateTime);          
            });
            Navigator.pop(context);
            ps.onConfirm(ps, ps.selecteds);
            pe.onConfirm(pe, pe.selecteds);
          },
           child: new Text('Confirm')),
    ];

    Dialog.showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text("Select Time Range"),
            actions: actions,
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Begin Time:"),
                  ps.makePicker(),
                  Text("End Time:"),
                  pe.makePicker()
                ],
              ),
            ),
          );
        });
  }
}