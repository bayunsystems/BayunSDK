/*
 * Copyright (C) Bayun Systems, Inc. All rights reserved.
 */
package com.bayun.S3wrapper;

import android.content.Context;

import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.services.s3.AmazonS3;
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
    // code for default encryption mode is 1
    private static int encryptionPolicyOnDevice = 1;
    private static String groupId = "";

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
        bayunCore = new BayunCore(context);
    }

    /**
     * Starts uploading the locked file to the given bucket, using the given key
     *
     * @param bucket The name of the bucket to upload the new object to.
     * @param key    The key in the specified bucket by which to store the new object.
     * @param file   The file to upload.
     * @return A SecureTransferObserver used to track upload progress and state
     */

    public TransferObserver secureUpload(String bucket, String key, File file, TransferListener transferListener)
            throws BayunException {
        if (encryptionPolicyOnDevice == BayunCore.ENCRYPTION_POLICY_DEFAULT) {
            bayunCore.lockFile(file.getAbsolutePath());
        }
        else {
            String groupId = null;
            if (encryptionPolicyOnDevice == BayunCore.ENCRYPTION_POLICY_GROUP) {
                groupId = SecureTransferUtility.groupId;
            }
            bayunCore.lockFile(file.getAbsolutePath(), encryptionPolicyOnDevice, groupId);
        }

        TransferObserver transferObserver = super.upload(bucket, key, file);
        //SecureTransferObserver secureTransferObserver = new SecureTransferObserver(transferObserver, context);
        //secureTransferObserver.setFileType("upload"); (done)
        setUploadTransferListener(transferListener, transferObserver);
        return transferObserver;
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
    public TransferObserver secureDownload(String bucket, String key, File file, TransferListener transferListener) {
        TransferObserver transferObserver = super.download(bucket, key, file);
        //SecureTransferObserver secureTransferObserver = new SecureTransferObserver(transferObserver, context);
        //secureTransferObserver.setFileType("download");
        setDownloadTransferListener(transferListener, transferObserver);
        return transferObserver;
    }

    /**
     * Gets the encryption policy saved on device
     *
     * @return encryption policy saved on device
     */
    public static int getEncryptionPolicyOnDevice() {
        return encryptionPolicyOnDevice;
    }

    /**
     * Sets the encryption policy saved on device
     *
     * @param policy encryption policy saved on device
     */
    public static void setEncryptionPolicyOnDevice(int policy) {
        encryptionPolicyOnDevice = policy;
    }

    /**
     * Gets the group id of the currently viewed group
     *
     * @return group id
     */
    public static String getGroupId() {
        return groupId;
    }

    /**
     * Set the group id
     *
     * @param groupId group id to be set
     */
    public static void setGroupId(String groupId) {
        SecureTransferUtility.groupId = groupId;
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
                        BayunCore bayunCore = new BayunCore(context);
                        try {
                            bayunCore.unlockFile(transferObserver.getAbsoluteFilePath());
                            listener.onStateChanged(id, state);
                        } catch (BayunException exception) {
                            onError(id, exception);
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















