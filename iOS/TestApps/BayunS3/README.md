## Instructions for use
~~~~~
1. Check out the latest code for BayunS3 sample application, along-with Bayun SDK,
by cloning the top-level BayunSDK repository.

2. Install the cocoa pods dependency manager, if you don't have it already, 
by executing the following command in a terminal window:
'sudo gem install cocoapods'

3. Make sure the BayunS3 project is not open in XCode. Go to the folder 
BayunSDK/iOS/TestApps/BayunS3 in a terminal window and run the following 
command to generate the xcode workspace file.
'pod install'

4. Use XCode 7.0 or higher to open the just created BayunS3.xcworkspace file in 
the folder BayunSDK/iOS/TestApps/BayunS3.

5. In the workspace, select the first target 'BayunS3'

6. Embed the Bayun framework from BayunCoreSDK in the project
i. In target settings select the "General" tab.
ii. Under "Embedded Binaries", click the "+" button to add an item.
iii. On the popup, click "Add Other..." 
iv. Select Bayun.framework from BayunSDK/iOS/BayunCoreSDK and click "Open". 
v. A pop up opens to choose options for adding the files. Choose the options 
"Copy items if needed" and "Create groups". Click on "Finish". 
This integrates the Bayun framework into the app.

7. You will need your AWSS3 access key and secret key. 
   Place the access key and secret key in the AppConfig.h file.

8. Build and Run the project.

9. Enter your company in the Company field, your employee id in Employee field, 
   and your password in Password field and hit Register button.

10. After authenticating with the Bayun Key Management Server, a bucket with name 'bayun-yourCompanyName' 
    is created. You should be able to upload and download files from the bucket. 
~~~~~
