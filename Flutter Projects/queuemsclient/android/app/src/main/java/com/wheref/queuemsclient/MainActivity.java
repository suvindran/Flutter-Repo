package com.wheref.queuemsclient;

import android.content.Context;
import android.content.Intent;
import android.location.LocationManager;
import android.location.LocationProvider;
import android.os.Bundle;
import 	android.bluetooth.BluetoothAdapter;
import android.provider.Settings;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }
}
