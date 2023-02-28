## BayunS3

BayunS3 is a sample application that uses overridden methods from AWSS3 SDK for secure storage onto AWS S3. For details, see [Documentation](https://bayun.gitbook.io/bayun-awss3-wrapper-android-programming-guide/).

**Instructions for use :**

1. Check out the latest code for BayunS3 sample application, along-with Bayun SDK, by cloning the top-level BayunSDK repository.

2. Create a folder in project(Bayun) and paste the aar(Bayun.aar) file in the folder

3. Add the dependencies in the app/build.gradle file
   implementation files('<Path-of-aar-file>')  //implementation files('../Bayun/Bayun.aar')

   implementation group: 'com.fasterxml.jackson.core', name: 'jackson-core', version: '2.10.1'
   implementation group: 'com.fasterxml.jackson.core', name: 'jackson-databind', version: '2.10.1'
   implementation group: 'com.fasterxml.jackson.core', name: 'jackson-annotations', version: '2.10.1'
   implementation 'com.github.tony19:logback-android:2.0.0'
   implementation 'androidx.biometric:biometric:1.0.1'
   implementation 'com.google.code.gson:gson:2.8.6'
   implementation 'com.squareup.retrofit2:retrofit:2.9.0'
   implementation 'com.squareup.okhttp3:okhttp:4.9.3'
   implementation 'org.slf4j:slf4j-api:1.7.30' 
   implementation 'com.yakivmospan:scytale:1.0.1'


5. Add Service and Activity in AndroidManifest.xml file
   <!-- Declare Bayun SDK's background service -->
   <service android:name="com.bayun_module.BayunBackgroundService"/>
   <!-- Declare Bayun SDK's background activity for screen locks -->
   <activity android:name="com.bayun_module.EmptyActivity"/>

6. Include the file name (include ':app', ':Bayun') in setting.gradle file

7. You will need your AWSS3 access key and secret key.
   Place the access key and secret key in the strings.xml file.

8. You are provided with an appId when your app is registered with Bayun, see  [Registering a new App](https://bayun.gitbook.io/bayuncoresdk-android/2-getting-started#2.3-register-a-new-application).
   In the strings.xml file, replace value of "base_url", "app_id", "app_salt" and "app_secret" with your Bayun Base URL, Application Id, Application Salt and Bayun App Secret.

9. You will need your userPoolId, clientId, clientSecret, cognitoRegion. Place them under the defined variables in class "CognitoHelper".

10. Application context and app id needs to be added to "SecureAuthentication" instance using setters. In this demo app this is done in "BayunApplication.java" class.

11. Build and Run the project.

12. You need to first signUp using Amazon Cognito User Pools .
    Enter your username, password, phone number and set your company name. Hit Register button.
    You will receive a confirmation code on your email address. Enter the confirmation code in the confirm signUp screen  and complete your signup process.

13. After signup you can signIn the app. Provide your username and password to signIn. A bucket with name 'bayun-test-yourCompanyName' is created. You should be able to upload and download files from the bucket.
