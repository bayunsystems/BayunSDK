package com.bayun.util;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.app.BayunApplication;
import com.bayun.database.ActivityDBOperations;
import com.bayun.screens.RegisterActivity;
import com.bayun_module.constants.BayunError;

/**
 * Created by Gagan on 01-06-2015.
 */
public class Utility {

    private static AlertDialog.Builder builder;
    private static AlertDialog alertDialog;
    // variable that store if error was already shown
    public static boolean isErrorShown = false;

    /**
     * Display Message using toast.
     *
     * @param message
     * @param toastLength
     */
    public static void displayToast(String message, int toastLength) {
        new Handler(Looper.getMainLooper()).post(() -> Toast.makeText(BayunApplication.appContext, message, toastLength).show());
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
        String errorMessage = null;
        if (error != null) {
            if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_CREDENTIALS)) {
                errorMessage = "Invalid credentials";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_PASSWORD)) {
                errorMessage = "Incorrect password";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_PASSPHRASE)) {
                errorMessage = "Incorrect passphrase";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_USER_INACTIVE)) {
                errorMessage = "Please contact your Admin to activate your account.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_APP_NOT_LINKED)) {
                errorMessage = "App not linked with Employee account. Please link the app through " +
                        "admin panel.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_APP_ID)) {
                errorMessage = "App doesn't exist for given App Id.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_COMPANY_NAME)) {
                errorMessage = "Company doesn't exist for given Company Name.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INVALID_GROUP_ID)) {
                errorMessage = "Group does not exist for the given group id.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_EMPLOYEE_DOESNT_EXIST)) {
                errorMessage = "Employee does not exists for given company employee id and/or " +
                        "company name.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_EMPLOYEE_DOESNT_BELONG_TO_GROUP)) {
                errorMessage = "Employee is not linked with the given group.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_MEMBER_EXISTS_IN_GROUP)) {
                errorMessage = "Given employee id already exist in the group.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_CANNOT_JOIN_PRIVATE_GROUP)) {
                errorMessage = "Given group is not public group. You cannot join this group.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_INTERNET_CONNECTION)) {
                errorMessage = Constants.ERROR_INTERNET_OFFLINE;
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_REQUEST_TIMEOUT)) {
                errorMessage = "Request timed out. Please try again.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_ACCESS_DENIED)) {
                errorMessage = "Access denied.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_COULD_NOT_CONNECT_TO_SERVER)) {
                errorMessage = "Could not connect to server.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_AUTHENTICATION_FAILED)) {
                errorMessage = "Authentication failed.";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_PASSPHRASE_CANNOT_BE_NULL)) {
                errorMessage = "Passphrase cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_CREDENTIALS_CANNOT_BE_NULL)) {
                errorMessage = "Credentials cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_COMPANY_EMPLOYEE_ID_CANNOT_BE_NULL)) {
                errorMessage = "Employee Id cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_COMPANY_CANNOT_BE_NULL)) {
                errorMessage = "Company name cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_GROUP_ID_CANNOT_BE_NULL)) {
                errorMessage = "Group Id cannot be null";
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_GROUP_TYPE_CANNOT_BE_NULL)) {
                errorMessage = "Group type cannot be null";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_DEVICE_PASSCODE_NOT_SET))) {
                errorMessage = "Device Passcode Is Not Set";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_ENCRYPTION_FAILED))) {
                errorMessage = "File could not be created.";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_DECRYPTION_FAILED))) {
                errorMessage = "File could not be opened.";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_REAUTHENTICATION_NEEDED))) {
                errorMessage = "Please login again to continue.";

                // logout the user
                BayunApplication.tinyDB.clear();
                BayunApplication.bayunCore.deauthenticate();
                Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                BayunApplication.appContext.startActivity(intent);
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_DEVICE_AUTHENTICATION_REQUIRED))) {
                errorMessage = "Passcode Authentication Canceled By User.";
                String userLoggedIn = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_LOGGED_IN);

                // logout the user if logged in
                if (userLoggedIn.equalsIgnoreCase(Constants.SHARED_PREFERENCES_REGISTER)) {
                    BayunApplication.tinyDB.clear();
                    BayunApplication.bayunCore.deauthenticate();
                    Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    BayunApplication.appContext.startActivity(intent);
                }
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_AT_LEAST_THREE_ANSWERS_REQUIRED))) {
                errorMessage = "Please answer at least 3 questions.";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_INCORRECT_ANSWERS))) {
                errorMessage = "One or more wrong answers entered.";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_INVALID_APP_SECRET))) {
                errorMessage = "Please login again to continue.";
                String userLoggedIn = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_LOGGED_IN);

                // logout the user if logged in
                if (userLoggedIn.equalsIgnoreCase(Constants.SHARED_PREFERENCES_REGISTER)) {
                    BayunApplication.tinyDB.clear();
                    BayunApplication.bayunCore.deauthenticate();
                    Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    BayunApplication.appContext.startActivity(intent);
                }
            }
            else {
                errorMessage = Constants.ERROR_SOMETHING_WENT_WRONG;
            }
        }
        displayToast(errorMessage, Toast.LENGTH_LONG);
    }

    /**
     * get common failure callback for api calls
     *
     * @param progressBar    progress bar for the activity
     * @return failure callback, dismissing the progress dialog and showing error message
     */
    public static Handler.Callback getDefaultFailureCallback(Activity activity, RelativeLayout progressBar) {
        return message -> {
            activity.runOnUiThread(() -> progressBar.setVisibility(View.GONE));
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
            String concatenatedString = Constants.APPLICATION_KEY_SANDBOX + ":" + Constants.APPLICATION_SECRET_KEY_SANDBOX;
            encodedKey = Base64.encode(concatenatedString.getBytes(), Base64.DEFAULT);
            key = new String(encodedKey);
            key = key.replace(System.getProperty("line.separator"), "");
        }
        else {
            String concatenatedString = Constants.APPLICATION_KEY_PROD + ":" + Constants.APPLICATION_KEY_SECRET_PROD;
            encodedKey = Base64.encode(concatenatedString.getBytes(), Base64.DEFAULT);
            key = new String(encodedKey);
            key = key.replace(System.getProperty("line.separator"), "");
        }
        Log.d("msg", "return String - " + new String(encodedKey));
        return key;
    }
}




