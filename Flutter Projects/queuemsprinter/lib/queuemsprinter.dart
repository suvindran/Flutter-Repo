import 'dart:async';

import 'package:flutter/services.dart';

class Queuemsprinter {
  static const MethodChannel _channel =
      const MethodChannel('queuemsprinter');

  static Future<void> printToken(String tokenLetter, String tokenNumber) async {
    await _channel.invokeMethod('printToken', <String, dynamic>{
        'tokenLetter': tokenLetter,
        'tokenNumber': tokenNumber
      });
  }

  static Future<bool> connect(String address) async {
    return await _channel.invokeMethod('connect', <String, dynamic>{
        'address': address,
      });
  }

  static Future<bool> disconnect() async {
    return await _channel.invokeMethod('disconnect');
  }

  static Future<bool> checkConnection() async {
    return await _channel.invokeMethod('checkConnection');
  }
}
