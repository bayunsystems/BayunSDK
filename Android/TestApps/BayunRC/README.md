**Instructions for use :**

1. Check out the latest code for BayunRC sample application, along-with Bayun SDK, by cloning the top-level BayunSDK repository.

2. Import BayunRC Project into android studio.

3. From the Menu bar click on File > New > Import Project > BayunRC.

4. Copy the bayun-android-sdk.jar file into the /libs directory of BayunRC application.

5. Navigate to the jar file in the Android Studio navigator, right click and select “Add As A Library".

6. In order to have access to the RingCentral's APIs, developer needs to register the app with RingCentral, and use the ApplicationKey and ApplicationSecret provided by RingCentral in the BayunRC sample app.

   **Sandbox Environment Build :** Select the devDebug or devRelease build variant and replace application_key and application_secret in strings.xml file with your Sandbox Application Key and Application Secret Key.

   **Production Environment Build :**
   Select the prodDebug or prodRelease build variant and replace application_key and application_secret in strings.xml file with your Production Application Key and Application Secret Key.

7. You are provided with an appId when your app is registered with Bayun, see  [Registering a new App](https://www.bayunsystems.com/resources/core_sdk_ios/before_you_begin.html).
     In the strings.xml file, replace value of "app_id" with your Bayun AppId.

8. Build and Run the project. You will need an active RingCentral account to login.

9. Enter your main RingCentral phone-number in the Phone Number field and extension in the Extension field.

10. You should be able to send and receive encrypted text-messages to other extensions within the same company (those using the same main phone-number). The RingCentral app itself will show garbled text for these secure messages sent by BayunRC app, while BayunRC app will be able to correctly decipher both secure messages.