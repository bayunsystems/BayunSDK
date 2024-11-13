## BayunS3

BayunS3 is a sample application that uses overridden methods from AWSS3 SDK for secure storage onto AWS S3. For details, see [Documentation](https://bayun.gitbook.io/bayun-awss3-wrapper-javascript-programming-guide/).

## Getting Started

Register as a developer on the Admin Panel(https://digilockbox.com/admin).

On the admin panel, register an email address. You will be asked to set security questions, and an optional passphrase, and select Developer as the account role. After registering as a developer on Bayun, you can create an application in the developer console. You need to provide your App name.

We provide you with a Base URL, Application Id, Application Salt, Application Secret and Bayun Server Public Key when your app is registered with Bayun.

The BaseURL, Application Id, Application Salt, and Application Secret will be needed along with the other authentication information when you authenticate with Bayun's Lockbox Management Server to use Bayun features.

These should be kept secure. You MUST register every new app with Bayun, and use a different Application Id, Application Salt, and Application Secret for every app. Otherwise, the data security of your apps will potentially be compromised, and the admin-panel functionality of different apps (used as a dashboard by enterprise admins for control and visibility) is also likely to get mixed up.

## Instructions for use

1. Check out the latest code for the BayunS3 sample application, along with Bayun SDK,
   by cloning the top-level BayunSDK repository.

2. Open the BayunS3 project in VSCode.

3. You will need your CognitoIdentityUserPoolRegion, CognitoIdentityUserPoolId,
   CognitoIdentityUserPoolAppClientId. Place the respective values in the js/config.js file.

4. You are provided with an Application Id, Application Salt, Application Secret and Base URL when your app is registered with Bayun, see  
   [Registering a new App](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/getting-started#2.2-register-a-new-application).  
   In the js/config.js file, replace the value of "BayunAppId", "BayunApplicationSalt", "BayunAppSecret", "BaseURL"
   with your Bayun Application Id, Application Salt, Application Secret, and BaseURL respectively.

5. Build and Run the project with any live server, or simply hit the 'Go Live' button in the bottom right corner of vs code.

6. You need to first signup using Amazon Cognito User Pools or you can signup only with Bayun.

   In order to signup with using Amazon Cognito User Pools, enter your username, and password and
   set your company name. Hit the Register button. You will receive a confirmation code at your email address.
   Enter the confirmation code in the confirm signUp screen and complete your signup process.

   In order to signup with only Bayun, you have the option to signup with or without a password.
   If you choose to signup without a password, you would be required to set Security Questions Answers and optionally Passphrase.

7. After signup you can sign in to the app with Amazon Cognito User Pools or only with Bayun. Manually replace credentials for creating a S3 instance.
   secures3 = await new SecureS3(
   '<bayunSessionId>', // Unique SessionId which is received in the login/registration function response.
   '<apiVersion>', //A String in YYYY-MM-DD format (or a date) that represents the latest possible API version that can be used in all services (unless overridden by apiVersions). Specify 'latest' to use the latest possible version.
   '<accessKeyId>', // Your AWS access key ID.
   '<secretAccessKey>', // your AWS secret access key.
   '<signatureVersion>', // The signature version to sign requests with (overriding the API configuration). Possible values are: 'v2', 'v3', 'v4'.
   '<region>', // The region to send service requests to.
   '<bucket>', // Name of your bucket
   );

8.You should be able to upload and download files from the AWS S3 bucket.
