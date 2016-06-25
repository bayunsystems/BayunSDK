package com.bayun.util;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Handler;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;

import java.util.Calendar;

/**
 * Created by Gagan on 01-06-2015.
 */
public class Utility {

    private static AlertDialog.Builder builder;
    private static AlertDialog alertDialog;

    /**
     * Display Message using toast.
     *
     * @param message
     * @param toastLength
     */
    public static void displayToast(String message, int toastLength) {
        Toast toast = Toast.makeText(BayunApplication.appContext, message, toastLength);
        toast.show();
    }

    /**
     * Checks if Network is available or not
     *
     * @return
     */
    public static boolean isNetworkAvailable() {
        ConnectivityManager connectivity = (ConnectivityManager) BayunApplication.appContext
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivity != null) {
            NetworkInfo activeNetwork = connectivity.getActiveNetworkInfo();
            if (null != activeNetwork && activeNetwork.isConnected()) {
                return true;
            }
        }
        return false;
    }

    /**
     * Creates progress dialog
     *
     * @param ctx
     * @param message
     * @return
     */
    public static ProgressDialog createProgressDialog(Context ctx, String message) {
        ProgressDialog progressDialog = new ProgressDialog(ctx);
        progressDialog.setMessage(message);
        progressDialog.setCanceledOnTouchOutside(false);
        progressDialog.setCancelable(false);
        return progressDialog;
    }

    /**
     * Show message alert for certain duration
     *
     * @param context
     * @param message
     */
    public static void messageAlertForCertainDuration(Context context, String message) {
        alertDialog = new AlertDialog.Builder(context, AlertDialog.THEME_HOLO_LIGHT).create();
        alertDialog.setMessage(message);
        alertDialog.show();
        TextView messageText = (TextView) alertDialog.findViewById(android.R.id.message);
        messageText.setGravity(Gravity.CENTER);
        // Hide after some seconds
        final Handler handler = new Handler();
        final Runnable runnable = new Runnable() {
            @Override
            public void run() {
                if (alertDialog != null) {
                    if (alertDialog.isShowing()) {
                        alertDialog.dismiss();
                    }
                }
            }
        };
        handler.postDelayed(runnable, 5000);
    }

    /**
     * Hide soft keyboard on button event
     *
     * @param view
     */
    public static void hideKeyboard(View view) {
        InputMethodManager inputManager = (InputMethodManager)
                BayunApplication.appContext.getSystemService(Context.INPUT_METHOD_SERVICE);
        inputManager.hideSoftInputFromWindow(view.getWindowToken(),
                InputMethodManager.HIDE_NOT_ALWAYS);
    }
}




