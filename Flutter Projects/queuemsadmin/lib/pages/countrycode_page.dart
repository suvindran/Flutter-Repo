import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/pages/auth_page.dart';

class CountrycodePage extends StatefulWidget {
  @override
  createState() => new CountrycodePageState();
}

class CountrycodePageState extends State<CountrycodePage> {

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('my');

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:150.0, left:30.0, right: 30.0),
                  child: Card(
                    color: Colors.white.withOpacity(0.9),
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Banner(
                          color: Colors.orange,
                          location: BannerLocation.topEnd,
                          message: 'Paperless'
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(30.0),
                              child: Text(AppLocalizations.of(context).title, style: TextStyle(fontSize: 50.0)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(30.0),
                              child: Text('Pick Your Right Country'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left:30.0, right: 30.0),
                              child: ListTile(
                                onTap: _openCountryPickerDialog,
                                title: _buildDialogItem(_selectedDialogCountry),
                              ),
                            ),                        
                            Padding(
                              padding: EdgeInsets.all(30.0),
                              child: RaisedButton(
                              child: Text(AppLocalizations.of(context).submit),
                                onPressed: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                        AuthPage(country: _selectedDialogCountry)
                                    )
                                  );
                                },
                              )
                            ),
                          ],
                        )                        
                      ],
                  ))),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogItem(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      );

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: CountryPickerDialog(
                titlePadding: EdgeInsets.all(8.0),
                searchCursorColor: Colors.pinkAccent,
                searchInputDecoration: InputDecoration(hintText: 'Search...'),
                isSearchable: true,
                title: Text('Select your phone code'),
                onValuePicked: (Country country) =>
                    setState(() => _selectedDialogCountry = country),
                itemBuilder: _buildDialogItem)),
      );
}