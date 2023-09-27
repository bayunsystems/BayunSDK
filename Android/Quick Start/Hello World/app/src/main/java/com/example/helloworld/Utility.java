package com.example.helloworld;

import android.content.Context;
import android.widget.Toast;

public class Utility {

    public static  String IS_LOGIN_DONE = "IS_LOGIN_DONE";

    public static void showToast(Context context, String message) {
        Toast.makeText(MyApplication.context, message, Toast.LENGTH_SHORT).show();
    }


}
