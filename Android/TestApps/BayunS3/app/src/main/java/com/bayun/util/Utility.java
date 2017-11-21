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

import com.bayun.app.BayunApplication;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

/**
 * Created by Gagan on 01-06-2015.
 */
public class Utility {

    private static AlertDialog.Builder builder;
    private static AlertDialog alertDialog;

    /**
     * Show user information by toast.
     *
     * @param message
     * @param toastLength
     */
    public static void displayToast(String message, int toastLength) {

        Toast toast = Toast.makeText(BayunApplication.appContext, message, toastLength);
        toast.show();
    }

    /**
     * Check if network is available or not
     *
     * @return True/False.
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
     * Create Progress dialog.
     *
     * @param context Context.
     * @param message Message.
     * @return progressDialog object.
     */
    public static ProgressDialog createProgressDialog(Context context, String message) {
        ProgressDialog progressDialog = new ProgressDialog(context);
        progressDialog.setMessage(message);
        progressDialog.setCanceledOnTouchOutside(false);
        progressDialog.setCancelable(false);
        return progressDialog;
    }

    /**
     * Create Progress dialog.
     *
     * @param context Context.
     * @param message Message.
     * @return progressDialog object.
     */
    public static ProgressDialog createFileProgressDialog(Context context, String message) {
        ProgressDialog progressDialog = new ProgressDialog(context);
        progressDialog.setMessage(message);
        progressDialog.setCanceledOnTouchOutside(false);
        progressDialog.setCancelable(false);
        progressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
        progressDialog.setProgress(0);
        progressDialog.setMax(100);
        return progressDialog;
    }

    /**
     * Show message alert for certain duration.
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

    public static void RunOnUIThread(Runnable runnable) {
        BayunApplication.applicationHandler.post(runnable);
    }

    /**
     * Hide soft keyboard.
     *
     * @param editText View.
     */
    public static void hideKeyboard(View editText) {
        InputMethodManager imm = (InputMethodManager) BayunApplication.appContext.getSystemService(
                Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(editText.getWindowToken(), 0);
    }

    /**
     * Show soft keyboard.
     *
     * @param editText
     */
    public static void showKeyboard(EditText editText) {
        InputMethodManager inputMethodManager = (InputMethodManager) BayunApplication.appContext.getSystemService(Context.INPUT_METHOD_SERVICE);
        inputMethodManager.toggleSoftInputFromWindow(editText.getApplicationWindowToken(), InputMethodManager.SHOW_FORCED, 0);
    }

    /**
     * Show message alert with single button ok.
     *
     * @param activity
     * @param message
     * @param positiveString
     * @param view
     * @param onClickListener
     */
    public static void showAlertDialog(Activity activity, String message, String positiveString, View view,
                                       DialogInterface.OnClickListener onClickListener) {
        builder = new AlertDialog.Builder(activity, AlertDialog.THEME_HOLO_LIGHT);
        builder.setMessage(message);
        builder.setPositiveButton(positiveString, onClickListener);
        builder.setView(view);
        alertDialog = builder.create();
        alertDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        alertDialog.show();
        TextView messageView = (TextView) alertDialog.findViewById(android.R.id.message);
        messageView.setGravity(Gravity.CENTER);
    }

    /**
     * Show message alert with two buttons.
     *
     * @param activity
     * @param title
     * @param message
     * @param positiveString
     * @param negativeString
     * @param posCallback
     * @param negCallback
     */
    public static void decisionAlert(Activity activity, String title, String message, String positiveString,
                                     String negativeString, DialogInterface.OnClickListener posCallback, DialogInterface.OnClickListener negCallback) {
        builder = new AlertDialog.Builder(activity, AlertDialog.THEME_HOLO_LIGHT);
        if (title != null && !Constants.EMPTY_STRING.equals(title)) {
            builder.setTitle(title);
        }
        builder.setMessage(message);
        builder.setPositiveButton(positiveString, posCallback);
        builder.setNegativeButton(negativeString, negCallback);

        alertDialog = builder.create();
        alertDialog.show();
        TextView titleView = (TextView) alertDialog.findViewById(alertDialog.getContext().getResources().getIdentifier("alertTitle", "id", "android"));
        if (titleView != null) {
            titleView.setGravity(Gravity.CENTER);
        }
    }

    /**
     * read data from file
     *
     * @return A file data as a byte array.
     */
    public static String readFile(String filePath) {
        byte[] fileData = new byte[0];
        File file = new File(filePath);
        //Read text from file
        StringBuilder text = new StringBuilder();

        try {
            BufferedReader reader = new BufferedReader(new FileReader(file));
            String line;

            while ((line = reader.readLine()) != null) {
                text.append(line);
                text.append('\n');
            }
            reader.close();
        } catch (IOException e) {
            //You'll need to add proper error handling here
        }
        return text.toString();
    }
}




