package com.bayun.screens.activity;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUser;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserAttributes;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserCodeDeliveryDetails;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.SignUpHandler;
import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.util.CognitoHelper;

public class CognitoRegisterUserActivity extends AbstractActivity {

    private EditText username;
    private EditText password;
    private EditText givenName;
    private EditText email;
    private EditText phone;

    private AlertDialog userDialog;
    private ProgressDialog waitDialog;
    private String usernameInput;
    private String userPasswd;


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
        username = (EditText) findViewById(R.id.editTextRegUserId);
        username.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegUserIdLabel);
                    label.setText(username.getHint());
                    username.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewRegUserIdMessage);
                label.setText("");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegUserIdLabel);
                    label.setText("");
                }
            }
        });

        password = (EditText) findViewById(R.id.editTextRegUserPassword);
        password.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegUserPasswordLabel);
                    label.setText(password.getHint());
                    password.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewUserRegPasswordMessage);
                label.setText("");

            }

            @Override
            public void afterTextChanged(Editable s) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegUserPasswordLabel);
                    label.setText("");
                }
            }
        });

        givenName = (EditText) findViewById(R.id.editTextRegGivenName);
        givenName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegGivenNameLabel);
                    label.setText(givenName.getHint());
                    givenName.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewRegGivenNameMessage);
                label.setText("");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegGivenNameLabel);
                    label.setText("");
                }
            }
        });

        email = (EditText) findViewById(R.id.editTextRegEmail);
        email.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegEmailLabel);
                    label.setText(email.getHint());
                    email.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewRegEmailMessage);
                label.setText("");

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegEmailLabel);
                    label.setText("");
                }
            }
        });

        phone = (EditText) findViewById(R.id.editTextRegPhone);
        phone.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegPhoneLabel);
                    label.setText(phone.getHint() + " with country code and no seperators");
                    phone.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewRegPhoneMessage);
                label.setText("");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewRegPhoneLabel);
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
                TextView view = (TextView) findViewById(R.id.textViewRegUserIdMessage);
                view.setText(username.getHint() + " cannot be empty");
                username.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                        R.drawable.text_border_error));
                return;
            }

            String userpasswordInput = password.getText().toString();
            userPasswd = userpasswordInput;
            if (userpasswordInput == null || userpasswordInput.isEmpty()) {
                TextView view = (TextView) findViewById(R.id.textViewUserRegPasswordMessage);
                view.setText(password.getHint() + " cannot be empty");
                password.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                        R.drawable.text_border_error));
                return;
            }

            String userInput = givenName.getText().toString();
            if (userInput != null) {
                if (userInput.length() > 0) {
                    userAttributes.addAttribute(CognitoHelper.getSignUpFieldsC2O().get(givenName.getHint()).toString(), userInput);
                }
            }

            userInput = email.getText().toString();
            if (userInput != null) {
                if (userInput.length() > 0) {
                    userAttributes.addAttribute(CognitoHelper.getSignUpFieldsC2O().get(email.getHint()).toString(), userInput);
                }
            }

            userInput = phone.getText().toString();
            if (userInput != null) {
                if (userInput.length() > 0) {
                    userAttributes.addAttribute(CognitoHelper.getSignUpFieldsC2O().get(phone.getHint()).toString(), userInput);
                }
            }

            showWaitDialog("Signing up...");
            BayunApplication.secureAuthentication.signUp(CognitoRegisterUserActivity.this,
                    CognitoHelper.getPool(), usernameInput, userpasswordInput, userAttributes,
                    null, signUpHandler);

        });
    }

    // Handler to maintain the signup process
    SignUpHandler signUpHandler = new SignUpHandler() {
        @Override
        public void onSuccess(CognitoUser user, boolean signUpConfirmationState,
                              CognitoUserCodeDeliveryDetails cognitoUserCodeDeliveryDetails) {
            // Check signUpConfirmationState to see if the user is already confirmed
            closeWaitDialog();
            if (signUpConfirmationState) {
                // User is already confirmed
                showDialogMessage("Sign up successful!",usernameInput+" has been Confirmed", true);
            }
            else {
                // User is not confirmed
                confirmSignUp(cognitoUserCodeDeliveryDetails);
            }
        }

        @Override
        public void onFailure(Exception exception) {
            closeWaitDialog();
            TextView label = (TextView) findViewById(R.id.textViewRegUserIdMessage);
            label.setText("Sign up failed");
            username.setBackground(ContextCompat.getDrawable(CognitoRegisterUserActivity.this,
                    R.drawable.text_border_error));
            showDialogMessage("Sign up failed", CognitoHelper.formatException(exception),false);
        }
    };

    /**
     * Sends to Sign up confirmation activity for further operations.
     *
     * @param cognitoUserCodeDeliveryDetails details for the sign up confirmation.
     */
    private void confirmSignUp(CognitoUserCodeDeliveryDetails cognitoUserCodeDeliveryDetails) {
        Intent intent = new Intent(this, SignUpConfirmActivity.class);
        intent.putExtra("source","signup");
        intent.putExtra("name", usernameInput);
        intent.putExtra("destination", cognitoUserCodeDeliveryDetails.getDestination());
        intent.putExtra("deliveryMed", cognitoUserCodeDeliveryDetails.getDeliveryMedium());
        intent.putExtra("attribute", cognitoUserCodeDeliveryDetails.getAttributeName());
        startActivityForResult(intent, 10);
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 10) {
            if(resultCode == RESULT_OK){
                String name = null;
                if(data.hasExtra("name")) {
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
        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(title).setMessage(body).setNeutralButton("OK", (dialog, which) -> {
            try {
                userDialog.dismiss();
                if(exit) {
                    exit(usernameInput);
                }
            } catch (Exception e) {
                if(exit) {
                    exit(usernameInput);
                }
            }
        });
        userDialog = builder.create();
        userDialog.show();
    }

    /**
     * Show progress dialog.
     *
     * @param message Message for the dialog box.
     */
    private void showWaitDialog(String message) {
        closeWaitDialog();
        waitDialog = new ProgressDialog(this);
        waitDialog.setTitle(message);
        waitDialog.show();
    }

    /**
     * Dismiss progress dialog.
     */
    private void closeWaitDialog() {
        try {
            waitDialog.dismiss();
        }
        catch (Exception e) {
            //
        }
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
}
