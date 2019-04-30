import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String MY_BASE_URL = 'https://wheref.com/';
const String MY_BASE_QUEUE_URL = 'https://queuems.wheref.com/';

class Texts {
  static const String APP_NAME = "QueueMS Client";
}

class PlatformQueue {
  static const String ADMIN = "admin";
  static const String CLIENT = "client";
}


class StatusAcronym {
  static const String ONWAIT = "W";
  static const String ONQUEUE = "Q";
  static const String COMPLETED = "C";
  static const String RECALL = "R";  
}

class Status {
  static const String ONWAIT = "onWait";
  static const String ONQUEUE = "onQueue";
  static const String COMPLETED = "completed";
  static const String RECALL = "recall";  
}

class StatusCode {
  static const int ONWAIT = 100;
  static const int ONQUEUE = 200;
  static const int RECALL = 300;  
  static const int COMPLETED = 400;
}

const List<Color> coolColors = const <Color>[
  const Color.fromARGB(255, 255, 59, 48),
  const Color.fromARGB(255, 255, 149, 0),
  const Color.fromARGB(255, 255, 204, 0),
  const Color.fromARGB(255, 76, 217, 100),
  const Color.fromARGB(255, 90, 200, 250),
  const Color.fromARGB(255, 0, 122, 255),
  const Color.fromARGB(255, 88, 86, 214),
  const Color.fromARGB(255, 255, 45, 85),
];