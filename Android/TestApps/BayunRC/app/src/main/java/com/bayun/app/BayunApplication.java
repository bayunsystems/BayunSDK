package com.bayun.app;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;

import com.bayun.database.ActivityDBHelper;
import com.bayun.database.DatabaseManager;
import com.bayun.util.Constants;
import com.bayun.util.RCCryptManager;
import com.bayun.util.TinyDB;
import com.bayun_module.BayunCore;

/**
 * Created by Gagan on 02/06/15.
 */

public class BayunApplication extends Application {

    public static Context appContext;
    public static TinyDB tinyDB;
    public static SharedPreferences settings;
    public static BayunCore bayunCore;
    public static RCCryptManager rcCryptManager;

    @Override
    public void onCreate() {
        super.onCreate();
        appContext = getApplicationContext();
        settings = getSharedPreferences(Constants.APP_NAME, MODE_PRIVATE);
        tinyDB = new TinyDB(settings);
        DatabaseManager.initializeInstance(ActivityDBHelper.getInstance());
        rcCryptManager=new RCCryptManager();
        bayunCore = new BayunCore(appContext);
    }
}

