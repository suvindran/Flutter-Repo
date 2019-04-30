import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/pages/loading_page.dart';
import 'package:queuemsclient/utils/functions.dart';

class StoreInfoPage extends StatefulWidget {

  final String storeKey;

  StoreInfoPage({this.storeKey});

  @override
  createState() => new StoreInfoPageState();
}

class StoreInfoPageState extends State<StoreInfoPage> {

  String _name = '';
  String _address = '';
  String _email = '';
  String _coordinates = '';
  String _logo;
  String _timezoneText;

  @override
  void initState() {
    super.initState();
    loadCompany(widget.storeKey).then((store){
      setState(() {
        _name = store.name; 
        _address = store.address;  
        _email = store.email; 
        _coordinates = store.lat.toString()+', '+store.lng.toString();
        _logo = store.logo;
        _timezoneText = store.timezoneText;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final globalKey = new GlobalKey<ScaffoldState>();

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: globalKey,
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('Store Info'),
      ),
      body: (_timezoneText==null)? new LoadingPage(): new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Container(
                height: 10.0,
              ),
              (_logo!=null)?Image.network(_logo, height: 100.0,): const SizedBox(height: 0.0),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: Icon(Icons.store),
                title: Text(AppLocalizations.of(context).store, style: textTheme.title),
                subtitle: Text(_name),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: Icon(Icons.map),
                title: Text(AppLocalizations.of(context).address, style: textTheme.title),
                subtitle: Text(_address),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: Icon(Icons.email),
                title: Text(AppLocalizations.of(context).email, style: textTheme.title),
                subtitle: Text(_email),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: Icon(Icons.pin_drop),
                title: Text(AppLocalizations.of(context).coordinates, style: textTheme.title),
                subtitle: Text(_coordinates),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: Icon(Icons.timelapse),
                title: Text(AppLocalizations.of(context).timezone, style: textTheme.title),
                subtitle: Text(_timezoneText),
              ),
              new Divider(
                height: 20.0,
              ),
            ]
          )
      )
    );
  }
}