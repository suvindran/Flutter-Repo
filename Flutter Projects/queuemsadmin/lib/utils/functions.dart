import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:queuemsadmin/common_widgets/my_bullet.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/models/company_data.dart';
import 'package:queuemsadmin/models/department_data.dart';
import 'package:queuemsadmin/models/counter_data.dart';
import 'package:queuemsadmin/models/holiday_data.dart';
import 'package:queuemsadmin/models/office_hours_data.dart';
import 'package:queuemsadmin/models/profile_data.dart';
import 'package:device_info/device_info.dart';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


Future<Null> assignLanguage() async {  
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  String lang = prefs.getString('lang');
  lang = (lang == null)?'en':lang;
  Logger.log("assignLanguage", message: 'lang is '+lang.toString());
  AppLocalizations.load(new Locale(lang, ""));
}

Future<FirebaseUser> currentUser() async {
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  return user;
}

String getYYYYMMDD(_date){
  var formatter = new DateFormat('yyyyMMdd');
  String formatted = formatter.format(_date);
  return formatted;
}

Future<CompanyData> loadCompany(companyKey) async {

  if (companyKey == null || companyKey == ''){
    return null;
  }

  DatabaseReference _companyRef = FirebaseDatabase.instance.reference().child('company');

  CompanyData company = new CompanyData();
  await _companyRef.child(companyKey).once().then((snapshot) {
    company.name = snapshot.value['name'];
    company.logo = snapshot.value['logo'];
    company.email = snapshot.value['email'];
    company.intervalTime = snapshot.value['intervalTime'];
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
  });
  return company;
}

Future<DepartmentData> loadDepartment(companyKey, depKey) async {

  DatabaseReference _departmentRef = FirebaseDatabase.instance.reference().child('department-'+companyKey);

  DepartmentData department = new DepartmentData();
  await _departmentRef.child(depKey).once().then((snapshot) {
    department.name = snapshot.value['name'];
    department.letter = snapshot.value['letter'];
    department.start = snapshot.value['start'];
    department.enable = snapshot.value['enable'];
  });
  return department;
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

Future<HolidayData> loadHoliday(storeKey, holidayKey) async {
  DatabaseReference _holidayRef = FirebaseDatabase.instance.reference().child('company').child(storeKey).child('holiday');

  HolidayData holiday = new HolidayData();
  await _holidayRef.child(holidayKey).once().then((snapshot) {
     holiday.key = snapshot.key;
     holiday.name = snapshot.value['name'];
     holiday.date = snapshot.value['date'];
     holiday.enable = snapshot.value['enable'];
  });
  return holiday;
}

Future<OfficeHoursData> loadOfficeHours(companyKey, officeHoursKey) async {

  DatabaseReference _officeHoursRef = FirebaseDatabase.instance.reference().child('company').child(companyKey).child('officeHours');

  OfficeHoursData officeHours = new OfficeHoursData();
  await _officeHoursRef.child(officeHoursKey).once().then((snapshot) {
    officeHours.startHour = snapshot.value['startHour'];
    officeHours.startMinute = snapshot.value['startMinute'];
    officeHours.endHour = snapshot.value['endHour'];
    officeHours.endMinute = snapshot.value['endMinute'];
    officeHours.name = snapshot.value['name'];
    officeHours.enable = snapshot.value['enable'];
    officeHours.mon = snapshot.value['mon'];
    officeHours.tues = snapshot.value['tues'];
    officeHours.wed = snapshot.value['wed'];
    officeHours.thurs = snapshot.value['thurs'];
    officeHours.fri = snapshot.value['fri'];
    officeHours.sat = snapshot.value['sat'];
    officeHours.sun = snapshot.value['sun'];
    officeHours.orderNum = snapshot.value['orderNum'];
  });
  return officeHours;
}

Future<CounterData> loadCounter(companyKey, counterKey) async {

  DatabaseReference _counterRef = FirebaseDatabase.instance.reference().child('counter-'+companyKey);

  CounterData counter = new CounterData();
  await _counterRef.child(counterKey).once().then((snapshot) {
    counter.name = snapshot.value['name'];
    counter.enable = snapshot.value['enable'];
  });
  return counter;
}

Future<ProfileData> loadProfile(phoneNumber) async {

  DatabaseReference _profileRef = FirebaseDatabase.instance.reference().child('profile');

  ProfileData profile = new ProfileData();
  await _profileRef.child(phoneNumber).once().then((snapshot) {
    if (snapshot != null){
        profile.platform = snapshot.value['platform'];
        profile.createdDate = snapshot.value['createdDate'];
        profile.disconnectDate = snapshot.value['disconnectDate'];
        profile.phone = snapshot.value['phone'];
        profile.online = snapshot.value['online'];
        profile.uid = snapshot.value['uid'];
        profile.distanceInMeter = snapshot.value['distanceInMeter'];
        profile.msgToken = snapshot.value['msgToken'];
        profile.authResult = snapshot.value['authResult'];
        profile.serverTimestampDistance = snapshot.value['serverTimestampDistance'];
    }
  });
  return profile;
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
                MyBullet(color: (conn)?Colors.green:Colors.red),
                SizedBox(width: 5.0),
                Text((conn)?'${AppLocalizations.of(context).online.toUpperCase()}':AppLocalizations.of(context).offline.toUpperCase()),
              ],
            ),
          ),          
        ],
      )
    );
  }
// Widget buildHeader(headerText) {
//     return new Container(
//       constraints: new BoxConstraints.expand(
//         height: 200.0,
//       ),
//       alignment: Alignment.centerLeft,
//       padding: new EdgeInsets.only(left: 36.0, bottom: 8.0),
//       decoration: new BoxDecoration(
//         image: new DecorationImage(
//           image: new AssetImage('assets/header.png'),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: new Text(headerText,
//         style: new TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 40.0,
//           color: Colors.white
//         )
//       ),
//     );
//   }

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

  void showEmptyCompanyToast(BuildContext context) { 
    Toast.show('You should select a store.', context,  duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
  }