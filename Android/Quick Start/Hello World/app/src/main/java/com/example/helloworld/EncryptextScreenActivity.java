package com.example.helloworld;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

public class EncryptextScreenActivity extends AppCompatActivity implements View.OnClickListener {
    TextView tv_text;
    TextView tv_text_unlock;
    EditText et_text;
    Button button_lock;
    Button button_unlock;
    String strLockedText;
    ImageView simpleImageView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_encryptext_screen);

        tv_text_unlock = (TextView) findViewById(R.id.tv_text_unlock);
        tv_text = (TextView) findViewById(R.id.tv_text);
        et_text = (EditText) findViewById(R.id.et_text);
        button_lock = (Button) findViewById(R.id.button_lock);
        button_unlock = (Button) findViewById(R.id.button_unlock);
        simpleImageView = (ImageView) findViewById(R.id.simpleImageView);



        button_lock.setOnClickListener(this);
        button_unlock.setOnClickListener(this);
        simpleImageView.setOnClickListener(this);

    }

    @Override
    public void onClick(View view) {
        switch (view.getId()){
            case R.id.button_lock:
                lockText();
                break;

            case R.id.button_unlock:
                unLockText(strLockedText);
                break;

                case R.id.simpleImageView:
               logout();
                break;
        }


    }

    private void logout() {
        MyApplication.mySharedPre.clear();
        MyApplication.bayunCore.logout();
        startActivity(new Intent(EncryptextScreenActivity.this, MainActivity.class));
        finish();
    }

    private void lockText() {
        String text = et_text.getText().toString();
        if(TextUtils.isEmpty(text)){
            showData("Please enter the task");
        }else {
            Handler.Callback success = new Handler.Callback() {
                @Override
                public boolean handleMessage(@NonNull Message message) {
                    strLockedText = message.getData().getString("lockedText", "");
                    if(!TextUtils.isEmpty(strLockedText)){
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                setDateInUnlockView(strLockedText);
                            }
                        });

                    }

                    return false;
                }
            };

            Handler.Callback failure = new Handler.Callback() {
                @Override
                public boolean handleMessage(@NonNull Message message) {
                    String error = message.getData().getString("BayunError", "");
                    showData(error);
                    return false;
                }
            };
            MyApplication.bayunCore.lockText(text, success, failure);
        }

    }

    private void setDateInUnlockView(String strLockedText) {
        tv_text.setText(strLockedText);
    }

    private void unLockText(String lockStr) {
      //  String lockStr = tv_text.getText().toString();
        if(TextUtils.isEmpty(lockStr)){
            showData("Please enter the task");
        }else {
            // Callbacks for unlocking text
            Handler.Callback success = new Handler.Callback() {
                @Override
                public boolean handleMessage(Message message) {
                    String unlockedText = message.getData().getString("unlockedText", "");
                    tv_text_unlock.setText(unlockedText);
             //  showData(unlockedText);
                    return false;
                }
            };

            Handler.Callback failure = new Handler.Callback() {
                @Override
                public boolean handleMessage(@NonNull Message message) {
                    String error = message.getData().getString("BayunError", "");
                    showData(error);

                    return false;
                }
            };
            MyApplication.bayunCore.unlockText(lockStr, success, failure);
        }

    }

    private void showData(String unlockedText) {
       runOnUiThread(new Runnable() {
            public void run() {
                Utility.showToast(EncryptextScreenActivity.this,unlockedText);
            }
        });

    }
}