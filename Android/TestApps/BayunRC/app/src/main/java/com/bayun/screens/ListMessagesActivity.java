package com.bayun.screens;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.database.ActivityDBOperations;
import com.bayun.database.entity.ConversationInfo;
import com.bayun.database.entity.MessageInfo;
import com.bayun.http.RingCentralAPIManager;
import com.bayun.screens.adapter.MessagesAdapter;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.Utility;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;


public class ListMessagesActivity extends AbstractActivity implements SwipeRefreshLayout.OnRefreshListener {

    private RecyclerView recyclerView;
    private RecyclerView.Adapter messagesAdapter;
    private SwipeRefreshLayout swipeRefreshLayout;
    private TextView emptyView;
    private ActivityDBOperations activityDBOperations;
    private Handler.Callback callback;
    public static ArrayList<ConversationInfo> conversationInfos;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_messages);
        setUpView();
        // Callback for handling the message list.
        callback = new Handler.Callback() {
            @Override
            public boolean handleMessage(Message message) {
                if (message.what == Constants.CALLBACK_SUCCESS) {
                    swipeRefreshLayout.setRefreshing(false);
                    setListView();
                } else {
                    swipeRefreshLayout.setRefreshing(false);
                }
                return false;
            }
        };
        getMessageList();
    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));
        recyclerView = (RecyclerView) findViewById(R.id.list_files_recycler_view);
        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipeRefreshLayout);
        emptyView = (TextView) findViewById(R.id.empty_view);
        recyclerView.setHasFixedSize(true);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.addItemDecoration(new DividerItemDecoration(this));
        swipeRefreshLayout.setOnRefreshListener(this);
        messagesAdapter = new MessagesAdapter(ListMessagesActivity.this);
        recyclerView.setAdapter(messagesAdapter);
        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_ACTIVITY, Constants.EMPTY_STRING);
        activityDBOperations = new ActivityDBOperations(ListMessagesActivity.this);
    }

    /**
     * Handles User More Options Button Click.
     *
     * @param view : more Text View.
     */
    public void moreOptionsClick(View view) {
        showAlertDialogue();
    }

    @Override
    public void onRefresh() {
        swipeRefreshLayout.setRefreshing(false);
        getMessage(getLastModifiedTime());
    }

    /**
     * Shows the Alert Dialogue for create a new file or logout.
     */
    private void showAlertDialogue() {
        final CharSequence sequences[] = new CharSequence[]{"Create", "Logout"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT);
        builder.setItems(sequences, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (sequences[which].equals("Create")) {
                    Intent intent = new Intent(ListMessagesActivity.this, ListExtensionActivity.class);
                    startActivity(intent);
                } else {
                    Intent intent = new Intent(ListMessagesActivity.this, RegisterActivity.class);
                    startActivity(intent);
                    finish();
                    BayunApplication.tinyDB.clear();
                    activityDBOperations.deleteAll();
                    BayunApplication.bayunCore.logoutBayun();
                }

            }
        });
        builder.show();
    }

    /**
     * Gets Message list.
     */
    private void getMessageList() {
        String lastModifiedDate = "0";
        conversationInfos = activityDBOperations.getAllConversations();
        if (null != conversationInfos && conversationInfos.size() > 0) {
            setListView();
        } else {
            getMessage(lastModifiedDate);
        }

    }

    /**
     * Sets recycler view when data is available.
     */
    private void setListView() {
        recyclerView.setVisibility(View.VISIBLE);
        emptyView.setVisibility(View.GONE);
        conversationInfos = activityDBOperations.getAllConversations();
        Collections.sort(conversationInfos);
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                messagesAdapter.notifyDataSetChanged();

            }
        });

    }

    /**
     * Gets Message using last modified date.
     *
     * @param lastModifiedDate
     */
    private void getMessage(String lastModifiedDate) {
        if (Utility.isNetworkAvailable()) {
            RingCentralAPIManager.getInstance(BayunApplication.appContext).getMessageList(lastModifiedDate, callback);
        } else {
            Utility.messageAlertForCertainDuration(ListMessagesActivity.this, Constants.ERROR_INTERNET_OFFLINE);
        }
    }

    /**
     * Gets Last modified time.
     *
     * @return String.
     */
    private String getLastModifiedTime() {
        String lastModifiedDate = "0";
        ArrayList<MessageInfo> messageInfos = activityDBOperations.getAllMessages();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.s");
        if (null != conversationInfos && conversationInfos.size() > 0) {
            Date date = new Date();
            date.setTime(0);
            for (MessageInfo messageInfo : messageInfos) {
                if (messageInfo.getCreationTime().after(date)) {
                    date = messageInfo.getCreationTime();
                }
            }
            lastModifiedDate = dateFormat.format(date);
            BayunApplication.tinyDB.putString(Constants.CREATION_TIME, lastModifiedDate);
        }
        return lastModifiedDate;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_ACTIVITY).equalsIgnoreCase(Constants.SHARED_PREFERENCES_ACTIVITY_STATUS)) {
            getMessage(getLastModifiedTime());
        }
    }
}