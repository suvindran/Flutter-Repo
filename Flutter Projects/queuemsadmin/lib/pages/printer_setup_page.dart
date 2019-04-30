import 'dart:async';

import 'package:flutter/material.dart';
import 'package:queuemsadmin/common_widgets/discover_device_dialog.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsprinter/queuemsprinter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PrinterPaperWidth { printer58mm, printer80mm }

class PrinterSetupPage extends StatefulWidget {

  PrinterSetupPage({Key key}) : super(key: key);

  _PrinterSetupPageState createState() => _PrinterSetupPageState();
}

class _PrinterSetupPageState extends State<PrinterSetupPage> {

  static const String TAG = "_PrinterSetupPageState";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static const STATUS_CONNECTED = 'Connected';
  static const STATUS_DISCONNECT = 'Disconnect';
  static const STATUS_CONNECTING = 'Connecting...';

  String _bluetoothName = '';
  String _bluetoothId = '';
  String _connection;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs){
      String name = prefs.getString('bluetooth_device_name');
      String id = prefs.getString('bluetooth_device_id');
      Queuemsprinter.checkConnection().then((connected){
        setState(() {
          if (connected){
            _connection = STATUS_CONNECTED;
          } else {
            _connection = STATUS_DISCONNECT;
          }
        });
      });
      if (mounted){
        setState(() {
          _bluetoothName = name;
          _bluetoothId = id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(AppLocalizations.of(context).setupBluetoothPrinter),
        ),
        body:SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: ListBody(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.bluetooth),
                title: Text('${AppLocalizations.of(context).discoverBluetooth}'),
                subtitle: Text('$_bluetoothName\n$_bluetoothId'),
                isThreeLine: true,
                onTap: () async{
                  await Navigator.of(context).push(new MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return DiscoverDeviceDialog();
                    },
                    fullscreenDialog: true
                  ));
                  SharedPreferences.getInstance().then((prefs){
                    String name = prefs.getString('bluetooth_device_name');
                    String id = prefs.getString('bluetooth_device_id');
                    setState(() {
                      _bluetoothName = name;
                      _bluetoothId = id;
                    });
                  });
                },
              ),
              RaisedButton(
                child: Text(AppLocalizations.of(context).connect),
                onPressed: () async{

                  bool connected = await Queuemsprinter.connect(_bluetoothId);

                  Timer timer = new Timer.periodic(new Duration(seconds: 2), (timer) async {
                    connected = await Queuemsprinter.checkConnection();
                    Logger.log(TAG, message: 'LOOP connect is $connected');
                    if (connected){
                      if (mounted) {
                        setState(() {
                          _connection = STATUS_CONNECTED; 
                        });
                      }
                    } else {
                      connected = await Queuemsprinter.connect(_bluetoothId);
                      if (mounted) {
                        setState(() {
                          _connection = STATUS_CONNECTING; 
                        });
                      }
                    }
                    
                  });

                  new Timer(new Duration(seconds: 10), () {
                    timer.cancel();
                  });
                },
              ),
              RaisedButton(
                child: Text(AppLocalizations.of(context).disconnect),
                onPressed: () async{

                  bool connected = await Queuemsprinter.disconnect();
                  Logger.log(TAG, message: 'disconnect is ${!connected}');
                  if (connected==false) {
                    setState(() {
                      _connection = STATUS_DISCONNECT; 
                    });
                  }
                },
              ),
              RaisedButton(
                child: Text(AppLocalizations.of(context).testPrinting),
                onPressed: () async{
                  if (await Queuemsprinter.checkConnection()) {
                    await Queuemsprinter.printToken('Z', '9999');
                  } else {
                    _showDialog();
                  }
                },
              ),
              Text('${AppLocalizations.of(context).connection}: ${(_connection==null)?'':_connection}'),
            ],
          ),
        )
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(AppLocalizations.of(context).testPrinting),
          content: new Text(AppLocalizations.of(context).cannotPrint),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations.of(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}