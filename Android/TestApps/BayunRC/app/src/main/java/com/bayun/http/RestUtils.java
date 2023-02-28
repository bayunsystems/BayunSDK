package com.bayun.http;

import android.content.SharedPreferences;

import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;
import com.bayun.util.Utility;

import retrofit.RequestInterceptor;
import retrofit.RestAdapter;

class RestUtils {

    private static final RequestInterceptor loginRequestInterceptor = request -> {

        String authHeader = "";
        // Required by Ringcentral Apis in Auth Header.
        authHeader = "Basic ".concat(Utility.getAuthHeader());
        request.addHeader("Authorization", authHeader);
        request.addHeader("Accept-Language", "en-US,en;q=0.8");
    };

    private static final RequestInterceptor requestInterceptor = request -> {

        SharedPreferences preferences = BayunApplication.settings;
        String token = preferences.getString(Constants.SHARED_PREFERENCES_ACCESS_TOKEN, Constants.EMPTY_STRING);
        token = "Bearer ".concat(token);
        request.addHeader("Authorization", token);
        request.addHeader("Accept-Language", "en-US,en;q=0.8");
    };

    private static final RequestInterceptor nonAuthRequestInterceptor = request ->
            request.addHeader("Accept-Language", "en-US,en;q=0.8");

    // Rest clients for production servers
    private static final RestAdapter restAdapter = new RestAdapter.Builder()
            .setEndpoint(RestUtils.getUrl())
            .setRequestInterceptor(requestInterceptor)
            .setLogLevel(Constants.RETROFIT_LOG_LEVEL)
            .setErrorHandler(new ErrorHandler())
            .setClient(new BayunClient())
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
            .setErrorHandler(new ErrorHandler())
            .build();

    // Rest clients for Sandbox servers
    private static final RestAdapter restSandboxAdapter = new RestAdapter.Builder()
            .setEndpoint(RestUtils.getSandboxUrl())
            .setRequestInterceptor(requestInterceptor)
            .setLogLevel(Constants.RETROFIT_LOG_LEVEL)
            .setErrorHandler(new ErrorHandler())
            .setClient(new BayunClient())
            .build();

    private static final RestAdapter nonRestSandboxAdapter = new RestAdapter.Builder()
            .setEndpoint(RestUtils.getSandboxUrl())
            .setRequestInterceptor(nonAuthRequestInterceptor)
            .setLogLevel(Constants.RETROFIT_LOG_LEVEL)
            .setErrorHandler(new ErrorHandler())
            .build();

    private static final RestAdapter loginRestSandboxAdapter = new RestAdapter.Builder()
            .setEndpoint(RestUtils.getSandboxUrl())
            .setRequestInterceptor(loginRequestInterceptor)
            .setLogLevel(Constants.RETROFIT_LOG_LEVEL)
            .setErrorHandler(new ErrorHandler())
            .build();

    public static RestAdapter getNonRestAdapter() {
        if (BayunApplication.tinyDB.getBoolean(Constants.SHARED_PREFERENCES_IS_SANDBOX_LOGIN, false)) {
            return nonRestSandboxAdapter;
        }
        else {
            return nonRestAdapter;
        }
    }

    public static RestAdapter restAdapter() {
        if (BayunApplication.tinyDB.getBoolean(Constants.SHARED_PREFERENCES_IS_SANDBOX_LOGIN, false)) {
            return restSandboxAdapter;
        }
        else {
            return restAdapter;
        }
    }

    public static RestAdapter getLoginRestAdapter() {
        if (BayunApplication.tinyDB.getBoolean(Constants.SHARED_PREFERENCES_IS_SANDBOX_LOGIN, false)) {
            return loginRestSandboxAdapter;
        }
        else {
            return loginRestAdapter;
        }
    }

    private static String getUrl() {
        return Constants.BASE_URL;
    }

    private static String getSandboxUrl() {
        return Constants.BASE_URL_SANDBOX;
    }
}
