package com.bayun.app;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;

import com.bayun.database.ActivityDBHelper;
import com.bayun.database.DatabaseManager;
import com.bayun.util.Constants;
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

    @Override
    public void onCreate() {
        super.onCreate();
        appContext = getApplicationContext();
        settings = getSharedPreferences(Constants.APP_NAME, MODE_PRIVATE);
        tinyDB = new TinyDB(settings);
        DatabaseManager.initializeInstance(ActivityDBHelper.getInstance());
        bayunCore = new BayunCore(appContext);
    }

    /**
     * Clears stored data in shared preferences.
     */
    public static void clearDB() {
        tinyDB.putString(Constants.SHARED_PREFERENCES_LOGGED_IN, Constants.SHARED_PREFERENCES_DEFAULT_VALUE);
        tinyDB.remove(Constants.SHARED_PREFERENCES_ACCESS_TOKEN);
        tinyDB.remove(Constants.SHARED_PREFERENCES_REFRESH_TOKEN);
        tinyDB.remove(Constants.SHARED_PREFERENCES_USERNAME);
        tinyDB.remove(Constants.SHARED_PREFERENCES_EXTENSION);
        tinyDB.remove(Constants.SHARED_PREFERENCES_PASSWORD);
        tinyDB.remove(Constants.SHARED_PREFERENCES_ACCOUNT_ID);
        tinyDB.remove(Constants.SHARED_PREFERENCES_ACCESS_TOKEN_EXPIRATION_TIME);
    }

}
