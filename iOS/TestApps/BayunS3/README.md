## BayunS3

BayunS3 is a sample application that uses overridden methods from AWSS3 SDK for secure storage onto AWS S3. For details, see [Documentation](https://bayun.gitbook.io/bayun-awss3-wrapper-ios-programming-guide/).

## Getting Started

Register as developer on the Admin Panel(https://digilockbox.com/admin).

On the admin panel, register an email address. You will be asked to set security questions, optional passphrase and select Developer as account role. After registering as developer on Bayun, you can create application in the developer console. You need to provide your App name. 

We provide you with an Application Id, Application Salt and Application Secret when your app is registered with Bayun.
The Application Id, Application Salt and Application Secret will be needed along with the other authentication information when you authenticate with Bayun's Lockbox Management Server to use Bayun features.
These should be kept secure. You MUST register every new app with Bayun, and use a different Application Id, Application Salt and Application Secret for every app. Otherwise the data security of your apps will potentially be compromised, and the admin-panel functionality of different apps (used as a dashboard by enterprise admins for control and visibility) is also likely to get mixed-up.

## Instructions for use

1. Check out the latest code for BayunS3 sample application, along-with Bayun SDK,
by cloning the top-level BayunSDK repository.

2. Install the cocoa pods dependency manager, if you don't have it already, 
by executing the following command in a terminal window:
'sudo gem install cocoapods'

3. Make sure the BayunS3 project is not open in XCode. Go to the folder 
BayunSDK/iOS/TestApps/BayunS3 in a terminal window and run the following 
command to generate the xcode workspace file.
'pod install'

4. Use XCode 12.0 or higher to open the just created BayunS3.xcworkspace file in 
the folder BayunSDK/iOS/TestApps/BayunS3.

5. In the workspace, select the first target 'BayunS3'

6. Embed the Bayun framework from BayunCoreSDK in the project
 ```
i. In target settings select the "General" tab.
ii. Under "Embedded Binaries", click the "+" button to add an item.
iii. On the popup, click "Add Other..." 
iv. Select Bayun.framework from BayunSDK/iOS/BayunCoreSDK and click "Open". 
v. A pop up opens to choose options for adding the files. Choose the options 
"Copy items if needed" and "Create groups". Click on "Finish". 
This integrates the Bayun framework into the app.
 ```

7. You will need your CognitoIdentityUserPoolRegion, CognitoIdentityUserPoolId, 
   CognitoIdentityUserPoolAppClientId, CognitoIdentityUserPoolAppClientSecret, 
   CognitoIdentityPoolId. Place the respective values in the Constants.m file.

8. You are provided with an Application Id, Application Salt, Application Secret 
   when your app is registered with Bayun, see  [Registering a new App](https://bayun.gitbook.io/bayuncoresdk-ios/2-getting-started).  
   In the Constants.m file, replace value of "kBayunBaseURL", "kBayunAppId", "kBayunApplicationSalt" and "kBayunAppSecret" 
   with your Bayun Base URL, Application Id, Application Salt and Application Secret respectively.

9. Build and Run the project.

10. You need to first signup using Amazon Cognito User Pools or you can signup only with Bayun.
    
    In order to signup with using Amazon Cognito User Pools, enter your username, password and 
    set your company name. Hit Register button. You will receive a confirmation code on your email address. 
    Enter the confirmation code in the confirm signUp screen and complete your signup process.
    
    In order to signup with only Bayun, you have option to signup with or without password. 
    If you choose to signup without password, you would be required to set Security Questions Answers and optionally Passphrase.   

11. After signup you can signIn the app with Amazon Cognito User Pools or only with Bayun. 
    A bucket with name 'bayun-test-yourCompanyName' is created. You should be able to upload and download files from the bucket.
