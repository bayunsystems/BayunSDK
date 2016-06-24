package com.bayun.http;

import android.content.SharedPreferences;
import android.util.Base64;
import android.util.Log;

import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;
import com.squareup.okhttp.OkHttpClient;

import java.io.UnsupportedEncodingException;

import retrofit.RequestInterceptor;
import retrofit.RestAdapter;


class RestUtils {

    private static final RequestInterceptor loginRequestInterceptor = new RequestInterceptor() {
        @Override
        public void intercept(RequestFacade request) {

            String header = Constants.CLIENT_KEY + ":" + Constants.CLIENT_SECRET;
            String authHeader = "";
            // Required by Ringcentral Apis in Auth Header.
            authHeader = "Basic ".concat("NDA0QjI3QUU1MmU1ZGExM2I1ZTBDQTJGNTczNjZGNUM5OEZEMjZFMWEzNjQ5NWJlODk1RTYwNTE5MjQxYzQ5YjoyMUNGNDlBODUwNTYyNEMyODc4OGQ5MGY2Mzg5QzVENTA4ZTIyQjQ3OGZhZjY2MEVDMTYwY2Q1YUYzNjY4NTgz");
            request.addHeader("Authorization", authHeader);
            request.addHeader("Accept-Language", "en-US,en;q=0.8");
        }
    };

    private static final RequestInterceptor requestInterceptor = new RequestInterceptor() {
        @Override
        public void intercept(RequestFacade request) {

            SharedPreferences preferences = BayunApplication.settings;
            String token = preferences.getString(Constants.SHARED_PREFERENCES_ACCESS_TOKEN, Constants.EMPTY_STRING);
            token = "Bearer ".concat(token);
            request.addHeader("Authorization", token);
            request.addHeader("Accept-Language", "en-US,en;q=0.8");
        }
    };

    private static final RequestInterceptor nonAuthRequestInterceptor = new RequestInterceptor() {
        @Override
        public void intercept(RequestFacade request) {
            request.addHeader("Accept-Language", "en-US,en;q=0.8");
        }
    };

    private static final RestAdapter restAdapter = new RestAdapter.Builder()
            .setEndpoint(RestUtils.getUrl())
            .setRequestInterceptor(requestInterceptor)
            .setLogLevel(Constants.RETROFIT_LOG_LEVEL)
            .setErrorHandler(new ErrorHandler())
            .setClient(new BayunClient(new OkHttpClient()))
            .build();

    private static final RestAdapter nonRestAdapter = new RestAdapter.Builder()
            .setEndpoint(RestUtils.getUrl())
            .setRequestInterceptor(nonAuthRequestInterceptor)
            .setLogLevel(Constants.RETROFIT_LOG_LEVEL)
            .setErrorHandler(new ErrorHandler())
            .build();

    private static final RestAdapter loginRestAdapter = new RestAdapter.Builder()
            .setEndpoint(RestUtils.getUrl())
            .setRequestInterceptor(loginRequestInterceptor)
            .setLogLevel(Constants.RETROFIT_LOG_LEVEL)
            .setErrorHandler(new NonRestErrorhandler())
            .build();

    public static RestAdapter getNonRestAdapter() {
        return nonRestAdapter;
    }

    public static RestAdapter restAdapter() {
        return restAdapter;
    }

    public static RestAdapter getLoginRestAdapter() {
        return loginRestAdapter;
    }

    private static String getUrl() {
        return Constants.BASE_URL;
    }
}
