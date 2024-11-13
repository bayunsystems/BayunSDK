## Getting Started

Register as developer on the Admin Panel(https://digilockbox.com/admin).

On the admin panel, register an email address. You will be asked to set security questions, optional passphrase and select Developer as account role. After registering as developer on Bayun, you can create application in the developer console. You need to provide your App name.

We provide you with an Application Id, Application Salt, Application Secret, Base URL and Bayun Server Public Key when your app is registered with Bayun on the developer portal.

The Application Id, Application Salt, Application Secret, Base URL and Bayun Server Public Key will be needed along with the other authentication information when you authenticate with Bayun's Lockbox Management Server to use Bayun features.

These should be kept secure. You MUST register every new app with Bayun, and use a different Application Id, Application Salt and Application Secret for every app. Otherwise the data security of your apps will potentially be compromised, and the admin-panel functionality of different apps (used as a dashboard by enterprise admins for control and visibility) is also likely to get mixed-up.

## Build the test program

You are provided with an appId when your app is registered with Bayun.
In the test file, replace value of "appId", "appSalt", "appSecret", "baseURL" , "bayunServerPublicKey" variables with your Bayun Application Id, Application Salt, Application Secret, Base URL and bayunServerPublicKey.

Build the test program test.cc using the following commands :

` cmake .`

` make`

### Run the test program

`./test_ex`

## Bayun C++ SDK Documentation

Checkout [Developer Guide](https://bayun.gitbook.io/bayuncoresdk-cpp/).
