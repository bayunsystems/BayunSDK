package com.bayun.screens.activity;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import androidx.core.content.ContextCompat;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserCodeDeliveryDetails;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.GenericHandler;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.VerificationHandler;
import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.util.CognitoHelper;

public class SignUpConfirmActivity extends AppCompatActivity {

    private EditText username;
    private EditText confCode;
    private RelativeLayout progressBar;

    private String userName;
    private AlertDialog userDialog;

    // Handler to manage sending confirmation code procedure.
    GenericHandler confHandler = new GenericHandler() {
        @Override
        public void onSuccess() {
            runOnUiThread(() -> progressBar.setVisibility(View.GONE));
            showDialogMessage("Success!",userName+" has been confirmed!", true);
        }

        @Override
        public void onFailure(Exception exception) {
            runOnUiThread(() -> {
                runOnUiThread(() -> progressBar.setVisibility(View.GONE));

                TextView label = (TextView) findViewById(R.id.textViewConfirmUserIdMessage);
                label.setText("Confirmation failed!");
                username.setBackground(ContextCompat.getDrawable(SignUpConfirmActivity.this,
                        R.drawable.text_border_error));

                label = (TextView) findViewById(R.id.textViewConfirmCodeMessage);
                label.setText("Confirmation failed!");
                confCode.setBackground(ContextCompat.getDrawable(SignUpConfirmActivity.this,
                        R.drawable.text_border_error));

                showDialogMessage("Confirmation failed", CognitoHelper.formatException(exception), false);
            });
        }
    };

    // Handler to manage resend confirmation code procedure.
    VerificationHandler resendConfCodeHandler = new VerificationHandler() {
        @Override
        public void onSuccess(CognitoUserCodeDeliveryDetails cognitoUserCodeDeliveryDetails) {
            TextView mainTitle = (TextView) findViewById(R.id.textViewConfirmTitle);
            mainTitle.setText("Confirm your account");
            confCode = (EditText) findViewById(R.id.editTextConfirmCode);
            confCode.requestFocus();
            showDialogMessage("Confirmation code sent.","Code sent to "+cognitoUserCodeDeliveryDetails.getDestination()+" via "+cognitoUserCodeDeliveryDetails.getDeliveryMedium()+".", false);
        }

        @Override
        public void onFailure(Exception exception) {
            TextView label = (TextView) findViewById(R.id.textViewConfirmUserIdMessage);
            label.setText("Confirmation code resend failed");
            username.setBackground(ContextCompat.getDrawable(SignUpConfirmActivity.this,
                    R.drawable.text_border_error));
            showDialogMessage("Confirmation code request has failed", CognitoHelper.formatException(exception), false);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_up_confirm);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        setUpViews();
    }

    /**
     * Sets up views for the activity.
     */
    private void setUpViews() {

        progressBar = (RelativeLayout) findViewById(R.id.progress_bar);
        progressBar.setVisibility(View.GONE);

        Bundle extras = getIntent().getExtras();
        if (extras !=null) {
            if(extras.containsKey("name")) {
                userName = extras.getString("name");
                username = (EditText) findViewById(R.id.editTextConfirmUserId);
                username.setText(userName);

                confCode = (EditText) findViewById(R.id.editTextConfirmCode);
                confCode.requestFocus();

                if(extras.containsKey("destination")) {
                    String dest = extras.getString("destination");
                    String delMed = extras.getString("deliveryMed");

                    TextView screenSubtext = (TextView) findViewById(R.id.textViewConfirmSubtext_1);
                    if(dest != null && delMed != null && dest.length() > 0 && delMed.length() > 0) {
                        screenSubtext.setText("A confirmation code was sent to "+dest+" via "+delMed);
                    }
                    else {
                        screenSubtext.setText("A confirmation code was sent");
                    }
                }
            }
            else {
                TextView screenSubtext = (TextView) findViewById(R.id.textViewConfirmSubtext_1);
                screenSubtext.setText("Request for a confirmation code or confirm with the code you already have.");
            }

        }

        username = (EditText) findViewById(R.id.editTextConfirmUserId);
        username.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewConfirmUserIdLabel);
                    label.setText(username.getHint());
                    username.setBackground(ContextCompat.getDrawable(SignUpConfirmActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewConfirmUserIdMessage);
                label.setText(" ");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewConfirmUserIdLabel);
                    label.setText("");
                }
            }
        });

        confCode = (EditText) findViewById(R.id.editTextConfirmCode);
        confCode.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewConfirmCodeLabel);
                    label.setText(confCode.getHint());
                    confCode.setBackground(ContextCompat.getDrawable(SignUpConfirmActivity.this,
                            R.drawable.text_border_selector));
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                TextView label = (TextView) findViewById(R.id.textViewConfirmCodeMessage);
                label.setText(" ");
            }

            @Override
            public void afterTextChanged(Editable s) {
                if(s.length() == 0) {
                    TextView label = (TextView) findViewById(R.id.textViewConfirmCodeLabel);
                    label.setText("");
                }
            }
        });

        Button confirm = (Button) findViewById(R.id.confirm_button);
        confirm.setOnClickListener(v -> sendConfCode());

        TextView reqCode = (TextView) findViewById(R.id.resend_confirm_req);
        reqCode.setOnClickListener(v -> reqConfCode());
    }

    /**
     * Sends confirmation code.
     */
    private void sendConfCode() {

        runOnUiThread(() -> progressBar.setVisibility(View.VISIBLE));
        userName = username.getText().toString();
        String confirmCode = confCode.getText().toString();

        if(userName == null || userName.length() < 1) {
            TextView label = (TextView) findViewById(R.id.textViewConfirmUserIdMessage);
            label.setText(username.getHint()+" cannot be empty");
            username.setBackground(ContextCompat.getDrawable(SignUpConfirmActivity.this,
                    R.drawable.text_border_error));
            return;
        }

        if(confirmCode == null || confirmCode.length() < 1) {
            TextView label = (TextView) findViewById(R.id.textViewConfirmCodeMessage);
            label.setText(confCode.getHint()+" cannot be empty");
            confCode.setBackground(ContextCompat.getDrawable(SignUpConfirmActivity.this,
                    R.drawable.text_border_error));
            return;
        }

        BayunApplication.secureAuthentication.confirmSignUp(SignUpConfirmActivity.this,
                CognitoHelper.getPool().getUser(userName), confirmCode, true, confHandler);
    }

    /**
     * Resends confirmation code.
     */
    private void reqConfCode() {
        userName = username.getText().toString();
        if(userName == null || userName.length() < 1) {
            TextView label = (TextView) findViewById(R.id.textViewConfirmUserIdMessage);
            label.setText(username.getHint()+" cannot be empty");
            username.setBackground(ContextCompat.getDrawable(SignUpConfirmActivity.this,
                    R.drawable.text_border_error));
            return;
        }
        CognitoHelper.getPool().getUser(userName).resendConfirmationCodeInBackground(resendConfCodeHandler);

    }

    /**
     * Show a dialog box with message.
     *
     * @param title         Title of the dialog box.
     * @param body          Body of the dialog box.
     * @param exitActivity  Boolean if app should exit after the dialog dismisses.
     */
    private void showDialogMessage(String title, String body, final boolean exitActivity) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(title).setMessage(body).setNeutralButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                try {
                    userDialog.dismiss();
                    if(exitActivity) {
                        exit();
                    }
                } catch (Exception e) {
                    exit();
                }
            }
        });
        userDialog = builder.create();
        userDialog.show();
    }

    /**
     * Exit the particular user.
     */
    private void exit() {
        Intent intent = new Intent();
        if(userName == null)
            userName = "";
        intent.putExtra("name",userName);
        setResult(RESULT_OK, intent);
        finish();
    }
}
