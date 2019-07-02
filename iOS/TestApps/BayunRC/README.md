## Instructions for use
~~~~~
1. Check out the latest code for BayunRC sample application, along-with Bayun SDK,
   by cloning the top-level BayunSDK repository.

2. Install the cocoa pods dependency manager, if you don't have it already, 
   by executing the following command in a terminal window:
      'sudo gem install cocoapods'

3. Make sure the BayunRC project is not open in XCode. Go to the folder 
   BayunSDK/iOS/TestApps/BayunRC in a terminal window and run the following 
   command to generate the xcode workspace file.
      'pod install'

4. Use XCode 8.0 or higher to open the just created BayunRC.xcworkspace file in
   the folder BayunSDK/iOS/TestApps/BayunRC.

5. In the workspace, select the first target 'BayunRC'
       
6. Embed the Bayun framework from BayunCoreSDK in the project
         i. In target settings select the "General" tab.
        ii. Under "Embedded Binaries", click the "+" button to add an item.
       iii. On the popup, click "Add Other..." 
        iv. Select Bayun.framework from BayunSDK/iOS/BayunCoreSDK and click "Open". 
         v. A pop up opens to choose options for adding the files. Choose the options 
            "Copy items if needed" and "Create groups". Click on "Finish". 
            This integrates the Bayun framework into the app.

7. Enter the values of the constants kApplicationKeySandbox, kApplicationSecretKeySandbox, kApplicationKeyProd, kApplicationSecretKeyProd, kBayunAppId, kAppSecret in RCConfig.h file.

8. Build and Run the project. You will need an active RingCentral account to login.

9. Enter your main RingCentral phone-number in the Phone Number field,extension in the Extension  field and password in the Password field. Checking the "Point to Sandbox Server" checkbox number let the app point to sandbox server else production server is pointed.

10. You should be able to send and receive encrypted text-messages to other extensions
within the same company (those using the same main phone-number). The RingCentral app
itself will show garbled text for these secure messages sent by BayunRC app, while BayunRC
app will be able to correctly decipher both secure messages sent by another BayunRC app
as well as cleartext messages sent by RingCentral app.
~~~~~
