package com.bayun.util;

/**
 * Created by gagan on 01-06-2015.
 */
public class Constants {

    // s3 bucket name
    public static final String S3_BUCKET_NAME = "bayunpoc";
    public static final String S3_BUCKET_NAME_PREFIX = "bayun-test-";
    public static final String ERROR_INTERNET_OFFLINE = "Internet connection appears to be offline.";

    // file upload/download messages
    public static final String ERROR_UPLOAD_FAILED = " File could not be saved. Please try again.";
    public static final String ERROR_SOMETHING_WENT_WRONG = "Something went wrong.Please try again";
    public static final String ERROR_USER_INACTIVE = "Please contact your Admin to activate your account.";
    public static final String ERROR_INCORRECT_PASSCODE = "Incorrect Passcode.";
    public static final String ERROR_MESSAGE_INVALID_CREDENTIALS = "Invalid Credentials";
    public static final String ERROR_MESSAGE_INVALID_PASSWORD = "Incorrect Password.";
    public static final String ERROR_MESSAGE_PASSCODE = "Incorrect Passcode.";
    public static final String ERROR_MESSAGE_USER_INACTIVE = "Please contact your Admin to activate your account.";
    public static final String ERROR_AUTHENTICATION_FAILED = "Authentication Failed.";
    public static final String ERROR_APP_NOT_LINKED = "Please link this app with your company employee account via Bayun admin-panel first.";

    public static final String FILE_EMPTY = "No text to be saved";
    public static final String EMPTY_STRING = "";
    public static final int START_INDEX = 0;

    public static final String APP_NAME = "BayunS3";
    public static final String BLANK_SPACE = " ";
    public static final String FILE_SAVED = "saved.";
    public static final String FILE_NAME_SPACE = " ";
    public static final String FILE_EXTENSION = ".txt";
    public static final String FILE_SIZE_KB = "KB";
    public static final String FILE_SIZE_BYTE = "bytes";
    public static final String FILE_NAME_SPLIT_CHAR = "_";
    public static final int LIST_SIZE_EMPTY = 0;

    public static final String DOWNLOAD_FILE_NAME = "file_name";
    public static final String FILE_ALREADY_EXIST = "file already exist";
    public static final long FILE_SIZE = 1024;
    public static final float FILE_PERCENTEGE = 100.0f;
    public static final String FILE_NAME_ERROR = "Please enter file name";
    public static final String LAST_MODIFIED_TIME_HOUR = "hours ago";
    public static final String LAST_MODIFIED_TIME_DAY = "days ago";
    public static final String LAST_MODIFIED_TIME_MINUTE = "minutes ago";
    public static final String LAST_MODIFIED_TIME_SECOND = "few seconds ago";

    // store value in sharedprefences in constants
    public static final String SHARED_PREFERENCES_COMPANY_NAME = "company_name";
    public static final String SHARED_PREFERENCES_LOGGED_IN = "logged_in";
    public static final String SHARED_PREFERENCES_REGISTER = "yes";

    // Response from bayun sdk handling
    public static final String AUTH_RESPONSE = "BayunAuthResponse";
    public static final String PASSCODE_REQUIRED = "BayunPasscodeRequired";
    public static final String AUTH_SUCCESS = "BayunAuthStatusSuccess";
    public static final String USER_INACTIVE = "BayunErrorUserInActive";

}
