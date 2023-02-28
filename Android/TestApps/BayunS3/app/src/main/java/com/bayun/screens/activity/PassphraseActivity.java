package com.bayun.screens.activity;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;
import com.bayun.util.Utility;
import com.bayun.R;


public class PassphraseActivity extends AbstractActivity {

    private EditText editBox1, editBox2, editBox3, editBox4, hiddenEditBox;
    private TextView continueButton;
    private RelativeLayout progressBar;
    private Handler.Callback successCallback, failureCallback;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_passcode);
        progressBar = (RelativeLayout) findViewById(R.id.progressBar);
        editBox1 = (EditText) findViewById(R.id.pinBox1);
        editBox2 = (EditText) findViewById(R.id.pinBox2);
        editBox3 = (EditText) findViewById(R.id.pinBox3);
        editBox4 = (EditText) findViewById(R.id.pinBox4);
        continueButton = (TextView) findViewById(R.id.continue_button);
        hiddenEditBox = (EditText) findViewById(R.id.hidden_edit);
        hiddenEditBox.requestFocus();
        continueButton.setTextColor(Color.parseColor("#9D9FA2"));

        // Success callback for passphrase validation.
        successCallback = message -> {
            runOnUiThread(() -> progressBar.setVisibility(View.GONE));
            Utility.hideKeyboard(hiddenEditBox);
            Intent intent1 = new Intent(PassphraseActivity.this, ListFilesActivity.class);
            startActivity(intent1);
            finish();
            BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_LOGGED_IN, Constants.YES);

            return false;
        };

        // Failure callback for passphrase validation.
        failureCallback = (message) -> {
            hiddenEditBox.setText("");
            editBox1.setText("");
            editBox2.setText("");
            editBox3.setText("");
            editBox4.setText("");
            Utility.displayToast(Constants.ERROR_INCORRECT_PASSPHRASE, Toast.LENGTH_SHORT);

            return false;
        };


        hiddenEditBox.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

                if (before == 0) {
                    if (hiddenEditBox.getText().length() > 3) {
                        editBox4.setText(s.subSequence(3, 4));
                        continueButton.setTextColor(Color.parseColor("#FFFFFF"));
                    }
                    else if (hiddenEditBox.getText().length() > 2) {
                        editBox3.setText(s.subSequence(2, 3));
                        continueButton.setTextColor(Color.parseColor("#9D9FA2"));
                    }
                    else if (hiddenEditBox.getText().length() > 1) {
                        editBox2.setText(s.subSequence(1, 2));
                        continueButton.setTextColor(Color.parseColor("#9D9FA2"));
                    }
                    else if (hiddenEditBox.getText().length() > 0) {
                        editBox1.setText(s.subSequence(0, 1));
                        continueButton.setTextColor(Color.parseColor("#9D9FA2"));
                    }
                }
                else {
                    continueButton.setTextColor(Color.parseColor("#9D9FA2"));
                    if (start > 2) {
                        editBox4.setText("");
                    }
                    else if (start > 1) {
                        editBox3.setText("");
                    }
                    else if (start > 0) {
                        editBox2.setText("");
                    }
                    else if (start == 0) {
                        editBox1.setText("");
                    }
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
    }

    @Override
    public void onBackPressed() {
    }

    /**
     * Manage the passphrase validation if continue button is pressed.
     *
     * @param view Button whose click will trigger the function.
     */
    public void continueClick(View view) {

    }

    /**
     * Manage if back button is pressed.
     *
     * @param view Button whose click will trigger the function.
     */
    public void backButtonImageClick(View view) {
        finish();
    }
}
