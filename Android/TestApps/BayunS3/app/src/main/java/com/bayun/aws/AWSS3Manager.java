package com.bayun.aws;

import android.os.AsyncTask;
import android.os.Environment;
import android.widget.Toast;

import com.amazonaws.AmazonClientException;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.model.CreateBucketRequest;
import com.amazonaws.services.s3.model.AmazonS3Exception;
import com.amazonaws.services.s3.model.ListObjectsRequest;
import com.amazonaws.services.s3.model.ObjectListing;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import com.bayun.R;
import com.bayun.S3wrapper.SecureAmazonS3Client;
import com.bayun.S3wrapper.SecureTransferObserver;
import com.bayun.S3wrapper.SecureTransferUtility;
import com.bayun.app.BayunApplication;
import com.bayun.app.NotificationCenter;
import com.bayun.aws.model.FileInfo;
import com.bayun.screens.ListFilesActivity;
import com.bayun.util.Constants;
import com.bayun.util.Utility;
import com.bayun_module.util.BayunException;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

/**
 * Created by Gagan on 01/06/15.
 */

public class AWSS3Manager {

    private List<FileInfo> fileInfoList;
    private static volatile AWSS3Manager sharedInstance = null;
    private static SecureTransferUtility secureTransferUtility = null;
    private static SecureAmazonS3Client secureAWSS3Client = null;

    public static AWSS3Manager getInstance() {
        AWSS3Manager localInstance = sharedInstance;

        if (localInstance == null) {
            AWSCredentials credentialsProvider = new AWSCredentials() {
                @Override
                public String getAWSAccessKeyId() {
                    return BayunApplication.appContext.getString(R.string.aws_access_key);
                }

                @Override
                public String getAWSSecretKey() {
                    return BayunApplication.appContext.getString(R.string.aws_secret_key);
                }
            };
            synchronized (AWSS3Manager.class) {
                localInstance = sharedInstance;
                if (localInstance == null) {
                    sharedInstance = localInstance = new AWSS3Manager();
                    secureAWSS3Client = new SecureAmazonS3Client(credentialsProvider, BayunApplication.appContext);
                    secureTransferUtility = new SecureTransferUtility(secureAWSS3Client, BayunApplication.appContext);
                    sharedInstance.fileInfoList = new ArrayList<FileInfo>();
                }
            }
        }
        return sharedInstance;
    }

    /**
     * Upload file on amazon s3 server.
     *
     * @param file New file for upload.
     */
    public void uploadFile(File file) {

        new uploadAsyncTask().execute(file);
    }

    /**
     * Download file from s3 server.
     *
     * @param fileName Download file by file name.
     */
    public void downloadFile(String fileName) {

        new DownloadFile().execute(fileName);
    }

    /**
     * Delete file from s3 server.
     *
     * @param fileName Delete file by file name
     */
    public void deleteFileFromS3(String fileName) {

        new deleteFileAsyncTask().execute(fileName);
    }

    /**
     * Create bucket on s3 server if not exist.
     *
     * @param bucketName bucket name.
     */
    public void createBucketOnS3(String bucketName) {

        new createBucketAsyncTask().execute(bucketName);
    }

    /**
     * Gets list of objects from amazon s3.
     */
    public void getListOfObjects() {
        new listFileAsyncTask().execute();

    }

    /**
     * Check file already exist or not on amazon s3
     *
     * @param key The key in the specified bucket by which to store the new object.
     */
    public void Exists(String key) {
        new fileExistAsyncTask().execute(key);
    }

    /**
     * Gets list of objects using asynchronous task.
     *
     * @return list of file.
     */
    public List<FileInfo> fileList() {
        return this.fileInfoList;
    }

    /**
     * Upload file using asynchronous task.
     */
    private class uploadAsyncTask extends AsyncTask<File, String, String> {

        @Override
        protected String doInBackground(File... params) {
            final File file = params[0];
            SecureTransferObserver observer = null;

            try {
                observer = secureTransferUtility.upload(getBucketName(), file.getName(), file);
            } catch (final BayunException exception) {
                // in case of user is not active
                Utility.RunOnUIThread(new Runnable() {
                    @Override
                    public void run() {
                        if (exception.getMessage().equalsIgnoreCase(Constants.USER_INACTIVE)) {
                            Utility.displayToast(Constants.ERROR_USER_INACTIVE, Toast.LENGTH_LONG);
                        }
                        NotificationCenter.getInstance().postNotificationName(NotificationCenter.TRANSFER_FAILED);
                    }
                });
            }

            if (observer != null) {
                //[OPTIONAL] The following error handling conditions are optional and client app may apply checks against the SecureAWSS3TransferUtilityErrorType according per its requirement.
                // TransferListener is an interface that provide the state of file like completed,failed etc.
                // if we implement this then we can track progress of file.
                observer.setTransferListener(new TransferListener() {

                    @Override
                    public void onStateChanged(int id, TransferState state) {
                        // do something
                        if (state.equals(TransferState.COMPLETED)) {

                            Utility.RunOnUIThread(new Runnable() {
                                @Override
                                public void run() {

                                    NotificationCenter.getInstance().postNotificationName(NotificationCenter.AWS_UPLOAD_COMPLETE);
                                }
                            });


                        } else if (state.equals(TransferState.FAILED)) {

                            Utility.RunOnUIThread(new Runnable() {
                                @Override
                                public void run() {

                                    Utility.displayToast(Constants.ERROR_UPLOAD_FAILED, Toast.LENGTH_SHORT);
                                }
                            });
                        }
                    }

                    @Override
                    public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                        float percentage = (((float) bytesCurrent / (float) bytesTotal) * Constants.FILE_PERCENTEGE);
                        ListFilesActivity.showProgress((int) percentage);
                    }

                    @Override
                    public void onError(int id, final Exception exception) {
                        Utility.RunOnUIThread(new Runnable() {
                            @Override
                            public void run() {
                                if (exception.getMessage().equalsIgnoreCase(BayunApplication.appContext.getString(R.string.something_went_wrong)))
                                    Utility.displayToast(Constants.ERROR_SOMETHING_WENT_WRONG, Toast.LENGTH_LONG);
                                    //[OPTIONAL] The following error handling conditions are optional
                                else if (exception.getMessage().equalsIgnoreCase(Constants.USER_INACTIVE)) {
                                    Utility.displayToast(Constants.ERROR_USER_INACTIVE, Toast.LENGTH_LONG);
                                }
                                NotificationCenter.getInstance().postNotificationName(NotificationCenter.TRANSFER_FAILED);
                            }
                        });
                    }

                });
            }
            return "";
        }
    }

    /**
     * Download file using asynchronous task.
     */
    private class DownloadFile extends AsyncTask<String, String, String> {
        @Override
        protected String doInBackground(String... params) {
            String fileName = params[0];
            File file = null;
            file = new File(BayunApplication.appContext.getExternalFilesDir(
                    Environment.DIRECTORY_PICTURES), fileName);
            SecureTransferObserver transferObserver = secureTransferUtility.download(getBucketName(), fileName, file);
            transferObserver.setTransferListener(new TransferListener() {
                @Override
                public void onStateChanged(int id, TransferState state) {
                    if (state.equals(TransferState.COMPLETED)) {
                        NotificationCenter.getInstance().postNotificationName(NotificationCenter.AWS_DOWNLOAD_COMPLETE);
                    }
                }

                @Override
                public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                    float percentage = (((float) bytesCurrent / (float) bytesTotal) * 100.0f);
                    ListFilesActivity.showProgress((int) percentage);
                }

                @Override
                public void onError(int id, final Exception exception) {
                    Utility.RunOnUIThread(new Runnable() {
                        @Override
                        public void run() {
                            if (exception.getMessage().equalsIgnoreCase(BayunApplication.appContext.getString(R.string.something_went_wrong)))
                                Utility.displayToast(Constants.ERROR_SOMETHING_WENT_WRONG, Toast.LENGTH_LONG);

                                //[OPTIONAL] The following error handling conditions are optional
                            else if (exception.getMessage().equalsIgnoreCase(Constants.USER_INACTIVE)) {
                                Utility.displayToast(Constants.ERROR_USER_INACTIVE, Toast.LENGTH_LONG);
                            }
                            NotificationCenter.getInstance().postNotificationName(NotificationCenter.TRANSFER_FAILED);
                        }
                    });

                }
            });
            return "";
        }
    }

    /**
     * Delete file object on s3 using s3 bucket name and file name.
     */
    private class deleteFileAsyncTask extends AsyncTask<String, String, String> {
        @Override
        protected String doInBackground(String... params) {
            try {
                String fileName = params[0];
                secureAWSS3Client.deleteObject(getBucketName(), fileName);
            } catch (AmazonServiceException ase) {
                System.out.println("Caught an AmazonServiceException.");
                System.out.println("Error Message:    " + ase.getMessage());
                System.out.println("HTTP Status Code: " + ase.getStatusCode());
                System.out.println("AWS Error Code:   " + ase.getErrorCode());
                System.out.println("Error Type:       " + ase.getErrorType());
                System.out.println("Request ID:       " + ase.getRequestId());
            } catch (AmazonClientException ace) {
                System.out.println("Caught an AmazonClientException.");
                System.out.println("Error Message: " + ace.getMessage());
            }
            return "";
        }

    }

    /**
     * Create bucket on s3 server if not exist.
     */
    private class createBucketAsyncTask extends AsyncTask<String, String, Boolean> {

        @Override
        protected Boolean doInBackground(String... params) {

            Boolean isExist = false;
            try {
                String bucketName = params[0];
                if (!(secureAWSS3Client.doesBucketExist(bucketName))) {
                    // Note that CreateBucketRequest does not specify region. So bucket is
                    // created in the region specified in the client.
                    secureAWSS3Client.setRegion(Region.getRegion(Regions.US_WEST_2));
                    secureAWSS3Client.createBucket(new CreateBucketRequest(
                            bucketName));
                } else {
                    isExist = true;
                }
            } catch (AmazonServiceException ase) {
                System.out.println("Caught an AmazonServiceException, which " +
                        "means your request made it " +
                        "to Amazon S3, but was rejected with an error response" +
                        " for some reason.");
                System.out.println("Error Message:    " + ase.getMessage());
                System.out.println("HTTP Status Code: " + ase.getStatusCode());
                System.out.println("AWS Error Code:   " + ase.getErrorCode());
                System.out.println("Error Type:       " + ase.getErrorType());
                System.out.println("Request ID:       " + ase.getRequestId());
            } catch (AmazonClientException ace) {
                System.out.println("Caught an AmazonClientException, which " +
                        "means the client encountered " +
                        "an internal error while trying to " +
                        "communicate with S3, " +
                        "such as not being able to access the network.");
                System.out.println("Error Message: " + ace.getMessage());
            }
            return isExist;
        }

        protected void onPostExecute(Boolean aBoolean) {
            super.onPostExecute(aBoolean);
            if (aBoolean) {
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_EXIST);
            }
        }
    }

    /**
     * Fetch list of files using asynchronous task.
     */
    private class listFileAsyncTask extends AsyncTask<String, String, List<FileInfo>> {

        @Override
        protected List<FileInfo> doInBackground(String... params) {

            ListObjectsRequest listObjectsRequest = new ListObjectsRequest()
                    .withBucketName(getBucketName());
            ObjectListing objectListing;
            fileInfoList.clear();
            try {
                do {
                    objectListing = secureAWSS3Client.listObjects(listObjectsRequest);

                    for (S3ObjectSummary objectSummary :
                            objectListing.getObjectSummaries()) {
                        FileInfo fileInfo = new FileInfo();
                        fileInfo.setDate(objectSummary.getLastModified());
                        fileInfo.setFileName(objectSummary.getKey());
                        fileInfo.setSize(objectSummary.getSize());
                        fileInfo.setLastModifiedTime(getLastModifiedTime(objectSummary.getLastModified()));
                        AWSS3Manager.getInstance().fileInfoList.add(fileInfo);

                    }
                    listObjectsRequest.setMarker(objectListing.getNextMarker());
                } while (objectListing.isTruncated());
            } catch (AmazonS3Exception e) {
                Toast.makeText(BayunApplication.appContext, e.getErrorMessage(), Toast.LENGTH_SHORT).show();
            }

            Collections.sort(AWSS3Manager.getInstance().fileInfoList, Collections.reverseOrder());
            return AWSS3Manager.getInstance().fileList();
        }

        @Override
        protected void onPostExecute(List list) {
            super.onPostExecute(list);
            NotificationCenter.getInstance().postNotificationName(NotificationCenter.AWS_DOWNLOAD_LIST);
        }
    }

    /**
     * Check file exist using asynchronous task.
     */
    private class fileExistAsyncTask extends AsyncTask<String, String, String> {

        @Override
        protected String doInBackground(String... params) {
            final String key = params[0];
            String fileExist = "exist";

            try {
                secureAWSS3Client.getObjectMetadata(getBucketName(), key);
            } catch (AmazonS3Exception s3e) {
                if (s3e.getStatusCode() == 404) {
                    // i.e. 404: NoSuchKey - The specified key does not exist
                    fileExist = "not exist";
                } else {
                    fileExist = "error";
                }
            }
            return fileExist;
        }

        @Override
        protected void onPostExecute(String s) {
            super.onPostExecute(s);
            if (s.equalsIgnoreCase("exist")) {
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_FILE_EXIST);
            } else if (s.equalsIgnoreCase("not exist")) {
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);
            } else {
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_EXCEPTION);
            }
        }
    }

    /**
     * Get BUcket Name.
     *
     * @return bucket name.
     */
    private String getBucketName() {
        String bucketName = BayunApplication.tinyDB.getString(Constants.S3_BUCKET_NAME);
        return bucketName;
    }

    /**
     * Writes text into file.
     *
     * @param encryptedData encrypted data.
     */
    public void writeFile(String encryptedData, String fileName) {
        File file = new File(BayunApplication.appContext.getExternalFilesDir(
                Environment.DIRECTORY_PICTURES), fileName);
        try {
            Writer out = new BufferedWriter(new OutputStreamWriter(
                    new FileOutputStream(file)));
            out.write(encryptedData);
            out.close();
            AWSS3Manager.getInstance().uploadFile(file);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Convert last modified date into time format.
     *
     * @param startDate
     * @return last modified date.
     */
    public String getLastModifiedTime(Date startDate) {
        String time = "";
        long different = System.currentTimeMillis() - startDate.getTime();
        long secondsInMilli = 1000;
        long minutesInMilli = secondsInMilli * 60;
        long hoursInMilli = minutesInMilli * 60;
        long daysInMilli = hoursInMilli * 24;
        long elapsedDays = different / daysInMilli;
        different = different % daysInMilli;
        long elapsedHours = different / hoursInMilli;
        different = different % hoursInMilli;
        long elapsedMinutes = different / minutesInMilli;
        if (elapsedDays > 1) {
            time = elapsedDays + Constants.BLANK_SPACE + Constants.LAST_MODIFIED_TIME_DAY;
        } else if (elapsedHours > 1) {

            time = elapsedHours + Constants.BLANK_SPACE + Constants.LAST_MODIFIED_TIME_HOUR;
        } else if (elapsedMinutes > 1) {
            time = elapsedMinutes + Constants.BLANK_SPACE + Constants.LAST_MODIFIED_TIME_MINUTE;
        } else {
            time = Constants.LAST_MODIFIED_TIME_SECOND;
        }
        return time;
    }
}


