/*
 * Copyright (C) Bayun Systems, Inc. All rights reserved.
 */
package com.bayun.S3wrapper;

import android.content.Context;

import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
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

    public SecureTransferObserver upload(String bucket, String key, File file) throws BayunException {

        bayunCore.lockFile(file.getAbsolutePath());
        TransferObserver transferObserver = super.upload(bucket, key, file);
        SecureTransferObserver secureTransferObserver = new SecureTransferObserver(transferObserver, context);
        secureTransferObserver.setFileType("upload");
        return secureTransferObserver;
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
    public SecureTransferObserver download(String bucket, String key, File file) {
        TransferObserver transferObserver = super.download(bucket, key, file);
        SecureTransferObserver secureTransferObserver = new SecureTransferObserver(transferObserver, context);
        secureTransferObserver.setFileType("download");
        return secureTransferObserver;
    }
}














