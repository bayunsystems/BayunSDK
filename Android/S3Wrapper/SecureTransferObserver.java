/*
 * Copyright (C) Bayun Systems, Inc. All rights reserved.
 */
package com.bayun_module.S3wrapper;

import android.content.Context;

import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.bayun_module.BayunCore;
import com.bayun_module.constants.Constants;
import com.bayun_module.util.BayunException;

/**
 * SecureTransferObserver is used to track state and progress of a transfer.
 * Applications can set a listener and will get notified when progress or state
 * changes.
 * <p>
 * For example, you can track the progress of an upload as the following:
 * </p>
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
 */

public class SecureTransferObserver extends TransferObserver {

    private String fileType;
    private String errorMessage = "";
    private final Context context;

    /**
     * Constructs a TransferObserver and initializes fields with the given
     * arguments.
     *
     * @param transferObserver pass id,context and bytes.
     */
    public SecureTransferObserver(TransferObserver transferObserver, Context context) {
        super(transferObserver.getId(), BayunCore.appContext, transferObserver.getBytesTotal());
        this.context = context;
    }

    /**
     * Sets a listener used to receive notification when state or progress
     * changes.
     * <p>
     * Note that callbacks of the listener will be invoked on the main thread.
     * </p>
     *
     * @param listener A TransferListener used to receive notification.
     */
    @Override
    public void setTransferListener(final TransferListener listener) {
        super.setTransferListener(new TransferListener() {
            @Override
            public void onStateChanged(int id, TransferState state) {
                if (getFileType().equals(Constants.DOWNLOADED_FILE)) {
                    if (state.equals(TransferState.COMPLETED)) {
                        BayunCore bayunCore = new BayunCore(context);
                        try {
                            bayunCore.decryptFileAtPath(getAbsoluteFilePath());
                            listener.onStateChanged(id, state);
                        } catch (BayunException exception) {
                            listener.onError(id, exception);
                        }
                    } else {
                        listener.onStateChanged(id, state);
                    }
                } else {
                    listener.onStateChanged(id, state);
                    if (!getErrorMessage().equalsIgnoreCase("")) {

                        listener.onError(id, new BayunException(getErrorMessage()));
                    }
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

    /**
     * Gets file type download or upload.
     *
     * @return file type.
     */
    private String getFileType() {
        return fileType;
    }

    /**
     * Sets file type download or upload.
     *
     * @param fileType download or upload.
     */
    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    /**
     * Sets Error Message.
     *
     * @return Bayun exception.
     */
    private String getErrorMessage() {
        return errorMessage;
    }

    /**
     * Gets Error Message.
     *
     * @param errorMessage Bayun Exception.
     */
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
}
