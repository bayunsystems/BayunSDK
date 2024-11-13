package com.bayun.app;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.StrictMode;

import com.bayun.R;
import com.bayun.S3wrapper.SecureAuthentication;
import com.bayun.thirdParty.TinyDB;
import com.bayun.util.Constants;
import com.bayun_module.BayunCore;
import com.bayun_module.configuration.BayunConfiguration;

/**
 * Created by Gagan on 02/06/15.
 */
public class BayunApplication extends Application {
    public static Context appContext;
    public static SharedPreferences settings;
    public static volatile Handler applicationHandler = null;
    public static BayunCore bayunCore;
    public static TinyDB tinyDB;
    public static SecureAuthentication secureAuthentication;
    public static boolean isDeviceLock = false;


    @Override
    public void onCreate() {
        super.onCreate();
        appContext = getApplicationContext();
        settings = getSharedPreferences(Constants.APP_NAME, MODE_PRIVATE);
        tinyDB = new TinyDB(settings);

        bayunCore =
                new BayunCore(appContext,  getResources().getString(R.string.base_url),getResources().getString(R.string.bayun_server_public_key), getResources().getString(R.string.app_id),
                getResources().getString(R.string.app_secret), getResources().getString(R.string.app_salt), BayunApplication.isDeviceLock );
        applicationHandler = new Handler(appContext.getMainLooper());
        secureAuthentication = SecureAuthentication.getInstance();
        secureAuthentication.setContext(appContext);
        secureAuthentication.setAppId(getResources().getString(R.string.app_id));
        secureAuthentication.setAppSecret(getResources().getString(R.string.app_secret));
        // NEW ADDED CODE
        secureAuthentication.setApplicationKeySalt(getResources().getString(R.string.app_salt));
        BayunCore.configure(new BayunConfiguration(BayunConfiguration.TracingStatus.DISABLED));
        // NEW ADDED CODE - END

        StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
        StrictMode.setVmPolicy(builder.build());
    }

}

