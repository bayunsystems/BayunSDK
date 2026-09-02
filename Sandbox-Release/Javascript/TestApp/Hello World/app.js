/**
 * Bayun Admin Integration Demo
 *
 * Built exclusively from the official programming guide:
 * https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide
 */
import React from "react";
import { createRoot } from "react-dom/client";
import { BayunFullApp } from "./admincomponent/bayun-admin.es.js";

let bayunConfig;
try {
  ({ bayunConfig } = await import("./config.js"));
} catch {
  ({ bayunConfig } = await import("./config.example.js"));
}

/** @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/4.-integrate-bayun-sdk */
const bayunCore = BayunCore.init({
  bayunAppId: bayunConfig.bayunAppId,
  bayunAppSecret: bayunConfig.bayunAppSecret,
  baseURL: bayunConfig.baseURL,
  bayunServerPublicKey: bayunConfig.bayunServerPublicKey,
  enableFaceRecognition: false,
});

let sessionId = "";
let adminRoot = null;

const loginPanel = document.getElementById("login-panel");
const cryptoPanel = document.getElementById("crypto-panel");
const adminPanel = document.getElementById("admin-panel");
const loginForm = document.getElementById("login-form");
const loginStatus = document.getElementById("login-status");
const cryptoStatus = document.getElementById("crypto-status");
const logoutBtn = document.getElementById("logout-btn");
const lockBtn = document.getElementById("lock-btn");
const unlockBtn = document.getElementById("unlock-btn");

function setStatus(el, message, type = "") {
  el.textContent = message;
  el.className = `status${type ? ` ${type}` : ""}`;
}

function showAuthenticatedUi(isAuthenticated) {
  loginPanel.classList.toggle("hidden", isAuthenticated);
  cryptoPanel.classList.toggle("hidden", !isAuthenticated);
  adminPanel.classList.toggle("hidden", !isAuthenticated);
  logoutBtn.classList.toggle("hidden", !isAuthenticated);
}

/**
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/5.1-register-agentic-member
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/5.3-login-agentic-member
 */
const authorizeMemberCallback = (data) => {
  if (data.sessionId) {
    if (
      data.authenticationResponse ===
      BayunCore.AuthenticateResponse.AUTHORIZATION_PENDING
    ) {
      console.info(
        "Member authorization pending. Ensure your application secret has the Authorization role enabled.",
        data.memberPublicKey,
      );
      setStatus(
        loginStatus,
        "Authorization pending. Create an app secret with all required roles in the Bayun Developer Console.",
        "error",
      );
    }
  }
};

/**
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/8.-integrate-bayun-admin-component
 */
async function renderAdminComponent() {
  const rootEl = document.getElementById("bayun-admin-wrapper");
  if (!rootEl) {
    return;
  }

  if (!adminRoot) {
    adminRoot = createRoot(rootEl);
  }

  adminRoot.render(
    React.createElement(BayunFullApp, {
      useBayunNavigation: true,
      defaultPage: "Members",
    }),
  );
}

/**
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/lock-unlock-text
 */
async function lockDemoText() {
  const plainText = document.getElementById("plain-text").value;
  const lockedTextEl = document.getElementById("locked-text");
  const unlockedTextEl = document.getElementById("unlocked-text");

  try {
    const lockedText = await bayunCore.lockText({
      sessionId,
      text: plainText,
      encryptionPolicy: BayunCore.EncryptionPolicy.MEMBER,
      keyGenerationPolicy: null,
      groupId: "",
    });

    lockedTextEl.value = lockedText;
    unlockedTextEl.value = "";
    setStatus(cryptoStatus, "Text locked successfully.", "success");
  } catch (error) {
    console.error(error);
    setStatus(cryptoStatus, error?.message || String(error), "error");
  }
}

/**
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/lock-unlock-text
 */
async function unlockDemoText() {
  const lockedText = document.getElementById("locked-text").value;
  const unlockedTextEl = document.getElementById("unlocked-text");

  if (!lockedText) {
    setStatus(cryptoStatus, "Lock some text first.", "error");
    return;
  }

  try {
    const unlockedText = await bayunCore.unlockText({
      sessionId,
      lockedText,
    });

    unlockedTextEl.value = unlockedText;
    setStatus(cryptoStatus, "Text unlocked successfully.", "success");
  } catch (error) {
    console.error(error);
    setStatus(cryptoStatus, error?.message || String(error), "error");
  }
}

/**
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/5.3-login-agentic-member
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/master-1
 */
async function loginAgenticMember(orgName, orgMemberId, passcode) {
  const localDataEncryptionMode =
    BayunCore.LocalDataEncryptionMode.EXPLICIT_LOGOUT_MODE;

  return new Promise((resolve, reject) => {
    const successCallback = async (data) => {
      if (!data?.sessionId) {
        reject(new Error("Login succeeded but no sessionId was returned."));
        return;
      }

      sessionId = data.sessionId;
      showAuthenticatedUi(true);
      setStatus(loginStatus, `Logged in. Session: ${sessionId}`, "success");
      await renderAdminComponent();
      resolve(data);
    };

    const failureCallback = (error) => {
      console.error(error);
      setStatus(loginStatus, error?.message || String(error), "error");
      reject(error);
    };

    bayunCore.loginAgenticMember({
      sessionId: null,
      orgName,
      orgMemberId,
      passcode,
      autoCreateMember: true,
      localDataEncryptionMode,
      authorizeMemberCallback,
      securityQuestionsCallback: null,
      passphraseCallback: null,
      successCallback,
      failureCallback,
    });
  });
}

/**
 * @see https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/5.5-logout
 */
function logout() {
  if (!sessionId) {
    return;
  }

  bayunCore.logout({ sessionId });

  sessionId = "";
  showAuthenticatedUi(false);
  setStatus(loginStatus, "Logged out.", "success");
  setStatus(cryptoStatus, "");

  document.getElementById("locked-text").value = "";
  document.getElementById("unlocked-text").value = "";

  if (adminRoot) {
    adminRoot.unmount();
    adminRoot = null;
  }
}

loginForm.addEventListener("submit", async (event) => {
  event.preventDefault();

  const orgName = document.getElementById("org-name").value.trim();
  const orgMemberId = document.getElementById("org-member-id").value.trim();
  const passcode = document.getElementById("passcode").value;

  setStatus(loginStatus, "Logging in...");
  document.getElementById("login-btn").disabled = true;

  try {
    await loginAgenticMember(orgName, orgMemberId, passcode);
  } finally {
    document.getElementById("login-btn").disabled = false;
  }
});

lockBtn.addEventListener("click", lockDemoText);
unlockBtn.addEventListener("click", unlockDemoText);
logoutBtn.addEventListener("click", logout);

console.info("BayunCore initialized.", bayunCore);
