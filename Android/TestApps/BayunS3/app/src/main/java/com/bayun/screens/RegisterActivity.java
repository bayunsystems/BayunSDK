package com.bayun.screens;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;
import com.bayun.util.Utility;
import com.bayun_module.constants.BayunError;
import com.bayun_module.credentials.BasicBayunCredentials;

public class RegisterActivity extends AbstractActivity {

    private TextView companyNameText, employeeIdText, passcodeText;
    private String companyName = "", employeeId = "", password = "";
    private Handler.Callback responseCallback, passcodeCallback;
    View view;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        setUpView();

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
                    Intent intent = new Intent(RegisterActivity.this, ListFilesActivity.class);
                    startActivity(intent);
                    finish();
                } else if (response.equalsIgnoreCase(BayunError.ERROR_USER_NOT_ACTIVE)) {
                    Utility.displayToast(Constants.ERROR_MESSAGE_USER_INACTIVE, Toast.LENGTH_SHORT);
                } else if (response.equalsIgnoreCase(BayunError.ERROR_INVALID_PASSCODE)) {
                    Utility.displayToast(Constants.ERROR_MESSAGE_PASSCODE, Toast.LENGTH_SHORT);
                } else if (response.equalsIgnoreCase(BayunError.ERROR_INVALID_CREDENTIALS)) {
                    Utility.displayToast(Constants.ERROR_MESSAGE_INVALID_CREDENTIALS, Toast.LENGTH_SHORT);
                } else if (response.equalsIgnoreCase(BayunError.ERROR_INVALID_PASSWORD)) {
                    Utility.displayToast(Constants.ERROR_MESSAGE_INVALID_PASSWORD, Toast.LENGTH_SHORT);
                } else if (response.equalsIgnoreCase(BayunError.ERROR_AUTHENTICATION_FAILED)) {
                    Utility.displayToast(Constants.ERROR_AUTHENTICATION_FAILED, Toast.LENGTH_SHORT);
                } else if (response.equalsIgnoreCase(BayunError.ERROR_APP_NOT_LINKED)) {
                    Utility.displayToast(Constants.ERROR_APP_NOT_LINKED, Toast.LENGTH_SHORT);
                }
                return false;
            }
        };

        // Callback to validate passcode.
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
     * Sets up Views.
     */
    private void setUpView() {
        companyNameText = (TextView) findViewById(R.id.company_name_text);
        employeeIdText = (TextView) findViewById(R.id.employee_id_text);
        passcodeText = (TextView) findViewById(R.id.passcode_text);
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));
        ScrollView scrollView = (ScrollView) findViewById(R.id.login_activity_scrollview);
        scrollView.setVerticalScrollBarEnabled(false);
        String userLoggedIn = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_LOGGED_IN);
        if (userLoggedIn.equalsIgnoreCase(Constants.SHARED_PREFERENCES_REGISTER)) {
            Intent intent = new Intent(RegisterActivity.this, ListFilesActivity.class);
            startActivity(intent);
            finish();
        }
    }

    /**
     * Handles User click on register Button.
     *
     * @param v : View as a Button.
     */
    public void registerClick(View v) {
        view = v;
        if (validateData()) {
            Utility.hideKeyboard(view);
            if (Utility.isNetworkAvailable()) {
                progressDialog.show();
                BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_COMPANY_NAME, companyName);
                String appId = getString(R.string.app_id);
                BasicBayunCredentials basicBayunCredentials = new BasicBayunCredentials(appId, companyName, employeeId, password);
                BayunApplication.bayunCore.authenticateWithCredentials(RegisterActivity.this, basicBayunCredentials, null, responseCallback);
            } else {
                Utility.messageAlertForCertainDuration(this, Constants.ERROR_INTERNET_OFFLINE);
            }
        }
    }

    /**
     * Validate user register data
     *
     * @return True/False.
     */
    public boolean validateData() {
        boolean isValid = true;
        String msg = null;
        companyName = companyNameText.getText().toString().trim();
        employeeId = employeeIdText.getText().toString().trim();
        password = passcodeText.getText().toString().trim();
        if (companyName.length() < 1 ||
                employeeId.length() < 1 ||
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
