package com.bayun.util;

/**
 * Created by gagan on 01-06-2015.
 */
public class Constants {

    // s3 bucket name
    public static final String S3_BUCKET_NAME = "bayunpoc";

    // file upload/download messages
    public static final String ERROR_UPLOAD_FAILED = " File could not be saved. Please try again.";
    public static final String ERROR_SOMETHING_WENT_WRONG  = "Something went wrong.Please try again";
    public static final String ERROR_USER_INACTIVE = "Please contact your Admin to activate your account.";
    public static final String ERROR_INCORRECT_PASSPHRASE = "Incorrect Passphrase.";
    public static final String ERROR_INTERNET_OFFLINE = "Internet connection appears to be offline.";

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
    public static final String COMPANY_NAME = "BayunS3Pool";

    public static final String DOWNLOAD_FILE_NAME = "file_name";
    public static final String SHARED_PREFERENCES_GROUP_NAME = "group_name";
    public static final String FILE_ALREADY_EXIST = "file already exist";
    public static final long FILE_SIZE = 1024;
    public static final float FILE_PERCENTAGE = 100.0f;
    public static final String FILE_NAME_ERROR = "Please enter file name";
    public static final String LAST_MODIFIED_TIME_HOUR = "hours ago";
    public static final String LAST_MODIFIED_TIME_DAY = "days ago";
    public static final String LAST_MODIFIED_TIME_MINUTE = "minutes ago";
    public static final String LAST_MODIFIED_TIME_SECOND = "few seconds ago";
    public static final String YES = "yes";

    // store value in sharedpreferences in constants
    public static final String SHARED_PREFERENCES_COMPANY_NAME = "company_name";
    public static final String SHARED_PREFERENCES_LOGGED_IN = "logged_in";
    public static final String SHARED_PREFERENCES_OLD_ENCRYPTION_POLICY_ON_DEVICE = "old_encryption_policy";
    public static final String SHARED_PREFERENCES_IS_BAYUN_LOGGED_IN = "bayun_login";
    public static final String SHARED_PREFERENCES_GROUP_ID_BEING_VIEWED = "idOfTheGroupBeingViewed";
    public static final String SHARED_PREFERENCES_KEY_GENERATION_POLICY_ON_DEVICE = "keyGenerationPolicyOnDevice";
    public static final String SHARED_PREFERENCES_CURRENT_ENCRYPTION_POLICY_ON_DEVICE = "encryptionPolicyOnDevice";

    // Response from bayun sdk
    public static final String ERROR = "BayunError";
    public static final String MY_GROUPS_ARRAY = "BayunMyGroupsArray";
    public static final String UNJOINED_GROUPS_ARRAY = "BayunUnjoinedGroupsArray";
    public static final String GET_GROUP = "BayunGetGroup";
}
