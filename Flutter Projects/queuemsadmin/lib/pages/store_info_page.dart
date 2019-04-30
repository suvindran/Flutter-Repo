import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:queuemsadmin/utils/functions.dart';

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
  String _phone = '';
  String _coordinates = '';
  String _logo;

  @override
  void initState() {
    super.initState();
    loadCompany(widget.storeKey).then((store){
      setState(() {
        _name = store.name; 
        _address = store.address;  
        _email = store.email; 
        _phone = store.phone;
        _coordinates = store.lat.toString()+', '+store.lng.toString();
        _logo = store.logo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('Store Info'),
      ),
      body: new SingleChildScrollView(
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
                leading: new Icon(Icons.home),
                title: new Text('Store Name', style: textTheme.title),
                subtitle: new Text(_name),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: new Icon(Icons.map),
                title: new Text('Store Address', style: textTheme.title),
                subtitle: new Text(_address),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: new Icon(Icons.email),
                title: new Text('Email', style: textTheme.title),
                subtitle: new Text(_email),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: new Icon(Icons.phone),
                title: new Text('Phone', style: textTheme.title),
                subtitle: new Text(_phone),
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                dense: true,
                leading: new Icon(Icons.pin_drop),
                title: new Text('Coordinates', style: textTheme.title),
                subtitle: new Text(_coordinates),
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