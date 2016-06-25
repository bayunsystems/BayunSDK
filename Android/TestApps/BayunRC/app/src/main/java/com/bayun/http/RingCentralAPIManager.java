package com.bayun.http;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;

import com.bayun.app.BayunApplication;
import com.bayun.database.ActivityDBOperations;
import com.bayun.http.model.*;
import com.bayun.http.model.ExtensionListInfo;
import com.bayun.http.model.LoginInfo;
import com.bayun.http.model.MessageInfo;
import com.bayun.http.model.MessageListInfo;
import com.bayun.screens.ListExtensionActivity;

import com.bayun.util.Constants;
import com.bayun.util.Utility;

import java.util.ArrayList;
import java.util.Date;

import retrofit.RetrofitError;
import retrofit.client.Response;


/**
 * Created by Gagan on 6/29/2015.
 */
public class RingCentralAPIManager {

    private static Context appContext;
    ActivityDBOperations activityDBOperations;

    public static RingCentralAPIManager getInstance(Context context) {
        appContext = context;
        return new RingCentralAPIManager();
    }


    /**
     * Authenticates User with Ringcentral.
     *
     * @param username
     * @param extension
     * @param password
     * @param callback
     */
    public void authenticate(final Long username, final Long extension, final String password, final Handler.Callback callback) {
        RestClient api = RestUtils.getLoginRestAdapter().create(RestClient.class);
        final Message message = Message.obtain();
        api.authenticate(username, extension, password,
                Constants.GRANT_TYPE_PASSWORD,
                new retrofit.Callback<LoginInfo>() {
                    @Override
                    public void success(LoginInfo loginInfo, Response response) {
                        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_ACCESS_TOKEN, loginInfo.getAccess_token());
                        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_REFRESH_TOKEN, loginInfo.getRefresh_token());
                        BayunApplication.tinyDB.putLong(Constants.SHARED_PREFERENCES_USERNAME, username);
                        BayunApplication.tinyDB.putLong(Constants.SHARED_PREFERENCES_EXTENSION, extension);
                        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_PASSWORD, password);
                        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_ACCOUNT_ID, loginInfo.getOwner_id());
                        BayunApplication.tinyDB.putLong(Constants.SHARED_PREFERENCES_ACCESS_TOKEN_EXPIRATION_TIME, loginInfo.getExpires_in());
                        Date currentDate = new Date();
                        long t = currentDate.getTime();
                        Date tokenExpireDate = new Date(t + loginInfo.getExpires_in() * 1000);
                        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_TOKEN_EXPIRES, "" + tokenExpireDate);
                        message.what = Constants.CALLBACK_SUCCESS;
                        callback.handleMessage(message);
                    }

                    @Override
                    public void failure(RetrofitError error) {
                        if (error.getResponse() != null && error.getResponse().getStatus() == 400) {
                            Utility.displayToast(Constants.ERROR_MESSAGE_AUTHENTICATION_FAILURE, Toast.LENGTH_SHORT);
                        }
                        message.what = Constants.CALLBACK_FAILURE;
                        callback.handleMessage(message);
                    }
                });
    }

    /**
     * Gets Message list from Ringcentral.
     *
     * @param date
     * @param callback
     */
    public void getMessageList(String date, final Handler.Callback callback) {
        RestClient api = RestUtils.restAdapter().create(RestClient.class);
        final Message message = Message.obtain();
        api.getMessageList(date, new retrofit.Callback<MessageListInfo>() {
            @Override
            public void success(MessageListInfo messageListInfo, Response response) {
                activityDBOperations = new ActivityDBOperations(appContext);
                activityDBOperations.insertConversationDetails(messageListInfo);
                activityDBOperations.insertMessageDetails(messageListInfo);
                message.what = Constants.CALLBACK_SUCCESS;
                callback.handleMessage(message);
            }

            @Override
            public void failure(RetrofitError error) {
                Utility.displayToast(error.getMessage(), Toast.LENGTH_SHORT);
                message.what = Constants.CALLBACK_FAILURE;
                callback.handleMessage(message);
            }
        });
    }

    /**
     * Gets Extension List of User.
     *
     * @param callback
     */
    public void getExtensionList(final Handler.Callback callback) {
        RestClient api = RestUtils.restAdapter().create(RestClient.class);
        final Message message = Message.obtain();
        api.getExtensionList(new retrofit.Callback<ExtensionListInfo>() {
            @Override
            public void success(ExtensionListInfo extensionListInfo, Response response) {
                Long extension = BayunApplication.tinyDB.getLong(Constants.SHARED_PREFERENCES_EXTENSION, Constants.EMPTY_DATA);
                ArrayList<ExtensionInfo> extensionInfoArrayList = extensionListInfo.getRecords();
                for (int i = 0; i < extensionInfoArrayList.size(); i++) {
                    if (String.valueOf(extension).equalsIgnoreCase(extensionInfoArrayList.get(i).getExtensionNumber())) {
                        extensionInfoArrayList.remove(i);
                        break;
                    }
                }
                ListExtensionActivity.extensionInfoArrayList = extensionInfoArrayList;
                message.what = Constants.CALLBACK_SUCCESS;
                callback.handleMessage(message);
            }

            @Override
            public void failure(RetrofitError error) {
                Utility.displayToast(error.getMessage(), Toast.LENGTH_SHORT);
                message.what = Constants.CALLBACK_FAILURE;
                callback.handleMessage(message);
            }
        });
    }

    /**
     * Sends a new message.
     *
     * @param extension
     * @param callback
     */
    public void sendMessage(Extension extension, final Handler.Callback callback) {
        RestClient api = RestUtils.restAdapter().create(RestClient.class);
        final Message message = Message.obtain();
        api.sendMessage(extension, new retrofit.Callback<MessageInfo>() {
            @Override
            public void success(MessageInfo messageInfo, Response response) {
                message.what = Constants.CALLBACK_SUCCESS;
                callback.handleMessage(message);
            }

            @Override
            public void failure(RetrofitError error) {
                Utility.displayToast(error.getMessage(), Toast.LENGTH_SHORT);
                message.what = Constants.CALLBACK_FAILURE;
                callback.handleMessage(message);
            }
        });

    }
}
