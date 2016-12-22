package com.bayun.http;

import android.content.SharedPreferences;
import android.util.Base64;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;
import com.squareup.okhttp.OkHttpClient;

import retrofit.RequestInterceptor;
import retrofit.RestAdapter;


class RestUtils {

    private static final RequestInterceptor loginRequestInterceptor = new RequestInterceptor() {
        @Override
        public void intercept(RequestFacade request) {

            String authHeader = "";
            // Required by Ringcentral Apis in Auth Header.
            String base64 = BayunApplication.appContext.getString(R.string.application_key) + ":" + BayunApplication.appContext.getString(R.string.application_secret);
            base64 = Base64.encodeToString(base64.getBytes(), Base64.NO_WRAP);
            authHeader = "Basic ".concat(base64);
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
            .setErrorHandler(new ErrorHandler())
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
        return BayunApplication.appContext.getString(R.string.base_url);
    }
}
