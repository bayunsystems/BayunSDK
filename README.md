## Get Started

Bayun’s mission is to make data security and privacy as common place and easy to use as a smartphone itself, not just for mobile data, but for all data stored everywhere.

## Bayun Framework

Bayun Framework provides support for encryption of files, text, and data.

#### iOS

- `BayunCore.h`
- `BayunError.h`

`BayunCore.h` contains methods that can be used for encryption and decryption.

* `encryptFileAtPath:success:failure:`
* `decryptFileAtPath:success:failure:`
* `encryptText:success:failure:`
* `decryptText:success:failure:`
* `encryptData:success:failure:`
* `decryptData:success:failure:`

`BayunError` contains the common errors thrown by the library.


#### Android

- `BayunCore.java`
- `BayunError.java`

`BayunCore.java` contains methods that can be used for encryption and decryption.

* `encryptText`
* `decryptText`
* `encryptFileAtPath`
* `decryptFileAtPath`
* `encryptData`
* `decryptData`


## Bayun RC

Secure chat messaging over existing architecture of RingCentral's messaging APIs.


## Bayun S3

Sample code that overrides methods from AWSS3 SDK. It encrypts a file before uploading it to the S3 bucket and decrypts a after downloading it from the S3 bucket.


## Bayun S3 Wrapper

#### iOS

- `SecureAWSS3Service.h` overrides `AWSS3Service.h`
- `SecureAWSS3TransferManager.h` overrides `AWSS3TransferManager.h`

#### Android

- `SecureAmazonS3Client` overrides `AmazonS3Client`
- `SecureTransferUtility` overrides `TransferUtility`
