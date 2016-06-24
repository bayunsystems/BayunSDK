## Istructions for use
~~~~~
1. Check out latest code for the test application.

2. Open the project file BayunRC.xcworkspace in XCode7 or higher.

3. In the project, select BayunRC target.
         i. In the opened project, verify that the "Frameworks" folder under the 	first target "BayunRC" is empty (the second target should be "Pods").
        ii. Select the first target "BayunRC".
       
4. Embed the Bayun framework in project
         i. In target settings select the "General" tab.
        ii. Under "Embedded Binaries", click the "+" button to add an item.
       iii. On the popup, click "Add Other..." 
        iv. Select Bayun.framework from Bayun/iOS/BayunCoreSDK and click "Open". A pop up opens to choose options for adding the files. Choose  the  options “Copy times if needed” and “Create groups”. Click on Finish. This integrates the Bayun framework into the app.

5. Install the cocoa pods dependency manager, if you don't have it already, by executing the following command in a terminal window:
'sudo gem install cocoapods'

6. Go to the path Bayun/iOS/TestApps/BayunRC/ i.e the RC Demo iOS app path and run the command 
    'pod install’

7. Run the project. It should build successfully.
~~~~~
