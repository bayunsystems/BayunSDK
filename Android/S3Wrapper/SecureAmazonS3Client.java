/*
 * Copyright (C) Bayun Systems, Inc. All rights reserved.
 */

package com.bayun.S3wrapper;

import android.content.Context;
import android.os.Handler;

import com.amazonaws.AmazonClientException;
import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.http.HttpClient;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.AbortMultipartUploadRequest;
import com.amazonaws.services.s3.model.CompleteMultipartUploadRequest;
import com.amazonaws.services.s3.model.CompleteMultipartUploadResult;
import com.amazonaws.services.s3.model.InitiateMultipartUploadRequest;
import com.amazonaws.services.s3.model.InitiateMultipartUploadResult;
import com.amazonaws.services.s3.model.PartETag;
import com.amazonaws.services.s3.model.PutObjectResult;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.amazonaws.services.s3.model.UploadPartRequest;
import com.amazonaws.util.IOUtils;
import com.bayun.aws.AWSS3Manager;
import com.bayun.util.Constants;
import com.bayun_module.BayunCore;
import com.bayun_module.util.BayunException;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import static com.amazonaws.services.s3.internal.Constants.MB;

/**
 * <p>
 * Provides the client for accessing the Amazon S3 web service.
 * </p>
 * <p>
 * Amazon S3 provides storage for the Internet, and is designed to make
 * web-scale computing easier for developers.
 * </p>
 * <p>
 * The Amazon S3 Java Client provides a simple interface that can be used to
 * store and retrieve any amount of data, at any time, from anywhere on the web.
 * It gives any developer access to the same highly scalable, reliable, secure,
 * fast, inexpensive infrastructure that Amazon uses to run its own global
 * network of web sites. The service aims to maximize benefits of scale and to
 * pass those benefits on to developers.
 * </p>
 */

public class  SecureAmazonS3Client extends AmazonS3Client {

    private final BayunCore bayunCore;
    /**
     * Default minimum part size for upload parts. Anything below this will use
     * a single upload
     */
    static final int MINIMUM_UPLOAD_PART_SIZE = 5 * MB;

    /**
     * Constructs a new Amazon S3 client using the specified AWS credentials to
     * access Amazon S3.
     *
     * @param awsCredentials The AWS credentials to use when making requests to
     *                       Amazon S3 with this client.
     * @param context        Application context.
     * @see AmazonS3Client#AmazonS3Client()
     * @see AmazonS3Client#AmazonS3Client(AWSCredentials, ClientConfiguration)
     */
    public SecureAmazonS3Client(AWSCredentials awsCredentials, Context context) {
        super(awsCredentials);
        bayunCore = new BayunCore(context);
    }

    /**
     * Constructs a new Amazon S3 client using the specified AWS credentials and
     * client configuration to access Amazon S3.
     *
     * @param awsCredentials      The AWS credentials to use when making requests to
     *                            Amazon S3 with this client.
     * @param clientConfiguration The client configuration options controlling
     *                            how this client connects to Amazon S3 (e.g. proxy settings,
     *                            retry counts, etc).
     * @param context             Application context.
     * @see AmazonS3Client#AmazonS3Client()
     * @see AmazonS3Client#AmazonS3Client(AWSCredentials)
     */
    public SecureAmazonS3Client(AWSCredentials awsCredentials, ClientConfiguration clientConfiguration, Context context) {
        super(awsCredentials, clientConfiguration);
        bayunCore = new BayunCore(context);
    }

    /**
     * Constructs a new Amazon S3 client using the specified AWS credentials
     * provider to access Amazon S3.
     *
     * @param credentialsProvider The AWS credentials provider which will
     *                            provide credentials to authenticate requests with AWS
     *                            services.
     * @param context             Application context.
     */
    public SecureAmazonS3Client(AWSCredentialsProvider credentialsProvider, Context context) {
        super(credentialsProvider);
        bayunCore = new BayunCore(context);
    }

    /**
     * Constructs a new Amazon S3 client using the specified AWS credentials and
     * client configuration to access Amazon S3.
     *
     * @param credentialsProvider The AWS credentials provider which will
     *                            provide credentials to authenticate requests with AWS
     *                            services.
     * @param clientConfiguration The client configuration options controlling
     *                            how this client connects to Amazon S3 (e.g. proxy settings,
     *                            retry counts, etc).
     * @param context             Application context.
     */
    public SecureAmazonS3Client(AWSCredentialsProvider credentialsProvider,
                                ClientConfiguration clientConfiguration, Context context) {
        super(credentialsProvider, clientConfiguration);
        bayunCore = new BayunCore(context);
    }

    /**
     * Constructs a new Amazon S3 client using the specified AWS credentials,
     * client configuration and request metric collector to access Amazon S3.
     *
     * @param credentialsProvider The AWS credentials provider which will
     *                            provide credentials to authenticate requests with AWS
     *                            services.
     * @param httpClient          Client.
     * @param clientConfiguration The client configuration options controlling
     *                            how this client connects to Amazon S3 (e.g. proxy settings,
     *                            retry counts, etc).
     * @param context             Application context.
     */
    public SecureAmazonS3Client(AWSCredentialsProvider credentialsProvider,
                                ClientConfiguration clientConfiguration, HttpClient httpClient, Context context) {
        super(credentialsProvider, clientConfiguration, httpClient);
        bayunCore = new BayunCore(context);
    }

    /**
     * Constructs a new client using the specified client configuration to
     * access Amazon S3. A credentials provider chain will be used that searches
     * for credentials in this order:
     *
     * @param clientConfiguration The client configuration options controlling
     *                            how this client connects to Amazon S3 (e.g. proxy settings,
     *                            retry counts, etc).
     * @param context             Application context.
     * @see AmazonS3Client#AmazonS3Client(AWSCredentials)
     * @see AmazonS3Client#AmazonS3Client(AWSCredentials, ClientConfiguration)
     */
    public SecureAmazonS3Client(ClientConfiguration clientConfiguration, Context context) {
        super(clientConfiguration);
        bayunCore = new BayunCore(context);
    }

    /**
     * Starts uploading the locked file to the given bucket, using the given key
     *
     * @param bucketName The name of the bucket to upload the new object to.
     * @param key        The key in the specified bucket by which to store the new object.
     * @param file       The file to upload.
     * @return A PutObjectResult is result of uploaded file.
     */
    public PutObjectResult putObject(String bucketName, String key, File file, int encryptionPolicy,
                                     int keyGenerationPolicy, String groupId, Handler.Callback success,
                                     Handler.Callback failure) throws AmazonClientException {
        PutObjectResult putObjectResult = null;
        CompleteMultipartUploadResult completeMultipartUploadResult = null;
        bayunCore.lockFile(file.getAbsolutePath(), encryptionPolicy, keyGenerationPolicy, groupId,
                success, failure);
        try {
            if (shouldUploadInMultipart(file)) {
                completeMultipartUploadResult = multipartUpload(bucketName, key, file);
                putObjectResult = new PutObjectResult();
                putObjectResult.setETag(completeMultipartUploadResult.getETag());
                putObjectResult.setVersionId(completeMultipartUploadResult.getVersionId());
                putObjectResult.setSSEAlgorithm(completeMultipartUploadResult.getSSEAlgorithm());
                putObjectResult.setSSECustomerAlgorithm(completeMultipartUploadResult.getSSECustomerAlgorithm());
                putObjectResult.setSSECustomerKeyMd5(completeMultipartUploadResult.getSSECustomerKeyMd5());
                putObjectResult.setExpirationTime(completeMultipartUploadResult.getExpirationTime());
                putObjectResult.setExpirationTimeRuleId(completeMultipartUploadResult.getExpirationTimeRuleId());
            } else {
                putObjectResult = super.putObject(bucketName, key, file);
            }
        } catch (BayunException exception) {
            throw new AmazonClientException(exception.getMessage());
        }
        return putObjectResult;
    }

    /**
     * Starts downloading the S3 object specified by the bucket and the key to
     * the file, then unlock the file.
     *
     * @param bucketName The name of the bucket containing the object to download.
     * @param key        The key under which the object to download is stored.
     * @return A S3Object for getObjectContent.
     */
    @Override
    public S3Object getObject(String bucketName, String key) throws AmazonClientException {
        S3Object s3Object = super.getObject(bucketName, key);
        S3ObjectInputStream objectContent = s3Object.getObjectContent();

        try {
            Handler.Callback success = msg -> {
                byte fileData[] = msg.getData().getByteArray("lockedData");
                if (fileData != null) {
                    InputStream stream = new ByteArrayInputStream(fileData);
                    s3Object.setObjectContent(stream);
                }
                return false;
            };

            Handler.Callback failure = msg -> {
                throw new AmazonClientException(msg.getData().getString(Constants.ERROR));
            };

            byte[] encryptedData = IOUtils.toByteArray(objectContent);
            String groupId = null;
            if (AWSS3Manager.getInstance().getEncryptionPolicyOnDevice() == BayunCore.ENCRYPTION_POLICY_GROUP) {
                groupId = AWSS3Manager.getInstance().getGroupId();
            }
            bayunCore.lockData(encryptedData, AWSS3Manager.getInstance().getEncryptionPolicyOnDevice(),
                    AWSS3Manager.getInstance().getKeyGenerationPolicyOnDevice(), groupId, success, failure);

        } catch (BayunException | IOException exception) {
            throw new AmazonClientException(exception.getMessage());
        }
        return s3Object;
    }

    /**
     * Complete a multipart upload request.
     *
     * @param bucketName The name of the bucket to upload the new object to.
     * @param keyName    The key in the specified bucket by which to store the new
     *                   object.
     * @param file       The file to upload.
     * @return CompleteMultipartUploadRequest.
     */
    private CompleteMultipartUploadResult multipartUpload(String bucketName, String keyName, File file) {
        CompleteMultipartUploadResult completeMultipartUploadResult;
        // Create a list of UploadPartResponse objects. You get one of these for
        List<PartETag> partETags = new ArrayList<PartETag>();
        InitiateMultipartUploadRequest initRequest = new InitiateMultipartUploadRequest(
                bucketName, keyName);
        InitiateMultipartUploadResult initResponse =
                initiateMultipartUpload(initRequest);
        long contentLength = file.length();
        long partSize = 5 * 1024 * 1024; // Set part size to 5 MB.
        try {
            long filePosition = 0;
            for (int i = 1; filePosition < contentLength; i++) {
                // Last part can be less than 5 MB. Adjust part size.
                partSize = Math.min(partSize, (contentLength - filePosition));
                // Create request to upload a part.
                UploadPartRequest uploadRequest = new UploadPartRequest()
                        .withBucketName(bucketName).withKey(keyName)
                        .withUploadId(initResponse.getUploadId()).withPartNumber(i)
                        .withFileOffset(filePosition)
                        .withFile(file)
                        .withPartSize(partSize);
                // Upload part and add response to our list.
                partETags.add(uploadPart(uploadRequest).getPartETag());

                filePosition += partSize;
            }
            CompleteMultipartUploadRequest compRequest = new
                    CompleteMultipartUploadRequest(bucketName,
                    keyName,
                    initResponse.getUploadId(),
                    partETags);

            completeMultipartUploadResult = completeMultipartUpload(compRequest);
        } catch (Exception e) {
            abortMultipartUpload(new AbortMultipartUploadRequest(
                    bucketName, keyName, initResponse.getUploadId()));
            throw new AmazonClientException(e.getMessage());
        }
        return completeMultipartUploadResult;
    }

    /**
     * File multipart upload required or not.
     *
     * @param file File to upload.
     * @return True/False.
     */
    private boolean shouldUploadInMultipart(File file) {
        if (file != null
                && file.length() > MINIMUM_UPLOAD_PART_SIZE) {
            return true;
        } else {
            return false;
        }
    }
}
