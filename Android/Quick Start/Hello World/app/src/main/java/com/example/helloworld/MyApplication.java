package com.example.helloworld;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;

import com.bayun_module.BayunCore;

public class MyApplication extends Application {
    public static final String MyPREFERENCES = "MyPrefs" ;
    public static BayunCore bayunCore;
    public static Context context;
    public static SharedPreferences sharedpreferences;
    public static MySharedPre mySharedPre;


    @Override
    public void onCreate() {
        super.onCreate();
        context =getApplicationContext();
        bayunCore =new BayunCore(context,
                context.getResources().getString(R.string.baseurl),
                context.getResources().getString(R.string.appId),
                context.getResources().getString(R.string.appSecret),
                context.getResources().getString(R.string.appSalt),
                true
                );


        bayunCore =new BayunCore(context,
                context.getResources().getString(R.string.baseurl),
                context.getResources().getString(R.string.appId),
                context.getResources().getString(R.string.appSecret),
                context.getResources().getString(R.string.appSalt),
                true
        );

        sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);

        mySharedPre = new MySharedPre(sharedpreferences);


    }
}
