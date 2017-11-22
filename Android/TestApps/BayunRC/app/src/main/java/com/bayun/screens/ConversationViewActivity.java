package com.bayun.screens;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.database.ActivityDBOperations;
import com.bayun.database.entity.MessageInfo;
import com.bayun.http.RCAPIManager;
import com.bayun.http.model.CallerInfo;
import com.bayun.http.model.Extension;
import com.bayun.screens.adapter.ConversationViewAdapter;
import com.bayun.util.Constants;
import com.bayun.util.Utility;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.TimerTask;


public class ConversationViewActivity extends AbstractActivity {
    private RecyclerView recyclerView;
    private RecyclerView.Adapter conversationAdapter;
    private TextView emptyView, senderName;
    private EditText messageEditText;
    private Button sendButton;
    private ActivityDBOperations activityDBOperations;
    private Handler.Callback callback, messageCallback;
    public static ArrayList<MessageInfo> messageInfoArrayList = new ArrayList<>();
    private String messageId, extensionNumber, name;
    private Extension extension;
    private static Handler handler = new Handler();
    int flag = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_conversation);
        setUpView();
        // Callback for handling the message list.
        callback = new Handler.Callback() {
            @Override
            public boolean handleMessage(Message message) {
                if (message.what == Constants.CALLBACK_SUCCESS) {
                    if (messageId.equalsIgnoreCase(Constants.EMPTY_STRING))
                        messageId = activityDBOperations.getConversationId(extensionNumber);
                    getConversationList(messageId);
                }
                return false;
            }
        };
        // Callback for handling the send message.
        messageCallback = new Handler.Callback() {
            @Override
            public boolean handleMessage(Message message) {
                if (message.what == Constants.CALLBACK_SUCCESS) {
                    messageEditText.setText(Constants.EMPTY_STRING);
                    getMessage(getLastModifiedTime());
                }
                return false;
            }
        };
        messageEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.toString().trim().length() == 0) {
                    sendButton.setEnabled(false);
                    sendButton.setTextColor(getResources().getColor(R.color.disabled));
                } else {
                    sendButton.setEnabled(true);
                    sendButton.setTextColor(getResources().getColor(R.color.background));

                }
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                                          int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        getConversationList(messageId);

    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));
        senderName = (TextView) findViewById(R.id.sender_name);
        sendButton = (Button) findViewById(R.id.send);
        recyclerView = (RecyclerView) findViewById(R.id.list_files_recycler_view);
        messageEditText = (EditText) findViewById(R.id.editText1);
        emptyView = (TextView) findViewById(R.id.empty_view);
        recyclerView.setHasFixedSize(true);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);
        messageInfoArrayList.clear();
        conversationAdapter = new ConversationViewAdapter(ConversationViewActivity.this);
        recyclerView.setAdapter(conversationAdapter);
        activityDBOperations = new ActivityDBOperations(ConversationViewActivity.this);
        Intent intent = getIntent();
        extensionNumber = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_EXTENSION_NUMBER);
        name = intent.getExtras().getString(Constants.MESSAGE_NAME, Constants.EMPTY_STRING);
        messageId = activityDBOperations.getConversationId(extensionNumber);
        senderName.setText(name);
        if (Utility.isNetworkAvailable()) {
            handler.post(runnable);

           /* timer = new Timer();
            timer.schedule(new RefreshView(), 0, 10000);*/
        }

    }

    /**
     * Gets conversation list using conversation id
     *
     * @param id conversation id
     */
    private void getConversationList(String id) {
        messageInfoArrayList = activityDBOperations.getAllMessagesById(id);
        if (null != messageInfoArrayList && messageInfoArrayList.size() > 0) {
            setListView();
        }
    }

    /**
     * Gets message list using last modified date.
     *
     * @param lastMessageDate last message date.
     */
    private void getMessage(String lastMessageDate) {
        if (Utility.isNetworkAvailable()) {
            RCAPIManager.getInstance(BayunApplication.appContext).getMessageList(lastMessageDate, callback);
        } else {
            Utility.displayToast(Constants.ERROR_INTERNET_OFFLINE, Toast.LENGTH_SHORT);
        }
    }

    /**
     * Handles User Back Button Click.
     *
     * @param view back button view.
     */
    public void backButtonImageClick(View view) {
        stopTimer();
        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_ACTIVITY,
                Constants.SHARED_PREFERENCES_ACTIVITY_STATUS);
        finish();
    }

    /**
     * Handles User Send Button Click.
     *
     * @param view
     */
    public void sendClick(View view) {
        String message = messageEditText.getText().toString();
        if (message.equalsIgnoreCase(Constants.EMPTY_STRING)) {
            Utility.displayToast(Constants.FILE_EMPTY, Toast.LENGTH_SHORT);
        } else {
            String encryptedText = BayunApplication.rcCryptManager.encryptText(message);
            if (encryptedText.isEmpty()) {
                Utility.displayToast("Message could not be sent.", Toast.LENGTH_SHORT);
            } else {
                flag = 1;
                message(encryptedText);
                sendNewMessage();
            }
            Utility.hideKeyboard(view);
        }
    }

    /**
     * Sends a new message.
     */
    private void sendNewMessage() {
        if (Utility.isNetworkAvailable()) {
            if (!isFinishing())
                RCAPIManager.getInstance(BayunApplication.appContext).sendMessage(extension, messageCallback);
        } else {
            Utility.displayToast(Constants.ERROR_INTERNET_OFFLINE, Toast.LENGTH_SHORT);
        }
    }

    /**
     * Creates a new message.
     *
     * @param message new message
     */
    private void message(String message) {
        Long ownExtensionNumber = BayunApplication.tinyDB.getLong(Constants.SHARED_PREFERENCES_EXTENSION, Constants.EMPTY_DATA);
        extension = new Extension();
        extension.setText(message);
        CallerInfo sender = new CallerInfo();
        sender.setExtensionNumber(String.valueOf(ownExtensionNumber));
        ArrayList<CallerInfo> receiverArrayList = new ArrayList<>();
        CallerInfo receiver = new CallerInfo();
        receiver.setExtensionNumber(extensionNumber);
        receiverArrayList.add(receiver);
        extension.setFrom(sender);
        extension.setTo(receiverArrayList);
    }

    /**
     * Sets recycler view when data is available.
     */
    private void setListView() {
        recyclerView.setVisibility(View.VISIBLE);
        emptyView.setVisibility(View.GONE);
        recyclerView.scrollToPosition(messageInfoArrayList.size() - 1);
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                conversationAdapter.notifyDataSetChanged();

            }
        });
    }

    /**
     * Gets last modified time of conversation.
     *
     * @return last message time.
     */
    private String getLastModifiedTime() {
        String lastModifiedDate = "0";
        ArrayList<MessageInfo> messages = activityDBOperations.getAllMessages();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.s");
        if (null != messages && messages.size() > 0) {
            Date date = new Date();
            date.setTime(0);
            for (MessageInfo messageInfo : messages) {
                if (messageInfo.getCreationTime().after(date)) {
                    date = messageInfo.getCreationTime();
                }
            }
            lastModifiedDate = dateFormat.format(date);
        }
        return lastModifiedDate;
    }

    private class RefreshView extends TimerTask {
        public void run() {
            if (Utility.isNetworkAvailable()) {
                getMessage(getLastModifiedTime());
            }
        }
    }

    private Runnable runnable = new Runnable() {
        @Override
        public void run() {
            if (Utility.isNetworkAvailable()) {
                getMessage(getLastModifiedTime());
            }
            handler.postDelayed(this, 10000);
        }
    };

    @Override
    public void onBackPressed() {
        // super.onBackPressed();
        stopTimer();
        Intent intent = new Intent();
        if(flag==1)
        {
            setResult(RESULT_OK, intent);
        }else
        {
            setResult(RESULT_CANCELED, intent);
        }


        finish();
    }

    public void stopTimer() {
        if (handler != null)
            handler.removeCallbacks(runnable);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopTimer();
    }
}
