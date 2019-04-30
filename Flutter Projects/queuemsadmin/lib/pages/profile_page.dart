import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:queuemsadmin/models/profile_data.dart';
import 'package:queuemsadmin/pages/loading_page.dart';
import 'package:queuemsadmin/utils/functions.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {

  final double comLat;
  final double comLng;
  final String phone;

  ProfilePage({this.comLat, this.comLng, this.phone});

  @override
  createState() => new ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  static const String TAG = "ProfilePageState";

  ProfileData _profile;
  DateTime now = new DateTime.now().toLocal();

  String _phone;
  String _distanceInMeter;
  String _captured;
  String _online;

  @override
  void initState() {
    super.initState();

    loadProfile(widget.phone).then((profile) {
      setState(() {
        _profile = profile;
      });
      Logger.log(TAG, message: '${profile.phone} compLat is ${widget.comLat}, compLng is ${widget.comLng}');

      String online = (_profile.online)?AppLocalizations.of(context).online:AppLocalizations.of(context).offline;
      String phone = _profile.phone;

      DatabaseReference profileGPSHistoryRef;
      String formatted = getYYYYMMDD(now);
      profileGPSHistoryRef = FirebaseDatabase.instance.reference().child('/profileGPSHistory-'+formatted); 
      profileGPSHistoryRef.orderByChild('phone').equalTo(phone).limitToLast(1).once().then((snapshot) {
        double distanceInMeters = 0.0;
        int distanceCreatedDate = 0;
        if (snapshot.value != null){
          snapshot.value.forEach((d, e) async{
            double lat = e['lat'];
            double lng = e['lng'];
            distanceCreatedDate = e['localCreatedDate'];
            Logger.log(TAG, message: lat.toString()+','+lng.toString());
            distanceInMeters = await Geolocator().distanceBetween(widget.comLat, widget.comLng, lat, lng);
            Logger.log(TAG, message: 'distanceInMeters is $distanceInMeters');

            String distanceInMeter = '${NumberFormat.compact().format(distanceInMeters)} ${AppLocalizations.of(context).meter} ${AppLocalizations.of(context).away}';
            String captured = '${AppLocalizations.of(context).captured} '+ Moment.fromMillisecondsSinceEpoch(distanceCreatedDate).fromNow()+' ${AppLocalizations.of(context).ago}';

            setState(() {
              _phone = phone;
              _distanceInMeter = distanceInMeter;
              _captured = captured;
              _online =online;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(AppLocalizations.of(context).userProfile),
      ),
      body: (_distanceInMeter != null)?new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: new Icon(Icons.phone),
                title: new Text((_phone!=null)?_phone:'', style: textTheme.title),
                trailing: new Text(AppLocalizations.of(context).callNow.toUpperCase()),
                onTap: (){
                  _launchURL('tel:$_phone');
                },
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: new Icon(Icons.directions),
                title: new Text((_distanceInMeter!=null)?_distanceInMeter:'', style: textTheme.title),
              ),
               new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: new Icon(Icons.alarm),
                title: new Text((_captured!=null)?_captured:'', style: textTheme.title),
              ),
               new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: new Icon(Icons.person),
                title: new Text((_online!=null)?_online:'', style: TextStyle(color: (_profile.online)?Colors.green:Colors.red, fontSize: 20.0)),
              ),
            ]
          )
        ): new LoadingPage()
      );
  }

  _launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
}