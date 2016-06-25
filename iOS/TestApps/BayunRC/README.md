## Instructions for use
~~~~~
1. Check out the latest code for BayunRC sample application with BayunSDK.

2. Open the folder BayunSDK/iOS/TestApps/BayunRC in XCode 7.0 or higher.

3. Install the cocoa pods dependency manager, if you don't have it already, 
   by executing the following command in a terminal window:
  'sudo gem install cocoapods'

4. Make sure current Xcode project is closed. Go to the path BayunSDK/iOS/TestApps/BayunRC i.e 
   the RC Demo iOS app path and run the command 
  'pod install'

5. Open the newly created .xcworkspace file.

6. In the workspace, select the first target 'BayunRC'
       
7. Embed the Bayun framework in project
         i. In target settings select the "General" tab.
        ii. Under "Embedded Binaries", click the "+" button to add an item.
       iii. On the popup, click "Add Other..." 
        iv. Select Bayun.framework from BayunSDK/iOS/BayunCoreSDK and click "Open". 
         v. A pop up opens to choose options for adding the files. Choose the options 
            "Copy items if needed" and "Create groups". Click on Finish. 
            This integrates the Bayun framework into the app.

8. Build and Run the project. You will need an active RingCentral account to login.

9. Enter your main RingCentral phone-number in the Phone Number field 
   and extension in the extension field.
~~~~~
