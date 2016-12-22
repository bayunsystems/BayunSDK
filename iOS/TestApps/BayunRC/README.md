## Instructions for use

1. Check out the latest code for BayunRC sample application, along-with Bayun SDK,
   by cloning the top-level BayunSDK repository.

2. Install the cocoa pods dependency manager, if you don't have it already, 
   by executing the following command in a terminal window:
      'sudo gem install cocoapods'

3. Make sure the BayunRC project is not open in XCode. Go to the folder 
   BayunSDK/iOS/TestApps/BayunRC in a terminal window and run the following 
   command to generate the xcode workspace file.
      'pod install'

4. Use XCode 7.0 or higher to open the just created BayunRC.xcworkspace file in 
   the folder BayunSDK/iOS/TestApps/BayunRC.
       
5. In the workspace, embed the Bayun framework from BayunCoreSDK in the project. You need to add Bayun.framework in both the targets.
 ```
  i. In targets ("BayunRC-Sandbox" and "BayunRC-Production") settings select the "General" tab.
 ii. Under "Embedded Binaries", click the "+" button to add an item.
iii. On the popup, click "Add Other..." (For the second target choose the existing Bayun.framework from the suggestions instead of clicking "Add Other"). 
 iv. Select Bayun.framework from BayunSDK/iOS/BayunCoreSDK and click "Open". 
  v. A pop up opens to choose options for adding the files. Choose the options 
     "Copy items if needed" and "Create groups". Click on "Finish". 
     This integrates the Bayun framework into the app.
 ```

6.  You are provided with an appId when your app is registered with Bayun, see [Registering a new App](https://www.bayunsystems.com/resources/core_sdk_ios/before_you_begin.html).  
    In the RCConfig.h file, replace value of "kBayunAppId" with your Bayun AppId.

7. In order to have access to the RingCentral's APIs, developer needs to register the app with RingCentral, and use the ApplicationKey and ApplicationSecret provided by RingCentral in the BayunRC sample app.
   To get the ApplicationKey and ApplicationSecret, see [App Development using RingCentral Developer Portal](https://developer.ringcentral.com/library/tutorials/getting-started.html##CreateYourApp)

8. In the RCConfig.h file, replace the values of "kApplicationKeySandbox" and "kApplicationSecretKeySandbox"            with the Sandbox Application Key and Application Secret Key.
   Also replace the values of "kApplicationKeyProd" and "kApplicationSecretKeyProd" with the Production Application Key and Application Secret Key respectively.

9. In the workspace you can find two Targets BayunRC-Sandbox and BayunRC-Production. Choose the appropriate target to build and run the app in Sandbox/Production Environment. You will need an active RingCentral account to login.

10. Enter your main RingCentral phone-number in the Phone Number field 
   and extension in the Extension field.

11. You should be able to send and receive encrypted text-messages to other extensions
   within the same company (those using the same main phone-number). The RingCentral app 
   itself will show garbled text for these secure messages sent by BayunRC app, while BayunRC 
   app will be able to correctly decipher both secure messages sent by another BayunRC app 
   as well as cleartext messages sent by RingCentral app.

