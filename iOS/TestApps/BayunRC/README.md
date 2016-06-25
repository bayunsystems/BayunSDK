## Instructions for use
~~~~~
1. Check out the latest code for BayunRC sample application along-with BayunSDK.

2. Install the cocoa pods dependency manager, if you don't have it already, 
   by executing the following command in a terminal window:
      'sudo gem install cocoapods'

3. Make sure the BayunRC Xcode project is not open. Go to the folder 
   BayunSDK/iOS/TestApps/BayunRC in a terminal window and run the following 
   command to update the xcode workspace file.
      'pod install'

4. Use XCode 7.0 or higher to open the just created BayunRC.xcworkspace file in 
   the folder BayunSDK/iOS/TestApps/BayunRC.

5. In the workspace, select the first target 'BayunRC'
       
6. Embed the Bayun framework in project
         i. In target settings select the "General" tab.
        ii. Under "Embedded Binaries", click the "+" button to add an item.
       iii. On the popup, click "Add Other..." 
        iv. Select Bayun.framework from BayunSDK/iOS/BayunCoreSDK and click "Open". 
         v. A pop up opens to choose options for adding the files. Choose the options 
            "Copy items if needed" and "Create groups". Click on "Finish". 
            This integrates the Bayun framework into the app.

7. Build and Run the project. You will need an active RingCentral account to login.

8. Enter your main RingCentral phone-number in the Phone Number field 
   and extension in the Extension field.

9. You should be able to send and receive encrypted text-messages to other extensions
   within the same company (using the same main phone-number). The RingCentral app 
   itself will show garbage for these secure messages sent by BayunRC app, while BayunRC 
   app will be able to correctly decipher messages sent from both RingCentral app as well 
   as BayunRC app.
~~~~~
