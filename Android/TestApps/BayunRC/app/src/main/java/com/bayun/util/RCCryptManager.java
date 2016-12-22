package com.bayun.util;

import android.util.Log;

import com.bayun.app.BayunApplication;
import com.bayun_module.util.BayunException;

/**
 * Created by gagan on 25/06/16.
 */

public class RCCryptManager {

    /*
    Returns encrypted text
     */
    public String decryptText(String text) {
        String decryptedText;
        try {
            decryptedText = BayunApplication.bayunCore.unlockText(text);
        } catch (BayunException exception) {
            decryptedText = text;
        }
        return decryptedText;
    }

    /*
     * Returns decrypted text
     */
    public String encryptText(String text) {
        String encryptedText;
        try {
            encryptedText = BayunApplication.bayunCore.lockText(text);
        } catch (BayunException exception) {
            Log.e("BayunException", exception.getMessage());
            encryptedText = "";
        }
        return encryptedText;
    }

}
