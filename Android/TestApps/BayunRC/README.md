**Instructions for use :**

1. Check out the latest code for BayunRC sample application, along-with Bayun SDK, by cloning the top-level BayunSDK repository.

2. Import BayunRC Project into android studio.

3. Create a folder in project(Bayun) and paste the aar(Bayun.aar) file in the folder

4. Add the dependencies in the app/build.gradle file
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

7. In order to have access to the RingCentral's APIs, developer needs to register the app with RingCentral, and use the ApplicationKey and ApplicationSecret provided by RingCentral in the BayunRC sample app.

   **Sandbox Environment Build :** Select the devDebug or devRelease build variant and replace application_key_sandbox and application_secret_key_sandbox in strings.xml file with your Sandbox Application Key and Application Secret Key.

   **Production Environment Build :**
   Select the prodDebug or prodRelease build variant and replace application_key_prod and application_key_secret_prod in strings.xml file with your Production Application Key and Application Secret Key.

8. You are provided with an appId when your app is registered with Bayun, see  [Registering a new App](https://bayun.gitbook.io/bayuncoresdk-android/2-getting-started).
     In the strings.xml file, replace value of "base_url", "app_id", "app_salt" and "app_secret" with your Bayun Base URL, Application Id, Application Salt and Application Secret.

9. Build and Run the project. You will need an active RingCentral account to login.

10. Enter your main RingCentral phone-number in the Phone Number field and extension in the Extension field.

11. You should be able to send and receive encrypted text-messages to other extensions within the same company (those using the same main phone-number). The RingCentral app itself will show garbled text for these secure messages sent by BayunRC app, while BayunRC app will be able to correctly decipher both secure messages.
