package com.bayun.http;

import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import com.bayun.util.Constants;
import com.bayun.util.Utility;

import retrofit.RetrofitError;
import retrofit.client.Response;

class NonRestErrorhandler implements retrofit.ErrorHandler {

    private static final Handler MAIN_LOOPER_HANDLER = new Handler(Looper.getMainLooper());

    @Override
    public Throwable handleError(RetrofitError cause) {
        Response r = cause.getResponse();
        if (r != null) {
            switch (r.getStatus()) {
                case 400:
                    break;

                case 403:
                    break;
                case 401:
                    if (r.getUrl().contains("oauth/token")) {
                        throw cause;
                    }
                    break;
                case -1001:
                    MAIN_LOOPER_HANDLER.post(new Runnable() {
                        @Override
                        public void run() {
                            Utility.displayToast(Constants.ERROR_REQUEST_TIMEOUT, Toast.LENGTH_SHORT);
                        }
                    });

                    break;
                case -1009:
                    MAIN_LOOPER_HANDLER.post(new Runnable() {
                        @Override
                        public void run() {
                            Utility.displayToast(Constants.ERROR_INTERNET_OFFLINE, Toast.LENGTH_SHORT);
                        }
                    });

                    break;
                case 500:
                    MAIN_LOOPER_HANDLER.post(new Runnable() {
                        @Override
                        public void run() {
                            Utility.displayToast(Constants.ERROR_UNEXPECTED_HAPPENED, Toast.LENGTH_SHORT);
                        }
                    });

                    break;
                default:
                    MAIN_LOOPER_HANDLER.post(new Runnable() {
                        @Override
                        public void run() {
                            Utility.displayToast(Constants.ERROR_COULD_NOT_CONNECT_TO_SERVER, Toast.LENGTH_SHORT);
                        }
                    });

                    break;
            }
        } else {
            MAIN_LOOPER_HANDLER.post(new Runnable() {
                @Override
                public void run() {
                    Utility.displayToast(Constants.ERROR_COULD_NOT_CONNECT_TO_SERVER, Toast.LENGTH_SHORT);
                }
            });
        }
        return cause;
    }

}

