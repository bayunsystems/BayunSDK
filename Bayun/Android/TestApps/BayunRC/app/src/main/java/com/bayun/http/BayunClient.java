package com.bayun.http;

/**
 * Created by Gagan on 23/07/15.
 */


import android.content.Intent;
import android.content.SharedPreferences;
import android.os.StrictMode;
import android.util.Log;

import com.bayun.app.BayunApplication;
import com.bayun.http.model.LoginInfo;
import com.bayun.screens.RegisterActivity;
import com.bayun.util.Constants;
import com.bayun.util.Utility;
import com.squareup.okhttp.OkHttpClient;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import retrofit.RetrofitError;
import retrofit.client.Header;
import retrofit.client.OkClient;
import retrofit.client.Request;
import retrofit.client.Response;


class BayunClient extends OkClient {

    public BayunClient(OkHttpClient client) {
        super(client);
    }

    @Override
    public Response execute(Request request) throws IOException {
        Response response = null;
        String token = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_ACCESS_TOKEN);
        String temp = "Bearer ".concat(token);
        List<Header> headers = new ArrayList<>();
        headers.add(new Header("Authorization", temp));
        headers.add(new Header("Accept-Language", "en-US,en;q=0.8"));
        StrictMode.ThreadPolicy policy =
                new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        if (!verifyAccessToken()) {
            if (Utility.isNetworkAvailable()) {
                Boolean authTokenRefreshed = getRefreshedAuthToken();
                if (authTokenRefreshed) {
                    return execute(request);
                }
            }
        } else {
            Request newReq = new Request(request.getMethod(), request.getUrl(), headers, request.getBody());
            response = super.execute(newReq);
            if (response.getStatus() == 401) {
                if (Utility.isNetworkAvailable()) {
                    Boolean authTokenRefreshed = getRefreshedAuthToken();
                    if (authTokenRefreshed) {
                        return execute(request);
                    }
                }
            }
        }
        return response;
    }

    /**
     * Returns new auth token.
     * @return True/False.
     */
    private boolean getRefreshedAuthToken() {
        String userLoggedIn = BayunApplication.settings.getString(Constants.SHARED_PREFERENCES_LOGGED_IN, Constants.SHARED_PREFERENCES_DEFAULT_VALUE);
        if (userLoggedIn.equalsIgnoreCase(Constants.SHARED_PREFERENCES_REGISTER)) {
            RestClient api = RestUtils.getLoginRestAdapter().create(RestClient.class);
            String token = BayunApplication.settings.getString(Constants.SHARED_PREFERENCES_REFRESH_TOKEN, Constants.STRING_NULL);
            if (token != null) {
                try {
                    LoginInfo loginInfo = api.getAccessToken(Constants.SHARED_PREFERENCES_REFRESH_TOKEN, token);
                    if (loginInfo != null) {
                        SharedPreferences.Editor editor = BayunApplication.settings.edit();
                        editor.putString(Constants.SHARED_PREFERENCES_ACCESS_TOKEN, loginInfo.getAccess_token());
                        editor.putString(Constants.SHARED_PREFERENCES_REFRESH_TOKEN, loginInfo.getRefresh_token());
                        editor.putLong(Constants.SHARED_PREFERENCES_ACCESS_TOKEN_EXPIRATION_TIME, loginInfo.getExpires_in());
                        Date currentDate = new Date();
                        long t = currentDate.getTime();
                        Date tokenExpireDate = new Date(t + loginInfo.getExpires_in() * 1000);
                        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_TOKEN_EXPIRES, "" + tokenExpireDate);
                        return true;
                    }
                } catch (RetrofitError error) {
                    BayunApplication.clearDB();
                    Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    BayunApplication.appContext.startActivity(intent);
                }
            } else {
                BayunApplication.clearDB();
                Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                BayunApplication.appContext.startActivity(intent);
            }
        }
        return false;
    }

    /**
     * Verifies access token
     * @return True/False.
     */
    private Boolean verifyAccessToken() {
        Boolean isTokenValid;
        String date = BayunApplication.settings.getString(Constants.SHARED_PREFERENCES_TOKEN_EXPIRES, Constants.EMPTY_STRING);
        Date currentDate = new Date();
        SimpleDateFormat formatter = new SimpleDateFormat("EEE MMM d HH:mm:ss Z yyyy");
        Date expireDate = null;
        try {
            expireDate = formatter.parse(date);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        if (currentDate.after(expireDate)) {
            isTokenValid = false;
        } else {
            isTokenValid = true;
        }
        return isTokenValid;
    }

}
