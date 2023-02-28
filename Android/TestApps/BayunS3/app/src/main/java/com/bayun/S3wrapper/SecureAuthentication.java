/*
 * Copyright © 2023 Bayun Systems, Inc. All rights reserved.
 */

package com.bayun.S3wrapper;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

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
import com.amazonaws.services.cognitoidentityprovider.model.SignUpResult;
import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;
import com.bayun_module.BayunCore;
import com.bayun_module.LockingKeys;
import com.bayun_module.configuration.BasicBayunCredentials;
import com.bayun_module.modal.SecurityAnswer;
import com.bayun_module.modal.SecurityQuestion;
import com.bayun_module.modal.SecurityQuestionAnswer;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class SecureAuthentication {

    private static SecureAuthentication singletonObject;

    private Context context;
    private String appId;
    private String companyName;
    private String appSecret;
    private String applicationKeySalt;

    private String signUpPassword;
    private String signUpEmail;
    private boolean signUpIsRegisterWithPwd;

    // Private constructor
    private SecureAuthentication() {
    }

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

    public void setApplicationKeySalt(String applicationKeySalt) {
        this.applicationKeySalt = applicationKeySalt;
    }

    /**
     * Signin User, first through Cognito. If successful, through Bayun.
     *
     * @param activity              Activity calling the function. Required for passphrase block
     *                              creation
     * @param username              Username for bayun authentication
     * @param password              Password for bayun authentication
     * @param user                  Cognito User for Cognito signin
     * @param authenticationHandler Handler for success / failure of calls
     */
    public void signIn(Activity activity, String username, String password, CognitoUser user,
                       AuthenticationHandler authenticationHandler) {
            // AuthenticationHandler for Cognito Signin
            AuthenticationHandler wrapperAuthHandler = new AuthenticationHandler() {
                @Override
                public void onSuccess(CognitoUserSession userSession, CognitoDevice newDevice) {

                    // Bayun login success Callback
                    Handler.Callback bayunAuthSuccess = msg -> {
                        String bucketName = "bayun-test-" + companyName;
                        bucketName = bucketName.toLowerCase();
                        BayunApplication.tinyDB.putString(Constants.S3_BUCKET_NAME, bucketName);

                        BayunApplication.tinyDB
                                .putString(Constants.SHARED_PREFERENCES_IS_BAYUN_LOGGED_IN,
                                        Constants.YES);
                        authenticationHandler.onSuccess(userSession, newDevice);
                        return false;
                    };

                    // Bayun login failure Callback
                    Handler.Callback bayunAuthFailure = msg -> {
                        Exception exception = new Exception(msg.getData().getString(Constants.ERROR));
                        user.signOut();
                        authenticationHandler.onFailure(exception);
                        return false;
                    };

                    // Bayun login authorizeEmployeeCallback  Callback
                    Handler.Callback authorizeEmployeeCallback = msg -> {
                        String employeePublicKey = msg.getData().getString(Constants.EMPLOYEE_PUBLICKEY);
                        Exception exception = new Exception("Employee Authorization is Pending");
                        authenticationHandler.onFailure(exception);
                        return false;
                    };

                    // login with Bayun
                    BayunApplication.bayunCore.loginWithPassword(activity,companyName,username,
                            password,false,authorizeEmployeeCallback,null,null,bayunAuthSuccess, bayunAuthFailure);
                }

                @Override
                public void getAuthenticationDetails(
                        AuthenticationContinuation authenticationContinuation, String UserId) {
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
     * @param user Cognito user to signout from Cognito session
     */
    public void signOut(CognitoUser user) {
        // Sign out from Bayun
        new BayunCore(context, context.getResources().getString(R.string.base_url),context.getResources().getString(R.string.app_id),
                context.getResources().getString(R.string.app_secret),context.getResources().getString(R.string.app_salt),BayunApplication.isDeviceLock).logout();
        // Sign out from Cognito Services
        // This has cleared all tokens and this user will have to go through the authentication
        // process to get tokens.
        user.signOut();
        // clear shared preferance variables
        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_LOGGED_IN, null);
        BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_IS_BAYUN_LOGGED_IN, null);
    }

    /**
     * Signup user.
     *
     * @param userPool       User pool to which the new user is o be added
     * @param username       username for authentication
     * @param password       password for authentication
     * @param userAttributes Contains all attributes for this user
     * @param validationData Parameters for lambda function for user registration
     * @param signUpHandler  Handler
     * @param registerBayunWithPwd  true if Register with password in Bayun SDK
     */
    public void signUp(Activity activity, CognitoUserPool userPool, String username,
                       String password,
                       CognitoUserAttributes userAttributes, Map<String, String> validationData,
                       SignUpHandler signUpHandler, boolean registerBayunWithPwd) {
            // Callback for cognito signup
            SignUpHandler wrapperSignUpHandler = new SignUpHandler() {
                @Override
                public void onSuccess(CognitoUser user, SignUpResult signUpResult) {
                    signUpPassword = password;
                    signUpEmail = userAttributes.getAttributes().get("email");
                    signUpIsRegisterWithPwd = registerBayunWithPwd;
                    // signUpConfirmationState is true if the user has been confirmed.
                    if (signUpResult.getUserConfirmed()) {
                        // authenticate with Bayun if user is already confirmed.
                        // Bayun Authentication success Callback
                        Handler.Callback bayunAuthSuccess = msg -> {
                            String bucketName = "bayun-test-" + companyName;
                            bucketName = bucketName.toLowerCase();
                            BayunApplication.tinyDB.putString(Constants.S3_BUCKET_NAME, bucketName);

                            signUpHandler.onSuccess(user, signUpResult);
                            return false;
                        };

                        // Bayun authentication failure Callback
                        Handler.Callback bayunAuthFailure = msg -> {
                            Exception exception =
                                    new Exception(msg.getData().getString(Constants.ERROR));
                            signUpHandler.onFailure(exception);
                            return false;
                        };

                        // Bayun Registration authorizeEmployeeCallback  Callback
                        Handler.Callback authorizeEmployeeCallback = msg -> {
                            String employeePublicKey = msg.getData().getString(Constants.EMPLOYEE_PUBLICKEY);
                            Exception exception = new Exception("Employee Authorization is Pending");
                            signUpHandler.onFailure(exception);
                            return false;
                        };

                        // Registration with Bayun
                        if(signUpIsRegisterWithPwd){
                            BayunApplication.bayunCore.registerEmployeeWithPassword
                                    (activity,companyName,user.getUserId(),signUpPassword, authorizeEmployeeCallback,  bayunAuthSuccess, bayunAuthFailure);
                        }else {
                            BayunApplication.bayunCore.registerEmployeeWithoutPassword(activity,companyName,user.getUserId()
                                    ,signUpEmail,false, authorizeEmployeeCallback,
                                    null,null,null,  bayunAuthSuccess, bayunAuthFailure);
                        }
                    }
                    // signupConfirmationState is false if used needs to be confirmed.
                    else {
                        signUpHandler.onSuccess(user,  signUpResult);
                    }
                }

                @Override
                public void onFailure(Exception exception) {
                    signUpHandler.onFailure(exception);
                }
            };

            // Signup with Cognito
            userPool.signUpInBackground(username, password, userAttributes, validationData,
                    wrapperSignUpHandler);



    }

    /**
     * Confirm cognito sign up and create user on Bayun system.
     *
     * @param activity            Activity calling the function. Needed for passphrase dialog
     *                            creation.
     * @param user                Cognito user to be confirmed.
     * @param confirmCode         Confirmation code entered.
     * @param forcedAliasCreation This flag indicates if the confirmation should go-through in
     *                            case of
     *                            parameter contentions.
     * @param confirmHandler      Handler.
     */
    public void confirmSignUp(Activity activity, CognitoUser user, String confirmCode,
                              boolean forcedAliasCreation, GenericHandler confirmHandler) {
        // Callback for Cognito sign up confirmation
        GenericHandler wrapperConfirmHandler = new GenericHandler() {
            @Override
            public void onSuccess() {
                // Bayun Registration success Callback
                Handler.Callback bayunAuthSuccess = msg -> {
                    confirmHandler.onSuccess();
                    return false;
                };


                // Bayun Registration failure Callback
                Handler.Callback bayunAuthFailure = msg -> {
                    Exception exception = new Exception(msg.getData().getString(Constants.ERROR));
                    confirmHandler.onFailure(exception);
                    return false;
                };

                // Bayun Registration authorizeEmployeeCallback  Callback
                Handler.Callback authorizeEmployeeCallback = msg -> {
                    String employeePublicKey = msg.getData().getString(Constants.EMPLOYEE_PUBLICKEY);
                    Exception exception = new Exception("Employee Authorization is Pending");
                    confirmHandler.onFailure(exception);
                    return false;
                };

                // Registration with Bayun
                BasicBayunCredentials basicBayunCredentials = new BasicBayunCredentials
                        (appId, companyName, user.getUserId(), signUpPassword.toCharArray(),
                                appSecret, applicationKeySalt);


                if(signUpIsRegisterWithPwd){
                    BayunApplication.bayunCore.registerEmployeeWithPassword
                            (activity,companyName,user.getUserId(),signUpPassword, authorizeEmployeeCallback,  bayunAuthSuccess, bayunAuthFailure);
                }else {
                    BayunApplication.bayunCore.registerEmployeeWithoutPassword(activity,companyName,user.getUserId()
                            ,signUpEmail,false, authorizeEmployeeCallback,
                            null,null,null,  bayunAuthSuccess, bayunAuthFailure);

                }
//                BayunApplication.bayunCore.registerEmployeeWithPassword
//                        (activity,companyName,user.getUserId(),signUpPassword, authorizeEmployeeCallback,  bayunAuthSuccess, bayunAuthFailure);


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
