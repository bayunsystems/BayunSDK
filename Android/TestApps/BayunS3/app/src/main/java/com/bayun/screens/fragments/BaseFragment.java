package com.bayun.screens.fragments;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import com.bayun.util.Utility;

/**
 * Base fragment.
 *
 * Created by Akriti on 8/22/2017.
 */

public class BaseFragment extends Fragment {
    protected ProgressDialog progressDialog;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        progressDialog = Utility.createProgressDialog(getActivity(), "Please wait...");
    }

    void showProgressDialog() {
        if (progressDialog != null) {
            progressDialog.show();
        }
    }

    void dismissProgressDialog() {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        dismissProgressDialog();
    }

    @Override
    public void onPause() {
        super.onPause();
        dismissProgressDialog();
    }
}

