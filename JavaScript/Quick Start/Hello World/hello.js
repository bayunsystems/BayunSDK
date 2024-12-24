import {} from "./lib/bayun.js";

console.log("BayunCore Object: ", BayunCore);

const Constants = {
  BAYUN_APP_ID: "a8f5d7c54cbf499e93a8c44b78e988bf", // Provided when an app is registered with Bayun on Developer Portal
  BAYUN_APP_SALT: "mAtVKFmxnQXvGZ4Lj1wdXwy5Dfi+1NAGXtsQgmPwTDM=", // Provided when an app is registered with Bayun on Developer Portal
  BAYUN_APP_SECRET: "d4e2d6ce28b340faadcde1183e4eaa51", // Provided when an app is registered with Bayun on Developer Portal
  ENABLE_FACE_RECOGNITION: false,
  BASE_URL: "https://www.digilockbox.com/", // Provided when an app is registered with Bayun on Developer Portal
  BAYUN_SERVER_PUBLIC_KEY:
    "-----BEGIN PUBLIC KEY-----,MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEJBPMzWe38mbFy4P/7pVKxtFr/BAaFyoq,vBLd57FoxC1DsDwuqYYc+8PdWXVlsM0r6ASrQe7z7IPrdT700jwQLcyY/oJ25wyd,jJUfBqfE8TX+0OOdicabhYIIzH/h5UZS,-----END PUBLIC KEY-----,", // Provided when an app is registered with Bayun on Developer Portal
};

var localStorageMode = BayunCore.LocalDataEncryptionMode.SESSION_MODE;
let bayunCore;
var sessionId = "";

/**
 * Function initiates BayunCore object
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3.-integrate-bayun-sdk#3.3-initialize-bayuncore
 */
function initBayunCore() {
  bayunCore = BayunCore.init(
    Constants.BAYUN_APP_ID,
    Constants.BAYUN_APP_SECRET,
    Constants.BAYUN_APP_SALT,
    localStorageMode,
    Constants.BASE_URL,
    Constants.BAYUN_SERVER_PUBLIC_KEY,
    Constants.ENABLE_FACE_RECOGNITION
  );
  console.log("Instanciated BayunCore Object ", bayunCore);
}

//--------------------------Callbacks-------------------------//
/**
 * onLoginSuccessCallback executes after successfully login of employee
 * @param {Any} data Data of employee status parameters
 * @returns nothing
 */
const registerSuccessCallback = async (data) => {
  console.log("data = ", data);
  if (data.sessionId) {
    //window.sessionId = data.sessionId;
    sessionId = data.sessionId;
    console.log("sessionId: ", sessionId);
    console.log("Login Success");

    //-------------------------BayunSecurityFlow----------------------//
    console.log("Starting Encryption for Hello World...\n\n");
    var lockedText = await lockText(
      sessionId,
      textToBeEncrypted,
      BayunCore.EncryptionPolicy.EMPLOYEE,
      BayunCore.KeyGenerationPolicy.DEFAULT
    );
    console.log("Hello World is encrypted as ", lockedText);
    console.log("Starting Decryption for Encrypted Text...\n\n");
    var unlockedText = await unlockText(sessionId, lockedText);
    console.log("Encrypted Text is Decrypted as", unlockedText);
  }
};

/**
 * onLoginFailureCallback executes after failure in login of employee flow
 * @param {Any} error Error containg cause of failure
 * @returns nothing
 */
const registerFailureCallback = (error) => {
  console.error(error);
  console.log("login fail");
};

/**
 * This callback will be called when, the authorization of an employee is pending.
 * @param {Any} data Data requried to authorize an employee.
 */
const authorizeEmployeeCallback = (data) => {
  console.log(
    "Authorization is pending, Please create app secret(on admin) with all the roles."
  );
};

/**
 * This function returns locked text.
 *
 * @param {String} sessionId Unique SessionId which is received in the login/registration function response.
 * @param {String} text Text to be locked.
 * @param {EncryptionPolicy} encryptionPolicy : BayunEncryptionPolicy determines the key to be used to generate the lockingKey.
 * @param {KeyGenerationPolicy} keyGenerationPolicy : BayunKeyGenerationPolicy determines the policy to generate the lockingKey.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/lock-unlock-text#5.1.1-lock-text
 */
async function lockText(
  sessionId,
  text,
  encryptionPolicy,
  keyGenerationPolicy
) {
  var lockedText = await bayunCore.lockText(
    sessionId,
    text,
    encryptionPolicy,
    keyGenerationPolicy
  );
  //console.log("lockedText = ", lockedText);
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
  //console.log("unlockedText = ", unlockedText);
  return unlockedText;
}

/**
 * The loginWithPassword function is the instance function that initialises your access to Bayun.
 *
 * @param {String} sessionId Unique sessionId, If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful authentication response in successCallback.
 * @param {String} companyName Unique name of the company/tenant the authenticating employee belongs to, e.g. bayunsystems.com
 * @param {String} companyEmployeeId EmployeeId unique within the company, e.g. username@bayunsystems.com
 * @param {String} password Password of the user. Used to keep user secret keys protected.
 * @param {Boolean} autoCreateEmployee Boolean flag that informs SDK to create an employee
 *                                    with the given credentials if an employee doesnt exist for those.
 * @param {Callback} securityQuestionsCallback provide a custom UI block for taking User’s input, By default, the SDK uses AlertView to take User’s input for the answers of the Security Questions
 * @param {Callback} passphraseCallback provide a custom UI block for taking User’s input, By default, the SDK uses AlertView to take user input for passphrase if it is enabled for a user.
 * @param {Callback} onLoginSuccessCallback Success block to be executed after successful employee login.
 * @param {Callback} onLoginFailureCallback Failure block to be executed if employee login fails, returns BayunError.
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/4.3-login-with-password
 **/
function loginWithPassword() {
  bayunCore.loginWithPassword(
    "", // session id, leave this empty you will get a unique session id each time from bayun.
    companyName,
    companyEmployeeId,
    password,
    false, //autoCreateEmployee,
    null, //securityQuestionsCallback,
    null, //passphraseCallback,
    onLoginSuccessCallback,
    onLoginFailureCallback,
    authorizeEmployeeCallback
  );
}

// For a consumer type use-case you can use app name as companyName.
var companyName = "company4Appty"; // Please edit this field and provide a unique application name.
var companyEmployeeId = getCompanyEmployeeId("myemail@tygmail.com"); // Please edit this field and provide a unique email.
var password = "1234";
var textToBeEncrypted = "Hello World";

function getCompanyEmployeeId(email) {
  return email;
}

alert(
  "Your Company Name is: " +
    companyName +
    "\nYour Company Employee Id is: " +
    companyEmployeeId
);

initBayunCore();
//loginWithPassword();

async function registerWithPassword() {
  await bayunCore.registerEmployeeWithPassword(
    "", //window.sessionId,
    companyName,
    companyEmployeeId,
    password,
    authorizeEmployeeCallback,
    registerSuccessCallback,
    registerFailureCallback
  );
}

registerWithPassword();
