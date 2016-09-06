## Introduction

Bayun’s mission is to make data security and privacy as commonplace and easy to use as a smartphone itself, not just for personal data stored on mobiles, but for *all* enterprise and consumer data stored *everywhere*.
Bayun enables application developers to integrate state-of-the-art “end-to-end” security and control for all data into their apps, similar to that being incorporated by the big and powerful consumer developers, like Apple (for iPhone, iPad), Facebook (for WhatsApp, Messenger), Google (for Allo, Duo), etc. Bayun allows an application developer to *relinquish control* of customer data to the true data owner, no matter where the data is actually stored - be it on any public cloud service, or private servers, or end-devices running the applications. Through simple integration with Bayun's SDK, an application developer can not only secure all the customer data against theft or loss, but also allow the true data-owners (e.g. enterprise IT admins) to exercise *exclusive* control over their data. Without having to move the data somewhere else (e.g. in a secure vault), all data is locked on creation, with strong encryption, and kept locked throughout the entire lifecycle comprising of: (1) local device storage, (2) transmission to the server, (3) storage in the cloud, (4) transmission to other devices and/or other users, and (5) local storage on these other devices; being unlocked (decrypted) only at the point of use (by the same or different user, at the same or different device). All this while, data keys are managed through flexible lockboxes such that all data remains in exclusive control of the data-owner, with possibility of no access for application developer, *or* Bayun, *or* anyone else - like a rogue entity (similar to how Apple itself cannot technically access a customer’s data on an iPhone, even on a subpoena from FBI). An enterprise developer can allow the IT admin of each customer company to control all the data used by its employees, while a consumer app developer can give exclusive control of the user-data to the end-users directly. This not only safeguards all the data against potential breaches, external or internal; but also relinquishes the developer from the *liability* associated with being a custodian of customer data. And all this end-to-end security can be achieved without degrading the user-experience of the applications in any way what-so-ever, without even the users realizing that this locking/unlocking of data is happening in the background. The developer doesn't need to worry about complicated encryption technologies or key-management techniques, or lockbox management for enterprise policy enforcement, as all that is handled by the Bayun SDK.

The following sections give an overview of different components present in this repository.

## `BayunCoreSDK` Framework

BayunCoreSDK provides a simple to use framework for locking/unlocking of different data-types for employees of a company, including files, text, and binary data. Developers can integrate this framework into any application to start protecting the application data. This core SDK forms the basis for all security and control functionality provided by Bayun. For sample usage of the SDK, see the different example apps in TestApps folder below to get started quickly. There are also different variants of the SDK for different OS environments as follows: 

#### iOS

- `BayunCore.h`: contains methods that can be used for encryption and decryption.
- `BayunError.h`: contains the different errors thrown by the library.


#### Android

- `BayunCore.java`: contains methods that can be used for encryption and decryption.


## Bayun `S3Wrapper` SDK

As the name suggests, it provides a wrapper on top of AWS S3's original SDK, to make life easy for developers storing any part of their application data on S3. It internally relies on BayunCoreSDK to do the actual locking or unlocking of objects, before uploading them to an S3 bucket, or after downloading them from a bucket respectively. The developer uses exactly similar API as provided by the original AWS S3 SDK, and the underlying calls take care of all encryption/decryption and key-management transparently, while keeping the user or enterprise IT in full control. The developer herself doesn't need to worry about any key-management, or even having any access to any customer data or encryption keys. For sample usage of the S3Wrapper SDK, see the BayunS3 TestApp below. 

#### iOS

- `SecureAWSS3Service.h` overrides `AWSS3Service.h` provided by Amazon
- `SecureAWSS3TransferManager.h` overrides `AWSS3TransferManager.h`

#### Android

- `SecureAmazonS3Client` overrides `AmazonS3Client` provided by Amazon
- `SecureTransferUtility` overrides `TransferUtility`

## `TestApps` Sample Applications

A set of example applications that use the above SDKs to showcase common usage.

#### `BayunRC`

A sample application that uses BayunCoreSDK to provide end-to-end encryption for SMS messages. It uses RingCentral's APIs to send and receive secure "Pager" messages within the same organization. Users can login with their RingCentral phone-number and extension, and communicate securely with other extensions associated with the same main number, without RingCentral or anyone else having access to the message contents (including Bayun itself). RingCentral's own app sees these messages as garbled text.

For detailed step-by-step instructions on how to build and run the iOS application, see the README file in the folder [iOS/TestApps/BayunRC](iOS/TestApps/BayunRC).


#### `BayunS3`

Sample application that uses overridden methods from S3Wrapper SDK for secure storage onto AWS S3. The app itself works exactly similar to the case of an app using the original AWS S3 SDK directly. However, the wrapper SDK automatically encrypts a file before uploading it to the S3 bucket and decrypts it after downloading it, without the application having to deal with encryption keys, etc.

