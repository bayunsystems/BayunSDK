**Instructions for use :**

1. Check out the latest code for BayunS3 sample application, along-with Bayun SDK, by cloning the top-level BayunSDK repository.

2. Import BayunS3 Project into android studio.

3. From the Menu bar click on File > New > Import Project > BayunS3.

4. Copy the bayun-android-sdk.jar file into the /libs directory of BayunS3 application.

5. Navigate to the jar file in the Android Studio navigator, right click and select “Add As A Library".

6. You will need your AWSS3 access key and secret key.
      Place the access key and secret key in the strings.xml file.

7. You are provided with an appId when your app is registered with Bayun, see  [Registering a new App](https://www.bayunsystems.com/resources/core_sdk_ios/before_you_begin.html).
     In the strings.xml file, replace value of "app_id" with your Bayun AppId.

8. Build and Run the project.

9. Enter your company in the Company field, your employee id in Employee field,
      and your password in Password field and hit Login/Register button.

10. After authenticating with the Bayun Lock Management Server, a bucket with name 'bayun-test-YourCompanyName'
       is created. You should be able to upload and download files from the bucket.