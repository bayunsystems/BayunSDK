## Getting Started

Register as developer on the Admin Panel(https://digilockbox.com/admin).

On the admin panel, register an email address. You will be asked to set security questions, optional passphrase and select Developer as account role. After registering as developer on Bayun, you can create application in the developer console. You need to provide your App name. 

We provide you with a Base URL, Application Id, Application Salt, Application Secret and BaseURL when your app is registered with Bayun.

The Base URL, Application Id, Application Salt and Application Secret will be needed along with the other authentication information when you authenticate with Bayun's Lockbox Management Server to use Bayun features.

These should be kept secure. You MUST register every new app with Bayun, and use a different Application Id, Application Salt and Application Secret for every app. Otherwise the data security of your apps will potentially be compromised, and the admin-panel functionality of different apps (used as a dashboard by enterprise admins for control and visibility) is also likely to get mixed-up.


## Bayun JavaScript SDK Documentation

Checkout [Developer Guide](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/).

## ESLint Error Resolution

If you are encountering ESLint-related errors in your project, you can choose one of the following solutions:

### Solution 1: Modify `bayun.js`

To address ESLint issues within the `bayun.js` file, follow these steps:

1. Open the `bayun.js` file in your project.
2. Add the following lines at the beginning of the file:

    ```javascript
    /* eslint-disable no-unused-expressions */
    /* eslint-disable no-restricted-globals */
    /* eslint-disable no-mixed-operators */
    /* eslint-disable no-undef */
    /* eslint-disable no-fallthrough */
    ```

### Solution 2: Remove ESLint from the project

If your application is using the Bayun SDK and you prefer not to enforce ESLint rules, you can consider removing ESLint from your app.
