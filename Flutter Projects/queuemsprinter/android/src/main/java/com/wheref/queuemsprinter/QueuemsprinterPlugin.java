package com.wheref.queuemsprinter;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.os.StrictMode;

import com.android.print.sdk.PrinterConstants;
import com.android.print.sdk.PrinterInstance;

import com.google.gson.Gson;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** QueuemsprinterPlugin */
public class QueuemsprinterPlugin implements MethodCallHandler {

  private static ExecutorService cachedThreadPool = Executors.newCachedThreadPool();
  private static PrintfManager manager;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "queuemsprinter");
    channel.setMethodCallHandler(new QueuemsprinterPlugin());

    if (android.os.Build.VERSION.SDK_INT > 9) {
      StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
      StrictMode.setThreadPolicy(policy);
    }
    manager = PrintfManager.getInstance(registrar.context());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    boolean connected = false;
    switch (call.method) {
      case "printToken":
        String tokenLetter = call.argument("tokenLetter");
        String tokenNumber = call.argument("tokenNumber");
        try {
          manager.printToken(tokenLetter, tokenNumber);
          result.success(null);
        } catch (Exception e) {
          result.error("printOrderError", e.getMessage(), null);
        }
        break; 
      case "checkConnection":
        connected = manager.checkConnection();
        result.success(connected);
        break;
      case "connect":
        final String address = call.argument("address");
        connected = manager.connect(address);
        result.success(connected);
        break;
      case "disconnect":
        connected = manager.disconnect();
        result.success(connected);
        break;
      default:
        result.notImplemented();
      }
    }
  
}
