package com.bayun.screens;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.EditText;
import android.widget.ScrollView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.http.RingCentralAPIManager;
import com.bayun.util.Constants;
import com.bayun.util.Utility;
import com.bayun_module.constants.BayunError;
import com.bayun_module.credentials.BasicBayunCredentials;


public class RegisterActivity extends AbstractActivity {

    private EditText phoneEditText, extensionEditText, passwordEditText;
    private Long userName = 0L, extension = 0L;
    private String password;
    private Handler.Callback ringcentralCallback, responseCallback, passcodeCallback;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        setUpView();
        // Callback to authenticate user with RingCentral.
        ringcentralCallback = new Handler.Callback() {
            @Override
            public boolean handleMessage(Message message) {

                if (progressDialog != null && progressDialog.isShowing()) {
                    progressDialog.dismiss();
                }
                if (message.what == Constants.CALLBACK_SUCCESS) {
                    String appId = "com.bayun.BayunRC";
                    BasicBayunCredentials basicBayunCredentials = new BasicBayunCredentials(appId, "BayunRC", userName.toString(), extension.toString(), password);
                    BayunApplication.bayunCore.authenticateWithCredentials(RegisterActivity.this, basicBayunCredentials, passcodeCallback, responseCallback);
                }
                return false;

            }
        };

        // Callback to authenticate user with Bayun.
        responseCallback = new Handler.Callback() {
            @Override
            public boolean handleMessage(Message message) {
                if (progressDialog != null && progressDialog.isShowing()) {
                    progressDialog.dismiss();
                }
                String response = message.getData().getString(Constants.AUTH_RESPONSE, "");
                if (response.equalsIgnoreCase(Constants.AUTH_SUCCESS)) {
                    BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_LOGGED_IN, Constants.SHARED_PREFERENCES_REGISTER);
                    Intent intent = new Intent(RegisterActivity.this, ListMessagesActivity.class);
                    startActivity(intent);
                    finish();
                } else if (response.equalsIgnoreCase(BayunError.ERROR_USER_NOT_ACTIVE)) {
                    Utility.displayToast(Constants.ERROR_MESSAGE_USER_INACTIVE, Toast.LENGTH_SHORT);
                } else if (response.equalsIgnoreCase(BayunError.ERROR_INVALID_PASSCODE)) {
                    Utility.displayToast(Constants.ERROR_MESSAGE_PASSCODE, Toast.LENGTH_SHORT);
                } else if (response.equalsIgnoreCase(BayunError.ERROR_INVALID_CREDENTIALS)) {
                    Utility.displayToast(Constants.ERROR_MESSAGE_INVALID_CREDENTIALS, Toast.LENGTH_SHORT);
                }
                return false;
            }
        };

        // Validate passcode.
        passcodeCallback = new Handler.Callback() {
            @Override
            public boolean handleMessage(Message message) {

                if (progressDialog != null && progressDialog.isShowing()) {
                    progressDialog.dismiss();
                }
                String response = message.getData().getString(Constants.AUTH_RESPONSE, "");
                if (response.equalsIgnoreCase(Constants.PASSCODE_REQUIRED)) {
                    // Developer will add Custom UI for passcode.
                }
                return false;

            }
        };
    }

    /**
     * Handles User Login Click.
     *
     * @param view : Login View as a Button.
     */
    public void loginClick(View view) {
        if (Utility.isNetworkAvailable()) {
            Utility.hideKeyboard(view);
            if (validateLoginData()) {
                progressDialog.show();
                RingCentralAPIManager.getInstance(BayunApplication.appContext).authenticate(userName, extension, password, ringcentralCallback);
            }
        } else {
            Utility.messageAlertForCertainDuration(this, Constants.ERROR_INTERNET_OFFLINE);
        }
    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        phoneEditText = (EditText) findViewById(R.id.phone_number);
        extensionEditText = (EditText) findViewById(R.id.extension);
        passwordEditText = (EditText) findViewById(R.id.passcode);
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));
        ScrollView scrollView = (ScrollView) findViewById(R.id.login_activity_scrollview);
        scrollView.setVerticalScrollBarEnabled(false);
        String userLoggedIn = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_LOGGED_IN);

        if (userLoggedIn.equalsIgnoreCase(Constants.SHARED_PREFERENCES_REGISTER)) {
            Intent intent = new Intent(RegisterActivity.this, ListMessagesActivity.class);
            startActivity(intent);
            finish();
        }
    }

    /**
     * Validates user login data.
     */
    private boolean validateLoginData() {
        boolean isValid = true;
        String msg = null;
        try {
            userName = Long.parseLong(phoneEditText.getText().toString());
            extension = Long.parseLong(extensionEditText.getText().toString());
        } catch (NumberFormatException e) {
            msg = getString(R.string.incompatible_type_error_message);
        }
        password = passwordEditText.getText().toString().trim();
        if (userName < 1 ||
                extension < 1 ||
                password.length() < 1) {
            msg = getString(R.string.incomplete_fields_error_message);
            isValid = false;
        }
        if (msg != null && msg.length() > 0) {
            Utility.messageAlertForCertainDuration(this, msg);
        }
        return isValid;
    }
}