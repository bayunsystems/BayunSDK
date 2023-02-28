package com.bayun.util;

import retrofit.RestAdapter;

/**
 * Created by gagan on 01-06-2015.
 */
public class Constants {

    public static final retrofit.RestAdapter.LogLevel RETROFIT_LOG_LEVEL = RestAdapter.LogLevel.FULL;

    public static final String APP_NAME = "BayunRC";

    public static final String BASE_URL = "https://platform.ringcentral.com";
    public static final String BASE_URL_SANDBOX = "https://platform.devtest.ringcentral.com";
    public static final String FILE_EMPTY = "No text to be saved";
    public static final String CREATION_TIME = "creation_time";
    public static final String EMPTY_STRING = "";
    public static final String STRING_NULL = null;
    public static final Long EMPTY_DATA = 0L;
    public static final String BLANK_SPACE = " ";
    public static final String MESSAGE_NAME = "name";
    public static final String LAST_MODIFIED_TIME_HOUR = "hours ago";
    public static final String LAST_MODIFIED_TIME_DAY = "days ago";
    public static final String LAST_MODIFIED_TIME_MINUTE = "minutes ago";
    public static final String LAST_MODIFIED_TIME_SECOND = "few seconds ago";
    public static final int CALLBACK_SUCCESS = 1;
    public static final int CALLBACK_FAILURE = 0;
    public static final String INBOUND = "Inbound";
    public static final String ERROR = "BayunError";
    public static final String UNLOCKED_TEXT = "unlockedText";
    public static final String LOCKED_TEXT = "lockedText";
    public static final String DECRYPTED_TEXT = "decryptedText";
    public static final String ENCRYPTED_TEXT = "encryptedText";


    public static final String SHARED_PREFERENCES_ACTIVITY = "activity";
    public static final String SHARED_PREFERENCES_ACTIVITY_STATUS = "back_button";
    public static final String SHARED_PREFERENCES_ACCESS_TOKEN = "access_token";
    public static final String SHARED_PREFERENCES_REFRESH_TOKEN = "refresh_token";
    public static final String SHARED_PREFERENCES_TOKEN_EXPIRES = "token_expires";
    public static final String GRANT_TYPE_PASSWORD = "password";
    public static final String SHARED_PREFERENCES_ACCESS_TOKEN_EXPIRATION_TIME = "access_token_expiration_time";
    public static final String SHARED_PREFERENCES_LOGGED_IN = "logged_in";
    public static final String SHARED_PREFERENCES_DEFAULT_VALUE = "no";
    public static final String SHARED_PREFERENCES_REGISTER = "yes";
    public static final String SHARED_PREFERENCES_USERNAME = "username";
    public static final String SHARED_PREFERENCES_EXTENSION = "extension";
    public static final String SHARED_PREFERENCES_PASSWORD = "password";
    public static final String SHARED_PREFERENCES_ACCOUNT_ID = "account";
    public static final String SHARED_PREFERENCES_EXTENSION_NUMBER = "ext_number";
    public static final String SHARED_PREFERENCES_IS_SANDBOX_LOGIN = "isSandboxLogin";

    public static final String ERROR_AUTHENTICATION_FAILED = "Authentication Failed.";
    public static final String ERROR_MESSAGE_INVALID_CREDENTIALS = "Invalid Credentials.";
    public static final String ERROR_MESSAGE_SESSION_EXPIRE = "Session is expired.";
    public static final String ERROR_MESSAGE_PASSCODE = "Incorrect Passcode.";
    public static final String ERROR_MESSAGE_USER_INACTIVE = "Please contact your Admin to activate your account.";
    public static final String ERROR_INTERNET_OFFLINE = "Internet connection appears to be offline.";
    public static final String ERROR_REQUEST_TIMEOUT = "Sorry, we could not contact the server. Please try again.";
    public static final String ERROR_COULD_NOT_CONNECT_TO_SERVER = "Could not connect to the server. Please try again.";
    public static final String ERROR_UNEXPECTED_HAPPENED = "Something unexpected happened on server.Please try again later.";
    public static final String ERROR_SOMETHING_WENT_WRONG = "Sorry, Something went wrong.";
    public static final String AUTH_RESPONSE = "BayunAuthResponse";
    public static final String PASSCODE_REQUIRED = "BayunPasscodeRequired";
    public static final String AUTH_SUCCESS = "BayunAuthStatusSuccess";

    public static final String DATABASE_NAME = "ringcenteral.db";
    public static final int DATABASE_VERSION = 1;

    public static final String TABLE_MESSAGE_DETAIL = "MESSAGE_ACTIVITY";
    public static final String TABLE_CONVERSATION_DETAIL = "CONVERSATION_ACTIVITY";

    public static final String ID = "id";
    public static final String CONVERSATION_MESSAGE_ID = "conversation_id";
    private static final String MESSAGE_TYPE = "type";
    private static final String MESSAGE_SENDER_EXTENSION = "sender_extension";
    private static final String MESSAGE_SENDER_NAME = "sender_name";
    private static final String MESSAGE_RECEIVER_EXTENSION = "receiver_extension";
    private static final String MESSAGE_RECEIVER_NAME = "receiver_name";
    private static final String MESSAGE_CREATION_TIME = "create_time";
    private static final String MESSAGE_SUBJECT = "subject";
    private static final String MESSAGE_STATUS = "status";

    public static final String CONVERSATION_ID = "id";
    public static final String LAST_MESSAGE_SUBJECT = "message_subject";
    public static final String LAST_MESSAGE_NAME = "message_name";
    public static final String MESSAGE_UPDATE_TIME = "create_time";
    public static final String MESSAGE_DIRECTION = "direction";
    public static final String EXTENSION_NUMBER = "extension";

    public static final String DATABASE_CREATE_TABLE_MESSAGE =
            "CREATE TABLE IF NOT EXISTS " + TABLE_MESSAGE_DETAIL +
                    "(" +
                    ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    MESSAGE_TYPE + " TEXT, " +
                    MESSAGE_DIRECTION + " TEXT, " +
                    MESSAGE_SENDER_EXTENSION + " TEXT, " +
                    MESSAGE_SENDER_NAME + " TEXT, " +
                    MESSAGE_RECEIVER_EXTENSION + " TEXT, " +
                    MESSAGE_RECEIVER_NAME + " TEXT, " +
                    MESSAGE_SUBJECT + " TEXT, " +
                    MESSAGE_STATUS + " TEXT, " +
                    MESSAGE_CREATION_TIME + " DATE, " +
                    CONVERSATION_MESSAGE_ID + " INTEGER " +
                    ");";

    public static final String DATABASE_CREATE_TABLE_CONVERSATION =
            "CREATE TABLE IF NOT EXISTS " + TABLE_CONVERSATION_DETAIL +
                    "(" + CONVERSATION_ID + " INTEGER, " +
                    LAST_MESSAGE_SUBJECT + " TEXT, " +
                    LAST_MESSAGE_NAME + " TEXT, " +
                    MESSAGE_UPDATE_TIME + " DATE, " + MESSAGE_DIRECTION + " TEXT, " + EXTENSION_NUMBER + " TEXT " +
                    ");";
}


