import 'dart:collection';

class CompanyData {
  String address = '';
  String email = '';
  int intervalTime = 0;
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
  bool selected = false;

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = new HashMap();
    map['address'] = address;
    map['email'] = email;
    map['intervalTime'] = intervalTime;
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
    map['uid'] = uid;
    map['selected'] = selected;
    return map;
  }
}