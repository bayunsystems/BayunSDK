package com.bayun.screens;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ScrollView;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.http.RCAPIManager;
import com.bayun.util.Constants;
import com.bayun.util.Utility;
import com.bayun_module.credentials.BasicBayunCredentials;


public class RegisterActivity extends AbstractActivity {

    private EditText phoneEditText, extensionEditText, passwordEditText;
    private Long userName = 0L, extension = 0L;
    private String password;
    private CheckBox sandboxCheckbox;

    // Callback to authenticate user with Bayun - Success.
    private Handler.Callback responseSuccessCallback = message -> {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_LOGGED_IN, Constants.SHARED_PREFERENCES_REGISTER);
        Intent intent = new Intent(RegisterActivity.this, ListMessagesActivity.class);
        startActivity(intent);
        finish();

        return false;
    };

    // Callback to authenticate user with RingCentral.
    private Handler.Callback ringcentralCallback = new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            if (message.what == Constants.CALLBACK_SUCCESS) {
                String appId = getResources().getString(R.string.app_id);
                BasicBayunCredentials basicBayunCredentials = new BasicBayunCredentials(appId,
                        userName.toString(), extension.toString(), password);
                BayunApplication.bayunCore.authenticateWithCredentials(RegisterActivity.this,
                        basicBayunCredentials, null, responseSuccessCallback,
                        Utility.getDefaultFailureCallback(progressDialog));
            } else {
                if (progressDialog != null && progressDialog.isShowing()) {
                    progressDialog.dismiss();
                }
            }
            return false;

        }
    };

    // Validate passcode.
    private Handler.Callback passcodeCallback = message -> {

        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
        String response = message.getData().getString(Constants.AUTH_RESPONSE, "");
        if (response.equalsIgnoreCase(Constants.PASSCODE_REQUIRED)) {
            // Developer will add Custom UI for passcode.
        }
        return false;

    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        setUpView();
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
                BayunApplication.tinyDB.putBoolean(Constants.SHARED_PREFERENCES_IS_SANDBOX_LOGIN,
                        sandboxCheckbox.isChecked());
                RCAPIManager.getInstance(BayunApplication.appContext).authenticate(userName,
                        extension, password, ringcentralCallback);
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
        sandboxCheckbox = (CheckBox) findViewById(R.id.sandbox_server_checkbox);
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