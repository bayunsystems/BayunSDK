package com.bayun.screens.activity;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoDevice;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUser;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserSession;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.AuthenticationContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.AuthenticationDetails;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.ChallengeContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.MultiFactorAuthenticationContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.AuthenticationHandler;
import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.util.CognitoHelper;
import com.bayun.util.Constants;
import com.bayun.util.Utility;

import java.util.Locale;

public class RegisterActivity extends AbstractActivity {

    // Screen fields
    private EditText inUsername;
    private EditText inPassword;

    // User Details
    private String username;
    private String password;
    private String companyName = Constants.COMPANY_NAME;


    // Handler for authentication with AWS Cognito
    AuthenticationHandler authenticationHandler = new AuthenticationHandler() {
        @Override
        public void onSuccess(CognitoUserSession cognitoUserSession, CognitoDevice device) {
            CognitoHelper.setCurrSession(cognitoUserSession);
            if (progressDialog != null && progressDialog.isShowing()) {
                progressDialog.dismiss();
            }

            // if already logged in do not save company name again, as it might overwrite it with the default company name.
            if (!BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_LOGGED_IN).equalsIgnoreCase(Constants.SHARED_PREFERENCES_REGISTER)) {
                BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_COMPANY_NAME, companyName);
                BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_LOGGED_IN, Constants.SHARED_PREFERENCES_REGISTER);
            }
            Intent intent = new Intent(RegisterActivity.this, ListFilesActivity.class);
            startActivity(intent);
            finish();
        }

        @Override
        public void getAuthenticationDetails(AuthenticationContinuation authenticationContinuation, String username) {
            Locale.setDefault(Locale.US);
            getUserAuthentication(authenticationContinuation, username);
        }

        @Override
        public void getMFACode(MultiFactorAuthenticationContinuation multiFactorAuthenticationContinuation) {

        }

        @Override
        public void onFailure(Exception e) {
            runOnUiThread(() -> {
                if (progressDialog != null && progressDialog.isShowing()) {
                    progressDialog.dismiss();
                }

                TextView label = (TextView) findViewById(R.id.textViewUserIdMessage);
                label.setText("Sign-in failed");
                inPassword.setBackground(ContextCompat.getDrawable(RegisterActivity.this,
                        R.drawable.text_border_error));

                label = (TextView) findViewById(R.id.textViewUserPasswordMessage);
                label.setText("Sign-in failed");
                inUsername.setBackground(ContextCompat.getDrawable(RegisterActivity.this,
                        R.drawable.text_border_error));

                Toast.makeText(RegisterActivity.this, CognitoHelper.formatException(e), Toast.LENGTH_SHORT).show();
            });
        }

        @Override
        public void authenticationChallenge(ChallengeContinuation continuation) {
            /**
             * For Custom authentication challenge, implement your logic to present challenge to the
             * user and pass the user's responses to the continuation.
             */
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));

        // Initialize
        CognitoHelper.init(getApplicationContext());
        BayunApplication.secureAuthentication.setCompanyName(companyName);

        setUpViews();
        findCurrent();
    }

    /**
     *  Initialize app views.
     */
    private void setUpViews() {
        inUsername = (EditText) findViewById(R.id.editTextUserId);
        inUsername.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewUserIdLabel);
                    label.setText(R.string.Username);
                    inUsername.setBackground(ContextCompat.getDrawable(RegisterActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewUserIdMessage);
                label.setText("");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewUserIdLabel);
                    label.setText("");
                }
            }
        });

        inPassword = (EditText) findViewById(R.id.editTextUserPassword);
        inPassword.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewUserPasswordLabel);
                    label.setText(R.string.Password);
                    inPassword.setBackground(ContextCompat.getDrawable(RegisterActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewUserPasswordMessage);
                label.setText("");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewUserPasswordLabel);
                    label.setText("");
                }
            }
        });
    }

    /**
     * Get the current user
     */
    private void findCurrent() {
        CognitoUser user = CognitoHelper.getPool().getCurrentUser();
        username = user.getUserId();
        if(username != null) {
            CognitoHelper.setUserId(username);
            inUsername.setText(user.getUserId());
            user.getSessionInBackground(authenticationHandler);
        }
    }

    /**
     * Get authentication details required for cognito to log a user in.
     *
     * @param continuation  AuthenticationContinuation object to continue with authentication once
     *                      it gets the auth details.
     * @param username      Username of the user to login.
     */
    private void getUserAuthentication(AuthenticationContinuation continuation, String username) {
        if(username != null) {
            this.username = username;
            CognitoHelper.setUserId(username);
        }
        if(this.password == null) {
            inUsername.setText(username);
            password = inPassword.getText().toString();
            if(password == null) {
                TextView label = (TextView) findViewById(R.id.textViewUserPasswordMessage);
                label.setText(inPassword.getHint()+" enter password");
                inPassword.setBackground(ContextCompat.getDrawable(RegisterActivity.this,
                        R.drawable.text_border_error));
                return;
            }

            if(password.length() < 1) {
                TextView label = (TextView) findViewById(R.id.textViewUserPasswordMessage);
                label.setText(inPassword.getHint()+" enter password");
                inPassword.setBackground(ContextCompat.getDrawable(RegisterActivity.this,
                        R.drawable.text_border_error));
                return;
            }
        }
        AuthenticationDetails authenticationDetails = new AuthenticationDetails(this.username, password, null);
        continuation.setAuthenticationDetails(authenticationDetails);
        continuation.continueTask();
    }

    /**
     * Login if a user is already registered.
     *
     * @param view  Button whose click will trigger the function.
     */
    public void logIn(View view) {
        username = inUsername.getText().toString();
        if(username == null || username.length() < 1) {
            TextView label = (TextView) findViewById(R.id.textViewUserIdMessage);
            label.setText(inUsername.getHint()+" cannot be empty");
            inUsername.setBackground(ContextCompat.getDrawable(RegisterActivity.this,
                    R.drawable.text_border_error));
            return;
        }

        CognitoHelper.setUserId(username);

        password = inPassword.getText().toString();
        if(password == null || password.length() < 1) {
            TextView label = (TextView) findViewById(R.id.textViewUserPasswordMessage);
            label.setText(inPassword.getHint()+" cannot be empty");
            inPassword.setBackground(ContextCompat.getDrawable(RegisterActivity.this,
                    R.drawable.text_border_error));
            return;
        }

        progressDialog.show();

        BayunApplication.secureAuthentication.signIn(RegisterActivity.this, username, password,
                CognitoHelper.getPool().getUser(username), authenticationHandler);
    }

    /**
     * Register user - start process
     *
     * @param view Button whose click will trigger the function.
     */
    public void signUp(View view) {
        Intent registerActivity = new Intent(this, CognitoRegisterUserActivity.class);
        startActivityForResult(registerActivity, 1);
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

        ((TextView)dialog.findViewById(R.id.dialog_title)).setText("Set Company Name");
        ((EditText)dialog.findViewById(R.id.dialog_group_name)).setText(companyName);
        dialog.findViewById(R.id.dialog_group_name).requestFocus();
        dialog.findViewById(R.id.dialog_employee_id).setVisibility(View.GONE);
        dialog.findViewById(R.id.dialog_spinner).setVisibility(View.GONE);

        dialog.findViewById(R.id.cancel_action).setOnClickListener(v -> dialog.dismiss());
        dialog.findViewById(R.id.ok_action).setOnClickListener(v -> {
            companyName = ((EditText)dialog.findViewById(R.id.dialog_group_name)).getText().toString();
            BayunApplication.secureAuthentication.setCompanyName(companyName);
            dialog.dismiss();
        });

        dialog.show();
    }

}
