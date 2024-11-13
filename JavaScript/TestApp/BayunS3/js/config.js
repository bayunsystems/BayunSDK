window._config = {
  cognito: {
    userPoolId: "<userPoolId>", // ID of your existing userpool, Provided on AWS Console
    region: "<region>", // region of perticular pool, Provided on AWS Console
    clientId: "<clientId>", // An app client connects your app to the user pool and authorizes Amazon Cognito to generate OAuth 2.0 tokens , Provided on AWS Console
  },
};

const BayunConstants = {
  BAYUN_APP_ID: "<BAYUN_APP_ID>", // Provided when an app is registered with Bayun on Developer Portal
  BAYUN_APP_SALT: "<BAYUN_APP_SALT>", // Provided when an app is registered with Bayun on Developer Portal
  BAYUN_APP_SECRET: "<BAYUN_APP_SECRET>", // Provided when an app is registered with Bayun on Developer Portal
  ENABLE_FACE_RECOGNITION: false | true,
  BASE_URL: "<BASE_URL>", // Provided when an app is registered with Bayun on Developer Portal
  BAYUN_SERVER_PUBLIC_KEY: "<SERVER_PUBLIC_KEY>", // Provided when an app is registered with Bayun on Developer Portal
};
