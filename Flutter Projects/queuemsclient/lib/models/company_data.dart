import 'dart:collection';

import 'package:queuemsclient/models/beacons_data.dart';
import 'package:queuemsclient/models/holiday_data.dart';
import 'package:queuemsclient/models/office_hours_data.dart';

class CompanyData {
  String address = '';
  String email = '';
  double lat = 0.0;
  double lng = 0.0;
  String logo = '';
  String name = '';
  String phone = '';
  String uid = '';
  double timezone = 0;
  String timezoneValue;
  String timezoneAbbr;
  bool timezoneIsdst;
  String timezoneText;
  String key = '';
  int intervalTime = 0;
  bool selected;
  List<OfficeHoursData> officeHoursList;
  List<OfficeHoursData> officeHoursAllList;
  List<HolidayData> holidayList;
  List<BeaconsData> beaconsList;

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = new HashMap();
    map['address'] = address;
    map['email'] = email;
    map['lat'] = lat;
    map['lng'] = lng;
    map['logo'] = logo;
    map['name'] = name;
    map['phone'] = phone;
    map['timezone'] = timezone;
    map['timezoneValue'] = timezoneValue;
    map['timezoneAbbr'] = timezoneAbbr;
    map['timezoneIsdst'] = timezoneIsdst;
    map['timezoneText'] = timezoneText;
    map['key'] = key;
    map['selected'] = selected;
    map['uid'] = uid;
    map['intervalTime'] = intervalTime;
    return map;
  }
}