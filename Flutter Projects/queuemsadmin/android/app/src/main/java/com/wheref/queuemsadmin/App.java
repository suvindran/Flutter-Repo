package com.wheref.queuemsadmin;

import io.flutter.app.FlutterApplication;
import android.content.Intent;
import android.content.Context;
import androidx.multidex.MultiDex;

public class App extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
}
