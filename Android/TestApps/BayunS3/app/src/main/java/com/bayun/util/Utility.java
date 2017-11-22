package com.bayun.util;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.app.BayunApplication;
import com.bayun_module.constants.BayunError;

/**
 * Created by Gagan on 01-06-2015.
 */
public class Utility {

    private static AlertDialog.Builder builder;
    private static AlertDialog alertDialog;

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
     * Show user information by toast.
     *
     * @param message       message to be displayed
     * @param toastLength   display duration for the toast
     */
    public static void displayToast(String message, int toastLength) {
        new Handler(Looper.getMainLooper()).post(() -> {
            Toast toast = Toast.makeText(BayunApplication.appContext, message, toastLength);
            toast.show();
        });
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
        final Runnable runnable = () -> {
            if (alertDialog != null) {
                if (alertDialog.isShowing()) {
                    alertDialog.dismiss();
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
        TextView titleView = (TextView) alertDialog.findViewById(alertDialog.getContext().getResources()
                .getIdentifier("alertTitle", "id", "android"));
        if (titleView != null) {
            titleView.setGravity(Gravity.CENTER);
        }
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
                returnMessage = Constants.ERROR_USER_INACTIVE;
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
                returnMessage = "Employee does not exists for given company employee id and/or " +
                        "company name.";
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
}




