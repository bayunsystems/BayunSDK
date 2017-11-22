package com.bayun.util;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Handler;
import android.util.Base64;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun_module.constants.BayunError;

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

    /**
     * Show error message as toast.
     *
     * @param error the response string obtained from api callback.
     */
    public static void showErrorMessage(String error) {
        String returnMessage = null;
        if (error != null) {
            if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_CREDENTIALS)) {
                returnMessage = "Invalid credentials";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_PASSWORD)) {
                returnMessage = "Incorrect password";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_PASSPHRASE)) {
                returnMessage = "Incorrect passphrase";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_USER_INACTIVE)) {
                returnMessage = "Please contact your Admin to activate your account.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_APP_NOT_LINKED)) {
                returnMessage = "App not linked with Employee account. Please link the app through " +
                        "admin panel.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_APP_ID)) {
                returnMessage = "App doesn't exist for given App Id.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_COMPANY_NAME)) {
                returnMessage = "Company doesn't exist for given Company Name.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_GROUP_ID)) {
                returnMessage = "Group does not exist for the given group id.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_EMPLOYEE_DOESNT_EXIST)) {
                returnMessage = "Employee does not exists for given company employee id and/or company name.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_EMPLOYEE_DOESNT_BELONG_TO_GROUP)) {
                returnMessage = "Employee is not linked with the given group.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_MEMBER_EXISTS_IN_GROUP)) {
                returnMessage = "Given employee id already exist in the group.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_CANNOT_JOIN_PRIVATE_GROUP)) {
                returnMessage = "Given group is not public group. You cannot join this group.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INTERNET_CONNECTION)) {
                returnMessage = Constants.ERROR_INTERNET_OFFLINE;
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_REQUEST_TIMEOUT)) {
                returnMessage = "Request timed out. Please try again.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_ACCESS_DENIED)) {
                returnMessage = "Access denied.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_COULD_NOT_CONNECT_TO_SERVER)) {
                returnMessage = "Could not connect to server.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_AUTHENTICATION_FAILED)) {
                returnMessage = "Authentication failed.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_PASSPHRASE_CANNOT_BE_NULL)) {
                returnMessage = "Passphrase cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_CREDENTIALS_CANNOT_BE_NULL)) {
                returnMessage = "Credentials cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_COMPANY_EMPLOYEE_ID_CANNOT_BE_NULL)) {
                returnMessage = "Employee Id cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_COMPANY_CANNOT_BE_NULL)) {
                returnMessage = "Company name cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_GROUP_ID_CANNOT_BE_NULL)) {
                returnMessage = "Group Id cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_GROUP_TYPE_CANNOT_BE_NULL)) {
                returnMessage = "Group type cannot be null";
            }
            else {
                returnMessage = Constants.ERROR_SOMETHING_WENT_WRONG;
            }
        }
        displayToast(returnMessage, Toast.LENGTH_LONG);
    }

    /**
     * get common failure callback for api calls
     *
     * @param progressDialog    progress dialog specific for the activity
     * @return failure callback, dismissing the progress dialog and showing error message
     */
    public static Handler.Callback getDefaultFailureCallback(ProgressDialog progressDialog) {
        return message -> {
            if (progressDialog != null && progressDialog.isShowing()) {
                progressDialog.dismiss();
            }
            String response = message.getData().getString(Constants.ERROR, "");
            showErrorMessage(response);
            return false;
        };
    }

    /**
     * Returns the auth header after Base64 encoding, and concatenation of both keys.
     *
     * @return generated auth header
     */
    public static String getAuthHeader() {
        byte[] encodedKey;
        String key;
        if (BayunApplication.tinyDB.getBoolean(Constants.SHARED_PREFERENCES_IS_SANDBOX_LOGIN, false)) {
            String concatenatedString = BayunApplication.appContext.getString(R.string.application_key_sandbox)
                    + ":" + BayunApplication.appContext.getString(R.string.application_secret_key_sandbox);
            encodedKey = Base64.encode(concatenatedString.getBytes(), Base64.DEFAULT);
            key = new String(encodedKey);
            key = key.replace(System.getProperty("line.separator"), "");
        }
        else {
            String concatenatedString = BayunApplication.appContext.getString(R.string.application_key_prod)
                    + ":" + BayunApplication.appContext.getString(R.string.application_key_secret_prod);
            encodedKey = Base64.encode(concatenatedString.getBytes(), Base64.DEFAULT);
            key = new String(encodedKey);
            key = key.replace(System.getProperty("line.separator"), "");
        }
        Log.d("msg", "return String - " + new String(encodedKey));
        return key;
    }
}