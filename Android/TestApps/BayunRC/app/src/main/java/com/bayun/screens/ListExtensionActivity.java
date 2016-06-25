package com.bayun.screens;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.http.RingCentralAPIManager;
import com.bayun.http.model.ExtensionInfo;
import com.bayun.http.model.ExtensionListInfo;
import com.bayun.screens.adapter.ExtensionListAdapter;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.Utility;

import java.util.ArrayList;


public class ListExtensionActivity extends AbstractActivity {

    private RecyclerView recyclerView;
    private RecyclerView.Adapter messagesAdapter;
    private TextView emptyView;
    public static ArrayList<ExtensionInfo> extensionInfoArrayList;
    private Handler.Callback callback;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setUpView();
        // Callback for handling the extension list.
        callback = new Handler.Callback() {
            @Override
            public boolean handleMessage(Message message) {
                if (message.what == Constants.CALLBACK_SUCCESS) {
                    if (progressDialog != null && progressDialog.isShowing()) {
                        progressDialog.dismiss();
                        setListView();
                    }
                } else {
                    if (progressDialog != null && progressDialog.isShowing()) {
                        progressDialog.dismiss();
                    }
                }
                return false;
            }
        };
        getExtensionList();
    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        setContentView(R.layout.activity_list_extension);
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));
        recyclerView = (RecyclerView) findViewById(R.id.list_files_recycler_view);
        emptyView = (TextView) findViewById(R.id.empty_view);
        recyclerView.setHasFixedSize(true);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.addItemDecoration(new DividerItemDecoration(this));
    }

    /**
     * Handles User Back Button Click.
     *
     * @param view : back label as a Text View.
     */
    public void backButtonImageClick(View view) {
        finish();
    }

    /**
     * Sets recycler view when data is available.
     */
    private void setListView() {
        recyclerView.setVisibility(View.VISIBLE);
        emptyView.setVisibility(View.GONE);
        messagesAdapter = new ExtensionListAdapter(ListExtensionActivity.this);
        recyclerView.setAdapter(messagesAdapter);
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                messagesAdapter.notifyDataSetChanged();
            }
        });

    }

    /**
     * Gets extensions list.
     */
    private void getExtensionList() {
        if (Utility.isNetworkAvailable()) {
            if (!isFinishing())
                progressDialog.show();
            RingCentralAPIManager.getInstance(BayunApplication.appContext).getExtensionList(callback);

        }
    }
}
