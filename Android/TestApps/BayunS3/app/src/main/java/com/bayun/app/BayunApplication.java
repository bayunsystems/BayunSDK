package com.bayun.app;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;

import com.bayun.util.Constants;
import com.bayun.util.TinyDB;
import com.bayun_module.BayunCore;

/**
 * Created by Gagan on 02/06/15.
 */

public class BayunApplication extends Application {

    public static Context appContext;
    public static SharedPreferences settings;
    public static volatile Handler applicationHandler = null;
    public static BayunCore bayunCore;
    public static TinyDB tinyDB;

    @Override
    public void onCreate() {
        super.onCreate();
        appContext = getApplicationContext();
        settings = getSharedPreferences(Constants.APP_NAME, MODE_PRIVATE);
        tinyDB = new TinyDB(settings);
        bayunCore = new BayunCore(appContext);
        applicationHandler = new Handler(appContext.getMainLooper());
    }

}
