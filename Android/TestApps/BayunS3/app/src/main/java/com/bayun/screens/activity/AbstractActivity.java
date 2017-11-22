package com.bayun.screens.activity;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.pm.ActivityInfo;
import android.os.Bundle;

/**
 * Abstract Activity to be extended by all activities to have portrait mode across app
 */
public abstract class AbstractActivity extends Activity {

    protected ProgressDialog progressDialog;
    protected static ProgressDialog fileProgressDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
        if (fileProgressDialog != null && fileProgressDialog.isShowing()) {
            fileProgressDialog.dismiss();
        }
    }
}
