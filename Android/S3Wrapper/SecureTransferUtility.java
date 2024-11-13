/*
 * Copyright © 2023 Bayun Systems, Inc. All rights reserved.
 */
 
package com.bayun.S3wrapper;

import android.content.Context;
import android.os.Handler;

import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.services.s3.AmazonS3;
import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;
import com.bayun_module.BayunCore;
import com.bayun_module.util.BayunException;

import java.io.File;


/**
 * The transfer manager is a high-level class for applications to upload and
 * download files. It inserts upload and download records into the database and
 * starts a Service to execute the tasks in the background. Here is the usage:
 * <p/>
 * <pre>
 * SecureTransferObserver transfer = secureTransferUtility.upload(bucket, key, file);
 * transfer.setListener(new TransferListener() {
 *     public onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
 *         // update progress bar
 *         progressBar.setProgress(bytesCurrent);
 *     }
 *
 *     public void onStateChanged(int id, TransferState state) {
 *     }
 *
 *     public void onError(int id, Exception ex) {
 *     }
 * });
 *
 *
 *
 */

public class SecureTransferUtility extends TransferUtility {

    private final BayunCore bayunCore;
    private final Context context;

    /**
     * Constructs a new TransferUtility specifying the client to use and
     * initializes configuration of TransferUtility and a key for S3 client weak
     * reference.
     *
     * @param s3      The client to use when making requests to Amazon S3
     * @param context The current context
     */
    public SecureTransferUtility(AmazonS3 s3, Context context) {
        super(s3, context);
        this.context = context;
        bayunCore = new BayunCore(context, context.getResources().getString(R.string.base_url),context.getResources().getString(R.string.app_id),
                context.getResources().getString(R.string.app_secret),context.getResources().getString(R.string.app_salt),BayunApplication.isDeviceLock);

    }

    /**
     * Starts uploading the locked file to the given bucket, using the given key
     *
     * @param bucket The name of the bucket to upload the new object to.
     * @param key    The key in the specified bucket by which to store the new object.
     * @param file   The file to upload.
     */

    public void secureUpload(String bucket, String key, File file, TransferListener transferListener) {
        Handler.Callback success = msg -> {
            TransferObserver transferObserver = super.upload(bucket, key, file);
            setUploadTransferListener(transferListener, transferObserver);

            return false;
        };

        Handler.Callback failure = msg -> {
            transferListener.onError(1, new Exception(msg.getData().getString(Constants.ERROR)));
            return false;
        };

        String groupId = null;
       int encryptionPolicyOnDevice = getEncryptionPolicyOnDevice();


        if (encryptionPolicyOnDevice == BayunCore.ENCRYPTION_POLICY_GROUP
                || encryptionPolicyOnDevice == BayunCore.ENCRYPTION_POLICY_GROUP_ASYMMETRIC) {
            groupId = getGroupId();
        }

        bayunCore.lockFile(file.getAbsolutePath(), encryptionPolicyOnDevice, getKeyGenerationPolicyOnDevice(),
                groupId, success, failure);
    }

    /**
     * Starts downloading the S3 object specified by the bucket and the key to
     * the file, then unlock the file.
     *
     * @param bucket The name of the bucket containing the object to download.
     * @param key    The key under which the object to download is stored.
     * @param file   The file to download the object's data to.
     * @return A SecureTransferObserver used to track download progress and state
     */
    public TransferObserver secureDownload(String bucket, String key, File file,
                                           TransferListener transferListener) {
        TransferObserver transferObserver = super.download(bucket, key, file);
        setDownloadTransferListener(transferListener, transferObserver);
        return transferObserver;
    }

    /**
     * Gets the encryption policy saved on device
     *
     * @return encryption policy saved on device
     */
    public static int getEncryptionPolicyOnDevice() {
        // code for default encryptionPolicy is 1
        return BayunApplication.tinyDB.getInt(Constants.SHARED_PREFERENCES_CURRENT_ENCRYPTION_POLICY_ON_DEVICE,
                1);
    }

    /**
     * Sets the encryption policy saved on device
     *
     * @param policy encryption policy saved on device
     */
    public static void setEncryptionPolicyOnDevice(int policy) {
        BayunApplication.tinyDB.putInt(Constants.SHARED_PREFERENCES_CURRENT_ENCRYPTION_POLICY_ON_DEVICE,
                policy);
    }

    /**
     * Gets the key generation policy.
     *
     * @return Key generation policy
     */
    public static int getKeyGenerationPolicyOnDevice() {
        // code for default KGP is 0
        return BayunApplication.tinyDB.getInt(Constants.SHARED_PREFERENCES_KEY_GENERATION_POLICY_ON_DEVICE,
                0);
    }

    /**
     * Sets the key generation policy.
     *
     * @param keyGenerationPolicyOnDevice policy to be saved as key generation policy
     */
    public static void setKeyGenerationPolicyOnDevice(int keyGenerationPolicyOnDevice) {
        BayunApplication.tinyDB.putInt(Constants.SHARED_PREFERENCES_KEY_GENERATION_POLICY_ON_DEVICE,
                keyGenerationPolicyOnDevice);
    }

    /**
     * Gets the group id of the currently viewed group
     *
     * @return group id
     */
    public static String getGroupId() {
        return BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_GROUP_ID_BEING_VIEWED);
    }

    /**
     * Set the group id
     *
     * @param groupId group id to be set
     */
    public static void setGroupId(String groupId) {
        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_GROUP_ID_BEING_VIEWED, groupId);
    }

    /**
     * Sets a listener used to receive notification when state or progress
     * changes for downloading a file.
     * <p>
     * Note that callbacks of the listener will be invoked on the main thread.
     * </p>
     *
     * @param listener A TransferListener used to receive notification.
     * @param transferObserver the pbserver to which listener is to be attached.
     */
    private void setDownloadTransferListener(final TransferListener listener,
                                             final TransferObserver transferObserver) {
        if (transferObserver != null) {
            transferObserver.setTransferListener(new TransferListener() {
                @Override
                public void onStateChanged(int id, TransferState state) {
                    if (state.equals(TransferState.COMPLETED)) {
                        BayunCore bayunCore = new BayunCore(context, context.getResources().getString(R.string.base_url),context.getResources().getString(R.string.app_id),
                                context.getResources().getString(R.string.app_secret),context.getResources().getString(R.string.app_salt),BayunApplication.isDeviceLock);;
                        try {
                            Handler.Callback unlockSuccess = msg -> {
                                listener.onStateChanged(id, state);
                                return false;
                            };

                            Handler.Callback unlockFailure = msg -> {
                                listener.onError(id, new Exception(msg.getData().getString(Constants.ERROR)));
                                return false;
                            };

                            bayunCore.unlockFile(transferObserver.getAbsoluteFilePath(), unlockSuccess,
                                    unlockFailure);
                        } catch (BayunException exception) {
                            listener.onError(id, exception);
                        }
                    } else {
                        listener.onStateChanged(id, state);
                    }
                }

                @Override
                public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                    listener.onProgressChanged(id, bytesCurrent, bytesTotal);

                }

                @Override
                public void onError(int id, Exception ex) {
                    listener.onError(id, ex);
                }
            });
        }
    }

    /**
     * Sets a listener used to receive notification when state or progress
     * changes for uploading a file.
     * <p>
     * Note that callbacks of the listener will be invoked on the main thread.
     * </p>
     *
     * @param listener A TransferListener used to receive notification.
     * @param transferObserver the pbserver to which listener is to be attached.
     */
    private void setUploadTransferListener(final TransferListener listener,
                                           final TransferObserver transferObserver) {
        if (transferObserver != null) {
            transferObserver.setTransferListener(new TransferListener() {
                @Override
                public void onStateChanged(int id, TransferState state) {
                    listener.onStateChanged(id, state);
                }

                @Override
                public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                    listener.onProgressChanged(id, bytesCurrent, bytesTotal);

                }

                @Override
                public void onError(int id, Exception ex) {
                    listener.onError(id, ex);
                }
            });
        }
    }

}