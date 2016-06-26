## Introduction

Bayun’s mission is to make data security and privacy as common-place and easy to use as a smartphone itself, not just for personal data stored on mobiles, but for all enterprise and consumer data stored "everywhere". 

Bayun allows application developers to easily build-in same level of "end-to-end" security and control into their applications, as is provided by iPhone for local data, or by WhatsApp for messages in transit. Through simple integration with Bayun's SDK, an application developer can not only secure all the local device data as well as cloud data against theft or loss, but also allow the true data-owners to exercise exclusive control over their data. All data is locked (encrypted) on creation, and kept locked throughout the entire lifecycle comprising of: (1) local device storage, (2) transmission to the server, (3) storage in the cloud, (4) transmission to other devices and/or other users, and (5) local storage on these other devices; being unlocked (decrypted) only on use, and while still remaining in exclusive control of the data-owners. For exercise of control, an enterprise application developer can allow the IT admin of each company to control all the data used by its employees, while a consumer app developer can give exclusive control of the user-data to the end-users directly. And this can be achieved in such a way that the developer itself has no access to any of the data, just like Apple does for local iPhone data (e.g. Apple vs FBI debate on encryption). This not only safe-guards the data against potential breaches, external or internal, but also relinquishes the developer from liability of having access to any of the data. And all this end-to-end security can be achieved without degrading the user-experience of the applications in any way what-so-ever, without even the users realizing that this locking/unlocking of data is happening in the background. And application developers don't need to worry about complicated encryption technologies or key-management techniques, as all that is handled in a simple way by the Bayun SDK.

The following sections give an overview of different components present in this repository.

## `BayunCoreSDK` Framework

BayunCoreSDK provides a simple to use framework for locking/unlocking of different data-types for employees of a company, including files, text, and binary data. Developers can integrate this framework into any application to start protecting the application data. This core SDK forms the basis for all security and control functionality provided by Bayun. For example usage of the SDK, see the different sample apps in TestApps folder below to get started quickly. There are also different variants of the SDK for different OS environments as follows: 

#### iOS

- `BayunCore.h`: contains methods that can be used for encryption and decryption.
- `BayunError.h`: contains the different errors thrown by the library.


#### Android

- `BayunCore.java`: contains methods that can be used for encryption and decryption.


## Bayun `S3Wrapper` SDK

As the name suggests, it provides a wrapper SDK on top of AWS S3's original SDK, to make life easy for developers storing any part of their application data on S3. It internally relies on BayunCoreSDK to do the actual locking or unlocking of objects, before uploading them to an S3 bucket, or after downloading them from a bucket respectively. The developer uses exactly similar API as provided by the original AWS S3 SDK, and the underlying calls take care of all encryption/decryption and key-management transparently, while keeping the user or enterprise IT in full control. The developer herself doesn't need to worry about any key-management, or even having any access to any customer data or encryption keys. For sample usage of the S3Wrapper SDK, see the BayunS3 TestApp below. 

#### iOS

- `SecureAWSS3Service.h` overrides `AWSS3Service.h` provided by Amazon
- `SecureAWSS3TransferManager.h` overrides `AWSS3TransferManager.h`

#### Android

- `SecureAmazonS3Client` overrides `AmazonS3Client` provided by Amazon
- `SecureTransferUtility` overrides `TransferUtility`

## `TestApps` Sample Applications

A set of example applications that use the above SDKs to showcase common usage.

#### `BayunRC`

A sample application that uses BayunCoreSDK to provide end-to-end encryption for SMS messages. It uses RingCentral's APIs to send and receive secure messages within the same organization. Users can login with their RingCentral phone-number and extension, and communicate securely with other extensions associated with the same main number, without RingCentral or anyone else having access to the message contents (including Bayun itself). 

For detailed step-by-step instructions on how to build and run the iOS application, see the README file in the folder iOS/TestApps/BayunRC.


#### `BayunS3`

Sample application that uses overridden methods from S3Wrapper SDK for secure storage onto AWS S3. The app itself works exactly similar to the case of an app using the original AWS S3 SDK directly. However, the wrapper SDK automatically encrypts a file before uploading it to the S3 bucket and decrypts it after downloading it, without the application having to deal with encryption keys, etc.

