import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoverDeviceDialog extends StatefulWidget {
  

  DiscoverDeviceDialog({Key key}) : super(key: key);

  _DiscoverDeviceDialogState createState() => _DiscoverDeviceDialogState();
}

class _DiscoverDeviceDialogState extends State<DiscoverDeviceDialog> {

  static const String TAG = "_DiscoverDeviceDialogState";
  
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  Map<DeviceIdentifier, ScanResult> _scanResults = new Map();
  BluetoothDevice _selected; 

  @override
  void initState() {
     super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('${AppLocalizations.of(context).selectBluetoothPrinter}'),
        centerTitle: true,
      ),
      body:StreamBuilder(
        stream: _flutterBlue.scan(timeout: const Duration(seconds: 3)),
        builder: (BuildContext context, AsyncSnapshot<ScanResult> snapshot) {
          
          if (snapshot.data != null) {
            //_bluetoothDeviceList.add(snapshot.data.device);
            _scanResults[snapshot.data.device.id] = snapshot.data;
          }
          if (snapshot.hasError)
            return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.none: return Text('Select lot');
            case ConnectionState.waiting: return Text('Awaiting ...');
            case ConnectionState.active: return Center(child: CircularProgressIndicator());
            case ConnectionState.done: {
              return new ListView.builder(
                itemCount: _scanResults.keys.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  BluetoothDevice device = _scanResults.values.elementAt(index).device;
                  return ListTile(                    
                    leading: Icon(Icons.bluetooth),
                    title: new Text('${device.name}'),
                    subtitle: new Text('${device.id}'),
                    onTap: () async {
                      _selected = device;
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('bluetooth_device_name', _selected.name);
                      prefs.setString('bluetooth_device_id', _selected.id.id);
                      Navigator.of(context).pop();
                    },
                  );
                }
              );
            }
          }
        },
      )
    );
  }
}