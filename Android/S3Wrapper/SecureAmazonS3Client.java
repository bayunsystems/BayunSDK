/*
 * Copyright (C) Bayun Systems, Inc. All rights reserved.
 */

package com.bayun_module.S3wrapper;

import android.content.Context;

import com.amazonaws.AmazonClientException;
import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.http.HttpClient;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.PutObjectResult;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.bayun_module.BayunCore;
import com.bayun_module.util.BayunException;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

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
 *
 *
 */

public class SecureAmazonS3Client extends AmazonS3Client {

    private final BayunCore bayunCore;

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
     * Starts uploading the encrypted file to the given bucket, using the given key
     *
     * @param bucketName The name of the bucket to upload the new object to.
     * @param key        The key in the specified bucket by which to store the new                   object.
     * @param file       The file to upload.
     * @return A PutObjectResult is result of uploaded file.
     */
    public PutObjectResult putObject(String bucketName, String key, File file) throws AmazonClientException {
        PutObjectResult putObjectResult = null;
        try {
            bayunCore.encryptFileAtPath(file.getAbsolutePath());
            putObjectResult = super.putObject(bucketName, key, file);
        } catch (BayunException exception) {
            throw new AmazonClientException(exception.getMessage());
        }
        return putObjectResult;
    }

    /**
     * Starts downloading the S3 object specified by the bucket and the key to
     * the file, then decrypt the file.
     *
     * @param bucketName The name of the bucket containing the object to download.
     * @param key        The key under which the object to download is stored.
     * @return A S3Object for getObjectContent.
     */
    @Override
    public S3Object getObject(String bucketName, String key) throws AmazonClientException {
        S3Object s3Object = super.getObject(bucketName, key);
        S3ObjectInputStream objectContent = s3Object.getObjectContent();
        byte fileData[];
        try {
            byte[] encryptedData = readFile(objectContent);
            fileData = bayunCore.decryptData(encryptedData);
            InputStream stream = new ByteArrayInputStream(fileData);
            s3Object.setObjectContent(stream);
        } catch (BayunException | IOException exception) {
            throw new AmazonClientException(exception.getMessage());
        }
        return s3Object;
    }

    /**
     * Read s3 object input stream data.
     *
     * @param s3ObjectInputStream input stream object.
     * @return byte data.
     */
    private static byte[] readFile(S3ObjectInputStream s3ObjectInputStream) throws IOException {
        StringBuilder out = null;
        String fileData = "";
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(s3ObjectInputStream));
            out = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                out.append(line);
            }
            fileData = out.toString();
            reader.close();
        } catch (IOException e) {
            throw new IOException(e.getMessage());
        }
        return fileData.getBytes();
    }

}







