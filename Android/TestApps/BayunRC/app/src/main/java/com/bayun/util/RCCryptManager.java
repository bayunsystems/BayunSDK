package com.bayun.util;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;

import com.bayun.app.BayunApplication;
import com.bayun.screens.RegisterActivity;
import com.bayun_module.constants.BayunError;

import java.util.Objects;

/**
 * Created by gagan on 25/06/16.
 */
public class RCCryptManager {

    /*
     * Returns encrypted text
     */
    public void decryptText(String text, Handler.Callback callback) {

        Handler.Callback success = msg -> {
            // get the decrypted text and return it.
            if (callback != null) {
                final Message message = Message.obtain();
                final Bundle bundle = new Bundle();
                message.setData(bundle);
                bundle.putString(Constants.DECRYPTED_TEXT,
                        Objects.requireNonNull(msg.getData().getString(Constants.UNLOCKED_TEXT)).trim());
                callback.handleMessage(message);
            }
            return false;
        };

        Handler.Callback failure = msg -> {
            // if a failure occurs, show the error if related to device authentication and just
            // return the locked text as it is.
            if (!Utility.isErrorShown && BayunError.ERROR_DEVICE_PASSCODE_NOT_SET.equalsIgnoreCase(
                    msg.getData().getString(Constants.ERROR))) {
                Utility.isErrorShown = true;
                Utility.displayToast("Device passcode is not set.", Toast.LENGTH_SHORT);
            }
            else if (!Utility.isErrorShown && (BayunError.ERROR_REAUTHENTICATION_NEEDED.equalsIgnoreCase(
                    msg.getData().getString(Constants.ERROR)) || BayunError.ERROR_INVALID_APP_SECRET.equalsIgnoreCase(
                    msg.getData().getString(Constants.ERROR)))) {
                Utility.isErrorShown = true;
                Utility.displayToast("Please login again to continue.", Toast.LENGTH_SHORT);

                // logout the user
                BayunApplication.tinyDB.clear();
                BayunApplication.bayunCore.logout();
                Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                BayunApplication.appContext.startActivity(intent);
            }
            else if (!Utility.isErrorShown && BayunError.ERROR_DEVICE_AUTHENTICATION_REQUIRED.equalsIgnoreCase(
                    msg.getData().getString(Constants.ERROR))) {
                Utility.isErrorShown = true;
                String errorMessage = "Passcode Authentication Canceled By User. Please login again to continue.";
                Utility.displayToast(errorMessage, Toast.LENGTH_SHORT);

                // logout the user if logged in
                String userLoggedIn = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_LOGGED_IN);
                if (userLoggedIn.equalsIgnoreCase(Constants.SHARED_PREFERENCES_REGISTER)) {
                    BayunApplication.tinyDB.clear();
                    BayunApplication.bayunCore.logout();
                    Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    BayunApplication.appContext.startActivity(intent);
                }
            }
            // return the text
            if (callback != null) {
                final Message message = Message.obtain();
                final Bundle bundle = new Bundle();
                message.setData(bundle);
                bundle.putString(Constants.DECRYPTED_TEXT, text);
                callback.handleMessage(message);
            }
            return false;
        };

        BayunApplication.bayunCore.unlockText(text, success, failure);
    }

    /*
     * Returns decrypted text
     */
    public void encryptText(String text, Handler.Callback callback) {

        Handler.Callback success = msg -> {
            // get the encrypted string and save it in the returning variable.
            if (callback != null) {
                final Message message = Message.obtain();
                final Bundle bundle = new Bundle();
                message.setData(bundle);
                bundle.putString(Constants.ENCRYPTED_TEXT, msg.getData().getString(Constants.LOCKED_TEXT));
                callback.handleMessage(message);
            }
            return false;
        };

        Handler.Callback failure = msg -> {
            // if a failure occurs, show the error if related to device authentication and
            // return empty string.
            if (BayunError.ERROR_DEVICE_PASSCODE_NOT_SET.equalsIgnoreCase(
                    msg.getData().getString(Constants.ERROR))) {
                Utility.displayToast("Device passcode is not set.", Toast.LENGTH_SHORT);
            }
            else if (BayunError.ERROR_REAUTHENTICATION_NEEDED.equalsIgnoreCase(
                    msg.getData().getString(Constants.ERROR)) || BayunError.ERROR_INVALID_APP_SECRET.equalsIgnoreCase(
                    msg.getData().getString(Constants.ERROR))) {
                Utility.displayToast("Please login again to continue.", Toast.LENGTH_SHORT);

                // logout the user
                BayunApplication.tinyDB.clear();
                BayunApplication.bayunCore.logout();
                Intent intent = new Intent(BayunApplication.appContext, RegisterActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                BayunApplication.appContext.startActivity(intent);
            }

            // return the text
            if (callback != null) {
                final Message message = Message.obtain();
                final Bundle bundle = new Bundle();
                message.setData(bundle);
                bundle.putString(Constants.ENCRYPTED_TEXT, "");
                callback.handleMessage(message);
            }
            return false;
        };

        BayunApplication.bayunCore.lockText(text, success, failure);
    }

}
