package com.bayun.screens.activity;

import android.app.Dialog;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;

import androidx.core.content.ContextCompat;
import androidx.appcompat.app.AlertDialog;

import android.os.Handler;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUser;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserAttributes;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserCodeDeliveryDetails;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.SignUpHandler;
import com.amazonaws.services.cognitoidentityprovider.model.CodeDeliveryDetailsType;
import com.amazonaws.services.cognitoidentityprovider.model.SignUpResult;
import com.bayun.app.BayunApplication;
import com.bayun.util.CognitoHelper;
import com.bayun.R;
import com.bayun.util.Constants;
import com.bayun.util.Utility;

public class CognitoRegisterUserActivity extends AbstractActivity {

    private EditText username;
    private EditText password;
    private EditText givenName;
    private EditText email;
    private EditText phone;
    private CheckBox chb_reg_type;
    private CheckBox chb_reg_with_bayun_only;
    private TextView textViewRegUserPasswordLabel;
    private TextView textViewUserRegPasswordMessage;
    private TextView textViewRegEmailLabel;
    private TextView textViewRegEmailMessage;


    private AlertDialog userDialog;
    private String usernameInput;
    private String userPasswd;
    private RelativeLayout progressBar;

    private String companyName = Constants.COMPANY_NAME;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cognito_register_user);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            // get back to main screen
            String value = extras.getString("TODO");
            if ("exit".equals(value)) {
                onBackPressed();
            }
        }

        setUpViews();
    }


    // This will create the list/form for registration
    private void setUpViews() {
        chb_reg_type = findViewById(R.id.chb_reg_type);
        chb_reg_with_bayun_only = findViewById(R.id.chb_reg_with_bayun_only);
        textViewRegUserPasswordLabel = findViewById(R.id.textViewRegUserPasswordLabel);
        textViewUserRegPasswordMessage = findViewById(R.id.textViewUserRegPasswordMessage);
        textViewRegEmailLabel = findViewById(R.id.textViewRegEmailLabel);
        textViewRegEmailMessage = findViewById(R.id.textViewRegEmailMessage);
        progressBar = findViewById(R.id.progressBar);
        username = findViewById(R.id.editTextRegUserId);
        password = findViewById(R.id.editTextRegUserPassword);


        chb_reg_with_bayun_only.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (chb_reg_with_bayun_only.isChecked()) {
                    if (chb_reg_type.isChecked()) {
                        password.setVisibility(View.VISIBLE);
                        textViewRegUserPasswordLabel.setVisibility(View.VISIBLE);
                        textViewUserRegPasswordMessage.setVisibility(View.VISIBLE);
                        password.setVisibility(View.VISIBLE);


                        email.setVisibility(View.GONE);
                        textViewRegEmailLabel.setVisibility(View.GONE);
                        textViewRegEmailMessage.setVisibility(View.GONE);
                        email.setText("");
                    } else {
                        password.setVisibility(View.GONE);
                        textViewRegUserPasswordLabel.setVisibility(View.GONE);
                        textViewUserRegPasswordMessage.setVisibility(View.GONE);
                        password.setVisibility(View.GONE);
                        password.setText("");

                        email.setVisibility(View.VISIBLE);
                        textViewRegEmailLabel.setVisibility(View.VISIBLE);
                        textViewRegEmailMessage.setVisibility(View.VISIBLE);

                    }
                } else {
                    password.setVisibility(View.VISIBLE);
                    textViewRegUserPasswordLabel.setVisibility(View.VISIBLE);
                    textViewUserRegPasswordMessage.setVisibility(View.VISIBLE);
                    password.setVisibility(View.VISIBLE);

                    email.setVisibility(View.VISIBLE);
                    textViewRegEmailLabel.setVisibility(View.VISIBLE);
                    textViewRegEmailMessage.setVisibility(View.VISIBLE);
                }
            }
        });

        chb_reg_type.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (chb_reg_type.isChecked()) {

                    if (chb_reg_with_bayun_only.isChecked()) {
                        email.setVisibility(View.GONE);
                        textViewRegEmailLabel.setVisibility(View.GONE);
                        textViewRegEmailMessage.setVisibility(View.GONE);
                        email.setText("");
                    } else {
                        email.setVisibility(View.VISIBLE);
                        textViewRegEmailLabel.setVisibility(View.VISIBLE);
                        textViewRegEmailMessage.setVisibility(View.VISIBLE);
                    }

                    password.setVisibility(View.VISIBLE);
                    textViewRegUserPasswordLabel.setVisibility(View.VISIBLE);
                    textViewUserRegPasswordMessage.setVisibility(View.VISIBLE);
                    password.setVisibility(View.VISIBLE);
                } else {
                    email.setVisibility(View.VISIBLE);
                    textViewRegEmailLabel.setVisibility(View.VISIBLE);
                    textViewRegEmailMessage.setVisibility(View.VISIBLE);
                    if (chb_reg_with_bayun_only.isChecked()) {
                        password.setVisibility(View.VISIBLE);
                        textViewRegUserPasswordLabel.setVisibility(View.VISIBLE);
                        textViewUserRegPasswordMessage.setVisibility(View.VISIBLE);
                        password.setVisibility(View.VISIBLE);
                    } else {
                        password.setVisibility(View.GONE);
                        textViewRegUserPasswordLabel.setVisibility(View.GONE);
                        textViewUserRegPasswordMessage.setVisibility(View.GONE);
                        password.setVisibility(View.GONE);
                        password.setText("");
                    }
                }
            }
        });


        username.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegUserIdLabel);
                    label.setText(username.getHint());
                    username.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = findViewById(R.id.textViewRegUserIdMessage);
                label.setText("");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegUserIdLabel);
                    label.setText("");
                }
            }
        });


        password.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegUserPasswordLabel);
                    label.setText(password.getHint());
                    password.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = findViewById(R.id.textViewUserRegPasswordMessage);
                label.setText("");

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegUserPasswordLabel);
                    label.setText("");
                }
            }
        });

        givenName = findViewById(R.id.editTextRegGivenName);
        givenName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegGivenNameLabel);
                    label.setText(givenName.getHint());
                    givenName.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = findViewById(R.id.textViewRegGivenNameMessage);
                label.setText("");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegGivenNameLabel);
                    label.setText("");
                }
            }
        });

        email = (EditText) findViewById(R.id.editTextRegEmail);
        email.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegEmailLabel);
                    label.setText(email.getHint());
                    email.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = findViewById(R.id.textViewRegEmailMessage);
                label.setText("");

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegEmailLabel);
                    label.setText("");
                }
            }
        });

        phone = (EditText) findViewById(R.id.editTextRegPhone);
        phone.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegPhoneLabel);
                    label.setText(phone.getHint() + " with country code and no seperators");
                    phone.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = findViewById(R.id.textViewRegPhoneMessage);
                label.setText("");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = findViewById(R.id.textViewRegPhoneLabel);
                    label.setText("");
                }
            }
        });

        Button signUp = (Button) findViewById(R.id.signUp);
        signUp.setOnClickListener(v -> {
            // Read user data and register
            CognitoUserAttributes userAttributes = new CognitoUserAttributes();

            usernameInput = username.getText().toString();
            if (usernameInput == null || usernameInput.isEmpty()) {
                TextView view = findViewById(R.id.textViewRegUserIdMessage);
                view.setText(username.getHint() + " cannot be empty");
                username.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                        R.drawable.text_border_error));
                return;
            }
            String userpasswordInput = password.getText().toString();
            if (password.getVisibility() == View.VISIBLE) {
                userPasswd = userpasswordInput;
                if (userpasswordInput == null || userpasswordInput.isEmpty()) {
                    TextView view = findViewById(R.id.textViewUserRegPasswordMessage);
                    view.setText(password.getHint() + " cannot be empty");
                    password.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_error));
                    return;
                }
            }


            String userInput = givenName.getText().toString();
            /*if (userInput != null) {
                if (userInput.length() > 0) {
                    userAttributes.addAttribute(CognitoHelper.getSignUpFieldsC2O().get(givenName.getHint()).toString(), userInput);
                }
            }*/

            String emailInput = email.getText().toString();
            if (password.getVisibility() == View.VISIBLE) {
                userInput = email.getText().toString();
                if (userInput != null) {
                    if (userInput.length() > 0) {
                        userAttributes.addAttribute(CognitoHelper.getSignUpFieldsC2O().get(email.getHint()).toString(), userInput);
                    }
                }
            }else if(!TextUtils.isEmpty(emailInput)){
                userAttributes.addAttribute(CognitoHelper.getSignUpFieldsC2O().get(email.getHint()).toString(), emailInput);

            }


            userInput = phone.getText().toString();
           /* if (userInput != null) {
                if (userInput.length() > 0) {
                    userAttributes.addAttribute(CognitoHelper.getSignUpFieldsC2O().get(phone.getHint()).toString(), userInput);
                }
            }*/

            showWaitDialog();


            if(chb_reg_with_bayun_only.isChecked()){
                // Bayun Authentication success Callback
                Handler.Callback bayunAuthSuccess = msg -> {
                    String bucketName = "bayun-test-" + companyName;
                    bucketName = bucketName.toLowerCase();
                    BayunApplication.tinyDB.putString(Constants.S3_BUCKET_NAME, bucketName);
                    signUpHandler.onSuccess(null,  null);
                    return false;
                };

                // Bayun authentication failure Callback
                Handler.Callback bayunAuthFailure = msg -> {
                    Exception exception =
                            new Exception(msg.getData().getString(Constants.ERROR));
                    signUpHandler.onFailure(exception);
                    return false;
                };

                // Bayun Registration authorizeEmployeeCallback  Callback
                Handler.Callback authorizeEmployeeCallback = msg -> {
                    String employeePublicKey = msg.getData().getString(Constants.EMPLOYEE_PUBLICKEY);
                    Exception exception = new Exception("Employee Authorization is Pending");
                    signUpHandler.onFailure(exception);
                    return false;
                };


                if(chb_reg_type.isChecked()){
                    BayunApplication.bayunCore.registerEmployeeWithPassword
                            (CognitoRegisterUserActivity.this,companyName,usernameInput,userpasswordInput, authorizeEmployeeCallback,  bayunAuthSuccess, bayunAuthFailure);
                }else {
                    BayunApplication.bayunCore.registerEmployeeWithoutPassword(CognitoRegisterUserActivity.this,companyName,usernameInput
                            ,userAttributes.getAttributes().get("email"),false, authorizeEmployeeCallback,
                            null,null,null,  bayunAuthSuccess, bayunAuthFailure);
                }
            }else {
                BayunApplication.secureAuthentication.signUp(CognitoRegisterUserActivity.this,
                        CognitoHelper.getPool(), usernameInput, userpasswordInput, userAttributes,
                        null, signUpHandler, chb_reg_type.isChecked());

            }
        });
    }

    // Handler to maintain the signup process
    SignUpHandler signUpHandler = new SignUpHandler() {
        @Override
        public void onSuccess(CognitoUser user,
                              SignUpResult signUpResult) {
            // Check signUpConfirmationState to see if the user is already confirmed
            closeWaitDialog();
            if(chb_reg_with_bayun_only.isChecked()){
                showDialogMessage("Sign up successful!", usernameInput + " has been Confirmed", true);
            }else {
                if (signUpResult.getUserConfirmed()) {
                    // User is already confirmed
                    showDialogMessage("Sign up successful!", usernameInput + " has been Confirmed", true);
                } else {
                    // User is not confirmed
                    confirmSignUp(signUpResult.getCodeDeliveryDetails());
                }
            }

        }

        @Override
        public void onFailure(Exception exception) {
            closeWaitDialog();
            TextView label = (TextView) findViewById(R.id.textViewRegUserIdMessage);
            label.setText("Sign up failed");
            username.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                    R.drawable.text_border_error));

            String error = CognitoHelper.formatException(exception);
            String errorMessage = error;

            if (error.startsWith("Bayun")) {
                Utility.showErrorMessage(error);
            }
            else {
                showDialogMessage("Sign up failed",  CognitoHelper.formatException(exception), false);
            }

        }
    };

    /**
     * Sends to Sign up confirmation activity for further operations.
     *
     * @param cognitoUserCodeDeliveryDetails details for the sign up confirmation.
     */
    private void confirmSignUp(CodeDeliveryDetailsType cognitoUserCodeDeliveryDetails) {
        Intent intent = new Intent(this, SignUpConfirmActivity.class);
        intent.putExtra("source", "signup");
        intent.putExtra("name", usernameInput);
        intent.putExtra("destination", cognitoUserCodeDeliveryDetails.getDestination());
        intent.putExtra("deliveryMed", cognitoUserCodeDeliveryDetails.getDeliveryMedium());
        intent.putExtra("attribute", cognitoUserCodeDeliveryDetails.getAttributeName());
        startActivityForResult(intent, 10);
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 10) {
            if (resultCode == RESULT_OK) {
                String name = null;
                if (data.hasExtra("name")) {
                    name = data.getStringExtra("name");
                }
                exit(name, userPasswd);
            }
        }
    }

    /**
     * Show a dialog box with message.
     *
     * @param title Title of the dialog box.
     * @param body  Body of the dialog box.
     * @param exit  Boolean if app should exit after the dialog dismisses.
     */
    private void showDialogMessage(String title, String body, final boolean exit) {
        runOnUiThread(() -> {
            final AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle(title).setMessage(body).setNeutralButton("OK", (dialog, which) -> {
                try {
                    userDialog.dismiss();
                    if (exit) {
                        exit(usernameInput);
                    }
                } catch (Exception e) {
                    if (exit) {
                        exit(usernameInput);
                    }
                }
            });
            userDialog = builder.create();
            userDialog.show();
        });
    }

    /**
     * Show progress dialog.
     */
    private void showWaitDialog() {
        closeWaitDialog();
        runOnUiThread(() -> progressBar.setVisibility(View.VISIBLE));
    }

    /**
     * Dismiss progress dialog.
     */
    private void closeWaitDialog() {
        runOnUiThread(() -> progressBar.setVisibility(View.GONE));
    }

    /**
     * Exit the particular user.
     *
     * @param uname Username of the user to exit.
     */
    private void exit(String uname) {
        exit(uname, null);
    }

    private void exit(String uname, String password) {
        Intent intent = new Intent();
        if (uname == null) {
            uname = "";
        }
        if (password == null) {
            password = "";
        }
        intent.putExtra("name", uname);
        intent.putExtra("password", password);
        setResult(RESULT_OK, intent);
        finish();
    }


    /**
     * Change company name with which a user is to be logged in/signed up.
     *
     * @param view Button whose click will trigger the function.
     */
    public void changeCompany(View view) {
        showChangeCompanyDialog();
    }

    /**
     * Create a dialog box to change company name.
     */
    private void showChangeCompanyDialog() {
        Dialog dialog = new Dialog(this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.spinner_dialog_layout);

        ((TextView) dialog.findViewById(R.id.dialog_title)).setText("Set Company Name");
        ((EditText) dialog.findViewById(R.id.dialog_group_name)).setText(companyName);
        dialog.findViewById(R.id.dialog_group_name).requestFocus();
        dialog.findViewById(R.id.dialog_employee_id).setVisibility(View.GONE);
        dialog.findViewById(R.id.dialog_spinner).setVisibility(View.GONE);

        dialog.findViewById(R.id.cancel_action).setOnClickListener(v -> dialog.dismiss());
        dialog.findViewById(R.id.ok_action).setOnClickListener(v -> {
            companyName = ((EditText) dialog.findViewById(R.id.dialog_group_name)).getText().toString();
            BayunApplication.secureAuthentication.setCompanyName(companyName);
            dialog.dismiss();
        });

        dialog.show();
    }
}
