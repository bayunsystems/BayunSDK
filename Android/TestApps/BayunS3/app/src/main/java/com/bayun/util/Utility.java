package com.bayun.util;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.S3wrapper.SecureAuthentication;
import com.bayun.app.BayunApplication;
import com.bayun.aws.AWSS3Manager;
import com.bayun.screens.activity.RegisterActivity;
import com.bayun_module.constants.BayunError;

import static com.bayun.aws.AWSS3Manager.getInstance;

/**
 * Created by Gagan on 01-06-2015.
 */
public class Utility {

    private static AlertDialog.Builder builder;
    private static AlertDialog alertDialog;

    /**
     * get common failure callback for api calls
     *
     * @return failure callback, dismissing the progress dialog and showing error message
     */
    public static Handler.Callback getDefaultFailureCallback(Activity activity, RelativeLayout progressBar) {
        return message -> {
            new Handler(Looper.getMainLooper()).post(() -> progressBar.setVisibility(View.GONE));
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
     * Show message alert for certain duration.
     *
     * @param context
     * @param message
     */
    public static void messageAlertForCertainDuration(Context context, String message) {
        new Handler(Looper.getMainLooper()).post(() -> {
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
        });
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
        new Handler(Looper.getMainLooper()).post(() -> {
            InputMethodManager imm = (InputMethodManager) BayunApplication.appContext.getSystemService(
                    Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(editText.getWindowToken(), 0);
        });
    }

    /**
     * Show soft keyboard.
     *
     * @param editText
     */
    public static void showKeyboard(EditText editText) {
        new Handler(Looper.getMainLooper()).post(() -> {
            InputMethodManager inputMethodManager = (InputMethodManager) BayunApplication.appContext.getSystemService(Context.INPUT_METHOD_SERVICE);
            inputMethodManager.toggleSoftInputFromWindow(editText.getApplicationWindowToken(), InputMethodManager.SHOW_FORCED, 0);
        });
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
        new Handler(Looper.getMainLooper()).post(() -> {
            builder = new AlertDialog.Builder(activity, AlertDialog.THEME_HOLO_LIGHT);
            builder.setMessage(message);
            builder.setPositiveButton(positiveString, onClickListener);
            builder.setView(view);
            alertDialog = builder.create();
            alertDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
            alertDialog.show();
            TextView messageView = alertDialog.findViewById(android.R.id.message);
            messageView.setGravity(Gravity.CENTER);
        });
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
                                     String negativeString, DialogInterface.OnClickListener posCallback,
                                     DialogInterface.OnClickListener negCallback) {
        new Handler(Looper.getMainLooper()).post(() -> {
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
        });
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
                errorMessage = Constants.ERROR_USER_INACTIVE;
            }
            else if (error.equalsIgnoreCase(BayunError.ERROR_APP_NOT_LINKED)) {
                errorMessage = "Application is not linked with this Employee account. Login to Admin Panel and link the application.";
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
                errorMessage = "Please enter passphrase.";
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
                errorMessage = "Device Passcode Is Not Set.";
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
                Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                BayunApplication.appContext.startActivity(intent);
                BayunApplication.tinyDB.clear();
                AWSS3Manager.getInstance().resetPoliciesOnDevice();
                SecureAuthentication.getInstance().signOut(CognitoHelper.getPool().getUser(CognitoHelper.getUserId()));
                if (getInstance().fileList() != null && getInstance().fileList().size() != 0)
                    getInstance().fileList().clear();
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_DEVICE_AUTHENTICATION_REQUIRED))) {
                if (BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_IS_BAYUN_LOGGED_IN)
                        .equalsIgnoreCase(Constants.YES)) {
                    errorMessage = "Passcode Authentication Canceled By User. Please login again to continue.";

                    // logout the user
                    Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    BayunApplication.appContext.startActivity(intent);
                    BayunApplication.tinyDB.clear();
                    AWSS3Manager.getInstance().resetPoliciesOnDevice();
                    SecureAuthentication.getInstance().signOut(CognitoHelper.getPool().getUser(CognitoHelper.getUserId()));
                    if (getInstance().fileList() != null && getInstance().fileList().size() != 0)
                        getInstance().fileList().clear();
                }
                else {
                    errorMessage = "Passcode Authentication Canceled By User.";
                }
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_AT_LEAST_THREE_ANSWERS_REQUIRED))) {
                errorMessage = "Please answer at least 3 questions.";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_INCORRECT_ANSWERS))) {
                errorMessage = "One or more wrong answers entered.";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_COMBINING_PARTS))) {
                errorMessage = "Error occurred while combining user private key parts.";
            }
            else if ((error.equalsIgnoreCase(BayunError.ERROR_DUPLICATE_ENTRY_CREATED))) {
                errorMessage = "Tried to create duplicate entry.";
            } else if ((error.equalsIgnoreCase(BayunError.ERROR_LINK_USER_ACCOUNT))) {
                errorMessage = "Login to Admin Panel to link this User Account with an existing Employee Account to continue using the SDK APIs.";
            }else if ((error.equalsIgnoreCase(BayunError.ERROR_NO_USER_ACCOUNT_WITHOUT_PASSWORD))) {
                errorMessage = "There is no User Account to login without password.";
            }else if ((error.equalsIgnoreCase(BayunError.ERROR_USER_PASSWORD_VERIFICATION_ENABLED))) {
                errorMessage = "There is no User Account to login without password.";
            }else if ((error.equalsIgnoreCase(BayunError.ERROR_EMPLOYEE_ALREADY_EXISTS))) {
                errorMessage = "Employee already exist with this complayee";
            }else if ((error.equalsIgnoreCase(BayunError.ERROR_USER_ALREADY_EXISTS))) {
                errorMessage = "User already exist with this complayee";
            }else if ((error.equalsIgnoreCase(BayunError.ERROR_EMPLOYEE_APP_NOT_REGISTERED))) {
                errorMessage = "Employee App Is Not Registered.";
            }else if ((error.equalsIgnoreCase(BayunError.BAYUN_ERROR_REGISTRATION_FAILED_EMPLOYEE_APP_IS_NOT_APPROVED))) {
                errorMessage = "Registration failed. Application is not approved, please contact your Admin for the application approval.";
            }
            else if((error.equalsIgnoreCase(BayunError.ERROR_INVALID_APP_SECRET))) {
                if (BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_IS_BAYUN_LOGGED_IN)
                        .equalsIgnoreCase(Constants.YES)) {
                    errorMessage = "Please login again to continue.";

                    // logout the user
                    Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    BayunApplication.appContext.startActivity(intent);
                    BayunApplication.tinyDB.clear();
                    AWSS3Manager.getInstance().resetPoliciesOnDevice();
                    SecureAuthentication.getInstance().signOut(CognitoHelper.getPool().getUser(CognitoHelper.getUserId()));
                    if (getInstance().fileList() != null && getInstance().fileList().size() != 0)
                        getInstance().fileList().clear();
                }
                else {
                    errorMessage = "Invalid credentials entered.";
                }
            }
            else {
                errorMessage = error;
                // errorMessage = Constants.ERROR_SOMETHING_WENT_WRONG;
            }
        }
        displayToast(errorMessage, Toast.LENGTH_SHORT);
    }
}




