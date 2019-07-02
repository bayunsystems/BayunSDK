package com.bayun.screens;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.http.RCAPIManager;
import com.bayun.http.model.ExtensionInfo;
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
    private RelativeLayout progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setUpView();
        // Callback for handling the extension list.
        callback = message -> {
            progressBar.setVisibility(View.GONE);

            if (message.what == Constants.CALLBACK_SUCCESS) {
                setListView();
            }
            return false;
        };
        if (Utility.isNetworkAvailable()) {
            getExtensionList();
        } else {
            Utility.displayToast(Constants.ERROR_INTERNET_OFFLINE, Toast.LENGTH_SHORT);
        }

    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        setContentView(R.layout.activity_list_extension);
        progressBar = (RelativeLayout) findViewById(R.id.progressBar);
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
        new Handler(Looper.getMainLooper()).post(() -> messagesAdapter.notifyDataSetChanged());

    }

    /**
     * Gets extensions list.
     */
    private void getExtensionList() {
        if (Utility.isNetworkAvailable()) {
            if (!isFinishing()) {
                progressBar.setVisibility(View.VISIBLE);
            }
            RCAPIManager.getInstance(BayunApplication.appContext).getExtensionList(callback);

        }
    }
}
