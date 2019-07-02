package com.bayun.screens;

import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.database.ActivityDBOperations;
import com.bayun.database.entity.ConversationInfo;
import com.bayun.database.entity.MessageInfo;
import com.bayun.http.RCAPIManager;
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
    private MessagesAdapter messagesAdapter;
    private SwipeRefreshLayout swipeRefreshLayout;
    private TextView emptyView;
    private ActivityDBOperations activityDBOperations;
    private Handler.Callback callback;
    public static ArrayList<ConversationInfo> conversationInfoArrayList;
    private RelativeLayout progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_messages);
        setUpView();
        progressBar.setVisibility(View.VISIBLE);

        // Callback for handling the message list.
        callback = message -> {
            if (message.what == Constants.CALLBACK_SUCCESS) {
                swipeRefreshLayout.setRefreshing(false);
                setListView();
            } else {
                swipeRefreshLayout.setRefreshing(false);
            }
            return false;
        };
        getMessageList();
    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        progressBar = (RelativeLayout) findViewById(R.id.progressBar);
        recyclerView = (RecyclerView) findViewById(R.id.list_files_recycler_view);
        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipeRefreshLayout);
        emptyView = (TextView) findViewById(R.id.empty_view);
        recyclerView.setHasFixedSize(true);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.addItemDecoration(new DividerItemDecoration(this));
        swipeRefreshLayout.setOnRefreshListener(this);
        // reset the variable that stores if error was already shown
        Utility.isErrorShown = false;
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
        final CharSequence sequences[] = new CharSequence[]{"New message", "Logout"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT);
        builder.setItems(sequences, (dialog, which) -> {
            if (sequences[which].equals("New message")) {
                Intent intent = new Intent(ListMessagesActivity.this, ListExtensionActivity.class);
                startActivity(intent);
            } else {
                logout();
            }

        });
        builder.show();
    }

    /**
     * Gets Message list.
     */
    private void getMessageList() {
        String lastModifiedDate = "0";
        conversationInfoArrayList = activityDBOperations.getAllConversations();
        if (null != conversationInfoArrayList && conversationInfoArrayList.size() > 0) {
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
        conversationInfoArrayList = activityDBOperations.getAllConversations();
        Collections.sort(conversationInfoArrayList);

        ArrayList<String> displayTexts = new ArrayList<>();
        final int[] count = {conversationInfoArrayList.size()};
        final int[] convoIndex = {0};
        final Handler.Callback[] decryptConvoSubjects = {message -> false};

        Handler.Callback setUpRecyclerViewWhenSuccess = message -> {
            // update convo list with the display texts
            for (int i = 0; i < conversationInfoArrayList.size(); i++) {
                conversationInfoArrayList.get(i).setSubject(displayTexts.get(i));
            }

            runOnUiThread(() -> {
                progressBar.setVisibility(View.GONE);
                messagesAdapter.notifyDataSetChanged();
            });
            return false;
        };

        Handler.Callback setUpRecyclerViewWhenFailure = message -> {
            // set recycler view with the list received
            runOnUiThread(() -> {
                progressBar.setVisibility(View.GONE);
                messagesAdapter.notifyDataSetChanged();
            });
            return false;
        };

        Handler.Callback decryptTextCallback = message -> {
            // if failure was called, don't continue with the list
            if (message.getData().getBoolean(Constants.WAS_AUTHENTICATION_CANCELLED)) {
                setUpRecyclerViewWhenFailure.handleMessage(null);
            }
            // text decryption was successful
            else {
                String decryptedText = message.getData().getString(Constants.DECRYPTED_TEXT);
                if (decryptedText == null || decryptedText.isEmpty()) {
                    displayTexts.add(conversationInfoArrayList.get(convoIndex[0]).getSubject());
                }
                else {
                    displayTexts.add(decryptedText);
                }
                count[0]--;
                convoIndex[0]++;

                // if all messages have been decrypted
                if (count[0] == 0) {
                    setUpRecyclerViewWhenSuccess.handleMessage(null);
                } else {
                    decryptConvoSubjects[0].handleMessage(null);
                }
            }

            return false;
        };

        // decrypt the conversation subjects
        decryptConvoSubjects[0] = message -> {
            BayunApplication.rcCryptManager.decryptText(conversationInfoArrayList.get(convoIndex[0])
                    .getSubject(), decryptTextCallback);
            return false;
        };

        decryptConvoSubjects[0].handleMessage(null);

    }

    /**
     * Gets Message using last modified date.
     *
     * @param lastMessageDate
     */
    private void getMessage(String lastMessageDate) {
        if (Utility.isNetworkAvailable()) {
            progressBar.setVisibility(View.VISIBLE);
            RCAPIManager.getInstance(BayunApplication.appContext).getMessageList(lastMessageDate, callback);
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
        if (null != conversationInfoArrayList && conversationInfoArrayList.size() > 0) {
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

    /*@Override
    protected void onResume() {
        super.onResume();
        if (BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_ACTIVITY).equalsIgnoreCase(Constants.SHARED_PREFERENCES_ACTIVITY_STATUS)) {
            getMessage(getLastModifiedTime());
        }
    }*/

    private void logout() {
        BayunApplication.tinyDB.clear();
        activityDBOperations.deleteAll();
        BayunApplication.bayunCore.deauthenticate();
        Intent intent = new Intent(ListMessagesActivity.this, RegisterActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }

    public void onClickCalled(int position) {
        if (Utility.isNetworkAvailable()) {
            Intent intent = new Intent(ListMessagesActivity.this, ConversationViewActivity.class);
            BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_EXTENSION_NUMBER,
                    ListMessagesActivity.conversationInfoArrayList.get(position).getExtensionNumber());
            intent.putExtra(Constants.MESSAGE_NAME, ListMessagesActivity.conversationInfoArrayList
                    .get(position).getName());
            startActivityForResult(intent, 1);
        }
        else {
            Utility.messageAlertForCertainDuration(ListMessagesActivity.this,
                    Constants.ERROR_INTERNET_OFFLINE);
        }

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1) {
            getMessage(getLastModifiedTime());
            /*if (resultCode == RESULT_OK) {
                getMessage(getLastModifiedTime());
            }*/
        }
    }

    @Override
    protected void onResume() {
        //getMessageList();
        super.onResume();
    }
}
