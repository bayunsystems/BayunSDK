package com.example.helloworld;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.LinearLayoutCompat;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    RelativeLayout rlayout;
    EditText etCompEmpId;
    EditText etPassword;
    Button login;
    String strCompEmpId;
    String strPassword;
    LinearLayoutCompat linearLayoutCompat;

    public  String companyNamw = "";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        rlayout = (RelativeLayout)findViewById(R.id.rlayout);
        etCompEmpId = (EditText)findViewById(R.id.et_company_emp_id);
        etPassword = (EditText)findViewById(R.id.et_password);
        login = (Button)findViewById(R.id.button);

        // For a consumer type use-case you can use app name as companyName.
        companyNamw = "company4App.<appName>";// Please edit this field and provide a unique application name.

        linearLayoutCompat = (LinearLayoutCompat) findViewById(R.id.ll_main);



        String isLoginFlag = MyApplication.mySharedPre.getString(Utility.IS_LOGIN_DONE);
        if(isLoginFlag.equalsIgnoreCase("true")){
            Intent intent = new Intent(MainActivity.this, EncryptextScreenActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK); //clear backstack
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION); //it will looks like the transition inside the app, so user will not notice login activity, instead of default animation, which look like starting other app.
            startActivity(intent);
        }

        rlayout.setVisibility(View.GONE);

        login.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        if(validation()){
            loginWithPassword(strCompEmpId,strPassword);
        }
    }

    private void loginWithPassword(String strCompEmpId, String strPassword) {
        rlayout.setVisibility(View.VISIBLE);

        Handler.Callback succ = new Handler.Callback() {
            @Override
            public boolean handleMessage(@NonNull Message message) {
                rlayout.setVisibility(View.GONE);
              MyApplication.mySharedPre.putString(Utility.IS_LOGIN_DONE,"true");

                Intent intent = new Intent(MainActivity.this, EncryptextScreenActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK); //clear backstack
               startActivity(intent);
               finish();
                return false;
            }
        };


        Handler.Callback failure = new Handler.Callback() {
            @Override
            public boolean handleMessage(@NonNull Message message) {
                rlayout.setVisibility(View.GONE);
                String error = message.getData().getString("BayunError", "");
                showData(error);
                return false;
            }
        };


        Handler.Callback auth = new Handler.Callback() {
            @Override
            public boolean handleMessage(@NonNull Message message) {
                rlayout.setVisibility(View.GONE);
                showData("need auth");
                return false;
            }
        };

        MyApplication.bayunCore.loginWithPassword(MainActivity.this,
                companyNamw,
                strCompEmpId,
                strPassword,
                true,
                auth,
                null,
                null,
                succ,
                failure);
    }




    private boolean validation() {
        strCompEmpId = etCompEmpId.getText().toString();
        strPassword = etPassword.getText().toString();

        if(TextUtils.isEmpty(strCompEmpId)){
            showData("Please enter company employee id");
            return false;
        }else if(TextUtils.isEmpty(strPassword)){
            showData("Please enter password");
            return false;
        }else {
            return true;
        }
    }


    private void showData(String unlockedText) {
        runOnUiThread(new Runnable() {
            public void run() {
                Utility.showToast(MainActivity.this,unlockedText);
            }
        });

    }


}