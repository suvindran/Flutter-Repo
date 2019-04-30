import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/utils/constants.dart';

class AddPhoneDialog extends StatefulWidget {

  @override
  AddPhoneDialogState createState() => new AddPhoneDialogState();
}

class AddPhoneDialogState extends State<AddPhoneDialog> {

  static const String TAG = "AddPhoneDialog";
  final decorationStyle = TextStyle(color: Colors.black, fontSize: 16.0);
  final hintStyle = TextStyle(color: Colors.white24);
  TextEditingController phoneNumberController = TextEditingController();

  String _phoneCode = AUTH_PHONE_CODE;
  String _countryCode = AUTH_COUNTYRY_CODE;

  String _phone;
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(AppLocalizations.of(context).phone),
        actions: [
          new FlatButton(
              onPressed: () {                
                Logger.log(TAG, message: this._phone);
                Navigator
                    .of(context)
                    .pop(this._phone);
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
        padding: EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0),
        child: new SingleChildScrollView(    
          child: new Column(
            children: <Widget>[
              const SizedBox(height: 20.0),
              new Text(AppLocalizations.of(context).issueTokenAdminText),
              const SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  CountryPickerDropdown(
                    initialValue: _countryCode,
                    itemBuilder: _buildDropdownItem,
                    onValuePicked: (Country country) {
                      print("${country.phoneCode}");
                      setState(() {
                        _phoneCode = country.phoneCode;
                      });
                    },
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: new TextField(
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: 34.0, color: Colors.blue),
                      onChanged: (v)=>setState((){_phone='+$_phoneCode$v';}),
                      decoration: InputDecoration(
                        hintText: '161234567',
                        hintStyle: TextStyle(color: Colors.grey[300], fontSize: 24.0)
                      ),
                    ),
                  )
                  
                ],
              ),
              
            ],
          )            
        )
      ),
    );
  } 

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 5.0,
            ),
            Text("+${country.phoneCode}", style: decorationStyle),
          ],
        ),
      );
}