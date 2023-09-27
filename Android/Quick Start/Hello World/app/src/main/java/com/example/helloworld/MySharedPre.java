package com.example.helloworld;

import android.content.SharedPreferences;

public class MySharedPre {

    private SharedPreferences preferences;
    private String DEFAULT_APP_IMAGEDATA_DIRECTORY;
    private String lastImagePath = "";

    public MySharedPre(SharedPreferences preferences) {
        //preferences = PreferenceManager.getDefaultSharedPreferences(appContext);
        this.preferences = preferences;
    }

    public void putString(String key, String value) {
        preferences.edit().putString(key, value).apply();
    }

    public String getString(String key) {
        return preferences.getString(key, "");
    }

    public void putBoolean(String key, boolean value) {
        preferences.edit().putBoolean(key, value).apply();
    }

    public boolean getBoolean(String key) {
        return preferences.getBoolean(key, false);
    }

    public void clear() {
        preferences.edit().clear().apply();
    }
}
