class SecureAuthentication {
  constructor(bayunCompanyName) {
    this.bayunCompanyName = bayunCompanyName;
  }

  register = async (
    sessionId,
    companyEmployeeId,
    email,
    password,
    registerBayunWithPwd
  ) => {
    if (registerBayunWithPwd == true) {
      await signUp(sessionId, true, companyEmployeeId, email, password);
    } else {
      await signUp(sessionId, false, companyEmployeeId, email, password);
    }
  };

  login = async (
    sessionId,
    companyEmployeeId,
    email,
    password,
    loginWithPwd
  ) => {
    var session_Id;
    if (loginWithPwd == true) {
      session_Id = await signIn(
        sessionId,
        true,
        companyEmployeeId,
        email,
        password
      );
    } else {
      session_Id = await signIn(
        sessionId,
        false,
        companyEmployeeId,
        email,
        password
      );
    }
    return session_Id;
  };

  confirmSignUp = async (email, code) => {
    var params = {
      ClientId: _config.cognito.clientId /* required */,
      ConfirmationCode: String(code) /* required */,
      Username: String(email) /* required */,
    };

    let region = _config.cognito.region;

    var cognitoidentityserviceprovider = new AWS.CognitoIdentityServiceProvider(
      { apiVersion: "2022-12-20", region }
    );

    console.log("Verifying...");

    cognitoidentityserviceprovider.confirmSignUp(params, function (err, data) {
      if (err) {
        console.log(err, err.stack);
      } // an error occurred
      else {
        console.log("Verification Success\nSign In to continue, " + data);
      }
    });
  };

  signOut = async () => {
    //bayun sign out
    bayunCoreInstance.logout(bayunSession);
    console.log("User Signed Out");
  };
}

async function signUp(
  sessionId,
  registerBayunWithPwd,
  personalname,
  email,
  password
) {
  let poolData = {
    UserPoolId: _config.cognito.userPoolId, // Your user pool id here
    ClientId: _config.cognito.clientId, // Your client id here
  };

  var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

  //attributeList is the list of parameters which are required for authentication, user has already deleared them while creating pool on AWS.
  var attributeList = [];

  var dataEmail = {
    Name: "email",
    Value: email, //get from form field
  };

  var dataPersonalName = {
    Name: "name", // name
    Value: personalname, //get from form field
  };

  var attributeEmail = new AmazonCognitoIdentity.CognitoUserAttribute(
    dataEmail
  );
  var attributePersonalName = new AmazonCognitoIdentity.CognitoUserAttribute(
    dataPersonalName
  );

  attributeList.push(attributeEmail);
  attributeList.push(attributePersonalName);

  let bayunData = {
    companyEmployeeId: personalname,
    email: email,
    password: password,
    sessionId: sessionId,
  };

  userPool.signUp(email, password, attributeList, null, function (err, result) {
    if (err) {
      //error while signing up
      console.log(err.message);
      console.log("result", result);
      alert(err.message || JSON.stringify(err));
      return;
    }
    //user has successfull signed up
    cognitoUser = result.user;
    console.log("User Details: ", cognitoUser);
    console.log("user name is " + cognitoUser.getUsername());

    registerSuccessHandler(
      registerBayunWithPwd,
      cognitoUser.getUsername(),
      bayunData
    );
  });
}

async function signIn(session_Id, LoginWithPwd, personalname, email, password) {
  var authenticationData = {
    Username: email,
    Password: password,
  };

  var authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(
    authenticationData
  );

  var poolData = {
    UserPoolId: _config.cognito.userPoolId, // Your user pool id here
    ClientId: _config.cognito.clientId, // Your client id here
  };

  var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

  var userData = {
    Username: email,
    Pool: userPool,
  };

  var cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

  let bayunData = {
    companyEmployeeId: personalname,
    email: email,
    password: password,
    session_Id: session_Id,
  };

  if (cognitoUser) {
    localStorage.setItem("LoggedInUser", userPool.getCurrentUser());
  }

  let sessionId;
  await authenticateUser(
    cognitoUser,
    authenticationDetails,
    LoginWithPwd,
    bayunData
  )
    .then((session) => {
      sessionId = session;
    })
    .catch((error) => {
      console.log(error);
    });

  return sessionId;
}

async function authenticateUser(
  cognitoUser,
  authenticationDetails,
  LoginWithPwd,
  bayunData
) {
  return new Promise((resolve, reject) => {
    cognitoUser.authenticateUser(authenticationDetails, {
      onSuccess: async function (result) {
        var accessToken = result.getAccessToken().getJwtToken();
        console.log("accessToken :", accessToken);

        let session = await signInSuccessHandler(
          accessToken,
          LoginWithPwd,
          bayunData
        );
        resolve(session);
      },
      onFailure: function (err) {
        reject(err);
        alert(err.message || JSON.stringify(err));
      },
    });
  });
}

async function registerSuccessHandler(registerBayunWithPwd, email, bayunData) {
  if (email != null) {
    if (registerBayunWithPwd) {
      await registerBayun(
        bayunData.sessionId,
        bayunCompanyName,
        bayunData.companyEmployeeId,
        bayunData.email,
        bayunData.password,
        true
      );
    } else {
      await registerBayun(
        bayunData.sessionId,
        bayunCompanyName,
        bayunData.companyEmployeeId,
        bayunData.email,
        bayunData.password,
        false
      );
    }
  }
}

async function signInSuccessHandler(accessToken, LoginWithPwd, bayunData) {
  var sessionid;
  if (accessToken != null) {
    if (LoginWithPwd) {
      sessionid = await loginBayun(
        bayunData.session_Id,
        bayunCompanyName,
        bayunData.companyEmployeeId,
        bayunData.password,
        true
      );
    } else {
      sessionid = await loginBayun(
        bayunData.session_Id,
        bayunCompanyName,
        bayunData.companyEmployeeId,
        bayunData.password,
        false
      );
    }
  }
  return sessionid;
}

async function registerBayun(
  sessionId,
  bayunCompanyName,
  companyEmployeeId,
  email,
  password,
  withPassword
) {
  if (withPassword) {
    await bayunCoreInstance.registerEmployeeWithPassword(
      sessionId, //window.sessionId
      bayunCompanyName,
      companyEmployeeId,
      password,
      authorizeEmployeeCallback,
      registerSuccessCallback,
      registerFailureCallback
    );
  } else {
    await bayunCoreInstance.registerEmployeeWithoutPassword(
      sessionId, //window.sessionId
      bayunCompanyName,
      companyEmployeeId,
      email,
      true,
      authorizeEmployeeCallback,
      null,
      null,
      null,
      registerSuccessCallback,
      registerFailureCallback
    );
  }
  return bayunSession;
}

async function loginBayun(
  sessionId,
  bayunCompanyName,
  companyEmployeeId,
  password,
  withPassword
) {
  if (withPassword) {
    await bayunCoreInstance.loginWithPassword(
      sessionId, //window.sessionId
      bayunCompanyName,
      companyEmployeeId,
      password,
      false, //autoCreateEmployee,
      null, //securityQuestionsCallback,
      null, //passphraseCallback,
      onLoginSuccessCallback,
      onLoginFailureCallback
    );
  } else {
    await bayunCoreInstance.loginWithoutPassword(
      sessionId, //window.sessionId,
      bayunCompanyName,
      companyEmployeeId,
      null,
      null,
      onLoginSuccessCallback,
      onLoginFailureCallback
    );
  }
  return bayunSession;
}

const registerSuccessCallback = (data) => {
  console.log("onRegisterSuccess");
  if (data.employeeAlreadyExists) {
    console.error(ErrorConstants.EMPLOYEE_ALREADY_EXISTS);
    alert(ErrorConstants.EMPLOYEE_ALREADY_EXISTS);
    return;
  }
  if (data.sessionId) {
    alert("Registered Successfully");
    console.log("sessionID: ", data.sessionId);
    bayunSession = data.sessionId;

    location.replace("./verification.html");
    return bayunSession;
  }
};

const authorizeEmployeeCallback = (data) => {
  console.log("In authorizeEmployeeCallback");
  if (data.sessionId) {
    if (
      data.authenticationResponse ==
      BayunCore.AuthenticateResponse.AUTHORIZATION_PENDING
    ) {
      // You will get employeePublicKey on data.employeePublicKey
      console.log(data);
      bayunCoreInstance.authorizeEmployee(
        data.sessionId,
        data.employeePublicKey,
        onLoginSuccessCallback,
        onLoginFailureCallback
      );
      console.log("after call");
    }
  }
};

const registerFailureCallback = (error) => {
  console.log("onRegisterFailure");
  console.error(error);
};

const onLoginFailureCallback = (error) => {
  console.error(error);
  console.log("login fail");
};

const onLoginSuccessCallback = async (data) => {
  console.log("data = ", data);
  if (data.sessionId) {
    console.log("sessionId: ", data.sessionId);
    console.log("login success");
    bayunSession = data.sessionId;

    window.location.replace("./test.html");
  }
};

function initBayunCore() {
  bayunCoreInstance = BayunCore.init(
    Constants.BAYUN_APP_ID,
    Constants.BAYUN_APP_SECRET,
    Constants.BAYUN_APP_SALT,
    localStorageMode,
    Constants.BASE_URL,
    Constants.BAYUN_SERVER_PUBLIC_KEY,
    Constants.ENABLE_FACE_RECOGNITION
  );
  console.log("Instanciated_BayunCore_Object_Cognito");
}

let AWSCognitoUser;
let bayunCoreInstance;
let bayunSession;
var localStorageMode = BayunCore.LocalDataEncryptionMode.SESSION_MODE;
initBayunCore();
