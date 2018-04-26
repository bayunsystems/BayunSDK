## BayunS3

BayunS3 is a sample application that uses overridden methods from AWSS3 SDK for secure storage onto AWS S3. For details, see [Documentation](https://www.bayunsystems.com/resources/awss3_wrapper_ios/bayuns3.html).

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

4. Use XCode 8.0 or higher to open the just created BayunS3.xcworkspace file in 
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

7. You will need your CognitoIdentityUserPoolRegion, CognitoIdentityUserPoolId, CognitoIdentityUserPoolAppClientId, CognitoIdentityUserPoolAppClientSecret, CognitoIdentityPoolId. Place the respective values in the Constants.m file.

8. You are provided with an appId when your app is registered with Bayun, see [Registering a new App](https://www.bayunsystems.com/resources/core_sdk_ios/before_you_begin.html).  
    In the Constants.m file, replace value of "BayunAppId" with your Bayun AppId.

9. Build and Run the project.

10. You need to first signUp using Amazon Cognito User Pools .
      Enter your username, password, phone number and set your company name. Hit Register button.
      You will receive a confirmation code on your email address. Enter the confirmation code in the confirm signUp screen  and complete your signup process.

11. After signup you can signIn the app. Provide your username and password to signIn. A bucket with name 'bayun-test-yourCompanyName' is created. You should be able to upload/download files to/from the bucket. 

