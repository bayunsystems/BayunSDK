package com.bayun.aws;

import android.os.AsyncTask;
import android.os.Environment;
import android.util.Log;
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
import com.bayun.S3wrapper.SecureAmazonS3Client;
import com.bayun.S3wrapper.SecureTransferUtility;
import com.bayun.app.BayunApplication;
import com.bayun.app.NotificationCenter;
import com.bayun.aws.model.FileInfo;
import com.bayun.util.Constants;
import com.bayun.util.Utility;
import com.bayun.R;
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
    public void uploadFile(File file, String bucketName) {

        new uploadAsyncTask().execute(file, bucketName);
    }

    /**
     * Download file from s3 server.
     *
     * @param fileName Download file by file name.
     */
    public void downloadFile(String fileName, String bucketName) {
        new DownloadFile().execute(fileName, bucketName);
    }

    /**
     * Delete file from s3 server.
     *
     * @param fileName Delete file by file name
     */
    public void deleteFileFromS3(String fileName, String bucketName) {

        new deleteFileAsyncTask().execute(fileName, bucketName);
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
    public void getListOfObjects(String bucketName) {
        new listFileAsyncTask().execute(bucketName);

    }

    /**
     * Check file already exist or not on amazon s3
     *
     * @param key The key in the specified bucket by which to store the new object.
     */
    public void Exists(String key, String bucketName) {
        new fileExistAsyncTask().execute(key, bucketName);

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
    private class uploadAsyncTask extends AsyncTask<Object, String, String> {

        @Override
        protected String doInBackground(Object... params) {
            final File file = (File) params[0];
            final String bucketName = (String) params[1];

            //[OPTIONAL] The following error handling conditions are optional and client app may apply checks against the SecureAWSS3TransferUtilityErrorType according per its requirement.
            // TransferListener is an interface that provide the state of file like completed,failed etc.
            // if we implement this then we can track progress of file.
            TransferListener transferListener = new TransferListener() {

                @Override
                public void onStateChanged(int id, TransferState state) {
                    // do something
                    if (state.equals(TransferState.COMPLETED)) {

                        Utility.RunOnUIThread(() ->
                                NotificationCenter.getInstance().postNotificationName(NotificationCenter.AWS_UPLOAD_COMPLETE));


                    } else if (state.equals(TransferState.FAILED)) {

                        Utility.RunOnUIThread(() ->
                                Utility.displayToast(Constants.ERROR_UPLOAD_FAILED, Toast.LENGTH_SHORT));
                    }
                }

                @Override
                public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                    float percentage = (((float) bytesCurrent / (float) bytesTotal) * Constants.FILE_PERCENTAGE);
                    //ListFilesActivity.showProgress((int) percentage);
                }

                @Override
                public void onError(int id, final Exception exception) {
                    Utility.RunOnUIThread(() -> {
                        Utility.showErrorMessage(exception.getMessage());
                        NotificationCenter.getInstance().postNotificationName(NotificationCenter.TRANSFER_FAILED);
                    });
                }

            };

            try {
                secureTransferUtility.secureUpload(bucketName, file.getName(), file, transferListener);
            } catch (final BayunException exception) {
                // in case of user is not active
                Utility.RunOnUIThread(() -> {
                    Utility.showErrorMessage(exception.getMessage());
                    NotificationCenter.getInstance().postNotificationName(NotificationCenter.TRANSFER_FAILED);
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
            final String bucketName = params[1];
            File file = null;
            file = new File(BayunApplication.appContext.getExternalFilesDir(
                    Environment.DIRECTORY_PICTURES), fileName);

            TransferListener transferListener = new TransferListener() {
                @Override
                public void onStateChanged(int id, TransferState state) {
                    if (state.equals(TransferState.COMPLETED)) {
                        NotificationCenter.getInstance().postNotificationName(NotificationCenter.AWS_DOWNLOAD_COMPLETE);
                    }
                }

                @Override
                public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                    float percentage = (((float) bytesCurrent / (float) bytesTotal) * 100.0f);
                    //ListFilesActivity.showProgress((int) percentage);
                }

                @Override
                public void onError(int id, final Exception exception) {
                    Utility.RunOnUIThread(new Runnable() {
                        @Override
                        public void run() {
                            Utility.showErrorMessage(exception.getMessage());
                            NotificationCenter.getInstance().postNotificationName(NotificationCenter.TRANSFER_FAILED);
                        }
                    });

                }
            };
            secureTransferUtility.secureDownload(bucketName, fileName, file, transferListener);
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
                final String bucketName = params[1];

                secureAWSS3Client.deleteObject(bucketName, fileName);
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

                   // final String region = "us-west-2";
                    secureAWSS3Client.setEndpoint(String.format("s3-%s.amazonaws.com", "us-west-2"));
                    secureAWSS3Client.setRegion(Region.getRegion(Regions.US_WEST_2));
                  //  secureAWSS3Client.setRegion(Region.getRegion(Regions.US_WEST_2));
                    secureAWSS3Client.createBucket(new CreateBucketRequest(
                            bucketName));
                    isExist = true;
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
                isExist = false;
            } catch (AmazonClientException ace) {
                System.out.println("Caught an AmazonClientException, which " +
                        "means the client encountered " +
                        "an internal error while trying to " +
                        "communicate with S3, " +
                        "such as not being able to access the network.");
                System.out.println("Error Message: " + ace.getMessage());
                isExist = false;
            }
            return isExist;
        }

        protected void onPostExecute(Boolean aBoolean) {
            super.onPostExecute(aBoolean);
            if (aBoolean) {
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_EXIST);
            }
            else {
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_ERROR);
            }
        }
    }

    /**
     * Fetch list of files using asynchronous task.
     */
    private class listFileAsyncTask extends AsyncTask<String, String, List<FileInfo>> {

        @Override
        protected List<FileInfo> doInBackground(String... params) {

            final String bucketName = params[0];
            ListObjectsRequest listObjectsRequest = new ListObjectsRequest()
                    .withBucketName(bucketName);
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
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_ERROR);
                return null;
            }

            Collections.sort(AWSS3Manager.getInstance().fileInfoList, Collections.reverseOrder());
            return AWSS3Manager.getInstance().fileList();
        }

        @Override
        protected void onPostExecute(List list) {
            if (list != null) {
                super.onPostExecute(list);
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.AWS_DOWNLOAD_LIST);
            }
        }
    }

    /**
     * Check file exist using asynchronous task.
     */
    private class fileExistAsyncTask extends AsyncTask<String, String, Boolean> {

        @Override
        protected Boolean doInBackground(String... params) throws AmazonClientException {
            final String bucketName = params[1];
            final String key = params[0];
            boolean isValidFile = true;
            try {
                secureAWSS3Client.getObjectMetadata(bucketName, key);

            } catch (AmazonS3Exception s3e) {
                if (s3e.getStatusCode() == 404) {
                    // i.e. 404: NoSuchKey - The specified key does not exist
                    isValidFile = false;
                } else {
                    throw s3e;    // rethrow all S3 exceptions other than 404
                }
            }
            return isValidFile;
        }

        @Override
        protected void onPostExecute(Boolean aBoolean) {
            super.onPostExecute(aBoolean);
            if (aBoolean) {
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_FILE_EXIST);
            } else {
                NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);
            }
        }
    }

    /**
     * Writes text into file.
     *
     * @param encryptedData encrypted data.
     */
    public void writeFile(String encryptedData, String fileName, String bucketName) {
        File file = new File(BayunApplication.appContext.getExternalFilesDir(
                Environment.DIRECTORY_PICTURES), fileName);
        try {
            Writer out = new BufferedWriter(new OutputStreamWriter(
                    new FileOutputStream(file)));
            out.write(encryptedData);
            out.close();
            AWSS3Manager.getInstance().uploadFile(file, bucketName);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Convert last modified date into time format.
     *
     * @param startDate
     * @return
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

    /**
     * Gets the encryption policy saved on device
     *
     * @return encryption policy saved on device
     */
    public int getEncryptionPolicyOnDevice() {
        return SecureTransferUtility.getEncryptionPolicyOnDevice();
    }

    /**
     * Sets the encryption policy saved on device
     *
     * @param encryptionPolicyOnDevice encryption policy save don device
     */
    public void setEncryptionPolicyOnDevice(int encryptionPolicyOnDevice) {
        SecureTransferUtility.setEncryptionPolicyOnDevice(encryptionPolicyOnDevice);
    }

    /**
     * Resets the encryption policy saved on device to default.
     */
    public void resetPoliciesOnDevice() {
        // policy 1 = default policy
        SecureTransferUtility.setEncryptionPolicyOnDevice(1);
        // kgp policy 0 = default policy
        SecureTransferUtility.setKeyGenerationPolicyOnDevice(0);
    }

    /**
     * Get the key generation policy.
     *
     * @return Key generation policy
     */
    public int getKeyGenerationPolicyOnDevice() {
        return SecureTransferUtility.getKeyGenerationPolicyOnDevice();
    }

    /**
     * Sets the key generation policy.
     *
     * @param keyGenerationPolicy policy to be saved as key generation policy
     */
    public void setKeyGenerationPolicy(int keyGenerationPolicy) {
        SecureTransferUtility.setKeyGenerationPolicyOnDevice(keyGenerationPolicy);
    }

    /**
     * Get the group id of the current group.
     *
     * @return Group id.
     */
    public String getGroupId() {
        return SecureTransferUtility.getGroupId();
    }

    /**
     * Sets the group id.
     *
     * @param groupId group id to be saved.
     */
    public void setGroupId (String groupId) {
        SecureTransferUtility.setGroupId(groupId);
    }
}


