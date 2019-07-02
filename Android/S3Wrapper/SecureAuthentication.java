package com.bayun.S3wrapper;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;

import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoDevice;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUser;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserAttributes;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserCodeDeliveryDetails;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserPool;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserSession;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.AuthenticationContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.ChallengeContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.MultiFactorAuthenticationContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.AuthenticationHandler;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.GenericHandler;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.SignUpHandler;
import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;
import com.bayun_module.BayunCore;
import com.bayun_module.credentials.BasicBayunCredentials;

import java.util.Map;

/**
 * Created by Akriti on 10/27/2017.
 */

public class SecureAuthentication {

    private static SecureAuthentication singletonObject;

    private Context context;
    private String appId;
    private String companyName;
    private String appSecret;

    private String signUpPassword;

    // Private constructor
    private SecureAuthentication() {}

    public static SecureAuthentication getInstance() {
        if (singletonObject == null) {
            singletonObject = new SecureAuthentication();
        }
        return singletonObject;
    }

    // Setters
    public void setContext(Context context) {
        this.context = context;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public void setAppSecret(String appSecret) {
        this.appSecret = appSecret;
    }

    /**
     * Signin User, first through Cognito. If successful, through Bayun.
     *
     * @param activity              Activity calling the function. Required for passphrase block creation
     * @param username              Username for bayun authentication
     * @param password              Password for bayun authentication
     * @param user                  Cognito User for Cognito signin
     * @param authenticationHandler Handler for success / failure of calls
     */
    public void signIn (Activity activity, String username, String password, CognitoUser user,
                        AuthenticationHandler authenticationHandler) {

        // AuthenticationHandler for Cognito Signin
        AuthenticationHandler wrapperAuthHandler = new AuthenticationHandler() {
            @Override
            public void onSuccess(CognitoUserSession userSession, CognitoDevice newDevice) {

                // Bayun Authentication success Callback
                Handler.Callback bayunAuthSuccess = msg -> {
                    BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_IS_BAYUN_LOGGED_IN,
                            Constants.YES);
                    authenticationHandler.onSuccess(userSession, newDevice);
                    return false;
                };

                // Bayun authentication failure Callback
                Handler.Callback bayunAuthFailure = msg -> {
                    Exception exception = new Exception(msg.getData().getString(Constants.ERROR));
                    user.signOut();
                    authenticationHandler.onFailure(exception);
                    return false;
                };

                // Authenticate with Bayun
                BasicBayunCredentials basicBayunCredentials = new BasicBayunCredentials
                        (appId, companyName, username, password, appSecret);
                BayunApplication.bayunCore.authenticateWithCredentials
                        (activity, basicBayunCredentials, null, null,
                                true,bayunAuthSuccess, bayunAuthFailure);
            }

            @Override
            public void getAuthenticationDetails(AuthenticationContinuation authenticationContinuation, String UserId) {
                authenticationHandler.getAuthenticationDetails(authenticationContinuation, UserId);
            }

            @Override
            public void getMFACode(MultiFactorAuthenticationContinuation continuation) {
                authenticationHandler.getMFACode(continuation);
            }

            @Override
            public void authenticationChallenge(ChallengeContinuation continuation) {
                authenticationHandler.authenticationChallenge(continuation);
            }

            @Override
            public void onFailure(Exception exception) {
                authenticationHandler.onFailure(exception);
            }
        };

        // Cognito call for authentication
        user.getSessionInBackground(wrapperAuthHandler);
    }

    /**
     * Signout user.
     *
     * @param user      Cognito user to signout from Cognito session
     */
    public void signOut (CognitoUser user) {
        // Sign out from Bayun
        new BayunCore(context).deauthenticate();
        // Sign out from Cognito Services
        // This has cleared all tokens and this user will have to go through the authentication process to get tokens.
        user.signOut();
        // clear shared preferance variables
        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_LOGGED_IN, null);
        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_IS_BAYUN_LOGGED_IN, null);
    }

    /**
     * Signup user.
     *
     * @param userPool          User pool to which the new user is o be added
     * @param username          username for authentication
     * @param password          password for authentication
     * @param userAttributes    Contains all attributes for this user
     * @param validationData    Parameters for lambda function for user registration
     * @param signUpHandler     Handler
     */
    public void signUp (Activity activity, CognitoUserPool userPool, String username, String password,
                        CognitoUserAttributes userAttributes, Map<String, String> validationData,
                        SignUpHandler signUpHandler) {

        // Callback for cognito signup
        SignUpHandler wrapperSignUpHandler = new SignUpHandler() {
            @Override
            public void onSuccess(CognitoUser user, boolean signUpConfirmationState, CognitoUserCodeDeliveryDetails cognitoUserCodeDeliveryDetails) {
                signUpPassword = password;

                // signUpConfirmationState is true if the user has been confirmed.
                if (signUpConfirmationState) {
                    // authenticate with Bayun if user is already confirmed.
                    // Bayun Authentication success Callback
                    Handler.Callback bayunAuthSuccess = msg -> {
                        signUpHandler.onSuccess(user, true, cognitoUserCodeDeliveryDetails);
                        return false;
                    };

                    // Bayun authentication failure Callback
                    Handler.Callback bayunAuthFailure = msg -> {
                        Exception exception = new Exception(msg.getData().getString(Constants.ERROR));
                        signUpHandler.onFailure(exception);
                        return false;
                    };

                    // Authenticate with Bayun
                    BasicBayunCredentials basicBayunCredentials = new BasicBayunCredentials
                            (appId, companyName, user.getUserId(), signUpPassword, appSecret);
                    BayunApplication.bayunCore.authenticateWithCredentials
                            (activity, basicBayunCredentials, null, null,
                                    true, bayunAuthSuccess, bayunAuthFailure);
                }
                // signupConfirmationState is false if used needs to be confirmed.
                else {
                    signUpHandler.onSuccess(user, false, cognitoUserCodeDeliveryDetails);
                }
            }

            @Override
            public void onFailure(Exception exception) {
                signUpHandler.onFailure(exception);
            }
        };

        // Signup with Cognito
        userPool.signUpInBackground(username, password, userAttributes, validationData, wrapperSignUpHandler);
    }

    /**
     * Confirm cognito sign up and create user on Bayun system.
     *
     * @param activity              Activity calling the function. Needed for passphrase dialog creation.
     * @param user                  Cognito user to be confirmed.
     * @param confirmCode           Confirmation code entered.
     * @param forcedAliasCreation   This flag indicates if the confirmation should go-through in case of
     *                              parameter contentions.
     * @param confirmHandler        Handler.
     */
    public void confirmSignUp (Activity activity, CognitoUser user, String confirmCode,
                               boolean forcedAliasCreation, GenericHandler confirmHandler) {
        // Callback for Cognito sign up confirmation
        GenericHandler wrapperConfirmHandler = new GenericHandler() {
            @Override
            public void onSuccess() {
                // Bayun Authentication success Callback
                Handler.Callback bayunAuthSuccess = msg -> {
                    confirmHandler.onSuccess();
                    return false;
                };

                // Bayun authentication failure Callback
                Handler.Callback bayunAuthFailure = msg -> {
                    Exception exception = new Exception(msg.getData().getString(Constants.ERROR));
                    confirmHandler.onFailure(exception);
                    return false;
                };

                // Authenticate with Bayun
                BasicBayunCredentials basicBayunCredentials = new BasicBayunCredentials
                        (appId, companyName, user.getUserId(), signUpPassword, appSecret);
                BayunApplication.bayunCore.authenticateWithCredentials
                        (activity, basicBayunCredentials, null, null,
                                true, bayunAuthSuccess, bayunAuthFailure);
            }

            @Override
            public void onFailure(Exception exception) {
                confirmHandler.onFailure(exception);
            }
        };

        // Confirmation call with Cognito
        user.confirmSignUpInBackground(confirmCode, forcedAliasCreation, wrapperConfirmHandler);
    }
}
