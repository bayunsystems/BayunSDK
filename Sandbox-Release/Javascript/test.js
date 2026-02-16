/**
 * appId : Provided when an app is registered with Bayun.
 * appSecret : Provided when an app is registered with Bayun.
 * appSalt : Provided when an app is registered with Bayun.
 *
 * localStorageMode : It can be SESSION_MODE or EXPLICIT_LOGOUT_MODE
      SESSION_MODE : User data is encrypted and stored locally in sessionstorage. User data gets cleared when the page session ends and user will have to login with Bayun again.
      EXPLICIT_LOGOUT_MODE : User data is encrypted and stored locally in localstorage. User data is kept in localstorage until the user logs out.

 * enableFaceRecognition : Boolean variable to determine whether or not to enable Face ID registration for a new user as an extra security measure.
 */
const Constants = {
  BAYUN_APP_ID: "<Your App ID>", //Provided when an app is registered with Bayun on Developer Portal
  BAYUN_APP_SECRET: "<Your App Secret>", //Provided when an app is registered with Bayun on Developer Portal

  ENABLE_FACE_RECOGNITION: false,
  BASE_URL: "<Your Base URL>", // Provided when an app is registered with Bayun on Developer Portal
  BAYUN_SERVER_PUBLIC_KEY: "<Your Server Public Key>", // Provided when an app is registered with Bayun on Developer Portal
};

var localStorageMode = BayunCore.LocalDataEncryptionMode.SESSION_MODE;
let bayunCore;

/**
 * Function initiates BayunCore object
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3.-integrate-bayun-sdk#3.3-initialize-bayuncore
 */
function initBayunCore() {
  bayunCore = BayunCore.init({
    bayunAppId: Constants.BAYUN_APP_ID,
    bayunAppSecret: Constants.BAYUN_APP_SECRET,
    localDataEncryptionMode: localStorageMode,
    baseURL: Constants.BASE_URL,
    bayunServerPublicKey: Constants.BAYUN_SERVER_PUBLIC_KEY,
    enableFaceRecognition: Constants.ENABLE_FACE_RECOGNITION,
  });
  console.log("Instantiated BayunCore Object");
}

/**
 * Function set the parameters of user's Cookie
 * @param {String} cname Name of cookie
 * @param {Any} cvalue Value of cookie
 * @param {Any} exdays Time period of cookie
 */
function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000);
  var expires = "expires=" + d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

/**
 * Function get the parameters of user's Cookie
 * @param {String} cname Name of cookie
 */
function getCookie(cname) {
  let name = cname + "=";
  let ca = document.cookie.split(";");
  for (let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == " ") {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

/**
 * Function clears perticular session data
 */
function clearSessionData() {
  setCookie("sessionId", "", 30); // window.sessionId = "";
  setCookie("localStorageMode", "", 30);
}

/**
 * registerSuccessCallback executes after successfully registration of member
 * @param {Any} data Data of member status success parameters
 * @returns nothing
 */
var sessionId = "";
var roomId = "";
const registerSuccessCallback = (data) => {
  console.log("onRegisterSuccess");
  if (data.memberAlreadyExists) {
    console.error(ErrorConstants.EMPLOYEE_ALREADY_EXISTS);
    alert(ErrorConstants.EMPLOYEE_ALREADY_EXISTS);
    return;
  }
  if (data.sessionId) {
    alert("Registered Successfully. Please login to continue.");
    // registerContainer.classList.add("hidden");
    bayunCore.logout(getCookie("sessionId"));
    console.log("sessionID: ", data.sessionId);
    sessionId = data.sessionId;
    clearSessionData();
    // showLoginScreen();
  }
};

/**
 * registerFailureCallback executes after failure in registration of member flow
 * @param {Any} error Error containg cause of failure
 * @returns nothing
 */
const registerFailureCallback = (error) => {
  console.log("onRegisterFailure");
  clearSessionData();
  console.error(error);
};

const newUserCredentialsCallback = (data) => {
  if (data.sessionId) {
    const authorizeMemberCallback = (data) => {
      if (data.sessionId) {
        if (
          data.authenticationResponse ==
          BayunCore.AuthenticateResponse.AUTHORIZATION_PENDING
        ) {
          // You can get memberPublicKey in data.memberPublicKey for it's authorization
        }
      }
    };

    const successCallback = (data) => {
      //Member Registered Successfully
      //Login to continue.
      console.log("yes", data);
    };

    const failureCallback = (error) => {
      console.error(error);
    };

    //Take User Input for Security Questions and Answers
    //Here securityQuestionsAnswers object is created just for reference
    var securityQuestionsAnswers = [];
    securityQuestionsAnswers.push({ question: "q", answer: "a" });
    securityQuestionsAnswers.push({ question: "q", answer: "a" });
    securityQuestionsAnswers.push({ question: "q", answer: "a" });
    securityQuestionsAnswers.push({ question: "q", answer: "a" });
    securityQuestionsAnswers.push({ question: "q", answer: "a" });

    // Take User Input for optional passphrase
    const passphrase = "1234";

    // Take user Input for optional registerFaceId
    const registerFaceId = false;

    bayunCore.setNewUserCredentials(
      data.sessionId,
      securityQuestionsAnswers,
      null, //passphrase,
      registerFaceId,
      authorizeMemberCallback,
      successCallback,
      failureCallback
    );
  }
};

/**
 * changePasswordSuccess executes after successfully password Change
 * @param {Any} data Data of member status parameters
 * @returns nothing
 */
const changePasswordSuccess = (data) => {
  if (data.sessionId) {
    console.log("Password changed");
  }
};

/**
 * changePasswordFailure executes after failure in password Change flow
 * @param {Any} error Error containg cause of failure
 * @returns nothing
 */
const changePasswordFailure = (error) => {
  console.error(error);
  console.log("Password can not be changed");
};

/**
 * onLoginSuccessCallback executes after successfully login of member
 * @param {Any} data Data of member status parameters
 * @returns nothing
 */
const onLoginSuccessCallback = async (data) => {
  console.log("data = ", data);
  if (data.sessionId) {
    //window.sessionId = data.sessionId;
    sessionId = data.sessionId;
    setCookie("sessionId", data.sessionId, 30);
    setCookie("localStorageMode", localStorageMode, 30);
    console.log("sessionId: ", sessionId);
    console.log("login success");
  }
};

/**
 * onLoginFailureCallback executes after failure in login of member flow
 * @param {Any} error Error containg cause of failure
 * @returns nothing
 */
const onLoginFailureCallback = (error) => {
  console.error(error);
  console.log("login fail");
};

/**
 * This callback will be called when, the authorization of a member is pending.
 * @param {Any} data Data requried to authorize a member.
 */
const authorizeMemberCallback = (data) => {
  console.log("In authorizeMemberCallback");
  if (data.sessionId) {
    if (
      data.authenticationResponse ==
      BayunCore.AuthenticateResponse.AUTHORIZATION_PENDING
    ) {
      // You will get memberPublicKey on data.memberPublicKey
      console.log(data);
      bayunCore.authorizeMember(
        data.sessionId,
        data.memberPublicKey,
        // orgName,
        // orgMemberId,
        onLoginSuccessCallback,
        onLoginFailureCallback
      );
      console.log("after call");
    }
  }
};

/**
 * Function changePassword which takes input as old password and new password and change it to new one.
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} currentPassword Current Password.
 * @param {String} newPassword New Password.
 * @param {Boolean} changePasswordSuccess Success block to be executed after successful password change.
 * @param {Boolean} changePasswordFailure Failure block to be executed if password change fails, returns BayunError.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/4.6-change-password
 */
function changePassword(
  sessionId,
  currentPassword,
  newPassword,
  changePasswordSuccess,
  changePasswordFailure
) {
  bayunCore.changePassword(
    sessionId,
    currentPassword,
    newPassword,
    changePasswordSuccess,
    changePasswordFailure
  );
}

/**
  * Register Member With Password.
  * @param {String} sessionId Unique sessionId. You can provide a unique sessionId to the registerMemberWithPassword function call. If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful registration response in successCallback.
                              Same sessionId should be provided in all the subsequent calls to the Bayun APIs as an argument.
  * @param {String} orgName Unique name of the org/tenant the registering member belongs to, preferably in domain-name format for consistency, e.g. bayunsystems.com.
  * @param {String} orgMemberId MemberId unique within the org, e.g. username@bayunsystems.com
  * @param {String} password Password of the member. Used to keep member secret keys protected.
  * @param {Callback} authorizeMemberCallback Block to be executed if member public key authorization is pending, returns memberPublicKey.
  * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/4.1-register-with-password
  **/
async function registerWithPassword() {
  await bayunCore.registerMemberWithPassword(
    getCookie("sessionId"), //window.sessionId,
    orgName,
    orgMemberId,
    password,
    authorizeMemberCallback,
    registerSuccessCallback,
    registerFailureCallback
  );
}

/**
 * The loginWithPassword function is the instance function that initialises your access to Bayun.
 *
 * @param {String} sessionId Unique sessionId, If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful authentication response in successCallback.
 * @param {String} orgName Unique name of the org/tenant the authenticating member belongs to, e.g. bayunsystems.com
 * @param {String} orgMemberId MemberId unique within the org, e.g. username@bayunsystems.com
 * @param {String} password Password of the user. Used to keep user secret keys protected.
 * @param {Boolean} autoCreateMember Boolean flag that informs SDK to create a member
 *                                    with the given credentials if a member doesnt exist for those.
 * @param {Callback} securityQuestionsCallback provide a custom UI block for taking User's input, By default, the SDK uses AlertView to take User's input for the answers of the Security Questions
 * @param {Callback} passphraseCallback provide a custom UI block for taking User's input, By default, the SDK uses AlertView to take user input for passphrase if it is enabled for a user.
 * @param {Callback} onLoginSuccessCallback Success block to be executed after successful member login.
 * @param {Callback} onLoginFailureCallback Failure block to be executed if member login fails, returns BayunError.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/4.3-login-with-password
 **/
function loginWithPassword() {
  bayunCore.loginWithPassword(
    getCookie("sessionId"), //window.sessionId
    orgName,
    orgMemberId,
    password,
    false, //autoCreateMember,
    null,
    null, //securityQuestionsCallback,
    null, //passphraseCallback,
    onLoginSuccessCallback,
    onLoginFailureCallback
  );
}

/**
 * Register Member Without Password.
 *
 * @param {String} sessionId Unique sessionId, If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful authentication response in successCallback.
 * @param {String} orgName Unique name of the org/tenant the authenticating member belongs to, e.g. bayunsystems.com
 * @param {String} orgMemberId MemberId unique within the org, e.g. username@bayunsystems.com
 * @param {String} email Bayun userId for the new user being registered, in the form of User Principal Name (UPN) represented as an email address e.g. username@bayunsystems.com.
 * @param {boolean} isCompanyOwnedEmail To identifiy if the email is company owned or user owned.
 * @param {Callback} authorizeMemberCallback Block to be executed if member public key authorization is pending, returns memberPublicKey.
 * @param {Callback} newUserCredentialsCallback Block to be executed when the developer provide a custom UI block for taking User's input. It is used to set Security Questions & Answers for a new user being created, as well as an optional Passphrase, and also optionally choose whether to register FaceID for the user or not.
 * @param {Callback} securityQuestionsCallback provide a custom UI block for taking User's input. It is used for taking answers to Security Questions from an existing Bayun User. By default, the SDK uses AlertView to take User's input for the answers to Security Questions.
 * @param {Callback} passphraseCallback provide a custom UI block for taking User's input. By default, the SDK uses AlertView to take user input for passphrase if it is enabled for the user.
 * @param {Callback} registerSuccessCallback Success block to be executed after successful member registration.
 * @param {Callback} registerFailureCallback Failure block to be executed if member registration fails, returns BayunError.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/4.2-register-without-password
 **/
function registerWithoutPassword() {
  bayunCore.registerMemberWithoutPassword(
    getCookie("sessionId"), //window.sessionId,
    orgName,
    orgMemberId,
    email,
    true,
    authorizeMemberCallback,
    newUserCredentialsCallback,
    null,
    null,
    registerSuccessCallback,
    registerFailureCallback
  );
}

/**
 * Login Without Password.
 *
 * @param {String} sessionId Unique sessionId, If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful authentication response in successCallback.
 * @param {String} orgName Unique name of the org/tenant the authenticating member belongs to, e.g. bayunsystems.com
 * @param {String} orgMemberId MemberId unique within the org, e.g. username@bayunsystems.com
 * @param {Callback} securityQuestionsCallback provide a custom UI block for taking User's input, By default, the SDK uses AlertView to take User's input for the answers of the Security Questions
 * @param {Callback} passphraseCallback provide a custom UI block for taking User's input, By default, the SDK uses AlertView to take user input for passphrase if it is enabled for a user.
 * @param {Callback} onLoginSuccessCallback Success block to be executed after successful member login.
 * @param {Callback} onLoginFailureCallback Failure block to be executed if member login fails, returns BayunError.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/4.4-login-without-password
 **/
function loginWithoutPassword() {
  bayunCore.loginWithoutPassword(
    getCookie("sessionId"), //window.sessionId,
    orgName,
    orgMemberId,
    null,
    null,
    onLoginSuccessCallback,
    onLoginFailureCallback
  );
}

/**
 * Using createGroup method, a new group is created. The group can be either of type PUBLIC or PRIVATE. The user creating the group automatically becomes a member of the group.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} groupName The name of the group. It is optional.
 * @param {String} groupType Type of group Public or Private
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/create-group
 */
async function createGroup(sessionId, groupName, groupType) {
  const group = await bayunCore.createGroup(sessionId, groupName, groupType);
  roomId = group.groupId;
  console.log("roomId : ", roomId);
}

/**
 * The deleteGroup function is used to delete a group by group member or group user
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} roomId The id of the group to be deleted.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/delete-group
 */
async function deleteGroup(sessionId, roomId) {
  await bayunCore.deleteGroup(sessionId, roomId);
}

/**
 * The getMyGroups function returns all the groups, both public and private, the user is a member of.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/get-my-groups
 */
async function getMyGroups(sessionId) {
  const myGroups = await bayunCore.getMyGroups(sessionId);
  console.log("myGroups = ", myGroups);
}

/**
 * The getGroupById function returns the group details for the given group id.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} groupId Id of the group.
 * @returns Group details for the given group id.
 */
async function getGroupById(sessionId, groupId) {
  var group = await bayunCore.getGroupById(sessionId, groupId);
  console.log("getGroupById = ", group);
  return group;
}

/**
 * The getUnjoinedPublicGroups function returns all the public groups of the company the member is not a member of.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @returns Array of the available public groups.
 */
async function getUnjoinedPublicGroups(sessionId) {
  const myGroups = await bayunCore.getUnjoinedPublicGroups(sessionId);
  console.log("myGroups = ", myGroups);
}

/**
 * The joinPublicGroup function is used to join any public group of the organisation.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} groupId Group Id of the Public Group.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/join-public-group
 */
async function joinPublicGroup(sessionId, groupId) {
  await bayunCore.joinPublicGroup(sessionId, groupId);
}

/**
 * The addParticipantToGroup function is used to add a new participant to the Group. The participant to be added may belong to a different org, provided that the org and the member must already be registered with Bayun. Any existing member of the group can add a new participant.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} groupId Id of the group to which the user is to be added.
 * @param {String} orgMemberId OrgMemberId of the member to be added to the group.
 * @param {String} orgName Name of the org of the member to be added to the group.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/add-group-member
 */
async function addParticipantToGroup(
  sessionId,
  groupId,
  orgMemberId,
  orgName
) {
  await bayunCore.addParticipantToGroup(
    sessionId,
    groupId,
    orgMemberId,
    orgName
  );
}

/**
 * This function adds the given list of participants to the given group.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} groupId Id of the group to which the user is to be added.
 * @param {List} groupParticipants the list of objects of participants to be added consisting of
 *                                "orgName" and "orgMemberId"
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/add-group-members
 */
async function addParticipantsToGroup(sessionId, groupId, groupParticipants) {
  let finalOutputTestJS = await bayunCore.addParticipantsToGroup(
    sessionId,
    groupId,
    groupParticipants
  );
  await printAddParticipantsErrorResponse(finalOutputTestJS);
}

/**
 * Use this code snippet to iterate over the possible errors from addParticipantsToGroup.
 * printAddParticipantsErrorResponse Prints the possible errors from addParticipantsToGroup function.
 * @param {Object} errorObject object of possible errors
 */
async function printAddParticipantsErrorResponse(errorObject) {
  if (errorObject.addedParticipantsCount != null) {
    console.log(
      "Successfully added participants count: ",
      errorObject.addedParticipantsCount
    );
  }
  if (errorObject["addParticipantErrObject"] && errorObject.addParticipantErrObject.length != 0) {
    let errorList = errorObject.addParticipantErrObject;

    for (let i = 0; i < errorList.length; i++) {
      let errorMessage = errorList[i].errorMessage;
      console.log("ERROR MESSAGE: ", errorMessage);

      for (let j = 0; j < errorList[i].participantsList.length; j++) {
        let participantDetails = errorList[i].participantsList[j];
        console.log("Details for " + (j + 1) + " participant");
        console.log("org member ID: ", participantDetails.orgMemberId);
        console.log("org name: ", participantDetails.orgName);
      }
    }
  }
}

/**
 * The removeParticipantFromGroup function is used to remove a participant from the Group. Any existing member of the group can remove other participants. The developer can choose to build stricter access-control mechanisms
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} groupId Id of the group from who the member is to be removed.
 * @param {String} orgMemberId OrgMemberId of the participant to be removed from the group.
 * @param {String} orgName Name of the org of the participant to be removed from the group.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/remove-group-member
 */
async function removeParticipantFromGroup(
  sessionId,
  groupId,
  orgMemberId,
  orgName
) {
  await bayunCore.removeParticipantFromGroup(
    sessionId,
    groupId,
    orgMemberId,
    orgName
  );
}

/**
 * The removeParticipantsFromGroup function is used to remove participants from the Group.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} groupId Id of the group from who the participants are to be removed.
 * @param {Array} participantsInfo List of group participants to be removed from the group.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/6.9-remove-group-members
 */
async function removeParticipantsFromGroup(sessionId, groupId, participantsInfo) {
  await bayunCore.removeParticipantsFromGroup(sessionId, groupId, participantsInfo);
}

/**
 * This function removes the given list of participants except from given list.
 *
 * @param {String} sessionId id of the session in question.
 * @param {String} groupId id of the group from who the participants are to be removed.
 * @param {String} participantsInfo credentials of the participants to be kept.
 * @param {Boolean} removeCallingParticipant boolean variable, has to be set true if we want to remove calling member itself, by default it is set false.
 */
async function removeParticipantsExceptList(
  sessionId,
  groupId,
  participantsInfo,
  removeCallingParticipant
) {
  await bayunCore.removeParticipantsExceptList(
    sessionId,
    groupId,
    participantsInfo,
    removeCallingParticipant
  );
}

/**
 * This function lets the logged in user leave the group associated with the given groupId.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} roomId The id of the group to leave.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/groups/leave-group
 */
async function leaveGroup(sessionId, roomId) {
  await bayunCore.leaveGroup(sessionId, roomId);
}

/**
 * This function returns locked text.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} text Text to be locked.
 * @param {EncryptionPolicy} encryptionPolicy : BayunEncryptionPolicy determines the key to be used to generate the lockingKey.
 * @param {KeyGenerationPolicy} keyGenerationPolicy : BayunKeyGenerationPolicy determines the policy to generate the lockingKey.
 * @param {String} groupId GroupId is required if encryptionPolicy is GROUP.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/lock-unlock-text#5.1.1-lock-text
 */
async function lockText(
  sessionId,
  text,
  encryptionPolicy,
  keyGenerationPolicy,
  groupId
) {
  var lockedText = await bayunCore.lockText(
    sessionId,
    text,
    encryptionPolicy,
    keyGenerationPolicy,
    groupId
  );
  console.log("lockedText = ", lockedText);
  return lockedText;
}

/**
 * The unlockText function unlocks a locked text.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} text Locked text which is going to be unlocked.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/lock-unlock-text#5.1.3-unlock-text
 */
async function unlockText(sessionId, text) {
  var unlockedText = await bayunCore.unlockText(sessionId, text);
  console.log("unlockedText = ", unlockedText);
  return unlockedText;
}

/**
 * This function returns locked text for image
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} text Text to be locked.
 * @param {EncryptionPolicy} encryptionPolicy : BayunEncryptionPolicy determines the key to be used to generate the lockingKey.
 * @param {KeyGenerationPolicy} keyGenerationPolicy : BayunKeyGenerationPolicy determines the policy to generate the lockingKey.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/lock-unlock-binary-data#5.2.2-lock-file-text
 */
async function lockTextForImage(
  sessionId,
  text,
  encryptionPolicy,
  keyGenerationPolicy,
  groupId
) {
  var lockedText = await bayunCore.lockFileText(
    sessionId,
    text,
    encryptionPolicy,
    keyGenerationPolicy,
    groupId
  );
  console.log("lockedText = ", lockedText);
  return lockedText;
}

/**
 * The unlockFileText function unlocks a locked file data as text.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} text Text to be unlocked.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/lock-unlock-binary-data#5.2.4-unlock-file-text
 */
async function unlockTextForImage(sessionId, text) {
  var unlockedText = await bayunCore.unlockFileText(sessionId, text);
  return unlockedText;
}

/**
 * This function locks and unlocks users data.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} text Byte array to lock and unlock.
 * @param {EncryptionPolicy} encryptionPolicy The encryption policy decides the key that will be used.
 * @param {KeyGenerationPolicy} keyGenrationPolicy It decides the policy that will be used.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/5.3-lock-unlock-binary-data
 */
async function lockAndUnlockData(
  sessionId,
  text,
  encryptionPolicy,
  keyGenerationPolicy
) {
  var lockedData = await bayunCore.lockData(
    sessionId,
    text,
    encryptionPolicy,
    keyGenerationPolicy
  );
  console.log("lockedData = ", lockedData);
  var unlockedData = await bayunCore.unlockData(sessionId, lockedData);
  console.log("unlockedData = ", unlockedData);
}

/**
 * This function returns an encryption key depending on the encryption policy.
 *
 * Imp info :- Most developers do not need to use this function, and should instead rely on appropriate lock/unlock methods for encrypting and decrypting all data.
 * This is meant only for highly advanced use-cases where the developer needs to use some custom encryption algorithm and/or explicitly add/validate signatures
 * on some special piece of data or stream which can't be easily passed to standard lock/unlock methods. In this case, the keys returned by this function should
 * be used very carefully for a single object or stream, and then destroyed immediately after encryption/decryption or signature generation/verification is done.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {EncryptionPolicy} encryptionPolicy  BayunEncryptionPolicy determines the key to be used to generate the lockingKey.
 * @param {KeyGenerationPolicy} keyGenrationPolicy  BayunKeyGenerationPolicy determines the policy to generate the lockingKey.
 * @param {String} groupId  GroupId is required if encryptionPolicy is GROUP.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/get-locking-key
 */
async function getLockingKey(
  sessionId,
  encryptionPolicy,
  keyGenerationPolicy,
  groupId
) {
  var lockingKey = await bayunCore.getLockingKey(
    sessionId,
    encryptionPolicy,
    keyGenerationPolicy,
    groupId
  );
  console.log(lockingKey);
}

/**
 * Function executes when user selects a image from device, after that locking and unlocking of image starts.
 */
//var metaData = "";
let fileInfoObject = { fileText: "", metaData: "" };
async function readFileAsText() {
  var file = document.getElementById("file").files[0];
  var reader = new FileReader();
  reader.readAsDataURL(file);
  //console.log("name ",file.name);
  reader.onload = function () {
    var inputData = reader.result;
    console.log("inputData = ", inputData);
    var replaceValue = inputData.split(",")[0];
    console.log("replaceValue ", replaceValue); //data:application/pdf;base64
    var metaData = replaceValue;
    var fileText = inputData.replace(replaceValue + ",", "");
    fileInfoObject = {
      fileText: fileText,
      metaData: metaData,
    };
    lockAndUnlockForImageTest(fileText);
  };
}

let unlocked_Text = "";
async function unlockLockedImage() {
  var file = document.getElementById("lockedFile").files[0];
  var reader = new FileReader();
  reader.readAsDataURL(file);
  reader.onload = async function () {
    var inputData = reader.result;
    console.log("inputData = ", inputData);
    var metaData = inputData.split(",")[0];
    var fileText = inputData.replace(metaData + ",", "");
    //lockAndUnlockForImageTest(fileText);
    //console.log("fileText",fileText);
    fileInfoObject = {
      fileText: fileText,
      metaData: metaData,
    };
    unlocked_Text = await unlockTextForImage("<sessionId>", fileText);
    console.log("unlockedText", unlocked_Text);
  };
}

/**
 * This function is the combination of lockTextForImage and unlockTextForImage
 * @param textToLock Text to be locked
 */
//let unlocked_Text ="";
async function lockAndUnlockForImageTest(textToLock) {
  var start = window.performance.now();

  let lockedText = await lockTextForImage(
    "<sessionId>",
    textToLock,
    BayunCore.EncryptionPolicy.GROUP,
    BayunCore.KeyGenerationPolicy.ENVELOPE,
    "GroupId"
  );
  console.log("Encryption Successful");

  var end = window.performance.now();
  console.log(`Encryption Execution time: ${end - start} ms`);

  //for downloading locked image
  await writeFileTextToFile(lockedText, fileInfoObject.metaData);
  console.log("Encrypted image downloaded");

  var start1 = window.performance.now();

  unlocked_Text = await unlockTextForImage("<sessionId>", lockedText);
  console.log("unlockedText", unlocked_Text);
  console.log("Decryption Successful");

  var end1 = window.performance.now();
  console.log(`Decryption Execution time: ${end1 - start1} ms`);
}

/**
 * Function used to download a image.
 * @param {Any} data Data of image
 * @param {String} filename Name of the file
 */
async function writeFileTextToFile(fileText, metaData) {
  var a = document.createElement("a");
  a.href = metaData + "," + fileText;
  var extension = metaData.substring(
    metaData.indexOf("/") + 1,
    metaData.indexOf(";")
  );
  a.download = "fileName" + "." + extension; //File name Here
  a.click();
}

/**
 * Function called when download button is clicked
 */
function downloadFile() {
  writeFileTextToFile(unlocked_Text, fileInfoObject.metaData);
}
/*Image test finish here*/

var orgName = "company.com";
var orgMemberId = "employee@company.com";
var email = "emp@company.com";
var password = "1234";

/**
 * Function basicApplicationFlow explains a simple application execution flow
 */
async function basicApplicationFlow() {
  await registerWithPassword();
  await createGroup(sessionId, "<GroupName>", BayunCore.GroupType.PRIVATE);
  await getMyGroups(sessionId);
  let testToBeLocked = "Hellow World!";
  console.log("Locking Text => ", testToBeLocked);
  let lockedText = await lockText(
    sessionId,
    testToBeLocked,
    BayunCore.EncryptionPolicy.COMPANY,
    BayunCore.KeyGenerationPolicy.STATIC,
    roomId
  );
  let unlockedText = await unlockText(sessionId, lockedText);
  await leaveGroup(sessionId, roomId);
}
setCookie("sessionId", "", 30);
initBayunCore();
