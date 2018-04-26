**Instructions for use :**

1. Check out the latest code for BayunS3 sample application, along-with Bayun SDK, by cloning the top-level BayunSDK repository.

2. Import BayunS3 Project into android studio.

3. From the Menu bar click on File > New > Import Project > BayunS3.

4. Copy the bayun-android-sdk.jar file into the /libs directory of BayunS3 application.

5. Navigate to the jar file in the Android Studio navigator, right click and select “Add As A Library".

6. You will need your AWSS3 access key and secret key.
Place the access key and secret key in the strings.xml file.

7. You are provided with an appId when your app is registered with Bayun, see  [Registering a new App](https://www.bayunsystems.com/resources/core_sdk_android/getting_started.html).
In the strings.xml file, replace value of "app_id" with your Bayun AppId.

8. You will need your userPoolId, clientId, clientSecret, cognitoRegion. Place them under the defined variables in class "CognitoHelper".

9. Application context and app id needs to be added to "SecureAuthentication" instance using setters. In this demo app this is done in "BayunApplication.java" class.

10. Build and Run the project.

11. You need to first signUp using Amazon Cognito User Pools .
Enter your username, password, phone number and set your company name. Hit Register button.
You will receive a confirmation code on your email address. Enter the confirmation code in the confirm signUp screen  and complete your signup process.

12. After signup you can signIn the app. Provide your username and password to signIn. A bucket with name 'bayun-test-yourCompanyName' is created. You should be able to upload and download files from the bucket.
