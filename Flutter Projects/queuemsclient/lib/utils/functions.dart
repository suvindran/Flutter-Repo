import 'dart:async';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:queuemsclient/common_widgets/my_bullet.dart';
import 'package:queuemsclient/localizations.dart';
import 'package:queuemsclient/models/beacons_data.dart';
import 'package:queuemsclient/models/company_data.dart';
import 'package:queuemsclient/logger.dart';
import 'package:queuemsclient/models/holiday_data.dart';
import 'package:queuemsclient/models/office_hours_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Null> assignLanguage() async {  
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  String lang = prefs.getString('lang');
  lang = (lang == null)?'en':lang;
  Logger.log("assignLanguage", message: 'lang is '+lang.toString());
  AppLocalizations.load(new Locale(lang, ""));
}

Future<void> signOut() async{
  await FirebaseAuth.instance.signOut();
}

Future<FirebaseUser> currentUser() async {
  return await FirebaseAuth.instance.currentUser();
}

String getYYYYMMDD(_date){
  var formatter = new DateFormat('yyyyMMdd');
  String formatted = formatter.format(_date);
  return formatted;
}

Future<CompanyData> loadCompany(companyKey) async {

  DatabaseReference _companyRef = FirebaseDatabase.instance.reference().child('company');

  CompanyData company = new CompanyData();
  await _companyRef.child(companyKey).once().then((snapshot) {
    company.name = snapshot.value['name'];
    company.logo = snapshot.value['logo'];
    company.email = snapshot.value['email'];
    company.key = snapshot.value['key'];
    company.lat = (snapshot.value['lat'] is int)?snapshot.value['lat'] + .0: snapshot.value['lat'];
    company.lng = (snapshot.value['lng'] is int)?snapshot.value['lng'] + .0: snapshot.value['lng'];
    company.phone = snapshot.value['phone'];
    company.timezone = (snapshot.value['timezone'] is int)?snapshot.value['timezone'] + .0:snapshot.value['timezone'];
    company.timezoneValue = snapshot.value['timezoneValue'];
    company.timezoneAbbr = snapshot.value['timezoneAbbr'];
    company.timezoneText = snapshot.value['timezoneText'];
    company.timezoneIsdst = snapshot.value['timezoneIsdst'];
    company.selected = snapshot.value['selected'];
    company.uid = snapshot.value['uid'];
    company.address = snapshot.value['address'];
    company.intervalTime = snapshot.value['intervalTime'];
    
    // handle officeHours
    List<OfficeHoursData> hoursAllList = new List();
    List<OfficeHoursData> hoursList = new List();
    if (snapshot.value['officeHours'] != null) {
      snapshot.value['officeHours'].forEach((k,v) {
        OfficeHoursData officeHours = new OfficeHoursData();
        officeHours.enable = v['enable'];
        officeHours.name = v['name'];
        officeHours.startHour = v['startHour'];
        officeHours.startMinute = v['startMinute'];
        officeHours.endHour = v['endHour'];
        officeHours.endMinute = v['endMinute'];
        officeHours.mon = v['mon'];
        officeHours.tues = v['tues'];
        officeHours.wed = v['wed'];
        officeHours.thurs = v['thurs'];
        officeHours.fri = v['fri'];
        officeHours.sat = v['sat'];
        officeHours.sun = v['sun'];
        officeHours.key = v['key'];
        officeHours.orderNum = v['orderNum'];
        hoursAllList.add(officeHours); 
        if (v['enable']) {
          hoursList.add(officeHours); 
        }    
      });
    }
    company.officeHoursList = hoursList;
    company.officeHoursAllList = hoursAllList;
    // end

    // handle holiday
    List<HolidayData> holidayList = new List();
    if (snapshot.value['holiday'] != null) {
      snapshot.value['holiday'].forEach((k,v) {
        HolidayData holiday = new HolidayData();
        holiday.enable = v['enable'];
        holiday.name = v['name'];
        holiday.date = v['date'];
        holiday.key = v['key'];
        holidayList.add(holiday);      
      });
    }
    company.holidayList = holidayList;
    // end

    // hanlde beacons
    List<BeaconsData> beaconsList = new List();
    if (snapshot.value['beacons'] != null) {
      snapshot.value['beacons'].forEach((k,v) {
        BeaconsData beacons = new BeaconsData();
        beacons.enable = v['enable'];
        beacons.name = v['name'];
        beacons.udid = v['udid'];
        beacons.major = v['major'];
        beacons.minor = v['minor'];
        beacons.key = v['key'];
        beaconsList.add(beacons);      
      });
    }
    company.beaconsList = beaconsList;
    // end
  });
  return company;
}

// GET Device Info  
Future<Map<String, dynamic>> getDeviceData() async {
  
  DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  Map<String, dynamic> deviceData = new HashMap();

  try {
    if (Platform.isAndroid) {
      deviceData = readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      deviceData = readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  } on PlatformException {
    deviceData = <String, dynamic>{
      'Error:': 'Failed to get platform version.'
    };
  }

  return deviceData;
  
}
// end

Future<PermissionStatus> requestPermission() async{
  PermissionGroup permissionGroup = PermissionGroup.location;
  PermissionStatus status;

  bool isShown = await PermissionHandler().shouldShowRequestPermissionRationale(permissionGroup); 
  Logger.log('requestPermission', message: 'isShown is $isShown');
  if (isShown == true) {
    return null;
  } else { 
    do {  
      isShown = await PermissionHandler().shouldShowRequestPermissionRationale(permissionGroup);
      if (isShown == true){
        return null;
      } else {
        Logger.log('requestPermission', message: 'isShown22 is $isShown'); 
        Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([permissionGroup]);
        status = permissions[permissionGroup];
      }
    } while (status == PermissionStatus.denied);
  }
    
  return status;
}

Future<StreamSubscription<Position>> subscribeGPS(FirebaseUser user) async{

  StreamSubscription<Position> positionStreamSubscription;

  Geolocator geolocator = Geolocator();
  PermissionStatus status =await requestPermission();
  Logger.log('subscribeGPS', message:'status is $status');

  if (status == PermissionStatus.granted){
    Logger.log('subscribeGPS', message: 'uid is '+ user.uid);
    DatabaseReference profileGPSHistoryRef;
    DateTime now = new DateTime.now().toLocal();
    String formatted = getYYYYMMDD(now);
    profileGPSHistoryRef = FirebaseDatabase.instance.reference().child('/profileGPSHistory-'+formatted);

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1);


    Stream<Position> positionStream = geolocator.getPositionStream(locationOptions);
    Logger.log('subscribeGPS', message: 'isBroadcast is ${positionStream.isBroadcast}');
    if (positionStream.isBroadcast == false) {
      positionStreamSubscription = positionStream.listen((Position position) async {
        if (position != null) {
          Logger.log('subscribeGPS', message: 'position is $position');
          DatabaseReference pushed = profileGPSHistoryRef.push();
          String key = pushed.key;
          double lat = position.latitude;
          double lng = position.longitude;
          pushed.set({
            'key': key,
            'uid': user.uid,
            'phone': user.phoneNumber,
            'lat': lat,
            'lng': lng,
            'alt': position.altitude,
            'localCreatedDate': now.millisecondsSinceEpoch,
            'serverCreatedDate': ServerValue.timestamp
          });
        }
      });
    }
  } else if (status == null){
    return null;
  }
  return positionStreamSubscription;
}

void updateUserOnlineStatus(user){
  DatabaseReference profileRef = FirebaseDatabase.instance.reference().child('/profile');
    
  profileRef.child(user.phoneNumber).update({
    'online': true,
  });
  profileRef.child(user.phoneNumber).onDisconnect().update({
    'online': false,
    'disconnectDate': ServerValue.timestamp,
  });
}

void updateMessageToken(user){
  
  DateTime now = new DateTime.now().toLocal();
  DatabaseReference profileRef = FirebaseDatabase.instance.reference().child('profile');
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) {
      //Logger.log(TAG, message: 'on message $message');
    },
    onResume: (Map<String, dynamic> message) {
      //Logger.log(TAG, message: 'on resume $message');
    },
    onLaunch: (Map<String, dynamic> message) {
      //Logger.log(TAG, message: 'on launch $message');
    },
  );
  firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true));
  firebaseMessaging.getToken().then((token){
    //Logger.log(TAG, message: token);
    profileRef.child(user.phoneNumber).update({
      'msgToken' : token,
      'createdDate': now.toLocal().millisecondsSinceEpoch, 
    });
  });
}

Widget buildHeader(headerText, resultConnect, context) {

    Logger.log('buildHeader', message: 'resultConnect is $resultConnect');
    bool conn = (resultConnect!=null)?resultConnect: false;
    
    return new Container(
      constraints: new BoxConstraints.expand(
        height: 140.0,
      ),
      alignment: Alignment.centerLeft,
      padding: new EdgeInsets.only(left: 16.0, bottom: 8.0),
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage('assets/header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(height: 10.0),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(headerText,
              style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
                color: Colors.white
              )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right:10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MyBullet(color: conn?Colors.green:Colors.red),
                SizedBox(width: 5.0),
                Text(conn?'${AppLocalizations.of(context).online.toUpperCase()}':AppLocalizations.of(context).offline.toUpperCase()),
              ],
            ),
          ),          
        ],
      )
    );
  }

  Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version_securityPatch': build.version.securityPatch,
      'version_sdkInt': build.version.sdkInt,
      'version_release': build.version.release,
      'version_previewSdkInt': build.version.previewSdkInt,
      'version_incremental': build.version.incremental,
      'version_codename': build.version.codename,
      'version_baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
    };
  }

  Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname_sysname:': data.utsname.sysname,
      'utsname_nodename:': data.utsname.nodename,
      'utsname_release:': data.utsname.release,
      'utsname_version:': data.utsname.version,
      'utsname_machine:': data.utsname.machine,
    };
  }