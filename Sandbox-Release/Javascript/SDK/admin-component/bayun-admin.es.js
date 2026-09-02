import lt, { useState as b, useEffect as ve, lazy as nt, useMemo as It, Suspense as Ya, useRef as Re, useCallback as Xs, useLayoutEffect as Va, useTransition as qa } from "react";
import { createPortal as Wa } from "react-dom";
var Xt = { exports: {} }, Lt = {};
/**
 * @license React
 * react-jsx-runtime.production.js
 *
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
var Es;
function Ha() {
  if (Es) return Lt;
  Es = 1;
  var r = Symbol.for("react.transitional.element"), t = Symbol.for("react.fragment");
  function s(n, a, o) {
    var i = null;
    if (o !== void 0 && (i = "" + o), a.key !== void 0 && (i = "" + a.key), "key" in a) {
      o = {};
      for (var c in a)
        c !== "key" && (o[c] = a[c]);
    } else o = a;
    return a = o.ref, {
      $$typeof: r,
      type: n,
      key: i,
      ref: a !== void 0 ? a : null,
      props: o
    };
  }
  return Lt.Fragment = t, Lt.jsx = s, Lt.jsxs = s, Lt;
}
var Dt = {};
/**
 * @license React
 * react-jsx-runtime.development.js
 *
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
var xs;
function $a() {
  return xs || (xs = 1, process.env.NODE_ENV !== "production" && function() {
    function r(A) {
      if (A == null) return null;
      if (typeof A == "function")
        return A.$$typeof === X ? null : A.displayName || A.name || null;
      if (typeof A == "string") return A;
      switch (A) {
        case U:
          return "Fragment";
        case D:
          return "Portal";
        case N:
          return "Profiler";
        case q:
          return "StrictMode";
        case J:
          return "Suspense";
        case le:
          return "SuspenseList";
      }
      if (typeof A == "object")
        switch (typeof A.tag == "number" && console.error(
          "Received an unexpected object in getComponentNameFromType(). This is likely a bug in React. Please file an issue."
        ), A.$$typeof) {
          case Y:
            return (A.displayName || "Context") + ".Provider";
          case P:
            return (A._context.displayName || "Context") + ".Consumer";
          case re:
            var se = A.render;
            return A = A.displayName, A || (A = se.displayName || se.name || "", A = A !== "" ? "ForwardRef(" + A + ")" : "ForwardRef"), A;
          case Q:
            return se = A.displayName || null, se !== null ? se : r(A.type) || "Memo";
          case de:
            se = A._payload, A = A._init;
            try {
              return r(A(se));
            } catch {
            }
        }
      return null;
    }
    function t(A) {
      return "" + A;
    }
    function s(A) {
      try {
        t(A);
        var se = !1;
      } catch {
        se = !0;
      }
      if (se) {
        se = console;
        var ie = se.error, Ee = typeof Symbol == "function" && Symbol.toStringTag && A[Symbol.toStringTag] || A.constructor.name || "Object";
        return ie.call(
          se,
          "The provided key is an unsupported type %s. This value must be coerced to a string before using it here.",
          Ee
        ), t(A);
      }
    }
    function n() {
    }
    function a() {
      if (H === 0) {
        V = console.log, F = console.info, _ = console.warn, B = console.error, oe = console.group, fe = console.groupCollapsed, G = console.groupEnd;
        var A = {
          configurable: !0,
          enumerable: !0,
          value: n,
          writable: !0
        };
        Object.defineProperties(console, {
          info: A,
          log: A,
          warn: A,
          error: A,
          group: A,
          groupCollapsed: A,
          groupEnd: A
        });
      }
      H++;
    }
    function o() {
      if (H--, H === 0) {
        var A = { configurable: !0, enumerable: !0, writable: !0 };
        Object.defineProperties(console, {
          log: j({}, A, { value: V }),
          info: j({}, A, { value: F }),
          warn: j({}, A, { value: _ }),
          error: j({}, A, { value: B }),
          group: j({}, A, { value: oe }),
          groupCollapsed: j({}, A, { value: fe }),
          groupEnd: j({}, A, { value: G })
        });
      }
      0 > H && console.error(
        "disabledDepth fell below zero. This is a bug in React. Please file an issue."
      );
    }
    function i(A) {
      if (ne === void 0)
        try {
          throw Error();
        } catch (ie) {
          var se = ie.stack.trim().match(/\n( *(at )?)/);
          ne = se && se[1] || "", me = -1 < ie.stack.indexOf(`
    at`) ? " (<anonymous>)" : -1 < ie.stack.indexOf("@") ? "@unknown:0:0" : "";
        }
      return `
` + ne + A + me;
    }
    function c(A, se) {
      if (!A || E) return "";
      var ie = Z.get(A);
      if (ie !== void 0) return ie;
      E = !0, ie = Error.prepareStackTrace, Error.prepareStackTrace = void 0;
      var Ee = null;
      Ee = I.H, I.H = null, a();
      try {
        var je = {
          DetermineComponentFrameRoot: function() {
            try {
              if (se) {
                var Je = function() {
                  throw Error();
                };
                if (Object.defineProperty(Je.prototype, "props", {
                  set: function() {
                    throw Error();
                  }
                }), typeof Reflect == "object" && Reflect.construct) {
                  try {
                    Reflect.construct(Je, []);
                  } catch (Ge) {
                    var $e = Ge;
                  }
                  Reflect.construct(A, [], Je);
                } else {
                  try {
                    Je.call();
                  } catch (Ge) {
                    $e = Ge;
                  }
                  A.call(Je.prototype);
                }
              } else {
                try {
                  throw Error();
                } catch (Ge) {
                  $e = Ge;
                }
                (Je = A()) && typeof Je.catch == "function" && Je.catch(function() {
                });
              }
            } catch (Ge) {
              if (Ge && $e && typeof Ge.stack == "string")
                return [Ge.stack, $e.stack];
            }
            return [null, null];
          }
        };
        je.DetermineComponentFrameRoot.displayName = "DetermineComponentFrameRoot";
        var Ae = Object.getOwnPropertyDescriptor(
          je.DetermineComponentFrameRoot,
          "name"
        );
        Ae && Ae.configurable && Object.defineProperty(
          je.DetermineComponentFrameRoot,
          "name",
          { value: "DetermineComponentFrameRoot" }
        );
        var pe = je.DetermineComponentFrameRoot(), Me = pe[0], He = pe[1];
        if (Me && He) {
          var Ue = Me.split(`
`), Oe = He.split(`
`);
          for (pe = Ae = 0; Ae < Ue.length && !Ue[Ae].includes(
            "DetermineComponentFrameRoot"
          ); )
            Ae++;
          for (; pe < Oe.length && !Oe[pe].includes(
            "DetermineComponentFrameRoot"
          ); )
            pe++;
          if (Ae === Ue.length || pe === Oe.length)
            for (Ae = Ue.length - 1, pe = Oe.length - 1; 1 <= Ae && 0 <= pe && Ue[Ae] !== Oe[pe]; )
              pe--;
          for (; 1 <= Ae && 0 <= pe; Ae--, pe--)
            if (Ue[Ae] !== Oe[pe]) {
              if (Ae !== 1 || pe !== 1)
                do
                  if (Ae--, pe--, 0 > pe || Ue[Ae] !== Oe[pe]) {
                    var Qe = `
` + Ue[Ae].replace(
                      " at new ",
                      " at "
                    );
                    return A.displayName && Qe.includes("<anonymous>") && (Qe = Qe.replace("<anonymous>", A.displayName)), typeof A == "function" && Z.set(A, Qe), Qe;
                  }
                while (1 <= Ae && 0 <= pe);
              break;
            }
        }
      } finally {
        E = !1, I.H = Ee, o(), Error.prepareStackTrace = ie;
      }
      return Ue = (Ue = A ? A.displayName || A.name : "") ? i(Ue) : "", typeof A == "function" && Z.set(A, Ue), Ue;
    }
    function l(A) {
      if (A == null) return "";
      if (typeof A == "function") {
        var se = A.prototype;
        return c(
          A,
          !(!se || !se.isReactComponent)
        );
      }
      if (typeof A == "string") return i(A);
      switch (A) {
        case J:
          return i("Suspense");
        case le:
          return i("SuspenseList");
      }
      if (typeof A == "object")
        switch (A.$$typeof) {
          case re:
            return A = c(A.render, !1), A;
          case Q:
            return l(A.type);
          case de:
            se = A._payload, A = A._init;
            try {
              return l(A(se));
            } catch {
            }
        }
      return "";
    }
    function d() {
      var A = I.A;
      return A === null ? null : A.getOwner();
    }
    function u(A) {
      if (f.call(A, "key")) {
        var se = Object.getOwnPropertyDescriptor(A, "key").get;
        if (se && se.isReactWarning) return !1;
      }
      return A.key !== void 0;
    }
    function m(A, se) {
      function ie() {
        ce || (ce = !0, console.error(
          "%s: `key` is not a prop. Trying to access it will result in `undefined` being returned. If you need to access the same value within the child component, you should pass it as a different prop. (https://react.dev/link/special-props)",
          se
        ));
      }
      ie.isReactWarning = !0, Object.defineProperty(A, "key", {
        get: ie,
        configurable: !0
      });
    }
    function p() {
      var A = r(this.type);
      return he[A] || (he[A] = !0, console.error(
        "Accessing element.ref was removed in React 19. ref is now a regular prop. It will be removed from the JSX Element type in a future release."
      )), A = this.props.ref, A !== void 0 ? A : null;
    }
    function y(A, se, ie, Ee, je, Ae) {
      return ie = Ae.ref, A = {
        $$typeof: R,
        type: A,
        key: se,
        props: Ae,
        _owner: je
      }, (ie !== void 0 ? ie : null) !== null ? Object.defineProperty(A, "ref", {
        enumerable: !1,
        get: p
      }) : Object.defineProperty(A, "ref", { enumerable: !1, value: null }), A._store = {}, Object.defineProperty(A._store, "validated", {
        configurable: !1,
        enumerable: !1,
        writable: !0,
        value: 0
      }), Object.defineProperty(A, "_debugInfo", {
        configurable: !1,
        enumerable: !1,
        writable: !0,
        value: null
      }), Object.freeze && (Object.freeze(A.props), Object.freeze(A)), A;
    }
    function g(A, se, ie, Ee, je, Ae) {
      if (typeof A == "string" || typeof A == "function" || A === U || A === N || A === q || A === J || A === le || A === te || typeof A == "object" && A !== null && (A.$$typeof === de || A.$$typeof === Q || A.$$typeof === Y || A.$$typeof === P || A.$$typeof === re || A.$$typeof === C || A.getModuleId !== void 0)) {
        var pe = se.children;
        if (pe !== void 0)
          if (Ee)
            if (k(pe)) {
              for (Ee = 0; Ee < pe.length; Ee++)
                w(pe[Ee], A);
              Object.freeze && Object.freeze(pe);
            } else
              console.error(
                "React.jsx: Static children should always be an array. You are likely explicitly calling React.jsxs or React.jsxDEV. Use the Babel transform instead."
              );
          else w(pe, A);
      } else
        pe = "", (A === void 0 || typeof A == "object" && A !== null && Object.keys(A).length === 0) && (pe += " You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports."), A === null ? Ee = "null" : k(A) ? Ee = "array" : A !== void 0 && A.$$typeof === R ? (Ee = "<" + (r(A.type) || "Unknown") + " />", pe = " Did you accidentally export a JSX literal instead of a component?") : Ee = typeof A, console.error(
          "React.jsx: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: %s.%s",
          Ee,
          pe
        );
      if (f.call(se, "key")) {
        pe = r(A);
        var Me = Object.keys(se).filter(function(Ue) {
          return Ue !== "key";
        });
        Ee = 0 < Me.length ? "{key: someKey, " + Me.join(": ..., ") + ": ...}" : "{key: someKey}", Ie[pe + Ee] || (Me = 0 < Me.length ? "{" + Me.join(": ..., ") + ": ...}" : "{}", console.error(
          `A props object containing a "key" prop is being spread into JSX:
  let props = %s;
  <%s {...props} />
React keys must be passed directly to JSX without using spread:
  let props = %s;
  <%s key={someKey} {...props} />`,
          Ee,
          pe,
          Me,
          pe
        ), Ie[pe + Ee] = !0);
      }
      if (pe = null, ie !== void 0 && (s(ie), pe = "" + ie), u(se) && (s(se.key), pe = "" + se.key), "key" in se) {
        ie = {};
        for (var He in se)
          He !== "key" && (ie[He] = se[He]);
      } else ie = se;
      return pe && m(
        ie,
        typeof A == "function" ? A.displayName || A.name || "Unknown" : A
      ), y(A, pe, Ae, je, d(), ie);
    }
    function w(A, se) {
      if (typeof A == "object" && A && A.$$typeof !== z) {
        if (k(A))
          for (var ie = 0; ie < A.length; ie++) {
            var Ee = A[ie];
            h(Ee) && M(Ee, se);
          }
        else if (h(A))
          A._store && (A._store.validated = 1);
        else if (A === null || typeof A != "object" ? ie = null : (ie = K && A[K] || A["@@iterator"], ie = typeof ie == "function" ? ie : null), typeof ie == "function" && ie !== A.entries && (ie = ie.call(A), ie !== A))
          for (; !(A = ie.next()).done; )
            h(A.value) && M(A.value, se);
      }
    }
    function h(A) {
      return typeof A == "object" && A !== null && A.$$typeof === R;
    }
    function M(A, se) {
      if (A._store && !A._store.validated && A.key == null && (A._store.validated = 1, se = x(se), !xe[se])) {
        xe[se] = !0;
        var ie = "";
        A && A._owner != null && A._owner !== d() && (ie = null, typeof A._owner.tag == "number" ? ie = r(A._owner.type) : typeof A._owner.name == "string" && (ie = A._owner.name), ie = " It was passed a child from " + ie + ".");
        var Ee = I.getCurrentStack;
        I.getCurrentStack = function() {
          var je = l(A.type);
          return Ee && (je += Ee() || ""), je;
        }, console.error(
          'Each child in a list should have a unique "key" prop.%s%s See https://react.dev/link/warning-keys for more information.',
          se,
          ie
        ), I.getCurrentStack = Ee;
      }
    }
    function x(A) {
      var se = "", ie = d();
      return ie && (ie = r(ie.type)) && (se = `

Check the render method of \`` + ie + "`."), se || (A = r(A)) && (se = `

Check the top-level render call using <` + A + ">."), se;
    }
    var T = lt, R = Symbol.for("react.transitional.element"), D = Symbol.for("react.portal"), U = Symbol.for("react.fragment"), q = Symbol.for("react.strict_mode"), N = Symbol.for("react.profiler"), P = Symbol.for("react.consumer"), Y = Symbol.for("react.context"), re = Symbol.for("react.forward_ref"), J = Symbol.for("react.suspense"), le = Symbol.for("react.suspense_list"), Q = Symbol.for("react.memo"), de = Symbol.for("react.lazy"), te = Symbol.for("react.offscreen"), K = Symbol.iterator, X = Symbol.for("react.client.reference"), I = T.__CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE, f = Object.prototype.hasOwnProperty, j = Object.assign, C = Symbol.for("react.client.reference"), k = Array.isArray, H = 0, V, F, _, B, oe, fe, G;
    n.__reactDisabledLog = !0;
    var ne, me, E = !1, Z = new (typeof WeakMap == "function" ? WeakMap : Map)(), z = Symbol.for("react.client.reference"), ce, he = {}, Ie = {}, xe = {};
    Dt.Fragment = U, Dt.jsx = function(A, se, ie, Ee, je) {
      return g(A, se, ie, !1, Ee, je);
    }, Dt.jsxs = function(A, se, ie, Ee, je) {
      return g(A, se, ie, !0, Ee, je);
    };
  }()), Dt;
}
var Ss;
function za() {
  return Ss || (Ss = 1, process.env.NODE_ENV === "production" ? Xt.exports = Ha() : Xt.exports = $a()), Xt.exports;
}
var e = za(), $ = /* @__PURE__ */ ((r) => (r.IN_PROGRESS = "InProgress", r.APPROVED = "Approved", r.COMPLETED = "Completed", r.DECLINED = "Declined", r))($ || {}), be = /* @__PURE__ */ ((r) => (r.PROMOTE_ADMIN = "PromoteAdmin", r.DEMOTE_SECURITY_ADMIN = "DemoteSecurityAdmin", r.TRANSFER_LOCK_BOX = "TransferLockBox", r.EDIT_MINIMUM_APPROVAL_COUNT = "EditMinimumApprovalCount", r.ADD_GROUP_PARTICIPANT = "AddGroupParticipant", r.RECOVER_USER = "RecoverUser", r))(be || {}), ye = /* @__PURE__ */ ((r) => (r.REGISTERED = "Registered", r.APPROVED = "Approved", r.CANCELLED = "Cancelled", r.ADMIN = "Admin", r.SECURITY_ADMIN = "SecurityAdmin", r.AUTO_APPROVED = "AutoApproved", r.AUTH_PENDING = "AuthPending", r))(ye || {}), gt = /* @__PURE__ */ ((r) => (r.MEMBER_LOCK_BOX = "memberLockBox", r.ADD_TO_GROUP = "addToGroup", r.ACTIVATE_MEMBER = "activateMember", r.TRANSACTION = "transaction", r.GROUP_OPERATION = "groupOperation", r.RECOVER_USER = "recoverUser", r))(gt || {});
const Qa = "transactionEncryptionKeyKek", Ja = "adminTemporaryPassphraseKek", Xa = "transferredMemberPrivateKeyKek", Za = "memberPrivateKeyInnerKek", eo = "memberPrivateKeyOuterKek", Bt = "Failed to Approve members. Please try again.", dt = "$", Ne = "#", Fe = {
  MembersList: "Members",
  Analytics: "Analytics",
  Applications: "Applications",
  Transactions: "Transactions",
  Groups: "Groups",
  LockboxRequests: "Lockbox Requests",
  TransferLockbox: "Transfer Lockbox",
  RecoverUser: "User Account Recovery",
  OrgSettings: "Org Settings",
  SecuritySettings: "Security Settings",
  Notifications: "Notifications"
}, Or = "AdminPublicKeyTag", to = "memberPublicKey", Zs = "memberAppPublicKey", jr = "withoutPasscode";
var Ze = /* @__PURE__ */ ((r) => (r.SINGLE_FA_WITH_PASSCODE = "SingleFAWithPasscode", r.SINGLE_FA_WITH_SECURITY_QUESTIONS = "SingleFAWithSecurityQuestions", r.SINGLE_FA_WITH_SECURITY_QUESTIONS_AND_PASSPHRASE = "SingleFAWithSecurityQuestionsAndPassphrase", r.TWO_FACTOR_AUTHENTICATION_WITHOUT_PASSPHRASE = "TwoFactorAuthenticationWithoutPassphrase", r.TWO_FACTOR_AUTHENTICATION_WITH_PASSPHRASE = "TwoFactorAuthenticationWithPassphrase", r))(Ze || {});
function ro() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-apps",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M4 4m0 1a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v4a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M4 14m0 1a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v4a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M14 14m0 1a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v4a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M14 7l6 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M17 4l0 6" })
      ]
    }
  ) });
}
function so() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-users",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M9 7m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M3 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2" }),
        /* @__PURE__ */ e.jsx("path", { d: "M16 3.13a4 4 0 0 1 0 7.75" }),
        /* @__PURE__ */ e.jsx("path", { d: "M21 21v-2a4 4 0 0 0 -3 -3.85" })
      ]
    }
  ) });
}
function no() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-transform",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M3 6a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M21 11v-3a2 2 0 0 0 -2 -2h-6l3 3m0 -6l-3 3" }),
        /* @__PURE__ */ e.jsx("path", { d: "M3 13v3a2 2 0 0 0 2 2h6l-3 -3m0 6l3 -3" }),
        /* @__PURE__ */ e.jsx("path", { d: "M15 18a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" })
      ]
    }
  ) });
}
function ao() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-affiliate",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M5.931 6.936l1.275 4.249m5.607 5.609l4.251 1.275" }),
        /* @__PURE__ */ e.jsx("path", { d: "M11.683 12.317l5.759 -5.759" }),
        /* @__PURE__ */ e.jsx("path", { d: "M5.5 5.5m-1.5 0a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0 -3 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M18.5 5.5m-1.5 0a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0 -3 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M18.5 18.5m-1.5 0a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0 -3 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M8.5 15.5m-4.5 0a4.5 4.5 0 1 0 9 0a4.5 4.5 0 1 0 -9 0" })
      ]
    }
  ) });
}
function oo() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-chart-bar-popular",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M3 13a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v6a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M9 9a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v10a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M15 5a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v14a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M4 20h14" })
      ]
    }
  ) });
}
function io() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-lock-access",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M10 5a2 2 0 1 1 4 0a7 7 0 0 1 4 6v3a4 4 0 0 0 2 3h-16a4 4 0 0 0 2 -3v-3a7 7 0 0 1 4 -6" }),
        /* @__PURE__ */ e.jsx("path", { d: "M9 17v1a3 3 0 0 0 6 0v-1" })
      ]
    }
  ) });
}
function co() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-replace-user",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M21 11v-3c0 -.53 -.211 -1.039 -.586 -1.414c-.375 -.375 -.884 -.586 -1.414 -.586h-6m0 0l3 3m-3 -3l3 -3" }),
        /* @__PURE__ */ e.jsx("path", { d: "M3 13.013v3c0 .53 .211 1.039 .586 1.414c.375 .375 .884 .586 1.414 .586h6m0 0l-3 -3m3 3l-3 3" }),
        /* @__PURE__ */ e.jsx("path", { d: "M16 16.502c0 .53 .211 1.039 .586 1.414c.375 .375 .884 .586 1.414 .586c.53 0 1.039 -.211 1.414 -.586c.375 -.375 .586 -.884 .586 -1.414c0 -.53 -.211 -1.039 -.586 -1.414c-.375 -.375 -.884 -.586 -1.414 -.586c-.53 0 -1.039 .211 -1.414 .586c-.375 .375 -.586 .884 -.586 1.414z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M4 4.502c0 .53 .211 1.039 .586 1.414c.375 .375 .884 .586 1.414 .586c.53 0 1.039 -.211 1.414 -.586c.375 -.375 .586 -.884 .586 -1.414c0 -.53 -.211 -1.039 -.586 -1.414c-.375 -.375 -.884 -.586 -1.414 -.586c-.53 0 -1.039 .211 -1.414 .586c-.375 .375 -.586 .884 -.586 1.414z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M21 21.499c0 -.53 -.211 -1.039 -.586 -1.414c-.375 -.375 -.884 -.586 -1.414 -.586h-2c-.53 0 -1.039 .211 -1.414 .586c-.375 .375 -.586 .884 -.586 1.414" }),
        /* @__PURE__ */ e.jsx("path", { d: "M9 9.499c0 -.53 -.211 -1.039 -.586 -1.414c-.375 -.375 -.884 -.586 -1.414 -.586h-2c-.53 0 -1.039 .211 -1.414 .586c-.375 .375 -.586 .884 -.586 1.414" })
      ]
    }
  ) });
}
function lo() {
  return /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-user-key",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M8 7a4 4 0 1 0 8 0a4 4 0 0 0 -8 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M6 21v-2a4 4 0 0 1 4 -4h5" }),
        /* @__PURE__ */ e.jsx("path", { d: "M18.5 18.5l-3.5 3.5l-1.5 -1.5" }),
        /* @__PURE__ */ e.jsx("path", { d: "M18.554 18.414a2 2 0 1 1 2.828 -2.828a2 2 0 0 1 -2.828 2.828" }),
        /* @__PURE__ */ e.jsx("path", { d: "M16 19l1 1" })
      ]
    }
  );
}
function uo() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-settings",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M10.325 4.317c.426 -1.756 2.924 -1.756 3.35 0a1.724 1.724 0 0 0 2.573 1.066c1.543 -.94 3.31 .826 2.37 2.37a1.724 1.724 0 0 0 1.065 2.572c1.756 .426 1.756 2.924 0 3.35a1.724 1.724 0 0 0 -1.066 2.573c.94 1.543 -.826 3.31 -2.37 2.37a1.724 1.724 0 0 0 -2.572 1.065c-.426 1.756 -2.924 1.756 -3.35 0a1.724 1.724 0 0 0 -2.573 -1.066c-1.543 .94 -3.31 -.826 -2.37 -2.37a1.724 1.724 0 0 0 -1.065 -2.572c-1.756 -.426 -1.756 -2.924 0 -3.35a1.724 1.724 0 0 0 1.066 -2.573c-.94 -1.543 .826 -3.31 2.37 -2.37c1 .608 2.296 .07 2.572 -1.065z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M9 12a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" })
      ]
    }
  ) });
}
function mo() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-bell",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M10 5a2 2 0 1 1 4 0a7 7 0 0 1 4 6v3a4 4 0 0 0 2 3h-16a4 4 0 0 0 2 -3v-3a7 7 0 0 1 4 -6" }),
        /* @__PURE__ */ e.jsx("path", { d: "M9 17v1a3 3 0 0 0 6 0v-1" })
      ]
    }
  ) });
}
function en({ children: r }) {
  const [t, s] = b(0), n = () => {
    s((a) => a + 1);
  };
  return /* @__PURE__ */ e.jsxs("div", { className: "reload-wrapper-container", children: [
    /* @__PURE__ */ e.jsx(
      "button",
      {
        type: "button",
        onClick: n,
        className: "reload-wrapper-button",
        children: "⟳"
      }
    ),
    /* @__PURE__ */ e.jsx("div", { children: r }, t)
  ] });
}
const v = {
  AUTH_TOKEN: "authToken",
  MEMBER_APP_PRIVATE_KEY: "memberAppPrivateKey",
  APP_ID: "appId",
  ECC_CURVE: "eccCurve",
  APP_SECRET: "appSecret",
  MEMBER_PUBLIC_KEY: "memberPublicKey",
  MEMBER_PRIVATE_KEY: "memberPrivateKey",
  ORG_KEY: "orgKey",
  MEMBER_KEY: "memberKey",
  MEMBER_AUTH_SALT: "memberAuthSalt",
  ORG_MEMBER_ID: "orgMemberId",
  ORG_NAME: "orgName",
  BACKDOOR_PUBLIC_KEY: "backdoorPublicKey",
  ORG_ID: "orgId",
  MEMBER_ID: "memberId",
  JOINED_GROUP_KEYS: "joinedGroupKeys",
  UNJOINED_GROUP_KEYS: "unjoinedGroupKeys",
  ORG_SIGNING_PRIVATE_KEY: "orgSigningPrivateKey",
  ORG_SIGNING_PUBLIC_KEY: "orgSigningPublicKey",
  MEMBER_SIGNING_PRIVATE_KEY: "memberSigningPrivateKey",
  MEMBER_SIGNING_PUBLIC_KEY: "memberSigningPublicKey",
  MEMBER_STATUS: "memberStatus",
  MEMBER_SIGNING_PRIVATE_KEY: "memberSigningPrivateKey",
  MEMBER_SIGNING_PUBLIC_KEY: "memberSigningPublicKey",
  USER_AUTH_SALT: "userAuthSalt",
  MEMBER_APP_ID: "memberAppId",
  ANSWER_AUTH_SALT: "authAnswerSalt",
  IS_PASSPHRASE_ACTIVE: "isPassphraseActive",
  USER_PRIVATE_KEY: "userPrivateKey",
  USER_ID: "userId",
  DEFAULT_ENCRYPTION_POLICY: "defaultEncryptionPolicy",
  DEFAULT_ENCRYPTION_MODE: "defaultEncryptionMode",
  DEFAULT_KEY_GENERATION_POLICY: "defaultKeyGenerationPolicy",
  ADMIN_PUBLIC_KEY: "adminPublicKey",
  MEMBER_APP_PUBLIC_KEY: "memberAppPublicKey",
  ORG_SIGNING_PUBLIC_KEY: "orgSigningPublicKey",
  CREATION_APP_PUBLIC_KEY: "creationAppPublicKey",
  AUTHORIZATION_APP_PUBLIC_KEY: "authorizationAppPublicKey",
  GHOST_MEMBER_PUBLIC_KEY: "ghostMemberPublicKey",
  GHOST_MEMBER_PUBLIC_KEY_WITH_SIGNATURES: "ghostMemberPublicKeyWithSignatures",
  USER_PUBLIC_KEY: "userPublicKey",
  APP_SECRET_SALT: "appSecretSalt",
  APP_KEY_PAIR_ID: "appKeyPairId",
  ACCESS_APP_PRIVATE_KEY: "accessAppPrivateKey",
  ACCESS_APP_KEY_PAIR_ID: "accessAppPrivateKeyPairId",
  CREATION_APP_PRIVATE_KEY: "creationAppPrivateKey",
  CREATION_APP_KEY_PAIR_ID: "creationAppPrivateKeyPairId",
  AUTHORISATION_APP_PRIVATE_KEY: "authorizationAppPrivateKey",
  AUTHORISATION_APP_KEY_PAIR_ID: "authorizationAppPrivateKeyPairId",
  GHOST_MEMBER_ID: "ghostMemberId",
  IS_TWO_FA_ENABLED: "isTwoFaEnabled",
  HALF_SIGNED_MEMBER_PUBLIC_KEY: "halfSignedMemberPublicKey",
  ENCRYPTION_TYPE: "encryptionType",
  IS_CREATE_ORG_REQUEST: "isCreateOrgRequest",
  IS_VALIDATE_2FA_FOR_CREATE_MEMBER_APP: "isValidate2FAForCreateMemberApp",
  IS_VALIDATE_2FA_FOR_CREATE_MEMBER: "isValidate2FAForCreateMember",
  EMAIL_ADDRESS: "emailId",
  DECRYPTED_CHALLENGE: "decryptedChallenge",
  IS_ENCRYPTION_ENABLED: "isEncryptionEnabled",
  LAST_CHAIN_OBJECT_FOR: "lastChainObjectFor",
  CHAIN_KGP_OBJECTS_LIST: "chainKgpObjectsList",
  STATS_SYNC_TIME_DURATION: "statsSyncTimeDuration",
  STATS_SYNC_EXPIRY_TIME: "statsSyncExpiryTime",
  STATISTICS_KEY: "statisticsKey",
  ENCRYPTION_COUNT: "encryptionCount",
  DECRYPTION_COUNT: "decryptionCount",
  LOCAL_STORAGE_ENCRYPTION_KEY: "localStorageEncryptionKey",
  LOCAL_STORAGE_ENCRYPTION_HASH: "localStorageEncryptionHash",
  AUTHENTICATION_SALT: "authenticationSalt",
  LOCAL_STORAGE_ENCRYPTION_MODE: "localStorageEncryptionMode",
  IS_NEW_AUTHENTICATION: "isNewAuthentication",
  MFA_SETTING: "mfaSetting",
  SECURITY_QUESTIONS: "securityQuestions",
  LAST_LOGIN_TIME: "lastLoginTime",
  ENCRYPTED_USER_PRIVATE_KEY_PARTS: "encryptedUserPrivateKeyParts",
  ANSWER_KEY_SALTS: "answerKeySalts",
  LOCAL_ENCRYPTION_VERIFICATION_STRING: "localEncryptionVerificationString",
  IS_APP_CREATED_WITH_PWD: "isAppCreatedWithPasscode",
  ENABLE_FACE_RECOGNITION: "enableFaceRecognition",
  FR_ENCRYPTION_KEY: "frEncryptionKey",
  FR_DECRYPTION_KEY: "frDecryptionKey",
  REGISTER_FACE_ID: "registerFaceId",
  VISHWAM_SECRET: "vishwamSecret",
  AUTH_PASSCODE_KEY: "authPasscodeKey",
  MEMBER_KEY_SALT: "memberKeySalt",
  LOCK_UNLOCK_EXPIRY_TIME: "lockAndUnlockExpiryTime",
  GROUP_PUBLIC_KEY: "groupPublicKey",
  MEMBER_APP_STATUS: "appStatus",
  BAYUN_SERVER_PUBLIC_KEY: "bayunServerPublicKey",
  USER_STATUS: "userStatus",
  MULTI_FACTOR_AUTH: "multiFactorAuth",
  LMS_TRANSACTION_KEY: "lmsTransactionKey",
  IS_PASSCODE_AUTH: "isPasscodeAuth",
  IS_DEVELOPER: "isDeveloper",
  DEVELOPER_KEY: "developerKey",
  DEVELOPER_KEY_KEK: "developerKeyKek",
  IS_USER: "isUser",
  IS_ADMIN: "isAdmin",
  IS_SECURITY_ADMIN: "isSecurityAdmin",
  ADMIN_PRIVATE_KEY_KEK: "adminPrivateKey_kek",
  BACKDOOR_PRIVATE_KEY_PART_KEK: "backdoorPrivateKeyPart_kek",
  IS_NEW_USER: "isNewUser",
  KEY_VALIDATION_POLICY: "keyValidationPolicy",
  ADMIN_PRIVATE_KEY: "adminPrivateKey",
  FIRST_TIME_LOG_IN: "firstTimeLogIn",
  VALIDATION_SECRET_DATA_REQUEST: "validationSecretDataRequest",
  MINIMUM_CORRECT_QUESTIONS: "minimumCorrectQuestions",
  SETTING_LAST_UPDATED_AT: "settingLastUpdatedAt"
};
function O(r) {
  for (var t = r + "=", s = document.cookie.split(";"), n = 0; n < s.length; n++) {
    for (var a = s[n]; a.charAt(0) == " "; ) a = a.substring(1, a.length);
    if (a.indexOf(t) == 0) return a.substring(t.length, a.length);
  }
  return null;
}
const tn = {
  __isBayunAdmin: !0,
  __receiveInternal(r) {
    this.internal = r;
  }
};
var sr, Js;
typeof window < "u" && ((Js = (sr = window.BayunCore) == null ? void 0 : sr.__grantInternalAccess) == null || Js.call(sr, tn));
function ue() {
  return tn.internal;
}
function po() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-settings",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M4 8h4v4h-4z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M6 4l0 4" }),
        /* @__PURE__ */ e.jsx("path", { d: "M6 12l0 8" }),
        /* @__PURE__ */ e.jsx("path", { d: "M10 14h4v4h-4z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M12 4l0 10" }),
        /* @__PURE__ */ e.jsx("path", { d: "M12 18l0 2" }),
        /* @__PURE__ */ e.jsx("path", { d: "M16 5h4v4h-4z" }),
        /* @__PURE__ */ e.jsx("path", { d: "M18 4l0 1" }),
        /* @__PURE__ */ e.jsx("path", { d: "M18 9l0 11" }),
        " "
      ]
    }
  ) });
}
const ct = {
  SECURITY_ADMIN: "securityadmin",
  ADMIN: "admin",
  APPROVED: "approved",
  MEMBER: "member",
  AUTO_APPROVED: "autoapproved"
}, Tr = /* @__PURE__ */ new Set([
  Fe.Transactions,
  Fe.Analytics,
  Fe.Applications,
  Fe.Groups,
  Fe.SecuritySettings
]), yo = (r) => r.filter((t) => t.key !== Fe.SecuritySettings), ho = (r) => {
  if (typeof r == "boolean")
    return r;
  if (typeof r == "string") {
    const t = r.trim().toLowerCase();
    if (t === "true")
      return !0;
    if (t === "false")
      return !1;
  }
  if (typeof r == "number") {
    if (r === 1)
      return !0;
    if (r === 0)
      return !1;
  }
}, go = (r) => {
  if (typeof r == "string") {
    const s = r.trim();
    return s.length ? s : void 0;
  }
  if (r == null)
    return;
  const t = String(r).trim();
  return t.length ? t : void 0;
}, mt = (r) => {
  const t = go(r);
  return t ? {
    memberStatus: t.toLowerCase()
  } : {};
}, rn = (r, t, s) => {
  var i;
  const n = (i = t == null ? void 0 : t.memberStatus) == null ? void 0 : i.toLowerCase(), a = typeof (t == null ? void 0 : t.keyValidationPolicy) == "string" ? t.keyValidationPolicy.toLowerCase() : void 0;
  if (!Array.isArray(r))
    return [];
  let o;
  return n === ct.SECURITY_ADMIN && (o = r.filter(
    (c) => c.key !== Fe.LockboxRequests
  )), n === ct.ADMIN && (o = r.filter(
    (c) => c.key !== Fe.LockboxRequests
  )), (n === ct.APPROVED || n === ct.MEMBER) && (o = r.filter((c) => Tr.has(c.key))), n === ct.AUTO_APPROVED && (a === "autoapproval" ? o = r.filter((c) => Tr.has(c.key)) : o = r.filter(
    (c) => Tr.has(c.key) && c.key !== Fe.Groups
  )), o || (o = [...r]), ((t == null ? void 0 : t.isTwoFaEnabled) === !1 || s === null || s === void 0) && (o = yo(o)), o;
}, sn = (r) => ({
  memberStatus: r == null ? void 0 : r.memberStatus,
  isTwoFaEnabled: ho(r == null ? void 0 : r.isTwoFaEnabled),
  keyValidationPolicy: r == null ? void 0 : r.keyValidationPolicy
});
function nn(r, t) {
  return function() {
    return r.apply(t, arguments);
  };
}
const { toString: fo } = Object.prototype, { getPrototypeOf: ts } = Object, { iterator: pr, toStringTag: an } = Symbol, yr = /* @__PURE__ */ ((r) => (t) => {
  const s = fo.call(t);
  return r[s] || (r[s] = s.slice(8, -1).toLowerCase());
})(/* @__PURE__ */ Object.create(null)), ot = (r) => (r = r.toLowerCase(), (t) => yr(t) === r), hr = (r) => (t) => typeof t === r, { isArray: Nt } = Array, Yt = hr("undefined");
function Vt(r) {
  return r !== null && !Yt(r) && r.constructor !== null && !Yt(r.constructor) && Ve(r.constructor.isBuffer) && r.constructor.isBuffer(r);
}
const on = ot("ArrayBuffer");
function bo(r) {
  let t;
  return typeof ArrayBuffer < "u" && ArrayBuffer.isView ? t = ArrayBuffer.isView(r) : t = r && r.buffer && on(r.buffer), t;
}
const wo = hr("string"), Ve = hr("function"), cn = hr("number"), qt = (r) => r !== null && typeof r == "object", Ao = (r) => r === !0 || r === !1, nr = (r) => {
  if (yr(r) !== "object")
    return !1;
  const t = ts(r);
  return (t === null || t === Object.prototype || Object.getPrototypeOf(t) === null) && !(an in r) && !(pr in r);
}, vo = (r) => {
  if (!qt(r) || Vt(r))
    return !1;
  try {
    return Object.keys(r).length === 0 && Object.getPrototypeOf(r) === Object.prototype;
  } catch {
    return !1;
  }
}, Eo = ot("Date"), xo = ot("File"), So = ot("Blob"), Mo = ot("FileList"), Po = (r) => qt(r) && Ve(r.pipe), Io = (r) => {
  let t;
  return r && (typeof FormData == "function" && r instanceof FormData || Ve(r.append) && ((t = yr(r)) === "formdata" || // detect form-data instance
  t === "object" && Ve(r.toString) && r.toString() === "[object FormData]"));
}, jo = ot("URLSearchParams"), [To, No, ko, Ro] = ["ReadableStream", "Request", "Response", "Headers"].map(ot), Co = (r) => r.trim ? r.trim() : r.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, "");
function Wt(r, t, { allOwnKeys: s = !1 } = {}) {
  if (r === null || typeof r > "u")
    return;
  let n, a;
  if (typeof r != "object" && (r = [r]), Nt(r))
    for (n = 0, a = r.length; n < a; n++)
      t.call(null, r[n], n, r);
  else {
    if (Vt(r))
      return;
    const o = s ? Object.getOwnPropertyNames(r) : Object.keys(r), i = o.length;
    let c;
    for (n = 0; n < i; n++)
      c = o[n], t.call(null, r[c], c, r);
  }
}
function ln(r, t) {
  if (Vt(r))
    return null;
  t = t.toLowerCase();
  const s = Object.keys(r);
  let n = s.length, a;
  for (; n-- > 0; )
    if (a = s[n], t === a.toLowerCase())
      return a;
  return null;
}
const vt = typeof globalThis < "u" ? globalThis : typeof self < "u" ? self : typeof window < "u" ? window : global, dn = (r) => !Yt(r) && r !== vt;
function Lr() {
  const { caseless: r } = dn(this) && this || {}, t = {}, s = (n, a) => {
    const o = r && ln(t, a) || a;
    nr(t[o]) && nr(n) ? t[o] = Lr(t[o], n) : nr(n) ? t[o] = Lr({}, n) : Nt(n) ? t[o] = n.slice() : t[o] = n;
  };
  for (let n = 0, a = arguments.length; n < a; n++)
    arguments[n] && Wt(arguments[n], s);
  return t;
}
const _o = (r, t, s, { allOwnKeys: n } = {}) => (Wt(t, (a, o) => {
  s && Ve(a) ? r[o] = nn(a, s) : r[o] = a;
}, { allOwnKeys: n }), r), Ko = (r) => (r.charCodeAt(0) === 65279 && (r = r.slice(1)), r), Oo = (r, t, s, n) => {
  r.prototype = Object.create(t.prototype, n), r.prototype.constructor = r, Object.defineProperty(r, "super", {
    value: t.prototype
  }), s && Object.assign(r.prototype, s);
}, Lo = (r, t, s, n) => {
  let a, o, i;
  const c = {};
  if (t = t || {}, r == null) return t;
  do {
    for (a = Object.getOwnPropertyNames(r), o = a.length; o-- > 0; )
      i = a[o], (!n || n(i, r, t)) && !c[i] && (t[i] = r[i], c[i] = !0);
    r = s !== !1 && ts(r);
  } while (r && (!s || s(r, t)) && r !== Object.prototype);
  return t;
}, Do = (r, t, s) => {
  r = String(r), (s === void 0 || s > r.length) && (s = r.length), s -= t.length;
  const n = r.indexOf(t, s);
  return n !== -1 && n === s;
}, Uo = (r) => {
  if (!r) return null;
  if (Nt(r)) return r;
  let t = r.length;
  if (!cn(t)) return null;
  const s = new Array(t);
  for (; t-- > 0; )
    s[t] = r[t];
  return s;
}, Fo = /* @__PURE__ */ ((r) => (t) => r && t instanceof r)(typeof Uint8Array < "u" && ts(Uint8Array)), Bo = (r, t) => {
  const n = (r && r[pr]).call(r);
  let a;
  for (; (a = n.next()) && !a.done; ) {
    const o = a.value;
    t.call(r, o[0], o[1]);
  }
}, Go = (r, t) => {
  let s;
  const n = [];
  for (; (s = r.exec(t)) !== null; )
    n.push(s);
  return n;
}, Yo = ot("HTMLFormElement"), Vo = (r) => r.toLowerCase().replace(
  /[-_\s]([a-z\d])(\w*)/g,
  function(s, n, a) {
    return n.toUpperCase() + a;
  }
), Ms = (({ hasOwnProperty: r }) => (t, s) => r.call(t, s))(Object.prototype), qo = ot("RegExp"), un = (r, t) => {
  const s = Object.getOwnPropertyDescriptors(r), n = {};
  Wt(s, (a, o) => {
    let i;
    (i = t(a, o, r)) !== !1 && (n[o] = i || a);
  }), Object.defineProperties(r, n);
}, Wo = (r) => {
  un(r, (t, s) => {
    if (Ve(r) && ["arguments", "caller", "callee"].indexOf(s) !== -1)
      return !1;
    const n = r[s];
    if (Ve(n)) {
      if (t.enumerable = !1, "writable" in t) {
        t.writable = !1;
        return;
      }
      t.set || (t.set = () => {
        throw Error("Can not rewrite read-only method '" + s + "'");
      });
    }
  });
}, Ho = (r, t) => {
  const s = {}, n = (a) => {
    a.forEach((o) => {
      s[o] = !0;
    });
  };
  return Nt(r) ? n(r) : n(String(r).split(t)), s;
}, $o = () => {
}, zo = (r, t) => r != null && Number.isFinite(r = +r) ? r : t;
function Qo(r) {
  return !!(r && Ve(r.append) && r[an] === "FormData" && r[pr]);
}
const Jo = (r) => {
  const t = new Array(10), s = (n, a) => {
    if (qt(n)) {
      if (t.indexOf(n) >= 0)
        return;
      if (Vt(n))
        return n;
      if (!("toJSON" in n)) {
        t[a] = n;
        const o = Nt(n) ? [] : {};
        return Wt(n, (i, c) => {
          const l = s(i, a + 1);
          !Yt(l) && (o[c] = l);
        }), t[a] = void 0, o;
      }
    }
    return n;
  };
  return s(r, 0);
}, Xo = ot("AsyncFunction"), Zo = (r) => r && (qt(r) || Ve(r)) && Ve(r.then) && Ve(r.catch), mn = ((r, t) => r ? setImmediate : t ? ((s, n) => (vt.addEventListener("message", ({ source: a, data: o }) => {
  a === vt && o === s && n.length && n.shift()();
}, !1), (a) => {
  n.push(a), vt.postMessage(s, "*");
}))(`axios@${Math.random()}`, []) : (s) => setTimeout(s))(
  typeof setImmediate == "function",
  Ve(vt.postMessage)
), ei = typeof queueMicrotask < "u" ? queueMicrotask.bind(vt) : typeof process < "u" && process.nextTick || mn, ti = (r) => r != null && Ve(r[pr]), L = {
  isArray: Nt,
  isArrayBuffer: on,
  isBuffer: Vt,
  isFormData: Io,
  isArrayBufferView: bo,
  isString: wo,
  isNumber: cn,
  isBoolean: Ao,
  isObject: qt,
  isPlainObject: nr,
  isEmptyObject: vo,
  isReadableStream: To,
  isRequest: No,
  isResponse: ko,
  isHeaders: Ro,
  isUndefined: Yt,
  isDate: Eo,
  isFile: xo,
  isBlob: So,
  isRegExp: qo,
  isFunction: Ve,
  isStream: Po,
  isURLSearchParams: jo,
  isTypedArray: Fo,
  isFileList: Mo,
  forEach: Wt,
  merge: Lr,
  extend: _o,
  trim: Co,
  stripBOM: Ko,
  inherits: Oo,
  toFlatObject: Lo,
  kindOf: yr,
  kindOfTest: ot,
  endsWith: Do,
  toArray: Uo,
  forEachEntry: Bo,
  matchAll: Go,
  isHTMLForm: Yo,
  hasOwnProperty: Ms,
  hasOwnProp: Ms,
  // an alias to avoid ESLint no-prototype-builtins detection
  reduceDescriptors: un,
  freezeMethods: Wo,
  toObjectSet: Ho,
  toCamelCase: Vo,
  noop: $o,
  toFiniteNumber: zo,
  findKey: ln,
  global: vt,
  isContextDefined: dn,
  isSpecCompliantForm: Qo,
  toJSONObject: Jo,
  isAsyncFn: Xo,
  isThenable: Zo,
  setImmediate: mn,
  asap: ei,
  isIterable: ti
};
function Se(r, t, s, n, a) {
  Error.call(this), Error.captureStackTrace ? Error.captureStackTrace(this, this.constructor) : this.stack = new Error().stack, this.message = r, this.name = "AxiosError", t && (this.code = t), s && (this.config = s), n && (this.request = n), a && (this.response = a, this.status = a.status ? a.status : null);
}
L.inherits(Se, Error, {
  toJSON: function() {
    return {
      // Standard
      message: this.message,
      name: this.name,
      // Microsoft
      description: this.description,
      number: this.number,
      // Mozilla
      fileName: this.fileName,
      lineNumber: this.lineNumber,
      columnNumber: this.columnNumber,
      stack: this.stack,
      // Axios
      config: L.toJSONObject(this.config),
      code: this.code,
      status: this.status
    };
  }
});
const pn = Se.prototype, yn = {};
[
  "ERR_BAD_OPTION_VALUE",
  "ERR_BAD_OPTION",
  "ECONNABORTED",
  "ETIMEDOUT",
  "ERR_NETWORK",
  "ERR_FR_TOO_MANY_REDIRECTS",
  "ERR_DEPRECATED",
  "ERR_BAD_RESPONSE",
  "ERR_BAD_REQUEST",
  "ERR_CANCELED",
  "ERR_NOT_SUPPORT",
  "ERR_INVALID_URL"
  // eslint-disable-next-line func-names
].forEach((r) => {
  yn[r] = { value: r };
});
Object.defineProperties(Se, yn);
Object.defineProperty(pn, "isAxiosError", { value: !0 });
Se.from = (r, t, s, n, a, o) => {
  const i = Object.create(pn);
  return L.toFlatObject(r, i, function(l) {
    return l !== Error.prototype;
  }, (c) => c !== "isAxiosError"), Se.call(i, r.message, t, s, n, a), i.cause = r, i.name = r.name, o && Object.assign(i, o), i;
};
const ri = null;
function Dr(r) {
  return L.isPlainObject(r) || L.isArray(r);
}
function hn(r) {
  return L.endsWith(r, "[]") ? r.slice(0, -2) : r;
}
function Ps(r, t, s) {
  return r ? r.concat(t).map(function(a, o) {
    return a = hn(a), !s && o ? "[" + a + "]" : a;
  }).join(s ? "." : "") : t;
}
function si(r) {
  return L.isArray(r) && !r.some(Dr);
}
const ni = L.toFlatObject(L, {}, null, function(t) {
  return /^is[A-Z]/.test(t);
});
function gr(r, t, s) {
  if (!L.isObject(r))
    throw new TypeError("target must be an object");
  t = t || new FormData(), s = L.toFlatObject(s, {
    metaTokens: !0,
    dots: !1,
    indexes: !1
  }, !1, function(w, h) {
    return !L.isUndefined(h[w]);
  });
  const n = s.metaTokens, a = s.visitor || u, o = s.dots, i = s.indexes, l = (s.Blob || typeof Blob < "u" && Blob) && L.isSpecCompliantForm(t);
  if (!L.isFunction(a))
    throw new TypeError("visitor must be a function");
  function d(g) {
    if (g === null) return "";
    if (L.isDate(g))
      return g.toISOString();
    if (L.isBoolean(g))
      return g.toString();
    if (!l && L.isBlob(g))
      throw new Se("Blob is not supported. Use a Buffer instead.");
    return L.isArrayBuffer(g) || L.isTypedArray(g) ? l && typeof Blob == "function" ? new Blob([g]) : Buffer.from(g) : g;
  }
  function u(g, w, h) {
    let M = g;
    if (g && !h && typeof g == "object") {
      if (L.endsWith(w, "{}"))
        w = n ? w : w.slice(0, -2), g = JSON.stringify(g);
      else if (L.isArray(g) && si(g) || (L.isFileList(g) || L.endsWith(w, "[]")) && (M = L.toArray(g)))
        return w = hn(w), M.forEach(function(T, R) {
          !(L.isUndefined(T) || T === null) && t.append(
            // eslint-disable-next-line no-nested-ternary
            i === !0 ? Ps([w], R, o) : i === null ? w : w + "[]",
            d(T)
          );
        }), !1;
    }
    return Dr(g) ? !0 : (t.append(Ps(h, w, o), d(g)), !1);
  }
  const m = [], p = Object.assign(ni, {
    defaultVisitor: u,
    convertValue: d,
    isVisitable: Dr
  });
  function y(g, w) {
    if (!L.isUndefined(g)) {
      if (m.indexOf(g) !== -1)
        throw Error("Circular reference detected in " + w.join("."));
      m.push(g), L.forEach(g, function(M, x) {
        (!(L.isUndefined(M) || M === null) && a.call(
          t,
          M,
          L.isString(x) ? x.trim() : x,
          w,
          p
        )) === !0 && y(M, w ? w.concat(x) : [x]);
      }), m.pop();
    }
  }
  if (!L.isObject(r))
    throw new TypeError("data must be an object");
  return y(r), t;
}
function Is(r) {
  const t = {
    "!": "%21",
    "'": "%27",
    "(": "%28",
    ")": "%29",
    "~": "%7E",
    "%20": "+",
    "%00": "\0"
  };
  return encodeURIComponent(r).replace(/[!'()~]|%20|%00/g, function(n) {
    return t[n];
  });
}
function rs(r, t) {
  this._pairs = [], r && gr(r, this, t);
}
const gn = rs.prototype;
gn.append = function(t, s) {
  this._pairs.push([t, s]);
};
gn.toString = function(t) {
  const s = t ? function(n) {
    return t.call(this, n, Is);
  } : Is;
  return this._pairs.map(function(a) {
    return s(a[0]) + "=" + s(a[1]);
  }, "").join("&");
};
function ai(r) {
  return encodeURIComponent(r).replace(/%3A/gi, ":").replace(/%24/g, "$").replace(/%2C/gi, ",").replace(/%20/g, "+").replace(/%5B/gi, "[").replace(/%5D/gi, "]");
}
function fn(r, t, s) {
  if (!t)
    return r;
  const n = s && s.encode || ai;
  L.isFunction(s) && (s = {
    serialize: s
  });
  const a = s && s.serialize;
  let o;
  if (a ? o = a(t, s) : o = L.isURLSearchParams(t) ? t.toString() : new rs(t, s).toString(n), o) {
    const i = r.indexOf("#");
    i !== -1 && (r = r.slice(0, i)), r += (r.indexOf("?") === -1 ? "?" : "&") + o;
  }
  return r;
}
class js {
  constructor() {
    this.handlers = [];
  }
  /**
   * Add a new interceptor to the stack
   *
   * @param {Function} fulfilled The function to handle `then` for a `Promise`
   * @param {Function} rejected The function to handle `reject` for a `Promise`
   *
   * @return {Number} An ID used to remove interceptor later
   */
  use(t, s, n) {
    return this.handlers.push({
      fulfilled: t,
      rejected: s,
      synchronous: n ? n.synchronous : !1,
      runWhen: n ? n.runWhen : null
    }), this.handlers.length - 1;
  }
  /**
   * Remove an interceptor from the stack
   *
   * @param {Number} id The ID that was returned by `use`
   *
   * @returns {Boolean} `true` if the interceptor was removed, `false` otherwise
   */
  eject(t) {
    this.handlers[t] && (this.handlers[t] = null);
  }
  /**
   * Clear all interceptors from the stack
   *
   * @returns {void}
   */
  clear() {
    this.handlers && (this.handlers = []);
  }
  /**
   * Iterate over all the registered interceptors
   *
   * This method is particularly useful for skipping over any
   * interceptors that may have become `null` calling `eject`.
   *
   * @param {Function} fn The function to call for each interceptor
   *
   * @returns {void}
   */
  forEach(t) {
    L.forEach(this.handlers, function(n) {
      n !== null && t(n);
    });
  }
}
const bn = {
  silentJSONParsing: !0,
  forcedJSONParsing: !0,
  clarifyTimeoutError: !1
}, oi = typeof URLSearchParams < "u" ? URLSearchParams : rs, ii = typeof FormData < "u" ? FormData : null, ci = typeof Blob < "u" ? Blob : null, li = {
  isBrowser: !0,
  classes: {
    URLSearchParams: oi,
    FormData: ii,
    Blob: ci
  },
  protocols: ["http", "https", "file", "blob", "url", "data"]
}, ss = typeof window < "u" && typeof document < "u", Ur = typeof navigator == "object" && navigator || void 0, di = ss && (!Ur || ["ReactNative", "NativeScript", "NS"].indexOf(Ur.product) < 0), ui = typeof WorkerGlobalScope < "u" && // eslint-disable-next-line no-undef
self instanceof WorkerGlobalScope && typeof self.importScripts == "function", mi = ss && window.location.href || "http://localhost", pi = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  hasBrowserEnv: ss,
  hasStandardBrowserEnv: di,
  hasStandardBrowserWebWorkerEnv: ui,
  navigator: Ur,
  origin: mi
}, Symbol.toStringTag, { value: "Module" })), Ye = {
  ...pi,
  ...li
};
function yi(r, t) {
  return gr(r, new Ye.classes.URLSearchParams(), {
    visitor: function(s, n, a, o) {
      return Ye.isNode && L.isBuffer(s) ? (this.append(n, s.toString("base64")), !1) : o.defaultVisitor.apply(this, arguments);
    },
    ...t
  });
}
function hi(r) {
  return L.matchAll(/\w+|\[(\w*)]/g, r).map((t) => t[0] === "[]" ? "" : t[1] || t[0]);
}
function gi(r) {
  const t = {}, s = Object.keys(r);
  let n;
  const a = s.length;
  let o;
  for (n = 0; n < a; n++)
    o = s[n], t[o] = r[o];
  return t;
}
function wn(r) {
  function t(s, n, a, o) {
    let i = s[o++];
    if (i === "__proto__") return !0;
    const c = Number.isFinite(+i), l = o >= s.length;
    return i = !i && L.isArray(a) ? a.length : i, l ? (L.hasOwnProp(a, i) ? a[i] = [a[i], n] : a[i] = n, !c) : ((!a[i] || !L.isObject(a[i])) && (a[i] = []), t(s, n, a[i], o) && L.isArray(a[i]) && (a[i] = gi(a[i])), !c);
  }
  if (L.isFormData(r) && L.isFunction(r.entries)) {
    const s = {};
    return L.forEachEntry(r, (n, a) => {
      t(hi(n), a, s, 0);
    }), s;
  }
  return null;
}
function fi(r, t, s) {
  if (L.isString(r))
    try {
      return (t || JSON.parse)(r), L.trim(r);
    } catch (n) {
      if (n.name !== "SyntaxError")
        throw n;
    }
  return (s || JSON.stringify)(r);
}
const Ht = {
  transitional: bn,
  adapter: ["xhr", "http", "fetch"],
  transformRequest: [function(t, s) {
    const n = s.getContentType() || "", a = n.indexOf("application/json") > -1, o = L.isObject(t);
    if (o && L.isHTMLForm(t) && (t = new FormData(t)), L.isFormData(t))
      return a ? JSON.stringify(wn(t)) : t;
    if (L.isArrayBuffer(t) || L.isBuffer(t) || L.isStream(t) || L.isFile(t) || L.isBlob(t) || L.isReadableStream(t))
      return t;
    if (L.isArrayBufferView(t))
      return t.buffer;
    if (L.isURLSearchParams(t))
      return s.setContentType("application/x-www-form-urlencoded;charset=utf-8", !1), t.toString();
    let c;
    if (o) {
      if (n.indexOf("application/x-www-form-urlencoded") > -1)
        return yi(t, this.formSerializer).toString();
      if ((c = L.isFileList(t)) || n.indexOf("multipart/form-data") > -1) {
        const l = this.env && this.env.FormData;
        return gr(
          c ? { "files[]": t } : t,
          l && new l(),
          this.formSerializer
        );
      }
    }
    return o || a ? (s.setContentType("application/json", !1), fi(t)) : t;
  }],
  transformResponse: [function(t) {
    const s = this.transitional || Ht.transitional, n = s && s.forcedJSONParsing, a = this.responseType === "json";
    if (L.isResponse(t) || L.isReadableStream(t))
      return t;
    if (t && L.isString(t) && (n && !this.responseType || a)) {
      const i = !(s && s.silentJSONParsing) && a;
      try {
        return JSON.parse(t);
      } catch (c) {
        if (i)
          throw c.name === "SyntaxError" ? Se.from(c, Se.ERR_BAD_RESPONSE, this, null, this.response) : c;
      }
    }
    return t;
  }],
  /**
   * A timeout in milliseconds to abort a request. If set to 0 (default) a
   * timeout is not created.
   */
  timeout: 0,
  xsrfCookieName: "XSRF-TOKEN",
  xsrfHeaderName: "X-XSRF-TOKEN",
  maxContentLength: -1,
  maxBodyLength: -1,
  env: {
    FormData: Ye.classes.FormData,
    Blob: Ye.classes.Blob
  },
  validateStatus: function(t) {
    return t >= 200 && t < 300;
  },
  headers: {
    common: {
      Accept: "application/json, text/plain, */*",
      "Content-Type": void 0
    }
  }
};
L.forEach(["delete", "get", "head", "post", "put", "patch"], (r) => {
  Ht.headers[r] = {};
});
const bi = L.toObjectSet([
  "age",
  "authorization",
  "content-length",
  "content-type",
  "etag",
  "expires",
  "from",
  "host",
  "if-modified-since",
  "if-unmodified-since",
  "last-modified",
  "location",
  "max-forwards",
  "proxy-authorization",
  "referer",
  "retry-after",
  "user-agent"
]), wi = (r) => {
  const t = {};
  let s, n, a;
  return r && r.split(`
`).forEach(function(i) {
    a = i.indexOf(":"), s = i.substring(0, a).trim().toLowerCase(), n = i.substring(a + 1).trim(), !(!s || t[s] && bi[s]) && (s === "set-cookie" ? t[s] ? t[s].push(n) : t[s] = [n] : t[s] = t[s] ? t[s] + ", " + n : n);
  }), t;
}, Ts = Symbol("internals");
function Ut(r) {
  return r && String(r).trim().toLowerCase();
}
function ar(r) {
  return r === !1 || r == null ? r : L.isArray(r) ? r.map(ar) : String(r);
}
function Ai(r) {
  const t = /* @__PURE__ */ Object.create(null), s = /([^\s,;=]+)\s*(?:=\s*([^,;]+))?/g;
  let n;
  for (; n = s.exec(r); )
    t[n[1]] = n[2];
  return t;
}
const vi = (r) => /^[-_a-zA-Z0-9^`|~,!#$%&'*+.]+$/.test(r.trim());
function Nr(r, t, s, n, a) {
  if (L.isFunction(n))
    return n.call(this, t, s);
  if (a && (t = s), !!L.isString(t)) {
    if (L.isString(n))
      return t.indexOf(n) !== -1;
    if (L.isRegExp(n))
      return n.test(t);
  }
}
function Ei(r) {
  return r.trim().toLowerCase().replace(/([a-z\d])(\w*)/g, (t, s, n) => s.toUpperCase() + n);
}
function xi(r, t) {
  const s = L.toCamelCase(" " + t);
  ["get", "set", "has"].forEach((n) => {
    Object.defineProperty(r, n + s, {
      value: function(a, o, i) {
        return this[n].call(this, t, a, o, i);
      },
      configurable: !0
    });
  });
}
let qe = class {
  constructor(t) {
    t && this.set(t);
  }
  set(t, s, n) {
    const a = this;
    function o(c, l, d) {
      const u = Ut(l);
      if (!u)
        throw new Error("header name must be a non-empty string");
      const m = L.findKey(a, u);
      (!m || a[m] === void 0 || d === !0 || d === void 0 && a[m] !== !1) && (a[m || l] = ar(c));
    }
    const i = (c, l) => L.forEach(c, (d, u) => o(d, u, l));
    if (L.isPlainObject(t) || t instanceof this.constructor)
      i(t, s);
    else if (L.isString(t) && (t = t.trim()) && !vi(t))
      i(wi(t), s);
    else if (L.isObject(t) && L.isIterable(t)) {
      let c = {}, l, d;
      for (const u of t) {
        if (!L.isArray(u))
          throw TypeError("Object iterator must return a key-value pair");
        c[d = u[0]] = (l = c[d]) ? L.isArray(l) ? [...l, u[1]] : [l, u[1]] : u[1];
      }
      i(c, s);
    } else
      t != null && o(s, t, n);
    return this;
  }
  get(t, s) {
    if (t = Ut(t), t) {
      const n = L.findKey(this, t);
      if (n) {
        const a = this[n];
        if (!s)
          return a;
        if (s === !0)
          return Ai(a);
        if (L.isFunction(s))
          return s.call(this, a, n);
        if (L.isRegExp(s))
          return s.exec(a);
        throw new TypeError("parser must be boolean|regexp|function");
      }
    }
  }
  has(t, s) {
    if (t = Ut(t), t) {
      const n = L.findKey(this, t);
      return !!(n && this[n] !== void 0 && (!s || Nr(this, this[n], n, s)));
    }
    return !1;
  }
  delete(t, s) {
    const n = this;
    let a = !1;
    function o(i) {
      if (i = Ut(i), i) {
        const c = L.findKey(n, i);
        c && (!s || Nr(n, n[c], c, s)) && (delete n[c], a = !0);
      }
    }
    return L.isArray(t) ? t.forEach(o) : o(t), a;
  }
  clear(t) {
    const s = Object.keys(this);
    let n = s.length, a = !1;
    for (; n--; ) {
      const o = s[n];
      (!t || Nr(this, this[o], o, t, !0)) && (delete this[o], a = !0);
    }
    return a;
  }
  normalize(t) {
    const s = this, n = {};
    return L.forEach(this, (a, o) => {
      const i = L.findKey(n, o);
      if (i) {
        s[i] = ar(a), delete s[o];
        return;
      }
      const c = t ? Ei(o) : String(o).trim();
      c !== o && delete s[o], s[c] = ar(a), n[c] = !0;
    }), this;
  }
  concat(...t) {
    return this.constructor.concat(this, ...t);
  }
  toJSON(t) {
    const s = /* @__PURE__ */ Object.create(null);
    return L.forEach(this, (n, a) => {
      n != null && n !== !1 && (s[a] = t && L.isArray(n) ? n.join(", ") : n);
    }), s;
  }
  [Symbol.iterator]() {
    return Object.entries(this.toJSON())[Symbol.iterator]();
  }
  toString() {
    return Object.entries(this.toJSON()).map(([t, s]) => t + ": " + s).join(`
`);
  }
  getSetCookie() {
    return this.get("set-cookie") || [];
  }
  get [Symbol.toStringTag]() {
    return "AxiosHeaders";
  }
  static from(t) {
    return t instanceof this ? t : new this(t);
  }
  static concat(t, ...s) {
    const n = new this(t);
    return s.forEach((a) => n.set(a)), n;
  }
  static accessor(t) {
    const n = (this[Ts] = this[Ts] = {
      accessors: {}
    }).accessors, a = this.prototype;
    function o(i) {
      const c = Ut(i);
      n[c] || (xi(a, i), n[c] = !0);
    }
    return L.isArray(t) ? t.forEach(o) : o(t), this;
  }
};
qe.accessor(["Content-Type", "Content-Length", "Accept", "Accept-Encoding", "User-Agent", "Authorization"]);
L.reduceDescriptors(qe.prototype, ({ value: r }, t) => {
  let s = t[0].toUpperCase() + t.slice(1);
  return {
    get: () => r,
    set(n) {
      this[s] = n;
    }
  };
});
L.freezeMethods(qe);
function kr(r, t) {
  const s = this || Ht, n = t || s, a = qe.from(n.headers);
  let o = n.data;
  return L.forEach(r, function(c) {
    o = c.call(s, o, a.normalize(), t ? t.status : void 0);
  }), a.normalize(), o;
}
function An(r) {
  return !!(r && r.__CANCEL__);
}
function kt(r, t, s) {
  Se.call(this, r ?? "canceled", Se.ERR_CANCELED, t, s), this.name = "CanceledError";
}
L.inherits(kt, Se, {
  __CANCEL__: !0
});
function vn(r, t, s) {
  const n = s.config.validateStatus;
  !s.status || !n || n(s.status) ? r(s) : t(new Se(
    "Request failed with status code " + s.status,
    [Se.ERR_BAD_REQUEST, Se.ERR_BAD_RESPONSE][Math.floor(s.status / 100) - 4],
    s.config,
    s.request,
    s
  ));
}
function Si(r) {
  const t = /^([-+\w]{1,25})(:?\/\/|:)/.exec(r);
  return t && t[1] || "";
}
function Mi(r, t) {
  r = r || 10;
  const s = new Array(r), n = new Array(r);
  let a = 0, o = 0, i;
  return t = t !== void 0 ? t : 1e3, function(l) {
    const d = Date.now(), u = n[o];
    i || (i = d), s[a] = l, n[a] = d;
    let m = o, p = 0;
    for (; m !== a; )
      p += s[m++], m = m % r;
    if (a = (a + 1) % r, a === o && (o = (o + 1) % r), d - i < t)
      return;
    const y = u && d - u;
    return y ? Math.round(p * 1e3 / y) : void 0;
  };
}
function Pi(r, t) {
  let s = 0, n = 1e3 / t, a, o;
  const i = (d, u = Date.now()) => {
    s = u, a = null, o && (clearTimeout(o), o = null), r(...d);
  };
  return [(...d) => {
    const u = Date.now(), m = u - s;
    m >= n ? i(d, u) : (a = d, o || (o = setTimeout(() => {
      o = null, i(a);
    }, n - m)));
  }, () => a && i(a)];
}
const cr = (r, t, s = 3) => {
  let n = 0;
  const a = Mi(50, 250);
  return Pi((o) => {
    const i = o.loaded, c = o.lengthComputable ? o.total : void 0, l = i - n, d = a(l), u = i <= c;
    n = i;
    const m = {
      loaded: i,
      total: c,
      progress: c ? i / c : void 0,
      bytes: l,
      rate: d || void 0,
      estimated: d && c && u ? (c - i) / d : void 0,
      event: o,
      lengthComputable: c != null,
      [t ? "download" : "upload"]: !0
    };
    r(m);
  }, s);
}, Ns = (r, t) => {
  const s = r != null;
  return [(n) => t[0]({
    lengthComputable: s,
    total: r,
    loaded: n
  }), t[1]];
}, ks = (r) => (...t) => L.asap(() => r(...t)), Ii = Ye.hasStandardBrowserEnv ? /* @__PURE__ */ ((r, t) => (s) => (s = new URL(s, Ye.origin), r.protocol === s.protocol && r.host === s.host && (t || r.port === s.port)))(
  new URL(Ye.origin),
  Ye.navigator && /(msie|trident)/i.test(Ye.navigator.userAgent)
) : () => !0, ji = Ye.hasStandardBrowserEnv ? (
  // Standard browser envs support document.cookie
  {
    write(r, t, s, n, a, o) {
      const i = [r + "=" + encodeURIComponent(t)];
      L.isNumber(s) && i.push("expires=" + new Date(s).toGMTString()), L.isString(n) && i.push("path=" + n), L.isString(a) && i.push("domain=" + a), o === !0 && i.push("secure"), document.cookie = i.join("; ");
    },
    read(r) {
      const t = document.cookie.match(new RegExp("(^|;\\s*)(" + r + ")=([^;]*)"));
      return t ? decodeURIComponent(t[3]) : null;
    },
    remove(r) {
      this.write(r, "", Date.now() - 864e5);
    }
  }
) : (
  // Non-standard browser env (web workers, react-native) lack needed support.
  {
    write() {
    },
    read() {
      return null;
    },
    remove() {
    }
  }
);
function Ti(r) {
  return /^([a-z][a-z\d+\-.]*:)?\/\//i.test(r);
}
function Ni(r, t) {
  return t ? r.replace(/\/?\/$/, "") + "/" + t.replace(/^\/+/, "") : r;
}
function En(r, t, s) {
  let n = !Ti(t);
  return r && (n || s == !1) ? Ni(r, t) : t;
}
const Rs = (r) => r instanceof qe ? { ...r } : r;
function St(r, t) {
  t = t || {};
  const s = {};
  function n(d, u, m, p) {
    return L.isPlainObject(d) && L.isPlainObject(u) ? L.merge.call({ caseless: p }, d, u) : L.isPlainObject(u) ? L.merge({}, u) : L.isArray(u) ? u.slice() : u;
  }
  function a(d, u, m, p) {
    if (L.isUndefined(u)) {
      if (!L.isUndefined(d))
        return n(void 0, d, m, p);
    } else return n(d, u, m, p);
  }
  function o(d, u) {
    if (!L.isUndefined(u))
      return n(void 0, u);
  }
  function i(d, u) {
    if (L.isUndefined(u)) {
      if (!L.isUndefined(d))
        return n(void 0, d);
    } else return n(void 0, u);
  }
  function c(d, u, m) {
    if (m in t)
      return n(d, u);
    if (m in r)
      return n(void 0, d);
  }
  const l = {
    url: o,
    method: o,
    data: o,
    baseURL: i,
    transformRequest: i,
    transformResponse: i,
    paramsSerializer: i,
    timeout: i,
    timeoutMessage: i,
    withCredentials: i,
    withXSRFToken: i,
    adapter: i,
    responseType: i,
    xsrfCookieName: i,
    xsrfHeaderName: i,
    onUploadProgress: i,
    onDownloadProgress: i,
    decompress: i,
    maxContentLength: i,
    maxBodyLength: i,
    beforeRedirect: i,
    transport: i,
    httpAgent: i,
    httpsAgent: i,
    cancelToken: i,
    socketPath: i,
    responseEncoding: i,
    validateStatus: c,
    headers: (d, u, m) => a(Rs(d), Rs(u), m, !0)
  };
  return L.forEach(Object.keys({ ...r, ...t }), function(u) {
    const m = l[u] || a, p = m(r[u], t[u], u);
    L.isUndefined(p) && m !== c || (s[u] = p);
  }), s;
}
const xn = (r) => {
  const t = St({}, r);
  let { data: s, withXSRFToken: n, xsrfHeaderName: a, xsrfCookieName: o, headers: i, auth: c } = t;
  t.headers = i = qe.from(i), t.url = fn(En(t.baseURL, t.url, t.allowAbsoluteUrls), r.params, r.paramsSerializer), c && i.set(
    "Authorization",
    "Basic " + btoa((c.username || "") + ":" + (c.password ? unescape(encodeURIComponent(c.password)) : ""))
  );
  let l;
  if (L.isFormData(s)) {
    if (Ye.hasStandardBrowserEnv || Ye.hasStandardBrowserWebWorkerEnv)
      i.setContentType(void 0);
    else if ((l = i.getContentType()) !== !1) {
      const [d, ...u] = l ? l.split(";").map((m) => m.trim()).filter(Boolean) : [];
      i.setContentType([d || "multipart/form-data", ...u].join("; "));
    }
  }
  if (Ye.hasStandardBrowserEnv && (n && L.isFunction(n) && (n = n(t)), n || n !== !1 && Ii(t.url))) {
    const d = a && o && ji.read(o);
    d && i.set(a, d);
  }
  return t;
}, ki = typeof XMLHttpRequest < "u", Ri = ki && function(r) {
  return new Promise(function(s, n) {
    const a = xn(r);
    let o = a.data;
    const i = qe.from(a.headers).normalize();
    let { responseType: c, onUploadProgress: l, onDownloadProgress: d } = a, u, m, p, y, g;
    function w() {
      y && y(), g && g(), a.cancelToken && a.cancelToken.unsubscribe(u), a.signal && a.signal.removeEventListener("abort", u);
    }
    let h = new XMLHttpRequest();
    h.open(a.method.toUpperCase(), a.url, !0), h.timeout = a.timeout;
    function M() {
      if (!h)
        return;
      const T = qe.from(
        "getAllResponseHeaders" in h && h.getAllResponseHeaders()
      ), D = {
        data: !c || c === "text" || c === "json" ? h.responseText : h.response,
        status: h.status,
        statusText: h.statusText,
        headers: T,
        config: r,
        request: h
      };
      vn(function(q) {
        s(q), w();
      }, function(q) {
        n(q), w();
      }, D), h = null;
    }
    "onloadend" in h ? h.onloadend = M : h.onreadystatechange = function() {
      !h || h.readyState !== 4 || h.status === 0 && !(h.responseURL && h.responseURL.indexOf("file:") === 0) || setTimeout(M);
    }, h.onabort = function() {
      h && (n(new Se("Request aborted", Se.ECONNABORTED, r, h)), h = null);
    }, h.onerror = function() {
      n(new Se("Network Error", Se.ERR_NETWORK, r, h)), h = null;
    }, h.ontimeout = function() {
      let R = a.timeout ? "timeout of " + a.timeout + "ms exceeded" : "timeout exceeded";
      const D = a.transitional || bn;
      a.timeoutErrorMessage && (R = a.timeoutErrorMessage), n(new Se(
        R,
        D.clarifyTimeoutError ? Se.ETIMEDOUT : Se.ECONNABORTED,
        r,
        h
      )), h = null;
    }, o === void 0 && i.setContentType(null), "setRequestHeader" in h && L.forEach(i.toJSON(), function(R, D) {
      h.setRequestHeader(D, R);
    }), L.isUndefined(a.withCredentials) || (h.withCredentials = !!a.withCredentials), c && c !== "json" && (h.responseType = a.responseType), d && ([p, g] = cr(d, !0), h.addEventListener("progress", p)), l && h.upload && ([m, y] = cr(l), h.upload.addEventListener("progress", m), h.upload.addEventListener("loadend", y)), (a.cancelToken || a.signal) && (u = (T) => {
      h && (n(!T || T.type ? new kt(null, r, h) : T), h.abort(), h = null);
    }, a.cancelToken && a.cancelToken.subscribe(u), a.signal && (a.signal.aborted ? u() : a.signal.addEventListener("abort", u)));
    const x = Si(a.url);
    if (x && Ye.protocols.indexOf(x) === -1) {
      n(new Se("Unsupported protocol " + x + ":", Se.ERR_BAD_REQUEST, r));
      return;
    }
    h.send(o || null);
  });
}, Ci = (r, t) => {
  const { length: s } = r = r ? r.filter(Boolean) : [];
  if (t || s) {
    let n = new AbortController(), a;
    const o = function(d) {
      if (!a) {
        a = !0, c();
        const u = d instanceof Error ? d : this.reason;
        n.abort(u instanceof Se ? u : new kt(u instanceof Error ? u.message : u));
      }
    };
    let i = t && setTimeout(() => {
      i = null, o(new Se(`timeout ${t} of ms exceeded`, Se.ETIMEDOUT));
    }, t);
    const c = () => {
      r && (i && clearTimeout(i), i = null, r.forEach((d) => {
        d.unsubscribe ? d.unsubscribe(o) : d.removeEventListener("abort", o);
      }), r = null);
    };
    r.forEach((d) => d.addEventListener("abort", o));
    const { signal: l } = n;
    return l.unsubscribe = () => L.asap(c), l;
  }
}, _i = function* (r, t) {
  let s = r.byteLength;
  if (s < t) {
    yield r;
    return;
  }
  let n = 0, a;
  for (; n < s; )
    a = n + t, yield r.slice(n, a), n = a;
}, Ki = async function* (r, t) {
  for await (const s of Oi(r))
    yield* _i(s, t);
}, Oi = async function* (r) {
  if (r[Symbol.asyncIterator]) {
    yield* r;
    return;
  }
  const t = r.getReader();
  try {
    for (; ; ) {
      const { done: s, value: n } = await t.read();
      if (s)
        break;
      yield n;
    }
  } finally {
    await t.cancel();
  }
}, Cs = (r, t, s, n) => {
  const a = Ki(r, t);
  let o = 0, i, c = (l) => {
    i || (i = !0, n && n(l));
  };
  return new ReadableStream({
    async pull(l) {
      try {
        const { done: d, value: u } = await a.next();
        if (d) {
          c(), l.close();
          return;
        }
        let m = u.byteLength;
        if (s) {
          let p = o += m;
          s(p);
        }
        l.enqueue(new Uint8Array(u));
      } catch (d) {
        throw c(d), d;
      }
    },
    cancel(l) {
      return c(l), a.return();
    }
  }, {
    highWaterMark: 2
  });
}, fr = typeof fetch == "function" && typeof Request == "function" && typeof Response == "function", Sn = fr && typeof ReadableStream == "function", Li = fr && (typeof TextEncoder == "function" ? /* @__PURE__ */ ((r) => (t) => r.encode(t))(new TextEncoder()) : async (r) => new Uint8Array(await new Response(r).arrayBuffer())), Mn = (r, ...t) => {
  try {
    return !!r(...t);
  } catch {
    return !1;
  }
}, Di = Sn && Mn(() => {
  let r = !1;
  const t = new Request(Ye.origin, {
    body: new ReadableStream(),
    method: "POST",
    get duplex() {
      return r = !0, "half";
    }
  }).headers.has("Content-Type");
  return r && !t;
}), _s = 64 * 1024, Fr = Sn && Mn(() => L.isReadableStream(new Response("").body)), lr = {
  stream: Fr && ((r) => r.body)
};
fr && ((r) => {
  ["text", "arrayBuffer", "blob", "formData", "stream"].forEach((t) => {
    !lr[t] && (lr[t] = L.isFunction(r[t]) ? (s) => s[t]() : (s, n) => {
      throw new Se(`Response type '${t}' is not supported`, Se.ERR_NOT_SUPPORT, n);
    });
  });
})(new Response());
const Ui = async (r) => {
  if (r == null)
    return 0;
  if (L.isBlob(r))
    return r.size;
  if (L.isSpecCompliantForm(r))
    return (await new Request(Ye.origin, {
      method: "POST",
      body: r
    }).arrayBuffer()).byteLength;
  if (L.isArrayBufferView(r) || L.isArrayBuffer(r))
    return r.byteLength;
  if (L.isURLSearchParams(r) && (r = r + ""), L.isString(r))
    return (await Li(r)).byteLength;
}, Fi = async (r, t) => {
  const s = L.toFiniteNumber(r.getContentLength());
  return s ?? Ui(t);
}, Bi = fr && (async (r) => {
  let {
    url: t,
    method: s,
    data: n,
    signal: a,
    cancelToken: o,
    timeout: i,
    onDownloadProgress: c,
    onUploadProgress: l,
    responseType: d,
    headers: u,
    withCredentials: m = "same-origin",
    fetchOptions: p
  } = xn(r);
  d = d ? (d + "").toLowerCase() : "text";
  let y = Ci([a, o && o.toAbortSignal()], i), g;
  const w = y && y.unsubscribe && (() => {
    y.unsubscribe();
  });
  let h;
  try {
    if (l && Di && s !== "get" && s !== "head" && (h = await Fi(u, n)) !== 0) {
      let D = new Request(t, {
        method: "POST",
        body: n,
        duplex: "half"
      }), U;
      if (L.isFormData(n) && (U = D.headers.get("content-type")) && u.setContentType(U), D.body) {
        const [q, N] = Ns(
          h,
          cr(ks(l))
        );
        n = Cs(D.body, _s, q, N);
      }
    }
    L.isString(m) || (m = m ? "include" : "omit");
    const M = "credentials" in Request.prototype;
    g = new Request(t, {
      ...p,
      signal: y,
      method: s.toUpperCase(),
      headers: u.normalize().toJSON(),
      body: n,
      duplex: "half",
      credentials: M ? m : void 0
    });
    let x = await fetch(g, p);
    const T = Fr && (d === "stream" || d === "response");
    if (Fr && (c || T && w)) {
      const D = {};
      ["status", "statusText", "headers"].forEach((P) => {
        D[P] = x[P];
      });
      const U = L.toFiniteNumber(x.headers.get("content-length")), [q, N] = c && Ns(
        U,
        cr(ks(c), !0)
      ) || [];
      x = new Response(
        Cs(x.body, _s, q, () => {
          N && N(), w && w();
        }),
        D
      );
    }
    d = d || "text";
    let R = await lr[L.findKey(lr, d) || "text"](x, r);
    return !T && w && w(), await new Promise((D, U) => {
      vn(D, U, {
        data: R,
        headers: qe.from(x.headers),
        status: x.status,
        statusText: x.statusText,
        config: r,
        request: g
      });
    });
  } catch (M) {
    throw w && w(), M && M.name === "TypeError" && /Load failed|fetch/i.test(M.message) ? Object.assign(
      new Se("Network Error", Se.ERR_NETWORK, r, g),
      {
        cause: M.cause || M
      }
    ) : Se.from(M, M && M.code, r, g);
  }
}), Br = {
  http: ri,
  xhr: Ri,
  fetch: Bi
};
L.forEach(Br, (r, t) => {
  if (r) {
    try {
      Object.defineProperty(r, "name", { value: t });
    } catch {
    }
    Object.defineProperty(r, "adapterName", { value: t });
  }
});
const Ks = (r) => `- ${r}`, Gi = (r) => L.isFunction(r) || r === null || r === !1, Pn = {
  getAdapter: (r) => {
    r = L.isArray(r) ? r : [r];
    const { length: t } = r;
    let s, n;
    const a = {};
    for (let o = 0; o < t; o++) {
      s = r[o];
      let i;
      if (n = s, !Gi(s) && (n = Br[(i = String(s)).toLowerCase()], n === void 0))
        throw new Se(`Unknown adapter '${i}'`);
      if (n)
        break;
      a[i || "#" + o] = n;
    }
    if (!n) {
      const o = Object.entries(a).map(
        ([c, l]) => `adapter ${c} ` + (l === !1 ? "is not supported by the environment" : "is not available in the build")
      );
      let i = t ? o.length > 1 ? `since :
` + o.map(Ks).join(`
`) : " " + Ks(o[0]) : "as no adapter specified";
      throw new Se(
        "There is no suitable adapter to dispatch the request " + i,
        "ERR_NOT_SUPPORT"
      );
    }
    return n;
  },
  adapters: Br
};
function Rr(r) {
  if (r.cancelToken && r.cancelToken.throwIfRequested(), r.signal && r.signal.aborted)
    throw new kt(null, r);
}
function Os(r) {
  return Rr(r), r.headers = qe.from(r.headers), r.data = kr.call(
    r,
    r.transformRequest
  ), ["post", "put", "patch"].indexOf(r.method) !== -1 && r.headers.setContentType("application/x-www-form-urlencoded", !1), Pn.getAdapter(r.adapter || Ht.adapter)(r).then(function(n) {
    return Rr(r), n.data = kr.call(
      r,
      r.transformResponse,
      n
    ), n.headers = qe.from(n.headers), n;
  }, function(n) {
    return An(n) || (Rr(r), n && n.response && (n.response.data = kr.call(
      r,
      r.transformResponse,
      n.response
    ), n.response.headers = qe.from(n.response.headers))), Promise.reject(n);
  });
}
const In = "1.11.0", br = {};
["object", "boolean", "number", "function", "string", "symbol"].forEach((r, t) => {
  br[r] = function(n) {
    return typeof n === r || "a" + (t < 1 ? "n " : " ") + r;
  };
});
const Ls = {};
br.transitional = function(t, s, n) {
  function a(o, i) {
    return "[Axios v" + In + "] Transitional option '" + o + "'" + i + (n ? ". " + n : "");
  }
  return (o, i, c) => {
    if (t === !1)
      throw new Se(
        a(i, " has been removed" + (s ? " in " + s : "")),
        Se.ERR_DEPRECATED
      );
    return s && !Ls[i] && (Ls[i] = !0, console.warn(
      a(
        i,
        " has been deprecated since v" + s + " and will be removed in the near future"
      )
    )), t ? t(o, i, c) : !0;
  };
};
br.spelling = function(t) {
  return (s, n) => (console.warn(`${n} is likely a misspelling of ${t}`), !0);
};
function Yi(r, t, s) {
  if (typeof r != "object")
    throw new Se("options must be an object", Se.ERR_BAD_OPTION_VALUE);
  const n = Object.keys(r);
  let a = n.length;
  for (; a-- > 0; ) {
    const o = n[a], i = t[o];
    if (i) {
      const c = r[o], l = c === void 0 || i(c, o, r);
      if (l !== !0)
        throw new Se("option " + o + " must be " + l, Se.ERR_BAD_OPTION_VALUE);
      continue;
    }
    if (s !== !0)
      throw new Se("Unknown option " + o, Se.ERR_BAD_OPTION);
  }
}
const or = {
  assertOptions: Yi,
  validators: br
}, it = or.validators;
let Et = class {
  constructor(t) {
    this.defaults = t || {}, this.interceptors = {
      request: new js(),
      response: new js()
    };
  }
  /**
   * Dispatch a request
   *
   * @param {String|Object} configOrUrl The config specific for this request (merged with this.defaults)
   * @param {?Object} config
   *
   * @returns {Promise} The Promise to be fulfilled
   */
  async request(t, s) {
    try {
      return await this._request(t, s);
    } catch (n) {
      if (n instanceof Error) {
        let a = {};
        Error.captureStackTrace ? Error.captureStackTrace(a) : a = new Error();
        const o = a.stack ? a.stack.replace(/^.+\n/, "") : "";
        try {
          n.stack ? o && !String(n.stack).endsWith(o.replace(/^.+\n.+\n/, "")) && (n.stack += `
` + o) : n.stack = o;
        } catch {
        }
      }
      throw n;
    }
  }
  _request(t, s) {
    typeof t == "string" ? (s = s || {}, s.url = t) : s = t || {}, s = St(this.defaults, s);
    const { transitional: n, paramsSerializer: a, headers: o } = s;
    n !== void 0 && or.assertOptions(n, {
      silentJSONParsing: it.transitional(it.boolean),
      forcedJSONParsing: it.transitional(it.boolean),
      clarifyTimeoutError: it.transitional(it.boolean)
    }, !1), a != null && (L.isFunction(a) ? s.paramsSerializer = {
      serialize: a
    } : or.assertOptions(a, {
      encode: it.function,
      serialize: it.function
    }, !0)), s.allowAbsoluteUrls !== void 0 || (this.defaults.allowAbsoluteUrls !== void 0 ? s.allowAbsoluteUrls = this.defaults.allowAbsoluteUrls : s.allowAbsoluteUrls = !0), or.assertOptions(s, {
      baseUrl: it.spelling("baseURL"),
      withXsrfToken: it.spelling("withXSRFToken")
    }, !0), s.method = (s.method || this.defaults.method || "get").toLowerCase();
    let i = o && L.merge(
      o.common,
      o[s.method]
    );
    o && L.forEach(
      ["delete", "get", "head", "post", "put", "patch", "common"],
      (g) => {
        delete o[g];
      }
    ), s.headers = qe.concat(i, o);
    const c = [];
    let l = !0;
    this.interceptors.request.forEach(function(w) {
      typeof w.runWhen == "function" && w.runWhen(s) === !1 || (l = l && w.synchronous, c.unshift(w.fulfilled, w.rejected));
    });
    const d = [];
    this.interceptors.response.forEach(function(w) {
      d.push(w.fulfilled, w.rejected);
    });
    let u, m = 0, p;
    if (!l) {
      const g = [Os.bind(this), void 0];
      for (g.unshift(...c), g.push(...d), p = g.length, u = Promise.resolve(s); m < p; )
        u = u.then(g[m++], g[m++]);
      return u;
    }
    p = c.length;
    let y = s;
    for (m = 0; m < p; ) {
      const g = c[m++], w = c[m++];
      try {
        y = g(y);
      } catch (h) {
        w.call(this, h);
        break;
      }
    }
    try {
      u = Os.call(this, y);
    } catch (g) {
      return Promise.reject(g);
    }
    for (m = 0, p = d.length; m < p; )
      u = u.then(d[m++], d[m++]);
    return u;
  }
  getUri(t) {
    t = St(this.defaults, t);
    const s = En(t.baseURL, t.url, t.allowAbsoluteUrls);
    return fn(s, t.params, t.paramsSerializer);
  }
};
L.forEach(["delete", "get", "head", "options"], function(t) {
  Et.prototype[t] = function(s, n) {
    return this.request(St(n || {}, {
      method: t,
      url: s,
      data: (n || {}).data
    }));
  };
});
L.forEach(["post", "put", "patch"], function(t) {
  function s(n) {
    return function(o, i, c) {
      return this.request(St(c || {}, {
        method: t,
        headers: n ? {
          "Content-Type": "multipart/form-data"
        } : {},
        url: o,
        data: i
      }));
    };
  }
  Et.prototype[t] = s(), Et.prototype[t + "Form"] = s(!0);
});
let Vi = class jn {
  constructor(t) {
    if (typeof t != "function")
      throw new TypeError("executor must be a function.");
    let s;
    this.promise = new Promise(function(o) {
      s = o;
    });
    const n = this;
    this.promise.then((a) => {
      if (!n._listeners) return;
      let o = n._listeners.length;
      for (; o-- > 0; )
        n._listeners[o](a);
      n._listeners = null;
    }), this.promise.then = (a) => {
      let o;
      const i = new Promise((c) => {
        n.subscribe(c), o = c;
      }).then(a);
      return i.cancel = function() {
        n.unsubscribe(o);
      }, i;
    }, t(function(o, i, c) {
      n.reason || (n.reason = new kt(o, i, c), s(n.reason));
    });
  }
  /**
   * Throws a `CanceledError` if cancellation has been requested.
   */
  throwIfRequested() {
    if (this.reason)
      throw this.reason;
  }
  /**
   * Subscribe to the cancel signal
   */
  subscribe(t) {
    if (this.reason) {
      t(this.reason);
      return;
    }
    this._listeners ? this._listeners.push(t) : this._listeners = [t];
  }
  /**
   * Unsubscribe from the cancel signal
   */
  unsubscribe(t) {
    if (!this._listeners)
      return;
    const s = this._listeners.indexOf(t);
    s !== -1 && this._listeners.splice(s, 1);
  }
  toAbortSignal() {
    const t = new AbortController(), s = (n) => {
      t.abort(n);
    };
    return this.subscribe(s), t.signal.unsubscribe = () => this.unsubscribe(s), t.signal;
  }
  /**
   * Returns an object that contains a new `CancelToken` and a function that, when called,
   * cancels the `CancelToken`.
   */
  static source() {
    let t;
    return {
      token: new jn(function(a) {
        t = a;
      }),
      cancel: t
    };
  }
};
function qi(r) {
  return function(s) {
    return r.apply(null, s);
  };
}
function Wi(r) {
  return L.isObject(r) && r.isAxiosError === !0;
}
const Gr = {
  Continue: 100,
  SwitchingProtocols: 101,
  Processing: 102,
  EarlyHints: 103,
  Ok: 200,
  Created: 201,
  Accepted: 202,
  NonAuthoritativeInformation: 203,
  NoContent: 204,
  ResetContent: 205,
  PartialContent: 206,
  MultiStatus: 207,
  AlreadyReported: 208,
  ImUsed: 226,
  MultipleChoices: 300,
  MovedPermanently: 301,
  Found: 302,
  SeeOther: 303,
  NotModified: 304,
  UseProxy: 305,
  Unused: 306,
  TemporaryRedirect: 307,
  PermanentRedirect: 308,
  BadRequest: 400,
  Unauthorized: 401,
  PaymentRequired: 402,
  Forbidden: 403,
  NotFound: 404,
  MethodNotAllowed: 405,
  NotAcceptable: 406,
  ProxyAuthenticationRequired: 407,
  RequestTimeout: 408,
  Conflict: 409,
  Gone: 410,
  LengthRequired: 411,
  PreconditionFailed: 412,
  PayloadTooLarge: 413,
  UriTooLong: 414,
  UnsupportedMediaType: 415,
  RangeNotSatisfiable: 416,
  ExpectationFailed: 417,
  ImATeapot: 418,
  MisdirectedRequest: 421,
  UnprocessableEntity: 422,
  Locked: 423,
  FailedDependency: 424,
  TooEarly: 425,
  UpgradeRequired: 426,
  PreconditionRequired: 428,
  TooManyRequests: 429,
  RequestHeaderFieldsTooLarge: 431,
  UnavailableForLegalReasons: 451,
  InternalServerError: 500,
  NotImplemented: 501,
  BadGateway: 502,
  ServiceUnavailable: 503,
  GatewayTimeout: 504,
  HttpVersionNotSupported: 505,
  VariantAlsoNegotiates: 506,
  InsufficientStorage: 507,
  LoopDetected: 508,
  NotExtended: 510,
  NetworkAuthenticationRequired: 511
};
Object.entries(Gr).forEach(([r, t]) => {
  Gr[t] = r;
});
function Tn(r) {
  const t = new Et(r), s = nn(Et.prototype.request, t);
  return L.extend(s, Et.prototype, t, { allOwnKeys: !0 }), L.extend(s, t, null, { allOwnKeys: !0 }), s.create = function(a) {
    return Tn(St(r, a));
  }, s;
}
const ee = Tn(Ht);
ee.Axios = Et;
ee.CanceledError = kt;
ee.CancelToken = Vi;
ee.isCancel = An;
ee.VERSION = In;
ee.toFormData = gr;
ee.AxiosError = Se;
ee.Cancel = ee.CanceledError;
ee.all = function(t) {
  return Promise.all(t);
};
ee.spread = qi;
ee.isAxiosError = Wi;
ee.mergeConfig = St;
ee.AxiosHeaders = qe;
ee.formToJSON = (r) => wn(L.isHTMLForm(r) ? new FormData(r) : r);
ee.getAdapter = Pn.getAdapter;
ee.HttpStatusCode = Gr;
ee.default = ee;
const {
  Axios: ql,
  AxiosError: Wl,
  CanceledError: Hl,
  isCancel: $l,
  CancelToken: zl,
  VERSION: Ql,
  all: Jl,
  Cancel: Xl,
  isAxiosError: Zl,
  spread: ed,
  toFormData: td,
  AxiosHeaders: rd,
  HttpStatusCode: sd,
  formToJSON: nd,
  getAdapter: ad,
  mergeConfig: od
} = ee, Yr = "bayun-org-settings-updated";
function Nn() {
  window.dispatchEvent(new Event(Yr));
}
let Zt = !1, Vr = [];
const Ds = (r, t = null) => {
  Vr.forEach((s) => {
    r ? s.reject(r) : s.resolve(t);
  }), Vr = [];
};
function Hi(r) {
  r.interceptors.request.use(
    async (t) => {
      t.withCredentials = !0;
      const s = O("bayunSessionId");
      if (s) {
        const n = ue();
        if (n)
          try {
            const a = await n.getFromStorage(
              s,
              v.APP_ID
            );
            a && (t.headers = t.headers || {}, t.headers.application_id = a);
          } catch (a) {
            console.warn("Failed to get application_id from storage:", a);
          }
      }
      return t;
    },
    (t) => Promise.reject(t)
  ), r.interceptors.response.use(
    (t) => {
      var o, i;
      const s = ((o = t == null ? void 0 : t.config) == null ? void 0 : o.url) ?? "", n = (i = t == null ? void 0 : t.headers) == null ? void 0 : i["x-settings-update"], a = O("bayunSessionId");
      if (a && (n === !0 || n === "true") && !s.includes("/refreshOrgSettings")) {
        const c = ue(), l = O("baseURL");
        c != null && c.checkAndRefreshOrgSettings && l && c.checkAndRefreshOrgSettings(
          a,
          r,
          l + "lms/refreshOrgSettings"
        ).then(() => {
          Nn();
        });
      }
      return t;
    },
    async (t) => {
      var o, i;
      const s = t.config, n = (o = t == null ? void 0 : t.response) == null ? void 0 : o.data, a = (n == null ? void 0 : n.errorType) === "ACCESS_DENIED" && (n == null ? void 0 : n.errorMessage) === "Token not found";
      if (((i = t == null ? void 0 : t.response) == null ? void 0 : i.status) === 401 && a && !(s != null && s._retry) && !s.url.includes("/auth/refreshToken")) {
        if (Zt)
          return new Promise((c, l) => {
            Vr.push({ resolve: c, reject: l });
          }).then(() => (s._retry = !1, r(s))).catch((c) => Promise.reject(c));
        s._retry = !0, Zt = !0;
        try {
          const l = new URL(s.url).origin;
          return await r.post(`${l}/lms/auth/refreshToken`), Ds(null, !0), Zt = !1, s._retry = !1, r(s);
        } catch (c) {
          return console.error("❌ Token refresh failed:", c), Ds(c, null), Zt = !1, Promise.reject(c);
        }
      }
      return Promise.reject(t);
    }
  );
}
Hi(ee);
class kn {
  /**
   * Fetch notification list with pending approval counts
   */
  static async getNotificationList() {
    try {
      return (await ee.get(
        O("baseURL") + "lms/admin/notificationList"
      )).data;
    } catch (t) {
      throw t;
    }
  }
  /**
   * Fetch approval history list
   */
  static async getApprovalHistoryList() {
    try {
      return (await ee.get(
        O("baseURL") + "lms/admin/approvalHistoryList"
      )).data;
    } catch (t) {
      throw t;
    }
  }
}
const Rn = "snackbar_last_shown_timestamp", $i = 10 * 60 * 1e3;
function zi() {
  try {
    const r = localStorage.getItem(Rn);
    if (!r)
      return !0;
    const t = parseInt(r, 10);
    return Date.now() - t >= $i;
  } catch (r) {
    return console.warn("Error checking snackbar cooldown:", r), !0;
  }
}
function Qi() {
  try {
    localStorage.setItem(Rn, Date.now().toString());
  } catch (r) {
    console.warn("Error recording snackbar shown timestamp:", r);
  }
}
async function Ji() {
  try {
    const r = await kn.getNotificationList(), t = parseInt(
      r.pendingMemberApprovalCount || "0",
      10
    ), s = parseInt(
      r.orgApplicationApprovalCount || "0",
      10
    );
    if (!(t > 0 || s > 0))
      return null;
    if (zi()) {
      Qi();
      let a = "";
      return t > 0 && s > 0 ? a = `You have ${t} pending member${t > 1 ? "s" : ""} and ${s} pending application${s > 1 ? "s" : ""}. Go to Members or Applications for more details` : t > 0 ? a = `You have ${t} pending member approval${t > 1 ? "s" : ""}. Go to Members for more details` : s > 0 && (a = `You have ${s} pending application approval${s > 1 ? "s" : ""}. Go to Applications for more details`), {
        hasPendingApprovals: !0,
        pendingMemberCount: t,
        pendingApplicationCount: s,
        message: a
      };
    }
    return null;
  } catch (r) {
    return console.error("Error fetching notification list:", r), null;
  }
}
function wr(r = !0) {
  const [t, s] = b(!1), [n, a] = b(""), [o, i] = b(null);
  return ve(() => {
    r ? (async () => {
      const l = O("bayunSessionId"), d = ue(), u = await (d == null ? void 0 : d.getFromStorage(
        l,
        v.MEMBER_STATUS
      )), m = mt(u);
      i(m);
    })() : i({ memberStatus: "allowed" });
  }, [r]), ve(() => {
    (async () => {
      var d;
      if (!o) return;
      if (r) {
        const u = (d = o.memberStatus) == null ? void 0 : d.toLowerCase();
        if (!(u === "admin" || u === "securityadmin"))
          return;
      }
      const l = await Ji();
      l != null && l.hasPendingApprovals && (a(l.message), s(!0));
    })();
  }, [o, r]), {
    snackbarOpen: t,
    snackbarMessage: n,
    setSnackbarOpen: s
  };
}
function ze({
  open: r,
  message: t,
  onClose: s,
  duration: n = 6e3,
  type: a = "info"
}) {
  if (ve(() => {
    if (r) {
      const i = setTimeout(() => {
        s();
      }, n);
      return () => clearTimeout(i);
    }
  }, [r, n, s]), !r) return null;
  const o = () => {
    switch (a) {
      case "error":
        return "✕";
      case "success":
        return "✓";
      case "info":
      default:
        return "ℹ";
    }
  };
  return /* @__PURE__ */ e.jsx("div", { className: `snackbar snackbar-${a}`, role: "alert", children: /* @__PURE__ */ e.jsxs("div", { className: `snackbar-content snackbar-content-${a}`, children: [
    /* @__PURE__ */ e.jsx("span", { className: `snackbar-icon snackbar-icon-${a}`, children: o() }),
    /* @__PURE__ */ e.jsx("span", { className: "snackbar-message", children: t }),
    /* @__PURE__ */ e.jsx("button", { className: "snackbar-close", onClick: s, "aria-label": "Close", children: "×" })
  ] }) });
}
function De(r) {
  const t = "Loading...", s = (a) => /* @__PURE__ */ e.jsxs("div", { className: "loader", children: [
    /* @__PURE__ */ e.jsx("div", { className: "spinner" }),
    /* @__PURE__ */ e.jsx("p", { children: a ?? t })
  ] });
  return {
    getLoader: s,
    renderLoader: (a, o) => a ? s(o) : null
  };
}
const qr = [
  {
    key: Fe.MembersList,
    label: "Members",
    icon: /* @__PURE__ */ e.jsx(so, {}),
    component: nt(() => Promise.resolve().then(() => _c))
  },
  {
    key: Fe.Notifications,
    label: "Notifications",
    icon: /* @__PURE__ */ e.jsx(mo, {}),
    component: nt(() => Promise.resolve().then(() => Oc))
  },
  {
    key: Fe.Transactions,
    label: "Transactions",
    icon: /* @__PURE__ */ e.jsx(no, {}),
    component: nt(() => Promise.resolve().then(() => rl))
  },
  {
    key: Fe.Applications,
    label: "Applications",
    icon: /* @__PURE__ */ e.jsx(ro, {}),
    component: nt(() => Promise.resolve().then(() => ol))
  },
  {
    key: Fe.Groups,
    label: "Groups",
    icon: /* @__PURE__ */ e.jsx(ao, {}),
    component: nt(() => Promise.resolve().then(() => yl))
  },
  {
    key: Fe.Analytics,
    label: "Analytics",
    icon: /* @__PURE__ */ e.jsx(oo, {}),
    component: nt(() => Promise.resolve().then(() => El))
  },
  {
    key: Fe.LockboxRequests,
    label: "Lockbox Requests",
    icon: /* @__PURE__ */ e.jsx(io, {}),
    component: nt(() => Promise.resolve().then(() => Sl))
  },
  {
    key: Fe.TransferLockbox,
    label: "Transfer Lockbox",
    icon: /* @__PURE__ */ e.jsx(co, {}),
    component: nt(() => Promise.resolve().then(() => Il))
  },
  {
    key: Fe.RecoverUser,
    label: "User Account Recovery",
    icon: /* @__PURE__ */ e.jsx(lo, {}),
    component: nt(() => Promise.resolve().then(() => Nl))
  },
  {
    key: Fe.OrgSettings,
    label: "Org Settings",
    icon: /* @__PURE__ */ e.jsx(po, {}),
    component: nt(() => Promise.resolve().then(() => Rl))
  },
  {
    key: Fe.SecuritySettings,
    label: "Security Settings",
    icon: /* @__PURE__ */ e.jsx(uo, {}),
    component: nt(() => Promise.resolve().then(() => Fl))
  }
];
function Xi({
  useBayunNavigation: r = !0,
  defaultPage: t = Fe.MembersList
}) {
  const { getLoader: s } = De(), [n, a] = b(!0), [o, i] = b(t), [c, l] = b("robert@gmail.com"), [d, u] = b(null), [m, p] = b(""), [y, g] = b(null), { snackbarOpen: w, snackbarMessage: h, setSnackbarOpen: M } = wr(!0), x = It(() => d ? rn(qr, d, y) : qr, [d, y]), T = It(() => {
    var P;
    const N = (P = d == null ? void 0 : d.memberStatus) == null ? void 0 : P.toLowerCase();
    return N === "securityadmin" ? "Security Admin" : N === "admin" ? "Admin" : N === "approved" || N === "member" ? "Member" : (d == null ? void 0 : d.memberStatus) ?? "Member";
  }, [d == null ? void 0 : d.memberStatus]), R = x.find(
    (N) => N.key === o
  ), D = (R == null ? void 0 : R.component) || (() => /* @__PURE__ */ e.jsx("div", { children: "No pages available" })), U = () => {
    a(!n);
  };
  ve(() => {
    const N = async () => {
      const P = O("bayunSessionId"), Y = ue(), re = await (Y == null ? void 0 : Y.getFromStorage(
        P,
        v.ORG_MEMBER_ID
      )), J = await (Y == null ? void 0 : Y.getFromStorage(
        P,
        v.MEMBER_STATUS
      )), le = await (Y == null ? void 0 : Y.getFromStorage(
        P,
        v.IS_TWO_FA_ENABLED
      )), Q = await (Y == null ? void 0 : Y.getFromStorage(
        P,
        v.ORG_NAME
      )), de = await (Y == null ? void 0 : Y.getFromStorage(
        P,
        v.USER_ID
      )), te = await (Y == null ? void 0 : Y.getFromStorage(
        P,
        v.KEY_VALIDATION_POLICY
      )), K = mt(J), X = sn({
        ...K,
        isTwoFaEnabled: le,
        keyValidationPolicy: te
      });
      u(X), l(re), p(Q), g(de);
    };
    return N(), window.addEventListener(Yr, N), () => {
      window.removeEventListener(Yr, N);
    };
  }, []), ve(() => {
    var P;
    if (!x.length)
      return;
    if (!x.some(
      (Y) => Y.key === o
    )) {
      const Y = ((P = x.find((re) => re.key === t)) == null ? void 0 : P.key) || x[0].key;
      Y !== o && i(Y);
    }
  }, [x, o, t]);
  const q = () => r ? /* @__PURE__ */ e.jsxs("div", { className: `side-drawer ${n ? "open" : ""}`, children: [
    /* @__PURE__ */ e.jsxs("div", { className: "sidebar-content", children: [
      /* @__PURE__ */ e.jsxs("div", { className: "org-header", children: [
        /* @__PURE__ */ e.jsx("div", { className: "org-logo", children: /* @__PURE__ */ e.jsx("span", { children: "XC" }) }),
        /* @__PURE__ */ e.jsxs("div", { className: "org-info", children: [
          /* @__PURE__ */ e.jsx("h3", { children: m }),
          /* @__PURE__ */ e.jsx("span", { className: "org-subtitle", children: "Admin Portal" })
        ] })
      ] }),
      /* @__PURE__ */ e.jsx("nav", { className: "sidebar-nav", children: /* @__PURE__ */ e.jsx("ul", { className: "nav-list", children: x.map((N) => /* @__PURE__ */ e.jsxs(
        "li",
        {
          onClick: () => i(N.key),
          className: `nav-item ${o === N.key ? "nav-item-active" : ""}`,
          children: [
            /* @__PURE__ */ e.jsx("span", { className: "nav-icon", children: N.icon }),
            /* @__PURE__ */ e.jsx("span", { className: "nav-label", children: N.label })
          ]
        },
        N.key
      )) }) })
    ] }),
    /* @__PURE__ */ e.jsxs("div", { className: "user-footer", children: [
      /* @__PURE__ */ e.jsx("div", { className: "user-avatar", children: /* @__PURE__ */ e.jsx("span", { className: "user-initial", children: ((c == null ? void 0 : c[0]) || "").toUpperCase() }) }),
      /* @__PURE__ */ e.jsxs("div", { className: "user-info", children: [
        /* @__PURE__ */ e.jsx("div", { className: "user-name", children: c }),
        /* @__PURE__ */ e.jsx("div", { className: "user-role", children: T })
      ] })
    ] })
  ] }) : null;
  return /* @__PURE__ */ e.jsxs("div", { className: `layout ${n && r ? "sidebar-open" : ""}`, children: [
    r && /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
      /* @__PURE__ */ e.jsx(
        "div",
        {
          className: `sidebar-backdrop ${n ? "open" : ""}`,
          onClick: U
        }
      ),
      /* @__PURE__ */ e.jsx(
        "button",
        {
          className: "floating-button",
          onClick: U,
          title: n ? "Close Sidebar" : "Open Sidebar",
          "aria-label": n ? "Close Sidebar" : "Open Sidebar",
          children: /* @__PURE__ */ e.jsxs("span", { className: "fab-content", children: [
            /* @__PURE__ */ e.jsx("span", { className: "fab-label", children: "Bayun" }),
            /* @__PURE__ */ e.jsx("span", { className: "fab-arrow", children: n ? "→" : "←" })
          ] })
        }
      )
    ] }),
    q(),
    /* @__PURE__ */ e.jsx("div", { className: "main-content", children: /* @__PURE__ */ e.jsx(Ya, { fallback: s(), children: /* @__PURE__ */ e.jsx(en, { children: /* @__PURE__ */ e.jsx(D, {}) }) }) }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: w,
        message: h || "You have pending approvals",
        onClose: () => M(!1),
        type: "info"
      }
    )
  ] });
}
function Zi() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-arrow-bar-left",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M4 12l10 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M4 12l4 4" }),
        /* @__PURE__ */ e.jsx("path", { d: "M4 12l4 -4" }),
        /* @__PURE__ */ e.jsx("path", { d: "M20 4l0 16" })
      ]
    }
  ) });
}
const Cn = /* @__PURE__ */ new Map();
Object.entries(Fe).forEach(([r, t]) => {
  Cn.set(t, r);
});
const ec = (r) => (t) => lt.createElement(en, {
  children: lt.createElement(r, t)
}), tc = (r) => ({
  id: Cn.get(r.key) || r.key,
  key: r.key,
  label: r.label,
  icon: r.icon,
  component: ec(r.component)
}), rc = {
  id: "BayunFullApp",
  key: "BayunFullApp",
  label: "Bayun Provided Drawer",
  icon: lt.createElement(Zi),
  component: Xi
}, sc = async (r = {}) => {
  const s = {
    ...mt(
      r.memberStatus
    ),
    isTwoFaEnabled: r.isTwoFaEnabled
  }, n = (i = {}) => sn({
    memberStatus: s.memberStatus ?? (i == null ? void 0 : i.memberStatus),
    isTwoFaEnabled: s.isTwoFaEnabled ?? (i == null ? void 0 : i.isTwoFaEnabled),
    keyValidationPolicy: s.keyValidationPolicy ?? (i == null ? void 0 : i.keyValidationPolicy)
  });
  if (r.skipStorage)
    return n(s);
  const a = ue == null ? void 0 : ue();
  if (!a)
    return n(s);
  const o = r.cookie || O("bayunSessionId");
  if (!o)
    return n(s);
  try {
    const i = r.memberStatus !== void 0 ? r.memberStatus : await a.getFromStorage(
      o,
      v.MEMBER_STATUS
    ), c = r.isTwoFaEnabled !== void 0 ? r.isTwoFaEnabled : await a.getFromStorage(
      o,
      v.IS_TWO_FA_ENABLED
    ), l = await a.getFromStorage(
      o,
      v.KEY_VALIDATION_POLICY
    ), d = mt(i);
    return n({
      ...d,
      isTwoFaEnabled: c,
      keyValidationPolicy: l
    });
  } catch (i) {
    return console.warn("Failed to read Bayun role flags from storage", i), n(s);
  }
}, nc = async (r = {}) => {
  if (r.skipStorage)
    return null;
  const t = ue == null ? void 0 : ue();
  if (!t)
    return null;
  const s = r.cookie || O("bayunSessionId");
  if (!s)
    return null;
  try {
    return await t.getFromStorage(
      s,
      v.USER_ID
    );
  } catch (n) {
    return console.warn("Failed to read userId from storage", n), null;
  }
};
async function ac(r = {}) {
  const t = await sc(r), s = t.memberStatus ? t.memberStatus.toLowerCase() : void 0;
  if (s === "cancelled" || s === "registered")
    return [];
  const n = await nc(r), o = rn(qr, t, n).map(tc);
  return o.length > 0 ? [...o, rc] : o;
}
async function id(r = {}) {
  const t = await ac(r), s = {};
  return t.forEach((n) => {
    s[n.id] = n.component;
  }), s;
}
function st({
  heading: r,
  subtitle: t,
  actions: s
}) {
  return /* @__PURE__ */ e.jsx("div", { className: "page-header", children: /* @__PURE__ */ e.jsxs("div", { className: "page-header-content", children: [
    /* @__PURE__ */ e.jsxs("div", { className: "page-header-text", children: [
      /* @__PURE__ */ e.jsx("h1", { className: "page-header-title", children: r }),
      t && /* @__PURE__ */ e.jsx("p", { className: "page-header-subtitle", children: t })
    ] }),
    s && /* @__PURE__ */ e.jsx("div", { className: "page-header-actions", children: s })
  ] }) });
}
async function Ce(r, t) {
  const s = r.asRawKey(
    await r.getFromStorage(t, v.ORG_KEY)
  );
  if (!s)
    throw new Error("Org key not found or invalid");
  return s;
}
function ns(r, t) {
  return typeof t == "string" ? t : r.encodeKey(t);
}
class Be {
  /**
   * Update first component rendering status for recovery popup display.
   */
  static async updateFirstComponentRendringStatus(t) {
    try {
      await ee.post(
        O("baseURL") + "lms/updateFirstComponentRendringStatus",
        { isfirstComponentRenderd: t }
      );
    } catch (s) {
      throw s;
    }
  }
  /**
   * Fetch list of members with optional search
   */
  static async fetchMembers(t, s) {
    try {
      const n = {
        memberAppId: t.memberAppId,
        lmsTransactionKey: t.lmsTransactionKey,
        searchParameter: t.searchParameter || "",
        memberStatus: t.memberStatus ?? null
      };
      return t.cursor != null && (n.cursor = t.cursor), t.limit != null && (n.limit = t.limit), (await ee.post(
        O("baseURL") + "lms/admin/memberListPage",
        n,
        {
          signal: s
        }
      )).data;
    } catch (n) {
      throw n;
    }
  }
  /**
   * Activate one or more members (batch activation)
   */
  static async activateMembers(t) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/activateMembers",
        t
      )).data;
    } catch (s) {
      throw console.error("Error activating members:", s), s;
    }
  }
  /**
   * Fetch auto-approve members in background.
   */
  static async fetchAutoApproveMembers() {
    try {
      const t = await ee.get(
        O("baseURL") + "lms/admin/fetchAutoApproveMembers"
      );
      return console.log(t), t.data.memberResponses;
    } catch (t) {
      throw t;
    }
  }
  /**
   * Release auto-approve members lock.
   */
  static async releaseAutoApproveMembersLock() {
    try {
      await ee.post(
        O("baseURL") + "lms/admin/releaseAutoApproveMembersLock",
        {}
      );
    } catch (t) {
      throw t;
    }
  }
  /**
   * Promote an member
   */
  static async promoteMember(t, s) {
    try {
      await ee.post(
        O("baseURL") + `lms/admin/promoteMember/${t}`,
        s
      );
    } catch (n) {
      throw n;
    }
  }
  /**
   * Deactivate an member
   */
  static async deactivateMember(t) {
    try {
      await ee.post(
        O("baseURL") + `lms/admin/deactivateMember/${t}`
      );
    } catch (s) {
      throw s;
    }
  }
  /**
   * Demote an admin
   */
  static async demoteAdmin(t) {
    try {
      await ee.post(
        O("baseURL") + `lms/admin/demoteAdmin/${t}`
      );
    } catch (s) {
      throw s;
    }
  }
  /**
   * Check whether a member can be deleted and if an ongoing transaction must be declined
   */
  static async checkDeleteEligibility(t) {
    try {
      return (await ee.get(
        O("baseURL") + `lms/admin/checkDeleteEligibility/${t}`
      )).data;
    } catch (s) {
      throw console.error("Error checking delete eligibility:", s), s;
    }
  }
  /**
   * Delete an member. When an ongoing transaction exists, pass decline fields
   * built the same way as declineTransaction.
   */
  static async deleteMember(t, s) {
    try {
      await ee.post(
        O("baseURL") + `lms/admin/deleteMember/${t}`,
        s ?? {}
      );
    } catch (n) {
      throw n;
    }
  }
  /**
   * Initiate promote admin transaction (API call only)
   */
  static async initiatePromoteAdmin(t) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/initiatePromoteAdmin",
        t
      )).data;
    } catch (s) {
      throw console.error("Error initiating promote admin transaction:", s), s;
    }
  }
  /**
   * Initiate demote security admin transaction (API call only)
   */
  static async initiateDemoteSecurityAdmin(t) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/initiateDemoteSecurityAdmin",
        t
      )).data;
    } catch (s) {
      throw console.error(
        "Error initiating demote security admin transaction:",
        s
      ), s;
    }
  }
  /**
   * Check whether a user account exists and is eligible for assisted recovery
   */
  static async checkUserRecoveryEligibility(t) {
    var s;
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/checkUserRecoveryEligibility",
        { email: t.trim() }
      )).data;
    } catch (n) {
      if (console.error("Error checking user recovery eligibility:", n), ee.isAxiosError(n)) {
        const a = (s = n.response) == null ? void 0 : s.data, o = (a == null ? void 0 : a.message) ?? (a == null ? void 0 : a.errorMessage);
        throw new Error(
          o || n.message || "Could not verify eligibility. Please try again."
        );
      }
      throw n;
    }
  }
  /**
   * Get member public key
   * @param orgName - Org name
   * @param orgMemberId - Org member ID
   * @returns Promise<MemberPublicKeyResponse> - Member public key and related information
   */
  static async getMemberPublicKey(t, s) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/memberPublicKey",
        {
          orgName: t,
          orgMemberId: s
        }
      )).data;
    } catch (n) {
      throw console.error("Error fetching member public key:", n), n;
    }
  }
  /**
   * Promote admin to security admin (API call)
   * @param request - Promote admin request with all required fields
   * @returns Promise<void> - Void response indicating success or failure
   */
  static async callPromoteAdminAPI(t) {
    try {
      await ee.post(
        O("baseURL") + "lms/admin/promoteAdmin",
        t
      );
    } catch (s) {
      throw console.error("Error promoting admin:", s), s;
    }
  }
  /**
   * Demote security admin to admin (API call)
   * @param request - Demote security admin request with all required fields
   * @returns Promise<void> - Void response indicating success or failure
   */
  static async callDemoteSecurityAdminAPI(t) {
    try {
      await ee.post(
        O("baseURL") + "lms/admin/demoteSecurityAdmin",
        t
      );
    } catch (s) {
      throw console.error("Error demoting security admin:", s), s;
    }
  }
}
const oc = /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
  /* @__PURE__ */ e.jsx("strong", { children: "Security Admin:" }),
  " User is active and also has security administrative privileges.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "Admin:" }),
  " User is active and also has administrative privileges.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "Approved:" }),
  " User is active and approved by admin.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "Auto Approved:" }),
  " User is active and has been approved automatically by the system, but with certain restrictions, and can only perform individual tasks.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "Registered:" }),
  " User is registered but not yet approved by an admin to become active.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "Deactivated:" }),
  " User has been deactivated by an admin.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "Authorization Pending:" }),
  " Member authorization is pending, it is typically done by the application server."
] }), ic = /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
  /* @__PURE__ */ e.jsx("p", { children: "Note that this setting is applicable only for the agentic members whose account was created with an application specific passcode at the time of registration. Each agentic member account can be standalone, where only the default setting is applicable; or be linked to a user account (associated with the user’s email), where the setting configured by the user applies. So even though this setting is configured at the user account level, it does not apply to user members themselves (where security questions for login are tied to the user account, and not specific to each app)." }),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "1FA with PC: Single Factor Authorization With App-specific Passcode" }),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  "With this setting enabled, the agentic member is required to validate only the application specific passcode for logging-in.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  "This is the default setting, as it makes the login behavior consistent for an agentic member irrespective of whether the account is linked to a user (associated with the user's email) or not. This setting can only be changed after explicitly linking, or transferring the lockbox of, the agentic-member account (associated with orgName, and memberId) to a user account, so that the Security Questions associated with the user account can take effect. The login behavior for the app-specific agentic-member account can then be controlled via these user-configured settings. Note that after a standalone agentic-member account with app-specific passcode is linked (or its lockbox transferred) to a user account, the subsequent login behavior of that app can change for the agentic-member depending on the MFA settings configured by the corresponding user and shown here.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "1FA with SQ: Single Factor Authorization With User Security Questions (or Passphrase)" }),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  "With this setting enabled, the agentic member is required to validate only Security Questions/Answers (or optionally Passphrase if set) while logging-in from a new device. Because SQs are tied to a User, it applies only for agentic members linked to a user account.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  "Even though the agentic member account, linked to the user account, has an application specific passcode of its own, it is not required to be entered at the time of login. This makes the login behavior for a user consistent across all the linked member accounts and applications, irrespective of the app-specific passcodes associated with any linked agentic-members.",
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("strong", { children: "2FA: Two Factor Authorization" }),
  /* @__PURE__ */ e.jsx("br", {}),
  /* @__PURE__ */ e.jsx("br", {}),
  "Two Factor Authorization adds an extra layer of security for all the agentic member accounts linked to a user account that have an Application Passcode of their own. When 2FA is enabled, login to any of the agentic member accounts will require not only validation of the app-specific passcode, but also an additional authorization with User Security Questions (or Passphrase if set)."
] }), ft = (r, t, s, n) => {
  r((a) => {
    if (!a) return a;
    const o = a.memberResponses.map(
      (i) => i.id === t ? { ...i, memberStatus: s } : i
    );
    return {
      ...a,
      memberResponses: n ? o.filter(n) : o
    };
  });
}, Cr = (r, t, s) => {
  r((n) => n && {
    ...n,
    memberResponses: n.memberResponses.map(
      (a) => a.id === t ? { ...a, publicKey: s } : a
    )
  });
}, _n = (r, t, s) => {
  r((n) => n && {
    ...n,
    onGoingSecurityAdminTransaction: t,
    targetOrgMemberId: s
  });
}, Kn = (r, t) => {
  r((s) => s && {
    ...s,
    securityAdminCount: t
  });
}, On = (r, t) => {
  r((s) => s && {
    ...s,
    minimumApprovalCount: t
  });
}, ls = class ls {
  /**
   * Store a value in the cache
   */
  static set(t, s) {
    this.cache.set(t, s);
  }
  /**
   * Retrieve a value from the cache
   */
  static get(t) {
    return this.cache.get(t);
  }
  /**
   * Check if a key exists in the cache
   */
  static has(t) {
    return this.cache.has(t);
  }
  /**
   * Remove a value from the cache
   */
  static delete(t) {
    return this.cache.delete(t);
  }
  /**
   * Clear all cached values
   */
  static clear() {
    this.cache.clear();
  }
  /**
   * Get all cache keys
   */
  static keys() {
    return Array.from(this.cache.keys());
  }
  /**
   * Get cache size
   */
  static size() {
    return this.cache.size;
  }
};
ls.cache = /* @__PURE__ */ new Map();
let dr = ls;
class tt {
  static getContextForTransactionEncryptionKeyKek(t, s) {
    return Qa + dt + t + s;
  }
  static getContextForAdminTemporaryPassphraseKek(t, s) {
    return Ja + dt + t + s;
  }
  static getContextForTransferredMemberPrivateKeyKek(t) {
    return Xa + dt + t;
  }
  static getContextForTrustedMemberPublicKey(t, s) {
    return to + dt + t + s;
  }
  static getContextForMemberPrivateKeyInnerKek(t, s, n) {
    return Za + dt + t + s + n;
  }
  static getContextForMemberPrivateKeyOuterKek(t) {
    return eo + dt + t;
  }
  static getContextForMemberAppPublicKeyLayer3(t, s, n, a) {
    return Zs + dt + t + s + n + a;
  }
  static getContextForUserKeyKek(t) {
    return "userKeyKek" + dt + t;
  }
}
const cc = [
  "memberApproval",
  "appApproval",
  "lockboxExpiry",
  "statsSyncTime",
  "encryptionStatus",
  "encryptionPolicy",
  "encryptionMode",
  "keyGenerationPolicy",
  "keyValidationPolicy",
  "minimumApprovalCount"
];
class Wr {
  /**
   * Fetch org settings for a specific org
   */
  static async fetchOrgSettings(t) {
    try {
      return (await ee.get(
        O("baseURL") + "lms/admin/orgSettings",
        {
          params: {
            lmsTransactionKey: t
          }
        }
      )).data;
    } catch (s) {
      throw s;
    }
  }
  /**
   * Update org settings
   */
  static async updateOrgSettings(t) {
    try {
      const s = {
        orgName: t.orgName,
        signedSettings: t.signedSettings,
        settingLastUpdatedAt: t.settingLastUpdatedAt
      };
      for (const n of cc)
        t[n] !== void 0 && (s[n] = t[n]);
      await ee.post(
        O("baseURL") + "lms/admin/orgSettings",
        s
      );
    } catch (s) {
      throw s;
    }
  }
}
async function Ln(r) {
  const t = ue(), s = O("bayunSessionId");
  if (!s || !t)
    throw new Error("Session ID or internal not found");
  const n = await Ce(t, s), a = await t.getFromStorage(
    s,
    v.ORG_NAME
  );
  if (!a)
    throw new Error("Org name not found");
  const o = await t.getFromStorage(
    s,
    v.ADMIN_PUBLIC_KEY
  );
  if (!o)
    throw new Error("Admin public key not found");
  const i = await t.aeadDecryptWithAssociatedData(
    r.minimumApprovalCount,
    a,
    n
  ), c = await t.aeadDecryptWithAssociatedData(
    r.lockboxExpiry,
    a,
    n
  ), l = await t.aeadDecryptWithAssociatedData(
    r.statsSyncTime,
    a,
    n
  ), d = await t.aeadDecryptWithAssociatedData(
    r.encryptionStatus,
    a,
    n
  ), u = await t.aeadDecryptWithAssociatedData(
    r.encryptionPolicy,
    a,
    n
  ), m = await t.aeadDecryptWithAssociatedData(
    r.encryptionMode,
    a,
    n
  ), p = await t.aeadDecryptWithAssociatedData(
    r.keyGenerationPolicy,
    a,
    n
  );
  return r.signedSettings && r.orgSettingsLastUpdatedAt != null && await t.verifyAndPersistOrgSettingsFromLastUpdatedAt(
    r.signedSettings,
    r.orgSettingsLastUpdatedAt,
    s,
    o,
    a
  ), {
    ...r,
    minimumApprovalCount: i,
    lockboxExpiry: c,
    statsSyncTime: l,
    encryptionStatus: d,
    encryptionPolicy: u,
    encryptionMode: m,
    keyGenerationPolicy: p
  };
}
const lc = {
  minimumApprovalCount: "minimumApprovalCountLastUpdatedAt",
  memberApproval: "memberApprovalLastUpdatedAt",
  appApproval: "appApprovalLastUpdatedAt",
  keyValidationPolicy: "keyValidationPolicyLastUpdatedAt",
  encryptionPolicy: "encryptionPolicyLastUpdatedAt",
  keyGenerationPolicy: "keyGenerationPolicyLastUpdatedAt",
  lockboxExpiry: "lockboxExpiryLastUpdatedAt",
  statsSyncTime: "statsSyncTimeLastUpdatedAt",
  encryptionStatus: "encryptionStatusLastUpdatedAt",
  encryptionMode: "encryptionModeLastUpdatedAt"
};
async function Dn(r, t, s, n) {
  var i;
  const a = r.getSettingLastUpdatedAtStorageKey(s), o = await r.getFromStorage(t, a);
  return (i = r.isOrgSettingsLastUpdatedAtObject) != null && i.call(r, o) ? { ...o } : n ? { ...n } : r.createInitialOrgSettingsLastUpdatedAt();
}
function Un(r, t) {
  var s;
  return ((s = r.getMaxOrgSettingsLastUpdatedAt) == null ? void 0 : s.call(r, t)) ?? Date.now();
}
function Fn(r, t, s = Date.now()) {
  const n = { ...r };
  for (const a of t) {
    const o = lc[a];
    o && (n[o] = s);
  }
  return n;
}
async function Hr(r, t, s, n) {
  const a = await t.getFromStorage(
    r,
    v.ORG_NAME
  ), o = await Ce(t, r);
  if (!a)
    throw new Error("Org name or org key not found");
  const i = await t.generateHMacHash(
    o,
    "lms" + a
  ), c = await Wr.fetchOrgSettings(i), l = await Ln(c), d = await Dn(
    t,
    r,
    a,
    l.orgSettingsLastUpdatedAt
  ), u = Fn(
    d,
    ["minimumApprovalCount"]
  ), { signedSettings: m } = await t.signOrgSettingsFromLastUpdatedAt(
    u,
    s,
    r,
    a
  );
  return await t.saveInStorage(
    r,
    t.getSettingLastUpdatedAtStorageKey(a),
    u
  ), {
    signedSettings: m,
    settingLastUpdatedAt: Un(
      t,
      u
    )
  };
}
class ut {
  /**
   * Prepare and initiate promote admin transaction
   * Handles all encryption, data preparation, and API call
   */
  static async prepareAndInitiatePromoteAdmin(t, s, n, a, o) {
    const i = O("baseURL");
    if (!i)
      throw new Error("Base URL not found in cookies");
    const c = await s.generateAesKey(), { transactionId: l } = await we.initiateTransaction(), d = await s.getFromStorage(
      t,
      v.ORG_NAME
    );
    if (!d)
      throw new Error("Org name not found");
    const u = await rt(
      t,
      d,
      s
    );
    if (await s.retrieveAndverifyLastSignature(
      t,
      n
    ))
      n = n.split(Ne)[0];
    else
      throw new Error("Target member ID signature verification failed");
    const m = await s.getFromStorage(
      t,
      v.MEMBER_PRIVATE_KEY
    );
    if (!m)
      throw new Error("Member private key not found");
    const p = await We(
      t,
      i,
      m,
      null,
      c,
      s
    ), y = await _e.getAdminPrivateKey(), g = await Ce(s, t), w = await s.generateHMacHash(
      g,
      "lms" + d
    ), h = await s.aeadEncryptWithAssociatedData(
      $.IN_PROGRESS,
      "lms" + d,
      w
    ), M = await s.aeadEncryptWithAssociatedData(
      be.PROMOTE_ADMIN,
      "lms" + d,
      w
    ), x = await s.getFromStorage(
      t,
      v.ORG_MEMBER_ID
    ), T = await s.context.getTransactionIdContext(
      l,
      $.IN_PROGRESS,
      be.PROMOTE_ADMIN,
      d,
      x
    );
    let R = await s.signData(
      l,
      y,
      T
    );
    R = await s.appendSignatureAndMetadata(
      l,
      R,
      s.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      T
    );
    const D = await we.getMinimumApprovalCount(), U = await s.aeadDecryptWithAssociatedData(
      D.minimumApprovalCount,
      d,
      g
    );
    if (!U)
      throw new Error("Failed to decrypt current minimum approval count");
    const q = await s.getFromStorage(
      t,
      v.ADMIN_PUBLIC_KEY
    );
    if (!q)
      throw new Error("Admin public key not found");
    const N = await s.encryptAsymmetric(
      U,
      q,
      d
    ), P = await s.encryptAsymmetric(
      a,
      q,
      d
    );
    if (!N || !P)
      throw new Error("Failed to encrypt minimum approval count values");
    const re = {
      transactionEncryptionKeyRequestList: await pt(
        c,
        u,
        y,
        m,
        d,
        s
      ),
      backdoorPrivateKeyPart: p || "",
      targetMemberId: n,
      authPasscodeHash: "",
      memberAppId: o,
      minimumApprovalCount: N.encryptedText,
      minimumApprovalCount_kek: N.keyEncryptionKey,
      newMinimumApprovalCount: P.encryptedText,
      newMinimumApprovalCount_kek: P.keyEncryptionKey,
      lmsTransactionKey: w,
      transactionStatus: h,
      transactionLabel: M,
      transactionId: l,
      signedTransactionId: R
    }, J = await Be.initiatePromoteAdmin(
      re
    );
    return await ut.finalizeInitiatePromoteAdmin(
      t,
      J,
      m,
      y,
      d,
      i,
      s,
      l,
      R
    ), J;
  }
  /**
   * Finalize initiate promote admin transaction
   * Handles business logic for finalizing promotion transaction
   */
  static async finalizeInitiatePromoteAdmin(t, s, n, a, o, i, c, l, d) {
    const u = await c.decryptAsymmetric(
      s.minimumApprovalCount,
      a,
      s.minimumApprovalCount_kek,
      o
    ), m = await c.decryptAsymmetric(
      s.newMinimumApprovalCount,
      a,
      s.newMinimumApprovalCount_kek,
      o
    );
    if (u == 1) {
      const p = await c.getFromStorage(
        t,
        v.ORG_MEMBER_ID
      ), y = await Mt(
        i,
        t,
        n,
        p,
        c
      ), g = await Ce(c, t);
      await ut.promoteAdmin(
        t,
        s.targetOrgMemberId,
        y,
        s.transactionId,
        m,
        u,
        g,
        a,
        n,
        c,
        d
      );
    }
  }
  /**
   * Promote admin to security admin
   * Handles promotion with encryption, signature verification, and key splitting
   */
  static async promoteAdmin(t, s, n, a, o, i, c, l, d, u, m) {
    const p = String(i) !== String(o), y = await u.getFromStorage(
      t,
      v.ORG_NAME
    ), g = typeof c == "string" ? u.asRawKey(c) : c;
    if (!g)
      throw new Error("Org key not found or invalid");
    const w = await Be.getMemberPublicKey(
      y,
      s
    );
    await u.verifyMemberPublicKey(
      t,
      w.publicKey,
      null,
      w.trustedMemberPublicKeySignature,
      y,
      s,
      null,
      null,
      null
      // null,
    );
    const h = await u.signDataAndAppendSignatureWithMetadata(
      w.publicKey,
      n,
      await u.context.getMemberPublicKeyContext(
        y,
        s
      ),
      u.signingPublicKeyTags.BACKDOOR_PUBLIC_KEY_TAG
    ), M = await u.signDataAndAppendSignatureWithMetadata(
      w.archivedPublicKey,
      n,
      await u.context.getMemberPublicKeyContext(
        y,
        s
      ),
      u.signingPublicKeyTags.BACKDOOR_PUBLIC_KEY_TAG
    ), x = await rt(
      t,
      y,
      u
    );
    x.push({
      memberId: "",
      orgMemberId: s,
      memberPublicKey: w.publicKey.split(Ne)[0],
      trustedMemberPublicKeySignature: w.trustedMemberPublicKeySignature
    });
    const T = await $r(
      t,
      x,
      n,
      l,
      d,
      y,
      parseInt(o),
      u
    ), R = await u.generateHMacHash(
      g,
      "lms" + y
    ), D = await u.aeadEncryptWithAssociatedData(
      $.COMPLETED.toString(),
      "lms" + y,
      R
    ), U = await u.getFromStorage(
      t,
      v.ORG_MEMBER_ID
    ), q = await u.signData(
      a,
      l,
      await u.context.getTransactionIdContext(
        a,
        $.COMPLETED,
        be.PROMOTE_ADMIN,
        y,
        U
      )
    );
    m = await u.appendSignatureAndMetadata(
      m,
      q,
      u.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      await u.context.getTransactionIdContext(
        a,
        $.COMPLETED,
        be.PROMOTE_ADMIN,
        y,
        U
      )
    );
    const N = await u.aeadEncryptWithAssociatedData(
      String(o),
      y,
      g
    ), P = await u.getFromStorage(
      t,
      v.MEMBER_ID
    );
    let Y = null, re = null;
    if (p) {
      const J = await Hr(t, u, l);
      Y = J.signedSettings, re = J.settingLastUpdatedAt;
    }
    await Be.callPromoteAdminAPI({
      backdoorPrivateKeyPartsRequest: T,
      transactionId: a,
      lmsTransactionKey: R,
      transactionStatus: D,
      newMinimumApprovalCount: N,
      minimumApprovalCountChanged: p,
      signingMemberId: P,
      signedMemberPublicKey: h,
      archivedMemberPublicKey: M,
      signedTransactionId: m,
      signedSettings: Y,
      settingLastUpdatedAt: re
    });
  }
  /**
   * Prepare and initiate demote security admin transaction
   * Handles all encryption, data preparation, and API call
   */
  static async prepareAndInitiateDemoteSecurityAdmin(t, s, n, a, o) {
    const i = O("baseURL");
    if (!i)
      throw new Error("Base URL not found in cookies");
    const c = await s.generateAesKey(), l = await s.getFromStorage(
      t,
      v.ORG_NAME
    );
    if (!l)
      throw new Error("Org name not found");
    const d = await rt(
      t,
      l,
      s
    );
    if (await s.retrieveAndverifyLastSignature(
      t,
      n
    ))
      n = n.split(Ne)[0];
    else
      throw new Error("Target member ID signature verification failed");
    const u = await s.getFromStorage(
      t,
      v.MEMBER_PRIVATE_KEY
    );
    if (!u)
      throw new Error("Member private key not found");
    const m = await We(
      t,
      i,
      u,
      null,
      c,
      s
    ), p = await _e.getAdminPrivateKey(), y = await Ce(s, t), g = await s.generateHMacHash(
      y,
      "lms" + l
    ), w = await s.aeadEncryptWithAssociatedData(
      $.IN_PROGRESS,
      "lms" + l,
      g
    ), h = await s.aeadEncryptWithAssociatedData(
      be.DEMOTE_SECURITY_ADMIN,
      "lms" + l,
      g
    ), { transactionId: M } = await we.initiateTransaction(), x = await s.getFromStorage(
      t,
      v.ORG_MEMBER_ID
    ), T = await s.context.getTransactionIdContext(
      M,
      $.IN_PROGRESS,
      be.DEMOTE_SECURITY_ADMIN,
      l,
      x
    );
    let R = await s.signData(
      M,
      p,
      T
    );
    R = await s.appendSignatureAndMetadata(
      M,
      R,
      s.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      T
    );
    const D = await we.getMinimumApprovalCount(), U = await s.aeadDecryptWithAssociatedData(
      D.minimumApprovalCount,
      l,
      y
    );
    if (!U)
      throw new Error("Failed to decrypt current minimum approval count");
    const q = await s.getFromStorage(
      t,
      v.ADMIN_PUBLIC_KEY
    );
    if (!q)
      throw new Error("Admin public key not found");
    const N = await s.encryptAsymmetric(
      U,
      q,
      l
    ), P = await s.encryptAsymmetric(
      a,
      q,
      l
    );
    if (!N || !P)
      throw new Error("Failed to encrypt minimum approval count values");
    const re = {
      transactionEncryptionKeyRequestList: await pt(
        c,
        d,
        p,
        u,
        l,
        s
      ),
      backdoorPrivateKeyPart: m || "",
      targetMemberId: n,
      authPasscodeHash: "",
      memberAppId: o,
      minimumApprovalCount: N.encryptedText,
      minimumApprovalCount_kek: N.keyEncryptionKey,
      newMinimumApprovalCount: P.encryptedText,
      newMinimumApprovalCount_kek: P.keyEncryptionKey,
      lmsTransactionKey: g,
      transactionStatus: w,
      transactionLabel: h,
      transactionId: M,
      signedTransactionId: R
    }, J = await Be.initiateDemoteSecurityAdmin(
      re
    );
    return await ut.finalizeInitiateDemoteSecurityAdmin(
      t,
      J,
      u,
      p,
      l,
      i,
      s,
      R
    ), J;
  }
  /**
   * Finalize initiate demote security admin transaction
   * Handles business logic for finalizing demotion transaction
   */
  static async finalizeInitiateDemoteSecurityAdmin(t, s, n, a, o, i, c, l) {
    const d = await c.decryptAsymmetric(
      s.minimumApprovalCount,
      a,
      s.minimumApprovalCount_kek,
      o
    ), u = await c.decryptAsymmetric(
      s.newMinimumApprovalCount,
      a,
      s.newMinimumApprovalCount_kek,
      o
    );
    if (d == 1) {
      const m = await c.getFromStorage(
        t,
        v.ORG_MEMBER_ID
      ), p = await Mt(
        i,
        t,
        n,
        m,
        c
      ), y = await Ce(c, t);
      await ut.demoteSecurityAdmin(
        t,
        s.targetOrgMemberId,
        p,
        s.transactionId,
        u,
        d,
        y,
        a,
        n,
        c,
        l
      );
    }
  }
  /**
   * Demote security admin to admin
   * Handles demotion with encryption, signature verification, and key splitting
   */
  static async demoteSecurityAdmin(t, s, n, a, o, i, c, l, d, u, m) {
    const p = String(i) !== String(o), y = await u.getFromStorage(
      t,
      v.ORG_NAME
    ), g = typeof c == "string" ? u.asRawKey(c) : c;
    if (!g)
      throw new Error("Org key not found or invalid");
    const h = (await rt(
      t,
      y,
      u
    )).filter(
      (Y) => Y.orgMemberId !== s
    ), M = await $r(
      t,
      h,
      n,
      l,
      d,
      y,
      parseInt(o),
      u
    ), x = await u.generateHMacHash(
      g,
      "lms" + y
    ), T = await u.aeadEncryptWithAssociatedData(
      $.COMPLETED.toString(),
      "lms" + y,
      x
    ), R = await u.getFromStorage(
      t,
      v.ORG_MEMBER_ID
    ), D = await u.signData(
      a,
      l,
      await u.context.getTransactionIdContext(
        a,
        $.COMPLETED,
        be.DEMOTE_SECURITY_ADMIN,
        y,
        R
      )
    );
    m = await u.appendSignatureAndMetadata(
      m,
      D,
      u.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      await u.context.getTransactionIdContext(
        a,
        $.COMPLETED,
        be.DEMOTE_SECURITY_ADMIN,
        y,
        R
      )
    );
    const U = await u.aeadEncryptWithAssociatedData(
      String(o),
      y,
      g
    ), q = await u.getFromStorage(
      t,
      v.MEMBER_ID
    );
    let N = null, P = null;
    if (p) {
      const Y = await Hr(
        t,
        u,
        l
      );
      N = Y.signedSettings, P = Y.settingLastUpdatedAt;
    }
    await Be.callDemoteSecurityAdminAPI({
      backdoorPrivateKeyPartsRequest: M,
      transactionId: a,
      lmsTransactionKey: x,
      transactionStatus: T,
      signedTransactionId: m,
      newMinimumApprovalCount: U,
      minimumApprovalCountChanged: p,
      signingMemberId: q,
      signedMemberPublicKey: "",
      archivedMemberPublicKey: "",
      signedSettings: N,
      settingLastUpdatedAt: P
    });
  }
}
class jt {
  static async fetchMemberAllGroups(t) {
    const n = `${O("baseURL")}lms/admin/group/memberAllGroups`;
    return (await ee.get(n, {
      params: {
        pageNumber: t.pageNumber
      },
      withCredentials: !0
    })).data;
  }
  static async fetchOrgAllGroups(t) {
    const n = `${O("baseURL")}lms/admin/group/orgAllGroups`;
    return (await ee.get(n, {
      params: {
        pageNumber: t.pageNumber
      },
      withCredentials: !0
    })).data;
  }
  static async getOrgAllGroupInfo() {
    const s = `${O("baseURL")}lms/admin/group/getOrgAllGroupInfo`;
    return (await ee.get(s, {
      withCredentials: !0
    })).data;
  }
  /**
   * Initiate add group participant transaction (API call only)
   */
  static async initiateAddGroupParticipant(t) {
    var s, n;
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/initiateAddGroupParticipant",
        t
      )).data;
    } catch (a) {
      if (console.error(
        "Error initiating add group participant transaction:",
        a
      ), ee.isAxiosError(a) && ((s = a.response) != null && s.data)) {
        const o = a.response.data;
        if (o.errorType === "INVALID_OPERATION" && ((n = o.errorMessage) != null && n.includes("already exists in the group")))
          throw new Error(
            o.errorMessage || "This member is already a participant of the selected group"
          );
      }
      throw a;
    }
  }
  /**
   * Get backdoor group private key for transaction
   */
  static async getBackdoorGroupPrivateKey(t, s) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/backdoorGroupPrivateKey",
        {
          transactionId: t,
          lmsTransactionKey: s
        }
      )).data;
    } catch (n) {
      throw console.error("Error getting backdoor group private key:", n), n;
    }
  }
  /**
   * Add participant to group (complete transaction)
   */
  static async addParticipantToGroup(t) {
    try {
      await ee.post(
        O("baseURL") + "lms/admin/addParticipantToGroup",
        t
      );
    } catch (s) {
      throw console.error("Error adding participant to group:", s), s;
    }
  }
}
class Tt {
  /**
   * Initiate add group participant transaction
   * Handles all encryption, data preparation, and API call to add a participant to a group
   *
   * @param sessionId - The session ID from cookies
   * @param internal - The Bayun internal API instance
   * @param group - The group to add the participant to
   * @param member - The member to add to the group
   * @returns Promise that resolves when the participant is successfully added
   */
  static async initiateAddGroupParticipant(t, s, n, a) {
    try {
      const o = O("baseURL");
      if (!o)
        throw new Error("Base URL not found in cookies");
      const i = await s.getFromStorage(
        t,
        v.ORG_NAME
      ), c = await s.getFromStorage(
        t,
        v.MEMBER_PRIVATE_KEY
      ), l = await _e.getAdminPrivateKey(), d = await Ce(s, t), u = await s.generateHMacHash(
        d,
        "lms" + i
      ), m = await s.aeadEncryptWithAssociatedData(
        $.IN_PROGRESS,
        "lms" + i,
        u
      ), p = await s.aeadEncryptWithAssociatedData(
        be.ADD_GROUP_PARTICIPANT,
        "lms" + i,
        u
      ), { transactionId: y } = await we.initiateTransaction(), g = await s.getFromStorage(
        t,
        v.ORG_MEMBER_ID
      );
      let w = await s.signData(
        y,
        l,
        s.context.getTransactionIdContext(
          y,
          $.IN_PROGRESS,
          be.ADD_GROUP_PARTICIPANT,
          i,
          g
        )
      );
      w = await s.appendSignatureAndMetadata(
        y,
        w,
        s.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        s.context.getTransactionIdContext(
          y,
          $.IN_PROGRESS,
          be.ADD_GROUP_PARTICIPANT,
          i,
          g
        )
      );
      const h = await we.getMinimumApprovalCount(), M = await s.aeadDecryptWithAssociatedData(
        h.minimumApprovalCount,
        i,
        d
      );
      if (!M)
        throw new Error("Failed to decrypt current minimum approval count");
      const x = await s.getFromStorage(
        t,
        v.ADMIN_PUBLIC_KEY
      ), T = await s.encryptAsymmetric(
        M,
        x,
        i
      ), R = await et.getMemberApproval(
        t,
        c,
        l,
        s
      );
      if (R.error)
        throw new Error("Failed to get member approval");
      const D = R.symmetricEncryptedBackdoorPrivateKeyPart, q = {
        transactionEncryptionKeyRequestList: R.transactionEncryptionKeyRequests || [],
        backdoorPrivateKeyPart: D || "",
        targetMemberId: a,
        authPasscodeHash: "",
        memberAppId: "",
        minimumApprovalCount: T.encryptedText,
        minimumApprovalCount_kek: T.keyEncryptionKey,
        newMinimumApprovalCount: null,
        newMinimumApprovalCount_kek: null,
        lmsTransactionKey: u,
        transactionStatus: m,
        transactionLabel: p,
        transactionId: y,
        signedTransactionId: w,
        groupId: n
      }, N = await jt.initiateAddGroupParticipant(
        q
      );
      await Tt.finalizeInitiateAddGroupParticipant(
        t,
        N,
        c,
        l,
        i,
        u,
        o,
        s,
        w
      );
      return;
    } catch (o) {
      throw console.error("Error initiating add group participant:", o), o instanceof Error ? o : new Error(
        o instanceof Error ? o.message : "Failed to add participant to group. Please try again."
      );
    }
  }
  /**
   * Finalize initiate add group participant transaction
   * Handles business logic for finalizing add group participant transaction
   */
  static async finalizeInitiateAddGroupParticipant(t, s, n, a, o, i, c, l, d) {
    try {
      const u = await l.decryptAsymmetric(
        s.minimumApprovalCount,
        a,
        s.minimumApprovalCount_kek,
        o
      ), m = await l.getFromStorage(
        t,
        v.MEMBER_STATUS
      ), p = (m == null ? void 0 : m.toLowerCase()) === ye.SECURITY_ADMIN.toLowerCase();
      if (u === "1" && p) {
        const y = await l.getFromStorage(
          t,
          v.ORG_MEMBER_ID
        );
        if (!y)
          throw new Error("Org member ID not found");
        const g = await Mt(
          c,
          t,
          n,
          y,
          l
        );
        await Tt.addGroupParticipant(
          t,
          s,
          g,
          i,
          n,
          a,
          o,
          l,
          d
        );
      }
    } catch (u) {
      throw console.error("Error finalizing initiate add group participant:", u), u;
    }
  }
  /**
   * Complete add group participant transaction
   * Handles encryption, verification, and API call to complete adding a participant to a group
   */
  static async addGroupParticipant(t, s, n, a, o, i, c, l, d) {
    try {
      const u = await l.getFromStorage(
        t,
        v.ORG_MEMBER_ID
      );
      if (!u)
        throw new Error("Org member ID not found");
      const m = await Be.getMemberPublicKey(
        c,
        s.targetOrgMemberId
      );
      await l.verifyMemberPublicKey(
        t,
        m.publicKey,
        null,
        m.trustedMemberPublicKeySignature,
        c,
        s.targetOrgMemberId,
        null,
        null,
        null
        // null,
      );
      let p = null;
      (!m.trustedMemberPublicKeySignature || m.trustedMemberPublicKeySignature.trim() === "") && (p = await l.signDataAndAppendSignatureWithMetadata(
        m.publicKey,
        o,
        await l.context.getMemberPublicKeyContext(
          c,
          s.targetOrgMemberId
        ),
        l.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
      ));
      const y = await jt.getBackdoorGroupPrivateKey(
        s.transactionId,
        a
      ), g = await l.decryptAsymmetric(
        y.backdoorEncryptedGroupPrivateKey,
        n,
        y.backdoorEncryptedGroupPrivateKey_kek,
        y.groupCreatorOrgMemberId
      ), w = await l.decryptAsymmetric(
        y.backdoorEncryptedGroupKey,
        n,
        y.backdoorEncryptedGroupKey_kek,
        y.groupCreatorOrgMemberId
      ), h = await l.encryptAsymmetric(
        g,
        m.publicKey.split(Ne)[0],
        s.targetOrgMemberId
      );
      if (!h)
        throw new Error("Failed to encrypt backdoor group private key");
      const M = await l.encryptAsymmetric(
        w,
        m.publicKey.split(Ne)[0],
        s.targetOrgMemberId
      );
      if (!M)
        throw new Error("Failed to encrypt backdoor group key");
      const x = await l.generateHMacHash(
        l.asRawKey(w),
        "lms" + y.groupCreatorOrgName + y.groupCreatorOrgMemberId
      ), T = await l.aeadDecryptWithAssociatedData(
        y.encryptedGroupInfoKey,
        "lms" + y.groupCreatorOrgName + y.groupCreatorOrgMemberId,
        x
      ), R = await l.aeadDecryptWithAssociatedData(
        y.groupName,
        y.groupCreatorOrgName + y.groupCreatorOrgMemberId,
        T
      ), D = await l.signData(
        M.encryptedText,
        o,
        l.context.getGroupKeyContext(t, R)
      ), U = await l.signData(
        h.encryptedText,
        o,
        l.context.getGroupPrivateKeyContext(t, R)
      ), q = await l.aeadEncryptWithAssociatedData(
        $.COMPLETED,
        "lms" + c,
        a
      ), N = await l.signData(
        s.transactionId,
        i,
        l.context.getTransactionIdContext(
          s.transactionId,
          $.COMPLETED,
          be.ADD_GROUP_PARTICIPANT,
          c,
          u
        )
      );
      d = await l.appendSignatureAndMetadata(
        d,
        N,
        l.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        l.context.getTransactionIdContext(
          s.transactionId,
          $.COMPLETED,
          be.ADD_GROUP_PARTICIPANT,
          c,
          u
        )
      );
      let P = h.keyEncryptionKey, Y = M.keyEncryptionKey;
      const re = await l.signData(
        P,
        o,
        await l.context.getGroupPrivateKeyKekContext(
          c,
          s.targetOrgMemberId
        )
      );
      P = await l.appendSignatureAndMetadata(
        P,
        re,
        l.signingPublicKeyTags.MEMBER_ADDING_PUBLIC_KEY_TAG,
        await l.context.getGroupPrivateKeyKekContext(
          c,
          s.targetOrgMemberId
        )
      );
      const J = await l.signData(
        Y,
        o,
        await l.context.getGroupKeyKekContext(
          t,
          s.targetOrgMemberId
        )
      );
      Y = await l.appendSignatureAndMetadata(
        Y,
        J,
        l.signingPublicKeyTags.MEMBER_ADDING_PUBLIC_KEY_TAG,
        await l.context.getGroupKeyKekContext(
          t,
          s.targetOrgMemberId
        )
      );
      const le = await l.getFromStorage(
        t,
        v.MEMBER_ID
      );
      if (!le)
        throw new Error("Member ID not found");
      const Q = {
        transactionId: s.transactionId,
        newEncryptedBackdoorGroupPrivateKey: h.encryptedText,
        newEncryptedBackdoorGroupPrivateKeyKek: P,
        newEncryptedBackdoorGroupKey: M.encryptedText,
        newEncryptedBackdoorGroupKeyKek: Y,
        lmsTransactionKey: a,
        transactionStatus: q,
        signedTransactionId: d,
        signingMemberId: le,
        trusteeSignedMemberPublicKey: p,
        signedGroupKey: D,
        signedGroupPrivateKey: U
      };
      await jt.addParticipantToGroup(Q), console.log("Add group participant transaction completed successfully");
    } catch (u) {
      throw console.error(
        "Error completing add group participant transaction:",
        u
      ), u;
    }
  }
  /**
   * Verify signatures for a single group member response
   * @param groupResponse - The group member response to verify
   * @param sessionId - Session ID for signature verification
   * @param internal - Bayun internal API instance
   * @param orgName - Org name for verification
   * @param orgMemberId - Org member ID for verification
   * @throws Error if signature verification fails
   */
  static async verifySingleOrgGroup(t, s, n) {
    try {
      await n.verifyMemberPublicKey(
        s,
        t.creatorMemberPublicKey,
        gt.GROUP_OPERATION,
        t.trustedCreatingMemberPublicKeySignature,
        t.creatorOrgName,
        t.creatorOrgMemberId,
        null,
        null,
        null
        // null,
      );
    } catch (o) {
      throw console.error("Group verification failed at creatorMemberPublicKey", {
        groupId: t.id,
        creatorOrgName: t.creatorOrgName,
        creatorOrgMemberId: t.creatorOrgMemberId,
        error: o
      }), o;
    }
    if (t.creatorMemberPublicKey = t.creatorMemberPublicKey.split(Ne)[0], t.groupKey_kek) {
      try {
        await n.verifyMemberPublicKey(
          s,
          t.addingMemberPublicKey,
          gt.GROUP_OPERATION,
          t.trustedAddingMemberPublicKeySignature,
          t.addingMemberOrgName,
          t.addingMemberOrgMemberId,
          null,
          null,
          null
          // null,
        );
      } catch (i) {
        throw console.error("Group verification failed at addingMemberPublicKey", {
          groupId: t.id,
          addingMemberOrgName: t.addingMemberOrgName,
          addingMemberOrgMemberId: t.addingMemberOrgMemberId,
          error: i
        }), i;
      }
      t.addingMemberPublicKey = t.addingMemberPublicKey.split(Ne)[0];
      let o = !1;
      try {
        o = await n.verifyMessageForPublicKeyTag(
          s,
          t.groupKey_kek,
          t.addingMemberPublicKey,
          n.signingPublicKeyTags.MEMBER_ADDING_PUBLIC_KEY_TAG
        );
      } catch (i) {
        throw console.error("Group verification failed at groupKey_kek validation", {
          groupId: t.id,
          addingMemberOrgName: t.addingMemberOrgName,
          addingMemberOrgMemberId: t.addingMemberOrgMemberId,
          error: i
        }), i;
      }
      if (!o)
        throw console.log("groupKeyKEK verification failed."), console.error("groupKey_kek signature mismatch", {
          groupId: t.id,
          addingMemberOrgName: t.addingMemberOrgName,
          addingMemberOrgMemberId: t.addingMemberOrgMemberId
        }), new Error("Member verification failed");
      t.groupKey_kek = t.groupKey_kek.split(Ne)[0];
    }
    let a = !1;
    try {
      a = await n.verifyMessageForPublicKeyTag(
        s,
        t.type,
        t.creatorMemberPublicKey,
        n.signingPublicKeyTags.GROUP_CREATOR_PUBLIC_KEY_TAG
      );
    } catch (o) {
      throw console.error("Group verification failed at group type signature check", {
        groupId: t.id,
        creatorOrgName: t.creatorOrgName,
        creatorOrgMemberId: t.creatorOrgMemberId,
        error: o
      }), o;
    }
    if (!a)
      throw console.log("EncryptedGroupType verification failed."), console.error("group type signature mismatch", {
        groupId: t.id,
        creatorOrgName: t.creatorOrgName,
        creatorOrgMemberId: t.creatorOrgMemberId
      }), new Error("Signature verification failed for groupType");
    t.type = t.type.split(Ne)[0];
  }
  /**
   * Verify signatures for all org group member responses
   * @param groupMemberResponses - Array of group member responses to verify
   * @param sessionId - Session ID for signature verification
   * @param internal - Bayun internal API instance
   * @throws Error if signature verification fails for any group
   */
  static async verifyAllOrgGroups(t, s, n) {
    for (const a of t)
      await Tt.verifySingleOrgGroup(
        a,
        s,
        n
      );
  }
}
class et {
  /**
   * Transfer lockbox ownership - orchestrates business logic and API calls
   */
  static async initiateLockBoxTransfer(t) {
    try {
      const s = O("baseURL");
      if (!s)
        throw new Error("Base URL not found in cookies");
      const n = O("bayunSessionId"), a = ue();
      if (!a)
        throw new Error("Internal API not available");
      const o = await _e.getAdminPrivateKey(), i = await Ce(a, n), c = await a.getFromStorage(
        n,
        v.ORG_NAME
      ), l = await a.generateHMacHash(
        i,
        "lms" + c
      ), d = await a.aeadEncryptWithAssociatedData(
        $.IN_PROGRESS,
        "lms" + c,
        l
      ), u = await a.aeadEncryptWithAssociatedData(
        be.TRANSFER_LOCK_BOX,
        "lms" + c,
        l
      ), m = await we.getMinimumApprovalCount(), p = await a.aeadDecryptWithAssociatedData(
        m.minimumApprovalCount,
        c,
        i
      ), y = await a.getFromStorage(
        n,
        v.ADMIN_PUBLIC_KEY
      ), g = await a.encryptAsymmetric(
        p,
        y,
        c
      );
      let w = "", h = "";
      g && (w = g.encryptedText, h = g.keyEncryptionKey);
      const M = await a.getFromStorage(
        n,
        v.MEMBER_PRIVATE_KEY
      ), x = await a.getFromStorage(
        n,
        v.MEMBER_APP_ID
      ) || "", T = await et.getMemberApproval(
        n,
        M,
        o,
        a
      );
      if (T.error)
        throw new Error("Error initiating lockbox transfer");
      const R = T.symmetricEncryptedBackdoorPrivateKeyPart, D = T.transactionEncryptionKeyRequests, { transactionId: U } = await we.initiateTransaction(), q = await a.getFromStorage(
        n,
        v.ORG_MEMBER_ID
      );
      let N = await a.signData(
        U,
        o,
        a.context.getTransactionIdContext(U, $.IN_PROGRESS, be.TRANSFER_LOCK_BOX, c, q)
      );
      N = await a.appendSignatureAndMetadata(
        U,
        N,
        a.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        a.context.getTransactionIdContext(U, $.IN_PROGRESS, be.TRANSFER_LOCK_BOX, c, q)
      );
      const P = {
        transactionEncryptionKeyRequestList: D || [],
        backdoorPrivateKeyPart: R || "",
        sourceMemberId: t.primaryOwnerId,
        targetMemberId: t.newOwnerId,
        authPasscodeHash: "",
        memberAppId: x,
        minimumApprovalCount: w,
        minimumApprovalCount_kek: h,
        newMinimumApprovalCount: "",
        newMinimumApprovalCount_kek: "",
        lmsTransactionKey: l,
        transactionStatus: d,
        transactionLabel: u,
        transactionId: U,
        signedTransactionId: N
      }, Y = await we.initiateLockBoxTransferTransaction(
        P
      );
      return et.finalizeInitiateLockBoxTransfer(
        n,
        Y,
        M,
        o,
        c,
        l,
        s,
        a,
        N
      );
    } catch (s) {
      throw console.error("Error transferring lockbox ownership:", s), s;
    }
  }
  static async initiateUserAccountRecovery(t) {
    try {
      const s = O("baseURL");
      if (!s)
        throw new Error("Base URL not found in cookies");
      const n = O("bayunSessionId"), a = ue();
      if (!a)
        throw new Error("Internal API not available");
      const o = await _e.getAdminPrivateKey(), i = await Ce(a, n), c = await a.getFromStorage(
        n,
        v.ORG_NAME
      ), l = await a.generateHMacHash(
        i,
        "lms" + c
      ), d = await a.aeadEncryptWithAssociatedData(
        $.IN_PROGRESS,
        "lms" + c,
        l
      ), u = await a.aeadEncryptWithAssociatedData(
        be.RECOVER_USER,
        "lms" + c,
        l
      ), m = await we.getMinimumApprovalCount(), p = await a.aeadDecryptWithAssociatedData(
        m.minimumApprovalCount,
        c,
        i
      ), y = await a.getFromStorage(
        n,
        v.ADMIN_PUBLIC_KEY
      ), g = await a.encryptAsymmetric(
        p,
        y,
        c
      );
      let w = "", h = "";
      g && (w = g.encryptedText, h = g.keyEncryptionKey);
      const M = await a.getFromStorage(
        n,
        v.MEMBER_PRIVATE_KEY
      ), x = await a.getFromStorage(
        n,
        v.MEMBER_APP_ID
      ) || "", T = await et.getMemberApproval(
        n,
        M,
        o,
        a
      );
      if (T.error)
        throw new Error("Error initiating user account recovery");
      const R = T.symmetricEncryptedBackdoorPrivateKeyPart, D = T.transactionEncryptionKeyRequests, q = globalThis.crypto.randomUUID().replace(/-/g, "").slice(0, 16), N = t.targetUserEmail.trim(), P = await a.encryptAsymmetric(
        q,
        y,
        N
      ), Y = P.encryptedText, re = P.keyEncryptionKey, J = await a.signData(
        re,
        o,
        tt.getContextForAdminTemporaryPassphraseKek(
          c,
          N
        )
      ), le = await a.appendSignatureAndMetadata(
        re,
        J,
        Or,
        tt.getContextForAdminTemporaryPassphraseKek(
          c,
          N
        )
      ), { transactionId: Q } = await we.initiateTransaction(), de = await a.getFromStorage(
        n,
        v.ORG_MEMBER_ID
      );
      let te = await a.signData(
        Q,
        o,
        a.context.getTransactionIdContext(Q, $.IN_PROGRESS, be.RECOVER_USER, c, de)
      );
      te = await a.appendSignatureAndMetadata(
        Q,
        te,
        a.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        a.context.getTransactionIdContext(Q, $.IN_PROGRESS, be.RECOVER_USER, c, de)
      );
      const K = {
        transactionEncryptionKeyRequestList: D || [],
        backdoorPrivateKeyPart: R || "",
        targetMemberId: null,
        authPasscodeHash: null,
        memberAppId: x,
        minimumApprovalCount: w,
        minimumApprovalCount_kek: h,
        newMinimumApprovalCount: null,
        newMinimumApprovalCount_kek: null,
        lmsTransactionKey: l,
        transactionStatus: d,
        transactionLabel: u,
        targetUserEmail: N,
        adminEncryptedTemporaryPassphrase: Y,
        adminEncryptedTemporaryPassphrase_kek: le,
        transactionId: Q,
        signedTransactionId: te
      }, X = await we.initiateUserAccountRecoveryTransaction(
        K
      );
      return await et.finalizeInitiateUserAccountRecovery(
        n,
        X,
        M,
        o,
        c,
        l,
        s,
        a,
        te
      ), { temporaryPassphrase: q };
    } catch (s) {
      throw console.error("Error initiating user account recovery:", s), s;
    }
  }
  static async finalizeInitiateUserAccountRecovery(t, s, n, a, o, i, c, l, d) {
    const u = await l.decryptAsymmetric(
      s.minimumApprovalCount,
      a,
      s.minimumApprovalCount_kek,
      o
    ), m = await l.getFromStorage(
      t,
      v.MEMBER_STATUS
    ), p = (m == null ? void 0 : m.toLowerCase()) === ye.SECURITY_ADMIN.toLowerCase();
    if (u == 1 && p) {
      const y = await l.getFromStorage(
        t,
        v.ORG_MEMBER_ID
      ), g = await Mt(
        c,
        t,
        n,
        y,
        l
      );
      await et.transferUserAccountRecovery(
        t,
        g,
        a,
        s.transactionId,
        o,
        i,
        l,
        d
      );
    }
  }
  static async finalizeInitiateLockBoxTransfer(t, s, n, a, o, i, c, l, d) {
    const u = await l.decryptAsymmetric(
      s.minimumApprovalCount,
      a,
      s.minimumApprovalCount_kek,
      o
    ), m = await l.getFromStorage(
      t,
      v.MEMBER_STATUS
    ), p = (m == null ? void 0 : m.toLowerCase()) === ye.SECURITY_ADMIN.toLowerCase();
    if (u == 1 && p) {
      const y = await l.getFromStorage(
        t,
        v.ORG_MEMBER_ID
      ), g = await Mt(
        c,
        t,
        n,
        y,
        l
      );
      return await et.transferMemberPrivateKey(
        t,
        s,
        g,
        a,
        s.transactionId,
        n,
        o,
        i,
        l,
        d
      );
    }
  }
  static async transferMemberPrivateKey(t, s, n, a, o, i, c, l, d, u) {
    try {
      const m = await Be.getMemberPublicKey(
        c,
        s.targetOrgMemberId
      );
      await d.verifyMemberPublicKey(
        t,
        m.publicKey,
        gt.TRANSACTION,
        m.trustedMemberPublicKeySignature,
        c,
        s.targetOrgMemberId,
        s.targetMemberStatus,
        null,
        null
        // null,
      );
      const p = await we.getBackdoorMemberPrivateKey({
        transactionId: o,
        lmsTransactionKey: l
      });
      await d.verifyMemberPublicKey(
        t,
        p.memberPublicKey,
        gt.TRANSACTION,
        null,
        c,
        s.sourceOrgMemberId,
        s.sourceMemberStatus,
        null,
        null
        // null,
      ), await d.verifyMessageForPublicKeyTag(
        t,
        p.backdoorMemberPrivateKey_kek,
        p.memberPublicKey.split(
          Ne
        )[0],
        d.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
      );
      const y = await d.decryptAsymmetric(
        p.backdoorMemberPrivateKey,
        n,
        p.backdoorMemberPrivateKey_kek.split(
          Ne
        )[0],
        s.sourceOrgMemberId
      ), g = await d.encryptAsymmetric(
        y,
        m.publicKey,
        s.targetOrgMemberId
      ), w = await d.aeadEncryptWithAssociatedData(
        $.APPROVED,
        "lms" + c,
        l
      ), h = await d.getFromStorage(
        t,
        v.ORG_MEMBER_ID
      ), M = await d.signData(
        o,
        a,
        d.context.getTransactionIdContext(o, $.APPROVED, be.TRANSFER_LOCK_BOX, c, h)
      );
      u = await d.appendSignatureAndMetadata(
        u,
        M,
        d.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        d.context.getTransactionIdContext(o, $.APPROVED, be.TRANSFER_LOCK_BOX, c, h)
      );
      let x = g.keyEncryptionKey;
      const T = tt.getContextForTransferredMemberPrivateKeyKek(
        o
      ), R = await d.signData(
        x,
        a,
        T
      );
      x = await d.appendSignatureAndMetadata(
        x,
        R,
        Or,
        T
      );
      const D = await d.getFromStorage(
        t,
        v.MEMBER_ID
      );
      if (!D)
        throw new Error("Member ID not found");
      let U = m.trustedMemberPublicKeySignature;
      if (!U) {
        const N = await d.context.getMemberPublicKeyContext(
          c,
          s.targetOrgMemberId
        );
        U = await d.signDataAndAppendSignatureWithMetadata(
          m.publicKey,
          i,
          N,
          d.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
        );
      }
      return await we.transferMemberPrivateKey({
        transactionId: o,
        transferredMemberPrivateKey: g.encryptedText,
        transferredMemberPrivateKey_kek: x,
        lmsTransactionKey: l,
        transactionStatus: w,
        signingMemberId: D,
        trusteeSignedMemberPublicKey: U,
        signedTransactionId: u
      });
    } catch (m) {
      throw console.error("Error transferring member private key:", m), m;
    }
  }
  static async transferUserAccountRecovery(t, s, n, a, o, i, c, l) {
    try {
      const {
        targetUserIdForUserAccountRecovery: d,
        targetUserEmailForUserAccountRecovery: u,
        userAuthSalt: m,
        userKeySalt: p,
        targetUserPassphrase: y,
        targetUserPassphrase_kek: g
      } = await we.getUserAccountRecoveryAuthSaltDetailsForTransactionId(
        a
      ), w = m || c.generateBCryptSalt(), h = p || c.generateBCryptSalt(), M = await we.getAllMembersBackdoorEncryptedPrivateKeys(
        a
      ), x = await c.generateAndExportEccKeyPair(), T = x.publicKey, R = x.privateKey, D = await c.generateAesKey(), U = ns(
        c,
        D
      ), q = await c.context.getUserPublicKeyContext(u), N = await c.signData(
        T,
        R,
        q
      ), P = await c.appendSignatureAndMetadata(
        T,
        N,
        c.signingPublicKeyTags.USER_PUBLIC_KEY_TAG,
        q
      ), Y = await c.encryptAsymmetric(
        U,
        T,
        d
      );
      let re = Y.encryptedText;
      const J = await c.context.getUserKeyKekContext(t), le = await c.signData(
        Y.keyEncryptionKey,
        R,
        J
      );
      let Q = await c.appendSignatureAndMetadata(
        Y.keyEncryptionKey,
        le,
        c.signingPublicKeyTags.USER_PUBLIC_KEY_TAG,
        J
      );
      const de = [];
      for (const H of M) {
        await c.verifyMemberPublicKey(
          t,
          H.memberPublicKey,
          gt.RECOVER_USER,
          null,
          o,
          H.orgMemberId,
          H.memberStatus,
          H.appPublicKey,
          null
          // null,
        ), await c.verifyMessageForPublicKeyTag(
          t,
          H.backdoorMemberPrivateKey_kek,
          H.memberPublicKey.split(Ne)[0],
          c.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
        );
        const V = await c.decryptAsymmetric(
          H.backdoorMemberPrivateKey,
          s,
          H.backdoorMemberPrivateKey_kek.split(Ne)[0],
          H.orgMemberId
        ), F = await c.encryptAsymmetric(
          V,
          T,
          d
        ), _ = await c.context.getUserPrivateKeyOuterKekContext(
          u
        ), B = await c.signData(
          F.keyEncryptionKey,
          R,
          _
        ), oe = await c.appendSignatureAndMetadata(
          F.keyEncryptionKey,
          B,
          c.signingPublicKeyTags.USER_PUBLIC_KEY_TAG,
          _
        );
        de.push({
          orgMemberId: H.orgMemberId,
          recoveredMemberPrivateKey: F.encryptedText,
          recoveredMemberPrivateKey_kek: oe
        });
      }
      const te = await c.getFromStorage(
        t,
        v.ADMIN_PUBLIC_KEY
      );
      if (!te)
        throw new Error("Admin public key not found");
      if (!await c.verifyMessageForPublicKeyTag(
        t,
        g,
        te,
        c.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG
      ))
        throw new Error(
          "Signature verification failed for target user passphrase kek"
        );
      const K = await c.decryptAsymmetric(
        y,
        n,
        g.split(Ne)[0],
        u
      ), X = await c.aeadEncryptWithPasscode(
        R,
        K,
        h,
        d
      ), I = await c.derivePbkdf2Encoded(
        K,
        w
      ), f = await c.aeadEncryptWithAssociatedData(
        $.APPROVED,
        "lms" + o,
        i
      ), j = await c.getFromStorage(
        t,
        v.ORG_MEMBER_ID
      ), C = await c.signData(
        a,
        n,
        c.context.getTransactionIdContext(a, $.APPROVED, be.RECOVER_USER, o, j)
      );
      l = await c.appendSignatureAndMetadata(
        l,
        C,
        c.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        c.context.getTransactionIdContext(a, $.APPROVED, be.RECOVER_USER, o, j)
      );
      const k = await c.getFromStorage(
        t,
        v.MEMBER_ID
      );
      if (!k)
        throw new Error("Member ID not found");
      await we.completeUserAccountRecovery({
        transactionId: a,
        targetUserId: d,
        recoveredUserPublicKey: P,
        recoveredUserPrivateKey: X,
        authPassphraseHash: I,
        recoveredUserKey: re,
        recoveredUserKey_kek: Q,
        recoveredMemberPrivateKeys: de,
        lmsTransactionKey: i,
        transactionStatus: f,
        signedTransactionId: l,
        signingMemberId: k,
        userAuthSalt: w,
        userKeySalt: h
      });
    } catch (d) {
      throw console.error("Error in transferUserAccountRecovery:", d), d;
    }
  }
  /**
   * Get member approval data for transactions
   * Handles SECURITY_ADMIN role check and prepares encryption keys and backdoor private key parts
   *
   * @param sessionId - Session ID for storage access
   * @param memberPrivateKey - Member's private key
   * @param adminPrivateKey - Admin's private key
   * @param internal - Bayun internal API
   * @returns Promise<{error: boolean, symmetricEncryptedBackdoorPrivateKeyPart: string | null, transactionEncryptionKeyRequests: BackendTransactionEncryptionKeyRequest[] | null}>
   */
  static async getMemberApproval(t, s, n, a) {
    try {
      const o = await a.getFromStorage(
        t,
        v.MEMBER_STATUS
      ), i = await a.getFromStorage(
        t,
        v.ORG_NAME
      );
      if (!i)
        throw new Error("Org name not found");
      if (!((o == null ? void 0 : o.toLowerCase()) === ye.SECURITY_ADMIN.toLowerCase()))
        return {
          error: !1,
          symmetricEncryptedBackdoorPrivateKeyPart: null,
          transactionEncryptionKeyRequests: null
        };
      const l = O("baseURL");
      if (!l)
        throw new Error("Base URL not found in cookies");
      const d = await a.generateAesKey(), u = await rt(
        t,
        i,
        a
      );
      if (!u || u.length === 0)
        return {
          error: !0,
          symmetricEncryptedBackdoorPrivateKeyPart: null,
          transactionEncryptionKeyRequests: null
        };
      const m = await pt(
        d,
        u,
        n,
        s,
        i,
        a
      );
      return {
        error: !1,
        symmetricEncryptedBackdoorPrivateKeyPart: await We(
          t,
          l,
          s,
          null,
          // transactionId is null for new transactions
          d,
          a
        ),
        transactionEncryptionKeyRequests: m
      };
    } catch (o) {
      return console.error("Error getting member approval:", o), {
        error: !0,
        symmetricEncryptedBackdoorPrivateKeyPart: null,
        transactionEncryptionKeyRequests: null
      };
    }
  }
}
async function pt(r, t, s, n, a, o) {
  const i = ns(
    o,
    r
  ), c = [];
  for (const l of t) {
    const d = l.orgMemberId, u = l.memberPublicKey;
    let m = null, p = null;
    try {
      const y = await o.encryptAsymmetric(
        i,
        u,
        d
      );
      if (y) {
        m = y.encryptedText, p = y.keyEncryptionKey;
        const g = await o.signData(
          p,
          s,
          tt.getContextForTransactionEncryptionKeyKek(
            a,
            d
          )
        );
        p = await o.appendSignatureAndMetadata(
          p,
          g,
          Or,
          tt.getContextForTransactionEncryptionKeyKek(
            a,
            d
          )
        );
        let w = null;
        l.trustedMemberPublicKeySignature || (w = await o.signDataAndAppendSignatureWithMetadata(
          l.memberPublicKey,
          n,
          await o.context.getMemberPublicKeyContext(
            a,
            l.orgMemberId
          ),
          o.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
        )), c.push({
          transactionEncryptionKey: m,
          transactionEncryptionKey_kek: p,
          orgMemberId: d,
          trusteeSignedMemberPublicKey: w || ""
        });
      }
    } catch (y) {
      throw console.error(
        `Error processing encryption for member ${d}:`,
        y
      ), y;
    }
  }
  return c;
}
async function We(r, t, s, n, a, o) {
  var i;
  try {
    const c = await o.getFromStorage(
      r,
      v.ORG_MEMBER_ID
    );
    let l = null;
    if (a != null && n == null)
      l = a;
    else {
      let m;
      try {
        m = await we.getApprovalTransactionKeyDetail(n);
      } catch (p) {
        throw ee.isAxiosError(p) && ((i = p.response) == null ? void 0 : i.status) === 404 ? new Error(
          "No approval transaction key detail found for transactionId: " + n
        ) : p;
      }
      if (!await o.retrieveAndverifyLastSignature(
        r,
        m.transactionEncryptionKey_kek
      ))
        throw new Error(
          "Transaction encryption key kek part signature verification failed"
        );
      l = await o.decryptAsymmetric(
        m.transactionEncryptionKey,
        s,
        m.transactionEncryptionKey_kek,
        c
      );
    }
    const d = await Mt(
      t,
      r,
      s,
      c,
      o
    );
    return await o.aeadEncryptWithAssociatedData(
      d,
      c,
      l
    );
  } catch (c) {
    throw console.error(
      "Error getting symmetric key encrypted backdoor private key part:",
      c
    ), c;
  }
}
async function Mt(r, t, s, n, a) {
  try {
    const o = await we.getBackdoorPrivateKeyPart(), { backdoorPrivateKeyPart: i, backdoorPrivateKeyPart_kek: c } = o;
    if (!await a.retrieveAndverifyLastSignature(
      t,
      c
    ))
      throw new Error(
        "Backdoor private key kek part signature verification failed"
      );
    const l = await a.decryptAsymmetric(
      i,
      s,
      c,
      n
    );
    if (!l)
      throw new Error("Failed to decrypt backdoor private key part");
    return l;
  } catch (o) {
    throw console.error("Error getting decrypted backdoor private key part:", o), o;
  }
}
async function rt(r, t, s) {
  try {
    const n = await we.getSecurityAdminPublicKeys(), a = n.securityAdminMemberPublicKeys, o = n.backdoorPublicKey;
    if (!await s.retrieveAndverifyLastSignature(
      r,
      o
    ))
      throw new Error("Backdoor public key signature verification failed");
    for (const i of a) {
      if (!await s.retrieveAndverifyLastSignature(
        r,
        i.memberId
      ))
        throw console.error("Member ID signature verification failed"), new Error("Member ID signature verification failed");
      i.memberId = i.memberId.split("$")[0], await s.verifyMemberPublicKey(
        r,
        i.memberPublicKey,
        gt.TRANSACTION,
        i.trustedMemberPublicKeySignature,
        t,
        i.orgMemberId,
        ye.SECURITY_ADMIN,
        null,
        o.split(Ne)[0]
        // null,
      ), i.memberPublicKey = i.memberPublicKey.split("$")[0];
    }
    return a;
  } catch (n) {
    throw console.error(
      "Error fetching and verifying security admin member public keys:",
      n
    ), n;
  }
}
async function $r(r, t, s, n, a, o, i, c) {
  const l = [], d = t.length, u = await c.getFromStorage(
    r,
    v.ADMIN_PUBLIC_KEY
  );
  try {
    if (i > 1) {
      const m = await c.splitUsingSSSDynamic(
        s,
        d,
        i
      );
      for (let p = 0; p < d; p++) {
        const y = t[p], g = m.get(
          `${p + 1}`
        ), w = y.orgMemberId, h = await c.encryptAsymmetric(
          await c.convertArrayBufferToBase64String(
            g
          ),
          y.memberPublicKey,
          w
        );
        if (!h)
          throw new Error(
            `Failed to encrypt backdoor private key part for member ${w}`
          );
        let M = h.encryptedText, x = h.keyEncryptionKey;
        const T = await c.signData(
          x,
          n,
          await c.context.getBackdoorPrivateKeyPartKekContext(
            o,
            w
          )
        );
        x = await c.appendSignatureAndMetadata(
          x,
          T,
          c.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          await c.context.getBackdoorPrivateKeyPartKekContext(
            o,
            w
          )
        );
        const R = o + w, D = await c.encryptAsymmetric(
          String(p + 1),
          u,
          R
        );
        if (!D)
          throw new Error(`Failed to encrypt index for member ${w}`);
        let U = null;
        if (!y.trustedMemberPublicKeySignature || y.trustedMemberPublicKeySignature.trim() === "") {
          const q = await c.context.getMemberPublicKeyContext(
            o,
            y.orgMemberId
          );
          U = await c.signDataAndAppendSignatureWithMetadata(
            y.memberPublicKey,
            a,
            q,
            c.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
          );
        } else
          U = y.trustedMemberPublicKeySignature;
        l.push({
          backdoorPrivateKeyPart: M,
          backdoorPrivateKeyPart_kek: x,
          orgMemberId: w,
          index: D.encryptedText,
          index_kek: D.keyEncryptionKey,
          trusteeSignedMemberPublicKey: U
        });
      }
    } else
      for (let m = 0; m < d; m++) {
        const p = t[m], y = p.orgMemberId, g = await c.encryptAsymmetric(
          s,
          p.memberPublicKey,
          y
        );
        if (!g)
          throw new Error(
            `Failed to encrypt backdoor private key for member ${y}`
          );
        const w = o + y, h = await c.encryptAsymmetric(
          String(m + 1),
          u,
          w
        );
        if (!h)
          throw new Error(`Failed to encrypt index for member ${y}`);
        let M = null;
        if (!p.trustedMemberPublicKeySignature || p.trustedMemberPublicKeySignature.trim() === "") {
          const R = await c.context.getMemberPublicKeyContext(
            o,
            p.orgMemberId
          );
          M = await c.signDataAndAppendSignatureWithMetadata(
            p.memberPublicKey,
            a,
            R,
            c.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
          );
        } else
          M = p.trustedMemberPublicKeySignature;
        let x = g.keyEncryptionKey;
        const T = await c.signData(
          x,
          n,
          await c.context.getBackdoorPrivateKeyPartKekContext(
            o,
            y
          )
        );
        x = await c.appendSignatureAndMetadata(
          x,
          T,
          c.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          await c.context.getBackdoorPrivateKeyPartKekContext(
            o,
            y
          )
        ), l.push({
          backdoorPrivateKeyPart: g.encryptedText,
          backdoorPrivateKeyPart_kek: x,
          orgMemberId: y,
          index: h.encryptedText,
          index_kek: h.keyEncryptionKey,
          trusteeSignedMemberPublicKey: M
        });
      }
    return l;
  } catch (m) {
    throw console.error("Error getting encrypted backdoor private key parts:", m), m;
  }
}
async function $t(r, t, s, n, a, o, i, c, l, d, u, m, p) {
  const y = ue();
  if (!y)
    throw new Error("Internal not found");
  const g = Number(d) + 1, w = await y.decryptAsymmetric(
    t.minimumApprovalCount,
    u,
    t.minimumApprovalCount_kek,
    l
  );
  let h = "";
  if (t.newMinimumApprovalCount && t.newMinimumApprovalCount.trim() !== "" && (h = await y.decryptAsymmetric(
    t.newMinimumApprovalCount,
    u,
    t.newMinimumApprovalCount_kek,
    l
  )), w == g) {
    const M = await we.getAllBackdoorPrivateKeyParts(s);
    if (M.length === 0)
      throw new Error("No backdoor private key parts found for transaction");
    let x;
    if (M.length === 1 ? x = await y.aeadDecryptWithAssociatedData(
      M[0].backdoorPrivateKeyPart,
      M[0].orgMemberId,
      o
    ) : x = await dc(
      r,
      i,
      M,
      s,
      c,
      u,
      l
    ), !await y.getFromStorage(
      r,
      v.ADMIN_PUBLIC_KEY
    ))
      throw new Error("Admin public key not found");
    if (p == be.PROMOTE_ADMIN) {
      await ut.promoteAdmin(
        r,
        t.targetOrgMemberId,
        x,
        s,
        h,
        w,
        n,
        u,
        i,
        y,
        m
      );
      return;
    } else if (p == be.DEMOTE_SECURITY_ADMIN) {
      await ut.demoteSecurityAdmin(
        r,
        t.targetOrgMemberId,
        x,
        s,
        h,
        w,
        n,
        u,
        i,
        y,
        m
      );
      return;
    } else if (p == be.EDIT_MINIMUM_APPROVAL_COUNT) {
      await Bn(
        r,
        x,
        s,
        Number(h),
        n,
        u,
        i,
        y,
        m
      );
      return;
    } else if (p == be.ADD_GROUP_PARTICIPANT) {
      await Tt.addGroupParticipant(
        r,
        t,
        x,
        a,
        i,
        u,
        l,
        y,
        m
      );
      return;
    } else if (p == be.TRANSFER_LOCK_BOX) {
      await et.transferMemberPrivateKey(
        r,
        t,
        x,
        u,
        s,
        i,
        l,
        a,
        y,
        m
      );
      return;
    } else if (p == be.RECOVER_USER) {
      await et.transferUserAccountRecovery(
        r,
        x,
        u,
        s,
        l,
        a,
        y,
        m
      );
      return;
    } else
      throw new Error("Invalid transaction label");
  }
}
async function dc(r, t, s, n, a, o, i) {
  const c = ue();
  if (!c)
    throw new Error("Internal not found");
  const l = await we.getApprovalTransactionKeyDetail(n);
  let d = "";
  if (l) {
    if (!await c.retrieveAndverifyLastSignature(
      r,
      l.transactionEncryptionKey_kek
    ))
      throw new Error(
        "Transaction encryption key kek part signature verification failed"
      );
    d = await c.decryptAsymmetric(
      l.transactionEncryptionKey,
      t,
      l.transactionEncryptionKey_kek,
      a
    );
  }
  if (!d)
    throw new Error("Failed to decrypt transaction encryption key");
  const u = /* @__PURE__ */ new Map();
  for (let m = 0; m < s.length; m++) {
    const p = s[m], y = await c.aeadDecryptWithAssociatedData(
      p.backdoorPrivateKeyPart,
      p.orgMemberId,
      d
    );
    let g;
    y ? g = await c.convertBase64StringToArrayBuffer(y) : g = new ArrayBuffer(0);
    const w = i + p.orgMemberId, h = await c.decryptAsymmetric(
      p.index,
      o,
      p.index_kek,
      w
    ), M = parseInt(h, 10);
    u.set(
      M,
      new Uint8Array(g)
    );
  }
  try {
    const m = await c.joinUsingSSS(
      u
    );
    if (!m)
      throw new Error("Failed to combine backdoor private key parts");
    return m.trim();
  } catch (m) {
    throw new Error(
      `Failed to combine backdoor private key parts: ${m instanceof Error ? m.message : String(m)}`
    );
  }
}
async function uc(r, t, s, n, a, o, i, c) {
  try {
    const l = await i.decryptAsymmetric(
      t.minimumApprovalCount,
      a,
      t.minimumApprovalCount_kek,
      n
    ), d = await i.decryptAsymmetric(
      t.newMinimumApprovalCount,
      a,
      t.newMinimumApprovalCount_kek,
      n
    );
    if (l == 1) {
      const u = await i.getFromStorage(
        r,
        v.ORG_MEMBER_ID
      ), m = await Mt(
        o,
        r,
        s,
        u,
        i
      ), p = await Ce(i, r);
      await Bn(
        r,
        m,
        t.transactionId,
        d,
        p,
        a,
        s,
        i,
        c
      );
    }
  } catch (l) {
    throw console.error(
      "Error finalizing edit minimum approval count transaction:",
      l
    ), l;
  }
}
async function Bn(r, t, s, n, a, o, i, c, l) {
  try {
    const d = await c.getFromStorage(
      r,
      v.ORG_NAME
    );
    if (!d)
      throw new Error("Org name not found");
    const u = typeof a == "string" ? c.asRawKey(a) : a;
    if (!u)
      throw new Error("Org key not found or invalid");
    const m = await rt(
      r,
      d,
      c
    );
    if (!m || m.length === 0)
      throw new Error("No security admin public keys found");
    const p = await $r(
      r,
      m,
      t,
      o,
      i,
      d,
      n,
      c
    ), y = await c.generateHMacHash(
      u,
      "lms" + d
    ), g = await c.aeadEncryptWithAssociatedData(
      $.COMPLETED,
      "lms" + d,
      y
    ), w = await c.getFromStorage(
      r,
      v.ORG_MEMBER_ID
    ), h = await c.signData(
      s,
      o,
      c.context.getTransactionIdContext(s, $.COMPLETED, be.EDIT_MINIMUM_APPROVAL_COUNT, d, w)
    );
    l = await c.appendSignatureAndMetadata(
      l,
      h,
      c.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      c.context.getTransactionIdContext(s, $.COMPLETED, be.EDIT_MINIMUM_APPROVAL_COUNT, d, w)
    );
    const M = await c.aeadEncryptWithAssociatedData(
      String(n),
      d,
      u
    ), x = await c.getFromStorage(
      r,
      v.MEMBER_ID
    );
    if (!x)
      throw new Error("Member ID not found");
    const { signedSettings: T, settingLastUpdatedAt: R } = await Hr(
      r,
      c,
      o,
      n
    );
    await we.completeEditMinimumApprovalCount({
      transactionId: s,
      backdoorPrivateKeyPartsRequest: p,
      lmsTransactionKey: y,
      transactionStatus: g,
      newMinimumApprovalCount: M,
      signingMemberId: x,
      signedTransactionId: l,
      signedSettings: T,
      settingLastUpdatedAt: R
    }), console.log(
      "Edit minimum approval count transaction completed successfully"
    );
  } catch (d) {
    throw console.error(
      "Error completing edit minimum approval count transaction:",
      d
    ), d;
  }
}
class xt {
  /**
   * Fetch application list for a specific member
   */
  static async fetchApplicationList() {
    try {
      return (await ee.get(
        O("baseURL") + "lms/admin/applicationList"
      )).data;
    } catch (t) {
      throw t;
    }
  }
  /**
   * Get all org applications (from orgApplicationResponse)
   */
  static async getAllOrgApplications() {
    try {
      return (await this.fetchApplicationList()).orgApplicationResponse || [];
    } catch (t) {
      throw t;
    }
  }
  /**
   * Get member-specific applications (from applicationResponse)
   */
  static async getMemberApplications() {
    try {
      return (await this.fetchApplicationList()).applicationResponse || [];
    } catch (t) {
      throw t;
    }
  }
  /**
   * Approve an application
   */
  static async approveOrgApplication(t) {
    try {
      await ee.post(
        O("baseURL") + "lms/admin/updateOrgApplicationStatus",
        {
          appId: t,
          status: "Approved"
        }
      );
    } catch (s) {
      throw s;
    }
  }
  /**
   * Get member apps for two-factor authentication
   */
  static async getMemberApps() {
    try {
      return (await ee.get(
        O("baseURL") + "lms/admin/twofa/memberApps"
      )).data;
    } catch (t) {
      throw t;
    }
  }
  /**
   * Link an application
   */
  static async linkApplication(t, s, n, a, o, i, c, l, d, u, m, p) {
    try {
      const y = {
        appId: t,
        memberAppId: n,
        memberAppLockBoxRequest: {
          memberAppId: s,
          memberPrivateKey: a,
          memberPrivateKeyInner_kek: o,
          memberPrivateKeyOuter_kek: i
        },
        adminEncryptedStatisticsKey: c,
        adminEncryptedStatisticsKey_kek: l,
        lmsEncryptedStatisticsKey: d,
        signedMemberAppPublicKey: u,
        encryptionCount: m,
        decryptionCount: p
      };
      await ee.post(
        O("baseURL") + "lms/admin/linkApplication",
        y
      );
    } catch (y) {
      throw y;
    }
  }
  /**
   * Reject an application
   */
  static async rejectOrgApplication(t) {
    try {
      await ee.post(
        O("baseURL") + "lms/admin/updateOrgApplicationStatus",
        {
          appId: t,
          status: "Rejected"
        }
      );
    } catch (s) {
      throw s;
    }
  }
}
class we {
  // ========== Pure HTTP API Methods (used internally and by TransactionService) ==========
  static normalizeApprovalTransactionStatus(t) {
    const { signedTransactionID: s, signed_transaction_id: n, ...a } = t, o = String(a.transactionId || ""), i = a.signedTransactionId || s || n || (o.includes(Ne) ? o : "");
    return {
      ...a,
      transactionId: o.includes(Ne) ? o.split(Ne)[0] : o,
      signedTransactionId: i
    };
  }
  static async getEncryptedMemberPrivateKey(t, s, n, a, o, i) {
    const c = await ue();
    let l = "", d = null, u = null;
    if (a === Ze.TWO_FACTOR_AUTHENTICATION_WITH_PASSPHRASE || a === Ze.TWO_FACTOR_AUTHENTICATION_WITHOUT_PASSPHRASE) {
      const m = await c.encryptAsymmetric(
        t,
        n,
        i
      );
      if (l = m.encryptedText, d = m.keyEncryptionKey, !s || !o)
        throw new Error(
          "User credentials missing for member private key encryption"
        );
      const p = await c.encryptAsymmetric(
        l,
        s,
        o
      );
      l = p.encryptedText, u = p.keyEncryptionKey;
    } else if (a === Ze.SINGLE_FA_WITH_PASSCODE) {
      const m = await c.encryptAsymmetric(
        t,
        n,
        i
      );
      l = m.encryptedText, d = m.keyEncryptionKey;
    } else {
      if (!s || !o)
        throw new Error(
          "User credentials missing for member private key encryption"
        );
      const m = await c.encryptAsymmetric(
        t,
        s,
        o
      );
      l = m.encryptedText, u = m.keyEncryptionKey;
    }
    return {
      encryptedMemberPrivateKey: l,
      memberPrivateKeyInnerDEK: d,
      memberPrivateKeyOuterDEK: u
    };
  }
  /**
   * Get admin sensitive data (admin private key and KEK)
   * Pure API call - no decryption or verification
   */
  static async getAdminSensitiveData() {
    const t = O("baseURL");
    if (!t)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${t}lms/admin/adminSensitiveData`
    )).data;
  }
  /**
   * Initiate a transaction on the server and get a transactionId.
   * Matches backend: GET /admin/initiateTransaction
   */
  static async initiateTransaction() {
    const t = O("baseURL");
    if (!t)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${t}lms/admin/initiateTransaction`
    )).data;
  }
  /**
   * Get minimum approval count
   * Pure API call
   */
  static async getMinimumApprovalCount() {
    const t = O("baseURL");
    if (!t)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${t}lms/admin/minimumApprovalCount`
    )).data;
  }
  /**
   * Get security admin member public keys
   * Pure API call - no verification
   */
  static async getSecurityAdminPublicKeys() {
    const t = O("baseURL");
    if (!t)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${t}lms/admin/securityAdminMemberPublicKeys`
    )).data;
  }
  /**
   * Get backdoor private key part for member
   * Pure API call - no decryption or verification
   */
  static async getBackdoorPrivateKeyPart() {
    const t = O("baseURL");
    if (!t)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${t}lms/admin/backdoorPrivateKeyPartForMember`
    )).data;
  }
  /**
   * Get backdoor member private key for lockbox transfer
   */
  static async getBackdoorMemberPrivateKey(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.post(
      `${s}lms/admin/backdoorMemberPrivateKey`,
      t
    )).data;
  }
  static async getAllMembersBackdoorEncryptedPrivateKeys(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${s}lms/admin/userAllMembersBackdoorEncryptedPrivateKeys`,
      { params: { transactionId: t } }
    )).data || [];
  }
  /**
   * Transfer member private key for lockbox transfer transaction
   * Pure API call - no decryption or verification
   */
  static async transferMemberPrivateKey(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    await ee.post(`${s}lms/admin/transferMemberPrivateKey`, t);
  }
  /**
   * Get transferred member private key by transaction id.
   */
  static async getTransferredMemberPrivateKey(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${s}lms/admin/transferredMemberPrivateKey`,
      { params: { transactionId: t } }
    )).data;
  }
  /**
   * Complete lockbox transfer by target owner acceptance.
   * Uses admin endpoint that accepts transaction id, source owner id, and optional passcode.
   */
  static async completeLockBoxTransfer(t) {
    var K, X;
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    const n = ue();
    if (!n)
      throw new Error("Internal not found");
    const a = O("bayunSessionId");
    if (!a)
      throw new Error("Session ID not found in cookies");
    const o = t.sourceOrgMemberId || t.sourceCompanyMemberId;
    if (!o)
      throw new Error("Source org member id is required");
    const i = await n.getFromStorage(
      a,
      v.MEMBER_PRIVATE_KEY
    ), c = await xt.getMemberApps();
    for (const I of c.memberApps || []) {
      if (!await n.retrieveAndverifyLastSignature(
        a,
        I.memberAppId
      ))
        throw new Error("Member app id signature verification failed");
      I.memberAppId = I.memberAppId.split(Ne)[0];
    }
    const l = [], d = await we.getTransferredMemberPrivateKey(
      t.transactionId
    ), u = await n.getFromStorage(
      a,
      v.ADMIN_PUBLIC_KEY
    );
    if (!u)
      throw new Error("Admin public key not found");
    if (!await n.verifyMessageForPublicKeyTag(
      a,
      d.transferredMemberPrivateKey_kek,
      u,
      n.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG
    ))
      throw new Error(
        "Signature verification failed for transferred member private key kek"
      );
    d.transferredMemberPrivateKey_kek = d.transferredMemberPrivateKey_kek.split(
      Ne
    )[0];
    const m = await n.getFromStorage(
      a,
      v.ORG_MEMBER_ID
    );
    if (!m)
      throw new Error("Org member id not found");
    const p = await n.decryptAsymmetric(
      d.transferredMemberPrivateKey,
      i,
      d.transferredMemberPrivateKey_kek,
      m
    ), y = await n.getFromStorage(
      a,
      v.USER_ID
    ), g = await n.getFromStorage(
      a,
      v.EMAIL_ADDRESS
    ), w = await n.getFromStorage(
      a,
      v.USER_PUBLIC_KEY
    ), h = await n.getFromStorage(
      a,
      v.USER_PRIVATE_KEY
    );
    let M = null, x = null;
    if (g && y && w && h) {
      const I = await n.encryptAsymmetric(
        p,
        w,
        y
      );
      M = I.encryptedText, x = I.keyEncryptionKey;
      const f = tt.getContextForMemberPrivateKeyOuterKek(g), j = await n.signData(
        x,
        h,
        f
      );
      x = await n.appendSignatureAndMetadata(
        x,
        j,
        n.signingPublicKeyTags.USER_PUBLIC_KEY_TAG,
        f
      );
    }
    let T = null;
    const R = t.passcode || "", D = (K = c.memberSalts) == null ? void 0 : K.memberAuthSalt, U = (X = c.memberSalts) == null ? void 0 : X.memberKeySalt, q = await n.getFromStorage(
      a,
      v.ORG_NAME
    ), N = await n.getFromStorage(
      a,
      v.MULTI_FACTOR_AUTH
    );
    if (R.length > 1 && D) {
      T = await n.derivePbkdf2Encoded(
        R,
        D
      );
      for (const I of c.memberApps || []) {
        if (!I.isCreatedWithPasscode) continue;
        let f = null, j = null, C = null;
        const k = await n.generateAndExportEccKeyPair(), H = await n.aeadEncryptWithPasscode(
          k.privateKey,
          R,
          U,
          o
        ), V = Zs + dt + q + o + I.appId, F = await n.signData(
          k.publicKey.trim(),
          k.privateKey.trim(),
          V
        );
        let _ = await n.appendSignatureAndMetadata(
          k.publicKey,
          F,
          n.signingPublicKeyTags.MEMBER_APP_PUBLIC_KEY_TAG,
          V
        );
        const B = tt.getContextForMemberAppPublicKeyLayer3(
          q,
          o,
          I.appId,
          F
        ), oe = await n.signData(
          k.publicKey,
          p,
          B
        );
        if (_ = await n.appendSignatureAndMetadata(
          _,
          oe,
          n.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG,
          B
        ), N !== Ze.SINGLE_FA_WITH_SECURITY_QUESTIONS && N !== Ze.SINGLE_FA_WITH_SECURITY_QUESTIONS_AND_PASSPHRASE) {
          const fe = await we.getEncryptedMemberPrivateKey(
            p,
            w,
            k.publicKey,
            N,
            y,
            o
          );
          if (C = fe.encryptedMemberPrivateKey, f = fe.memberPrivateKeyInnerDEK, j = fe.memberPrivateKeyOuterDEK, f) {
            const G = tt.getContextForMemberPrivateKeyInnerKek(
              q,
              o,
              I.appId
            ), ne = await n.signData(
              f,
              p,
              G
            );
            f = await n.appendSignatureAndMetadata(
              f,
              ne,
              n.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG,
              G
            );
          }
          if (j) {
            if (!g || !h)
              throw new Error(
                "User credentials missing for outer KEK signature"
              );
            const G = tt.getContextForMemberPrivateKeyOuterKek(g), ne = await n.signData(
              j,
              h,
              G
            );
            j = await n.appendSignatureAndMetadata(
              j,
              ne,
              n.signingPublicKeyTags.USER_PUBLIC_KEY_TAG,
              G
            );
          }
        }
        l.push({
          memberAppId: I.memberAppId,
          memberPrivateKey: C || "",
          memberPrivateKeyInner_kek: f,
          memberPrivateKeyOuter_kek: j,
          memberAppKeyPairRequest: {
            privateKey: H,
            publicKey: _
          }
        });
      }
    }
    const P = await Ce(n, a), Y = await n.generateHMacHash(
      P,
      "lms" + q
    ), re = await n.getFromStorage(
      a,
      v.MEMBER_STATUS
    );
    if (!await n.retrieveAndverifyLastSignature(
      a,
      t.signedTransactionId
    ))
      throw new Error("Signed transaction ID verification failed");
    let J = null;
    (re === ye.ADMIN || re === ye.SECURITY_ADMIN) && (J = await _e.getAdminPrivateKey());
    const le = await n.aeadEncryptWithAssociatedData(
      $.COMPLETED,
      "lms" + q,
      Y
    );
    let Q = null;
    J ? (Q = await n.signData(
      t.transactionId,
      J,
      n.context.getTransactionIdContext(
        t.transactionId,
        $.COMPLETED,
        be.TRANSFER_LOCK_BOX,
        q,
        m
      )
    ), Q = await n.appendSignatureAndMetadata(
      t.signedTransactionId,
      Q,
      n.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      n.context.getTransactionIdContext(
        t.transactionId,
        $.COMPLETED,
        be.TRANSFER_LOCK_BOX,
        q,
        m
      )
    )) : (Q = await n.signData(
      t.transactionId,
      i,
      n.context.getTransactionIdContext(
        t.transactionId,
        $.COMPLETED,
        be.TRANSFER_LOCK_BOX,
        q,
        m
      )
    ), Q = await n.appendSignatureAndMetadata(
      t.signedTransactionId,
      Q,
      n.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG,
      n.context.getTransactionIdContext(
        t.transactionId,
        $.COMPLETED,
        be.TRANSFER_LOCK_BOX,
        q,
        m
      )
    ));
    const de = {
      transactionId: t.transactionId,
      authPasscodeHash: T || "",
      transactionStatus: le,
      signedTransactionId: Q,
      lmsTransactionKey: Y,
      recreateMemberAppLockBoxRequests: l,
      encryptedMemberPrivateKeySSO: M || "",
      memberPrivateKeyOuterKeyKekSSO: x || ""
    }, te = await we.apiCompleteLockBoxTransfer(
      s,
      de
    );
    if (te.data && te.data.errorType)
      throw new Error(
        te.data.errorMessage || "Failed to complete lockbox transfer"
      );
    return te.data;
  }
  static async apiCompleteLockBoxTransfer(t, s) {
    return ee.post(
      `${t}lms/admin/completeLockBoxTransfer`,
      s
    );
  }
  /**
   * Initiate lockbox transfer transaction
   * Pure API call - no orchestration
   */
  static async initiateLockBoxTransferTransaction(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.post(
      `${s}lms/admin/initiateLockBoxTransfer`,
      t
    )).data;
  }
  static async initiateUserAccountRecoveryTransaction(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.post(
      `${s}lms/admin/initiateUserAccountRecovery`,
      t
    )).data;
  }
  static async completeUserAccountRecovery(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.post(
      `${s}lms/admin/completeUserAccountRecovery`,
      t
    )).data;
  }
  /**
   * Get server-generated salts for recovered user passphrase flow.
   */
  static async getUserRecoverySalts(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.post(
      `${s}lms/admin/userRecoverySalts`,
      t
    )).data;
  }
  /**
   * Get admin-encrypted target user passphrase details for recovery.
   */
  static async getUserAccountRecoveryPassphraseDetails(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.post(
      `${s}lms/admin/userAccountRecoveryPassphraseDetails`,
      t
    )).data;
  }
  /**
   * User recovery authentication salts/details for a transaction.
   * Matches backend:
   * GET /admin/userAccountRecoveryAuthSaltDetailsForTransactionId?transactionId=...
   */
  static async getUserAccountRecoveryAuthSaltDetailsForTransactionId(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${s}lms/admin/userAccountRecoveryAuthSaltDetailsForTransactionId`,
      { params: { transactionId: t } }
    )).data;
  }
  /**
   * Get all backdoor private key parts for a transaction
   * Pure API call - no decryption or verification
   */
  static async getAllBackdoorPrivateKeyParts(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${s}lms/admin/allBackdoorPrivateKeyParts`,
      { params: { transactionId: t } }
    )).data;
  }
  /**
   * Get approval transaction key detail for transaction ID
   * Pure API call - no decryption or verification
   */
  static async getApprovalTransactionKeyDetail(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    return (await ee.get(
      `${s}lms/admin/approvalTransactionKeyDetailForTransactionId`,
      { params: { transactionId: t } }
    )).data;
  }
  /**
   * Get approval transaction status
   * Pure API call - returns list of approval transaction statuses
   */
  static async getApprovalTransactionStatus(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    try {
      return ((await ee.post(
        `${s}lms/admin/approvalTransactionStatus`,
        {
          orgName: t.orgName,
          lmsTransactionKey: t.lmsTransactionKey
        }
      )).data || []).map(
        we.normalizeApprovalTransactionStatus
      );
    } catch (n) {
      throw console.error("Error fetching approval transaction status:", n), n;
    }
  }
  /**
   * Approve a transaction
   * Pure API call - approves a transaction with given parameters
   */
  static async approveTransaction(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    try {
      const n = {
        transactionId: t.transactionId,
        backdoorPrivateKeyPart: t.backdoorPrivateKeyPart,
        authPasscodeHash: t.authPasscodeHash,
        memberAppId: t.memberAppId,
        lmsTransactionKey: t.lmsTransactionKey,
        transactionEncryptionKeyRequestList: t.transactionEncryptionKeyRequestList,
        signedTransactionId: t.signedTransactionId
      };
      return t.currentApprovalCount !== void 0 && (n.currentApprovalCount = t.currentApprovalCount), t.minimumApprovalCount !== void 0 && (n.minimumApprovalCount = t.minimumApprovalCount), (await ee.post(
        `${s}lms/admin/approveTransaction`,
        n
      )).data;
    } catch (n) {
      throw console.error("Error approving transaction:", n), n;
    }
  }
  /**
   * Decline a transaction
   * Pure API call - declines a transaction with given parameters
   */
  static async declineTransaction(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    try {
      const n = await ee.post(
        `${s}lms/admin/declineTransaction`,
        {
          transactionId: t.transactionId,
          lmsTransactionKey: t.lmsTransactionKey,
          transactionStatus: t.transactionStatus,
          signedTransactionId: t.signedTransactionId
        }
      );
      if (n.data && n.data.errorType)
        throw new Error(
          n.data.errorMessage || "Failed to decline transaction"
        );
    } catch (n) {
      throw console.error("Error declining transaction:", n), n;
    }
  }
  /**
   * Initiate edit minimum approval count transaction
   * Pure API call - initiates a transaction to edit minimum approval count
   */
  static async initiateEditMinimumApprovalCount(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    try {
      return (await ee.post(
        `${s}lms/admin/initiateEditMinimumApprovalCount`,
        t
      )).data;
    } catch (n) {
      throw console.error(
        "Error initiating edit minimum approval count transaction:",
        n
      ), n;
    }
  }
  /**
   * Complete edit minimum approval count transaction
   * Pure API call - completes a transaction to edit minimum approval count
   */
  static async completeEditMinimumApprovalCount(t) {
    const s = O("baseURL");
    if (!s)
      throw new Error("Base URL not found in cookies");
    try {
      await ee.post(
        `${s}lms/admin/completeEditMinimumApprovalCount`,
        t
      );
    } catch (n) {
      throw console.error(
        "Error completing edit minimum approval count transaction:",
        n
      ), n;
    }
  }
  /**
   * Fetch all members for lockbox transfer
   * Pure HTTP call with error handling
   */
  static async getAllMembers() {
    try {
      const t = O("baseURL");
      if (!t)
        throw new Error("Base URL not found in cookies");
      return (await ee.get(
        `${t}lms/admin/getAllMembers`
      )).data || [];
    } catch (t) {
      throw console.error("Error fetching members for lockbox transfer:", t), new Error("Failed to load member data. Please try again.");
    }
  }
  /**
   * Fetch all user emails for user account recovery
   * Pure HTTP call with error handling
   */
  static async getAllUsers() {
    try {
      const t = O("baseURL");
      if (!t)
        throw new Error("Base URL not found in cookies");
      return (await ee.get(
        `${t}lms/admin/getAllUsers`
      )).data || [];
    } catch (t) {
      throw console.error("Error fetching users for account recovery:", t), new Error("Failed to load user emails. Please try again.");
    }
  }
  /**
   * Transfer lockbox ownership from one member to another
   * Delegates to TransactionService which handles orchestration
   */
  static async initiateLockBoxTransfer(t) {
    var s, n, a, o, i;
    try {
      await et.initiateLockBoxTransfer(t);
    } catch (c) {
      if (console.error("Error transferring lockbox ownership:", c), ee.isAxiosError(c)) {
        if (((s = c.response) == null ? void 0 : s.status) === 400)
          throw new Error(
            "Invalid request: Please check the provided member IDs"
          );
        if (((n = c.response) == null ? void 0 : n.status) === 403)
          throw new Error(
            "Access denied: You don't have permission to transfer lockbox ownership"
          );
        if (((a = c.response) == null ? void 0 : a.status) === 404)
          throw new Error("Member not found: One or both members don't exist");
        if (((o = c.response) == null ? void 0 : o.status) === 409)
          throw new Error(
            "Conflict: Lockbox transfer cannot be completed at this time"
          );
        if (((i = c.response) == null ? void 0 : i.status) >= 500)
          throw new Error("Server error: Please try again later");
      }
      throw new Error(
        "Failed to transfer lockbox ownership. Please try again."
      );
    }
  }
  /**
   * Initiate assisted user account recovery
   * Delegates to TransactionService (same orchestration pattern as lockbox transfer)
   */
  static async initiateUserAccountRecovery(t) {
    var s, n, a, o, i, c;
    try {
      return await et.initiateUserAccountRecovery(t);
    } catch (l) {
      if (console.error("Error initiating user account recovery:", l), ee.isAxiosError(l)) {
        const d = (s = l.response) == null ? void 0 : s.data, u = (d == null ? void 0 : d.errorMessage) || (d == null ? void 0 : d.message);
        if (u != null && u.trim())
          throw new Error(u);
        if (((n = l.response) == null ? void 0 : n.status) === 400)
          throw new Error(
            "Invalid request: Please check the email and try again"
          );
        if (((a = l.response) == null ? void 0 : a.status) === 403)
          throw new Error(
            "Access denied: You don't have permission to initiate recovery"
          );
        if (((o = l.response) == null ? void 0 : o.status) === 404)
          throw new Error("User or account not found");
        if (((i = l.response) == null ? void 0 : i.status) === 409)
          throw new Error(
            "Conflict: Recovery cannot be initiated at this time"
          );
        if (((c = l.response) == null ? void 0 : c.status) >= 500)
          throw new Error("Server error: Please try again later");
      }
      throw new Error(
        "Failed to initiate user account recovery. Please try again."
      );
    }
  }
}
class _e {
  /**
   * Get admin private key with caching, decryption, and verification
   */
  static async getAdminPrivateKey() {
    try {
      const t = ue();
      if (!t)
        throw new Error("Internal not found");
      const s = O("bayunSessionId");
      if (!s)
        throw new Error("Session ID not found in cookies");
      const n = await t.getFromStorage(
        s,
        v.ORG_MEMBER_ID
      ), a = await t.getFromStorage(
        s,
        v.ORG_NAME
      );
      if (!n || !a)
        throw new Error("Org member ID or org name not found");
      const o = `${v.ADMIN_PRIVATE_KEY}_${n}_${a}`;
      let i = dr.get(o);
      if (i)
        return i;
      const c = await we.getAdminSensitiveData(), l = await t.getFromStorage(
        s,
        v.MEMBER_PRIVATE_KEY
      );
      if (!await t.retrieveAndverifyLastSignature(
        s,
        c.adminPrivateKeyKek
      ))
        throw new Error("Admin private key KEK verification failed");
      return i = await t.decryptAsymmetric(
        c.adminPrivateKey,
        l,
        c.adminPrivateKeyKek,
        n
      ), dr.set(o, i), i;
    } catch (t) {
      throw console.error("Error fetching admin sensitive data:", t), t;
    }
  }
}
const as = "Approval of member in process", ur = "Some members are currently being approved by other admins. Please retry in a moment.";
function zr(r) {
  var n, a, o, i, c;
  const t = Number((n = r == null ? void 0 : r.response) == null ? void 0 : n.status), s = String(
    ((o = (a = r == null ? void 0 : r.response) == null ? void 0 : a.data) == null ? void 0 : o.errorMessage) || ((c = (i = r == null ? void 0 : r.response) == null ? void 0 : i.data) == null ? void 0 : c.message) || ""
  ).trim();
  return t === 400 && s === as;
}
function Qr(r) {
  return r.trim() === as;
}
function mc(r, t) {
  var a, o, i, c;
  const s = ((o = (a = r == null ? void 0 : r.response) == null ? void 0 : a.data) == null ? void 0 : o.errorMessage) || ((c = (i = r == null ? void 0 : r.response) == null ? void 0 : i.data) == null ? void 0 : c.message);
  if (typeof s == "string" && s.trim())
    return s;
  const n = r == null ? void 0 : r.message;
  return typeof n == "string" && n.trim() ? n : t;
}
const Jr = async (r, t, s, n = !1) => {
  var y;
  const a = [], o = [], i = [], [c, l] = await Promise.all([
    t == null ? void 0 : t.getFromStorage(s, v.MEMBER_APP_ID),
    t == null ? void 0 : t.getFromStorage(s, v.ORG_NAME)
  ]), [d, u, m] = await Promise.all([
    t == null ? void 0 : t.getFromStorage(s, v.MEMBER_PRIVATE_KEY),
    t == null ? void 0 : t.getFromStorage(s, v.ORG_KEY),
    t == null ? void 0 : t.getFromStorage(
      s,
      v.ORG_SIGNING_PRIVATE_KEY
    )
  ]), p = await _e.getAdminPrivateKey();
  for (const g of r)
    try {
      if (!await (t == null ? void 0 : t.retrieveAndverifyLastSignature(s, g.id))) {
        a.push({
          memberId: g.id,
          // Use signed member.id as-is
          orgMemberId: g.orgMemberId,
          errorMessage: "Member ID signature verification failed"
        });
        continue;
      }
      const w = g.id.split(Ne)[0], h = g.publicKey;
      let M = g.archivedPublicKey;
      await (t == null ? void 0 : t.verifyMemberPublicKey(
        s,
        h,
        gt.ACTIVATE_MEMBER,
        null,
        l,
        g.orgMemberId,
        g.memberStatus,
        g.appPublicKey,
        null
      ));
      const x = h.split(Ne), T = x[0];
      if (!((y = g.memberTrustedAdminPublicKey) != null && y.trim()))
        throw new Error("Admin public key not found");
      let R = t.getMessageFromSignatureString(
        g.memberTrustedAdminPublicKey
      );
      if (!await t.publicKeysMatch(
        p,
        R
      ))
        throw new Error(
          "Admin public key does not match member's trusted admin key"
        );
      let U = g.memberTrustedAdminPublicKey;
      if (g.memberStatus === ye.CANCELLED)
        if (await t.verifyMessageForPublicKeyTag(
          s,
          U,
          T,
          t.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
        ))
          U = t.removeSignatureLayersForPublicKeyTag(
            g.memberTrustedAdminPublicKey,
            t.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG
          );
        else
          throw new Error(
            "Admin public key verification failed"
          );
      const N = await t.context.getAdminPublicKeyContext(s), P = await t.signData(
        R,
        p,
        N
      );
      if (!P)
        throw new Error(
          "Member trusted admin public key verification failed"
        );
      const Y = await t.appendSignatureAndMetadata(
        U,
        P,
        t.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        N
      );
      if (!Y)
        throw new Error(
          "Member trusted admin public key verification failed"
        );
      U = Y;
      const re = g.orgMemberId, J = await (t == null ? void 0 : t.encryptAsymmetric(
        u,
        T,
        re
      )), le = await (t == null ? void 0 : t.encryptAsymmetric(
        m,
        T,
        re
      )), Q = [
        ...x
      ];
      for (; Q.length > 5; )
        Q.pop();
      let de = Q.join(Ne);
      const te = await (t == null ? void 0 : t.context.getMemberPublicKeyContext(
        l,
        re
      ));
      de = await (t == null ? void 0 : t.signDataAndAppendSignatureWithMetadata(
        de,
        d,
        te,
        t == null ? void 0 : t.signingPublicKeyTags.APPROVING_MEMBER_PUBLIC_KEY_TAG
      )), M = await (t == null ? void 0 : t.signDataAndAppendSignatureWithMetadata(
        M,
        d,
        te,
        t == null ? void 0 : t.signingPublicKeyTags.APPROVING_MEMBER_PUBLIC_KEY_TAG
      )), de = await (t == null ? void 0 : t.signDataAndAppendSignatureWithMetadata(
        de,
        p,
        te,
        t == null ? void 0 : t.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG
      )), M = await (t == null ? void 0 : t.signDataAndAppendSignatureWithMetadata(
        M,
        p,
        te,
        t == null ? void 0 : t.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG
      ));
      let K = null;
      g.trustedMemberPublicKeySignature || (K = await (t == null ? void 0 : t.signDataAndAppendSignatureWithMetadata(
        T,
        d,
        te,
        t == null ? void 0 : t.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
      )));
      const X = await (t == null ? void 0 : t.context.getOrgKeyContext(s)), I = await (t == null ? void 0 : t.signData(
        u,
        d,
        X
      )), f = await (t == null ? void 0 : t.context.getOrgPrivateKeyContext(s)), j = await (t == null ? void 0 : t.signData(
        m,
        d,
        f
      ));
      let C = J.keyEncryptionKey, k = le.keyEncryptionKey;
      const H = await (t == null ? void 0 : t.context.getOrgKeyKekMemberLockboxContext(s)), V = await (t == null ? void 0 : t.signData(
        C,
        p,
        H
      ));
      C = await (t == null ? void 0 : t.appendSignatureAndMetadata(
        C,
        V,
        t == null ? void 0 : t.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        H
      ));
      const F = await (t == null ? void 0 : t.context.getOrgPrivateKeyKekContext(s)), _ = await (t == null ? void 0 : t.signData(
        k,
        p,
        F
      ));
      k = await (t == null ? void 0 : t.appendSignatureAndMetadata(
        k,
        _,
        t == null ? void 0 : t.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
        F
      ));
      const B = {
        memberId: w,
        // Use unsigned for API request
        authPasscodeHash: "",
        memberAppId: c || "",
        encryptedOrgKey: J.encryptedText,
        encryptedOrgKey_kek: C,
        orgPrivateKey: le.encryptedText,
        orgPrivateKey_kek: k,
        signedMemberPublicKey: de,
        archivedMemberPublicKey: M,
        trusteeSignedMemberPublicKey: K,
        signedOrgKey: I,
        signedOrgPrivateKey: j,
        memberTrustedAdminPublicKey: U
      };
      o.push(B), i.push({
        member: g,
        trimmedUpdatedMemberPublicKey: de
      });
    } catch (w) {
      console.error(`Error processing member ${g.orgMemberId}:`, w);
      const h = w instanceof Error ? w.message : "Failed to process member. Please try again.";
      a.push({
        memberId: g.id,
        // Use signed member.id as-is
        orgMemberId: g.orgMemberId,
        errorMessage: h
      });
    }
  if (o.length === 0)
    return {
      successes: [],
      errors: a
    };
  try {
    const g = await Be.activateMembers({
      memberActivations: o,
      individualRequest: n
    }), w = new Set(g.errors.map((x) => x.memberId)), h = i.filter((x) => {
      const T = x.member.id.split(Ne)[0];
      return !w.has(T);
    }), M = g.errors.map((x) => {
      const T = r.find(
        (R) => R.id.split(Ne)[0] === x.memberId
      );
      return {
        memberId: (T == null ? void 0 : T.id) || x.memberId,
        // Use signed member.id if found, else API's unsigned
        orgMemberId: T == null ? void 0 : T.orgMemberId,
        errorMessage: x.errorMessage
      };
    });
    return {
      successes: h,
      errors: [...a, ...M]
    };
  } catch (g) {
    console.error("Error calling activateMembers API:", g);
    const w = zr(g) ? as : mc(g, Bt);
    return {
      successes: [],
      errors: [
        ...a,
        {
          errorMessage: w
        }
      ]
    };
  }
}, pc = async (r, t, s, n, a) => {
  try {
    const o = r.orgMemberId, i = r.publicKey, c = await (t == null ? void 0 : t.getFromStorage(
      s,
      v.ORG_NAME
    ));
    await (t == null ? void 0 : t.verifyMemberPublicKey(
      s,
      i,
      null,
      r.trustedMemberPublicKeySignature,
      c,
      o,
      r.memberStatus,
      null,
      null
    ));
    const l = i.split(Ne)[0], d = await _e.getAdminPrivateKey(), u = await (t == null ? void 0 : t.encryptAsymmetric(
      d,
      l,
      o
    )), m = u.encryptedText, p = u.keyEncryptionKey, y = await (t == null ? void 0 : t.context.getAdminPrivateKeyKekContext(
      c,
      o
    )), g = await (t == null ? void 0 : t.signData(
      p,
      d,
      y
    )), w = await (t == null ? void 0 : t.appendSignatureAndMetadata(
      p,
      g,
      t == null ? void 0 : t.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      y
    ));
    let h = null;
    if (!r.trustedMemberPublicKeySignature) {
      const x = await (t == null ? void 0 : t.getFromStorage(
        s,
        v.MEMBER_PRIVATE_KEY
      )), T = await (t == null ? void 0 : t.context.getMemberPublicKeyContext(
        c,
        o
      ));
      h = await (t == null ? void 0 : t.signDataAndAppendSignatureWithMetadata(
        l,
        x,
        T,
        t == null ? void 0 : t.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG
      ));
    }
    const M = {
      authPasscodeHash: "",
      encryptedAdminPrivateKey: m,
      adminPrivateKey_kek: w,
      trusteeSignedMemberPublicKey: h
    };
    await Be.promoteMember(r.id, M), ft(n, r.id, ye.ADMIN), a(
      `Member ${r.orgMemberId} promoted successfully!`,
      "success"
    );
  } catch (o) {
    console.error("Error promoting member:", o), a("Failed to promote member. Please try again.", "error");
  }
}, yc = async (r, t, s, n, a, o, i, c) => {
  if (!n) {
    c("Internal API not available", "error");
    return;
  }
  try {
    const l = await ut.prepareAndInitiatePromoteAdmin(
      a,
      n,
      r.id,
      t,
      s
    );
    console.log("Initiate promote admin response:", l);
    const d = (o == null ? void 0 : o.minimumApprovalCount) || "1";
    if (parseInt(d) === 1) {
      ft(
        i,
        r.id,
        ye.SECURITY_ADMIN
      );
      const u = (o == null ? void 0 : o.securityAdminCount) || 0;
      Kn(i, u + 1), On(i, t);
    } else
      _n(
        i,
        `A promote/demote transaction is already in progress for member ${r.orgMemberId}.`,
        r.orgMemberId
      );
    c(
      `Promote Admin transaction initiated successfully! Transaction ID: ${l.transactionId}`,
      "success"
    );
  } catch (l) {
    console.error("Error promoting admin:", l), c(
      l instanceof Error ? l.message : "Failed to initiate promote admin transaction. Please try again.",
      "error"
    );
  }
}, hc = async (r, t, s, n, a, o, i, c, l) => {
  if (!n) {
    c("Internal API not available", "error");
    return;
  }
  try {
    const d = await ut.prepareAndInitiateDemoteSecurityAdmin(
      a,
      n,
      r.id,
      t,
      s
    );
    console.log("Initiate demote security admin response:", d);
    const u = (o == null ? void 0 : o.minimumApprovalCount) || "1", m = (o == null ? void 0 : o.securityAdminCount) || 0;
    parseInt(u) === 1 ? (ft(
      i,
      r.id,
      ye.ADMIN
    ), Kn(i, m - 1), On(i, t)) : _n(
      i,
      `A promote/demote transaction is already in progress for member ${r.orgMemberId}.`,
      r.orgMemberId
    ), c(
      `Demote Security Admin transaction initiated successfully! Transaction ID: ${d.transactionId}`,
      "success"
    ), l();
  } catch (d) {
    console.error("Error demoting security admin:", d), c(
      d instanceof Error ? d.message : "Failed to initiate demote security admin transaction. Please try again.",
      "error"
    );
  }
}, gc = async (r, t, s) => {
  try {
    await Be.demoteAdmin(r.id), ft(t, r.id, ye.APPROVED), s(
      `Admin ${r.orgMemberId} demoted successfully!`,
      "success"
    );
  } catch (n) {
    console.error("Error demoting admin:", n), s("Failed to demote admin. Please try again.", "error");
  }
}, fc = async (r, t, s) => {
  try {
    await Be.deactivateMember(r.id), ft(
      t,
      r.id,
      ye.CANCELLED
    ), s(
      `Member ${r.orgMemberId} deactivated successfully!`,
      "success"
    );
  } catch (n) {
    console.error("Error deactivating member:", n), s("Failed to deactivate member. Please try again.", "error");
  }
}, bc = async (r, t, s) => {
  const n = ue();
  if (!n)
    throw new Error("Internal not found");
  const a = O("bayunSessionId");
  if (!a)
    throw new Error("Session ID not found in cookies");
  const o = await n.getFromStorage(
    a,
    v.ORG_NAME
  ), i = await Ce(n, a), c = await n.getFromStorage(
    a,
    v.ORG_MEMBER_ID
  ), l = await _e.getAdminPrivateKey(), d = await n.generateHMacHash(
    i,
    "lms" + o
  ), u = await n.aeadEncryptWithAssociatedData(
    $.DECLINED,
    "lms" + o,
    d
  );
  if (!await n.retrieveAndverifyLastSignature(
    a,
    t
  ))
    throw new Error("Signed transaction ID verification failed");
  const m = n.context.getTransactionIdContext(
    r,
    $.DECLINED,
    s,
    o,
    c
  );
  let p = await n.signData(
    r,
    l,
    m
  );
  return p = await n.appendSignatureAndMetadata(
    t,
    p,
    n.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
    m
  ), {
    transactionId: r,
    lmsTransactionKey: d,
    transactionStatus: u,
    signedTransactionId: p
  };
}, wc = async (r, t, s) => {
  var n, a, o, i;
  try {
    if (!confirm(`Are you sure you want to delete member ${r.orgMemberId}?`))
      return;
    const c = await Be.checkDeleteEligibility(r.id);
    let l;
    c.transactionId && c.signedTransactionId && c.transactionLabel && (l = await bc(
      c.transactionId,
      c.signedTransactionId,
      c.transactionLabel
    )), await Be.deleteMember(r.id, l), t(
      `Member ${r.orgMemberId} deleted successfully!`,
      "success"
    ), s();
  } catch (c) {
    console.error("Error deleting member:", c);
    const l = ((a = (n = c == null ? void 0 : c.response) == null ? void 0 : n.data) == null ? void 0 : a.errorMessage) || ((i = (o = c == null ? void 0 : c.response) == null ? void 0 : o.data) == null ? void 0 : i.message) || (c == null ? void 0 : c.message) || "Failed to delete member. Please try again.";
    t(l, "error");
  }
}, mr = (r) => r.isAuthorized !== "false", Ac = ({
  row: r,
  filteredData: t,
  isSecurityAdmin: s,
  handleActivateMember: n,
  handlePromoteMember: a,
  handlePromoteAdmin: o
}) => {
  const i = (t == null ? void 0 : t.onGoingSecurityAdminTransaction) || "";
  return mr(r) ? r.memberStatus === ye.CANCELLED ? {
    show: !0,
    disabled: !1,
    title: "Activate",
    onClick: () => n(r),
    style: {}
  } : r.memberStatus === ye.REGISTERED || r.memberStatus === ye.AUTO_APPROVED ? {
    show: !0,
    disabled: !1,
    title: "Approve",
    onClick: () => n(r),
    style: {}
  } : r.memberStatus === ye.APPROVED ? {
    show: !0,
    disabled: !1,
    title: "Promote Member to Admin",
    onClick: () => a(r),
    style: {}
  } : r.memberStatus === ye.ADMIN && s ? i === "" ? {
    show: !0,
    disabled: !1,
    title: "Promote Admin to Security Admin",
    onClick: () => o(r),
    style: {}
  } : {
    show: !0,
    disabled: !0,
    title: i,
    onClick: () => {
    },
    style: { color: "#aaaaaa", cursor: "not-allowed" }
  } : {
    show: !1,
    disabled: !1,
    title: "",
    onClick: () => {
    },
    style: {}
  } : {
    show: !0,
    disabled: !0,
    title: "Member is not yet authorized to be activated",
    onClick: () => {
    },
    style: { color: "#aaaaaa", cursor: "not-allowed" }
  };
}, vc = ({
  row: r,
  filteredData: t,
  isSecurityAdmin: s,
  handleDemoteAdmin: n,
  handleDeactivateMember: a,
  handleDemoteSecurityAdmin: o
}) => {
  const i = (t == null ? void 0 : t.onGoingSecurityAdminTransaction) || "", c = (t == null ? void 0 : t.targetOrgMemberId) || "";
  if (!mr(r))
    return {
      show: !1,
      disabled: !1,
      title: "",
      onClick: () => {
      },
      style: {}
    };
  if (r.memberStatus === ye.ADMIN)
    return i !== "" && r.orgMemberId === c ? {
      show: !0,
      disabled: !0,
      title: i,
      onClick: () => {
      },
      style: { color: "#aaaaaa", cursor: "not-allowed" }
    } : {
      show: !0,
      disabled: !1,
      title: "Demote Admin to Regular Member",
      onClick: () => n(r),
      style: {}
    };
  if (r.memberStatus === ye.APPROVED || r.memberStatus === ye.AUTO_APPROVED)
    return {
      show: !0,
      disabled: !1,
      title: "Deactivate",
      onClick: () => a(r),
      style: {}
    };
  if (r.memberStatus === ye.SECURITY_ADMIN && s)
    if (i === "") {
      const l = (t == null ? void 0 : t.securityAdminCount) || 0, d = (t == null ? void 0 : t.minimumApprovalCount) || "1";
      return {
        show: !0,
        disabled: !1,
        title: "Demote Security Admin to Regular Admin",
        onClick: () => o(
          r,
          d,
          l
        ),
        style: {}
      };
    } else
      return {
        show: !0,
        disabled: !0,
        title: i,
        onClick: () => {
        },
        style: { color: "#aaaaaa", cursor: "not-allowed" }
      };
  return {
    show: !1,
    disabled: !1,
    title: "",
    onClick: () => {
    },
    style: {}
  };
}, Ec = ({
  row: r,
  filteredData: t,
  deleteMember: s,
  setOpenActionMenuMemberId: n,
  setActionMenuPosition: a
}) => {
  const o = (t == null ? void 0 : t.onGoingSecurityAdminTransaction) || "", i = (t == null ? void 0 : t.targetOrgMemberId) || "";
  return r.memberStatus === ye.SECURITY_ADMIN ? {
    disabled: !0,
    title: "Deleting a Security Admin is not allowed. Please demote the Security Admin first.",
    onClick: () => {
    },
    style: { color: "#aaaaaa", cursor: "not-allowed" }
  } : o !== "" && r.orgMemberId === i ? {
    disabled: !0,
    title: "This member is in the process of being promoted/demoted.",
    onClick: () => {
    },
    style: { color: "#aaaaaa", cursor: "not-allowed" }
  } : {
    disabled: !1,
    title: "Delete Member",
    onClick: () => {
      n(null), a(null), s(r);
    },
    style: {}
  };
};
function Pe({
  loading: r = !1,
  loadingText: t,
  children: s,
  disabled: n,
  ...a
}) {
  return /* @__PURE__ */ e.jsx("button", { ...a, disabled: n || r, children: r ? /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx("div", { className: "btn-spinner", "aria-hidden": "true" }),
    t ?? s
  ] }) : s });
}
function xc() {
  return /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs(
    "svg",
    {
      xmlns: "http://www.w3.org/2000/svg",
      width: "20",
      height: "20",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "1.5",
      strokeLinecap: "round",
      strokeLinejoin: "round",
      className: "icon icon-tabler icons-tabler-outline icon-tabler-info-circle",
      children: [
        /* @__PURE__ */ e.jsx("path", { stroke: "none", d: "M0 0h24v24H0z", fill: "none" }),
        /* @__PURE__ */ e.jsx("path", { d: "M3 12a9 9 0 1 0 18 0a9 9 0 0 0 -18 0" }),
        /* @__PURE__ */ e.jsx("path", { d: "M12 9h.01" }),
        /* @__PURE__ */ e.jsx("path", { d: "M11 12h1v4h1" })
      ]
    }
  ) });
}
const Ft = 10, er = 8, Sc = 10050, Mc = 120;
function Pc() {
  return document.body;
}
function Us(r) {
  r.stopPropagation();
}
function Ke({
  content: r,
  children: t,
  className: s = "",
  wide: n = !1,
  variant: a = "light",
  placement: o = "auto"
}) {
  const i = Re(null), c = Re(null), l = Re(null), [d, u] = b(!1), [m, p] = b({ top: 0, left: 0 }), [y, g] = b(
    o === "bottom" ? "bottom" : "top"
  ), [w, h] = b(!1), M = () => {
    l.current && (clearTimeout(l.current), l.current = null);
  }, x = () => {
    M(), u(!0);
  }, T = () => {
    M(), l.current = setTimeout(() => u(!1), Mc);
  }, R = Xs(() => {
    const U = i.current, q = c.current;
    if (!U || !q) return;
    const N = U.getBoundingClientRect(), P = q.getBoundingClientRect(), Y = window.innerWidth, re = window.innerHeight;
    let J, le;
    o === "bottom" ? (J = "bottom", le = N.bottom + er) : o === "top" ? (J = "top", le = N.top - P.height - er) : (J = "top", le = N.top - P.height - er, le < Ft && (le = N.bottom + er, J = "bottom")), le = Math.max(
      Ft,
      Math.min(le, re - P.height - Ft)
    );
    let Q = N.left + N.width / 2 - P.width / 2;
    Q = Math.max(
      Ft,
      Math.min(Q, Y - P.width - Ft)
    ), g(J), p({ top: le, left: Q }), h(!0);
  }, [o]);
  Va(() => {
    if (!d) {
      h(!1);
      return;
    }
    R();
    const U = requestAnimationFrame(() => R());
    return () => cancelAnimationFrame(U);
  }, [d, r, n, a, o, R]), ve(() => {
    if (!d) return;
    const U = () => R();
    return window.addEventListener("resize", U), window.addEventListener("scroll", U, !0), () => {
      window.removeEventListener("resize", U), window.removeEventListener("scroll", U, !0);
    };
  }, [d, R]), ve(() => () => M(), []);
  const D = !!t;
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      "span",
      {
        ref: i,
        className: [
          "info-tooltip-trigger",
          D && "info-tooltip-trigger-custom",
          a === "dark" && "info-tooltip-trigger-dark",
          s
        ].filter(Boolean).join(" "),
        onMouseEnter: x,
        onMouseLeave: T,
        onFocus: x,
        onBlur: T,
        onClick: Us,
        onMouseDown: Us,
        children: t ?? /* @__PURE__ */ e.jsx(xc, {})
      }
    ),
    d && Wa(
      /* @__PURE__ */ e.jsx(
        "div",
        {
          ref: c,
          className: [
            "info-tooltip-portal",
            n && "info-tooltip-portal-wide",
            a === "dark" && "info-tooltip-portal-dark",
            y === "top" ? "info-tooltip-portal-top" : "info-tooltip-portal-bottom"
          ].filter(Boolean).join(" "),
          style: {
            position: "fixed",
            top: m.top,
            left: m.left,
            zIndex: Sc,
            visibility: w ? "visible" : "hidden"
          },
          role: "tooltip",
          onMouseEnter: x,
          onMouseLeave: T,
          children: r
        }
      ),
      Pc()
    )
  ] });
}
const Ic = 30 * 60 * 1e3;
let Xr = !1, ir = null, _r = !1, Xe;
function Kr(r, t) {
  var a, o, i, c;
  const s = ((o = (a = r == null ? void 0 : r.response) == null ? void 0 : a.data) == null ? void 0 : o.errorMessage) || ((c = (i = r == null ? void 0 : r.response) == null ? void 0 : i.data) == null ? void 0 : c.message);
  if (typeof s == "string" && s.trim())
    return s;
  const n = r == null ? void 0 : r.message;
  return typeof n == "string" && n.trim() ? n : t;
}
function jc() {
  ir !== null && (clearInterval(ir), ir = null), Xr = !1;
}
function os() {
  Xe = void 0;
}
async function Fs() {
  var n, a;
  if (_r)
    return;
  _r = !0;
  let r = !1, t = !1;
  const s = (o, i = "error") => {
    var c;
    t || (t = !0, (c = Xe == null ? void 0 : Xe.onNotification) == null || c.call(Xe, o, i));
  };
  try {
    const o = O("bayunSessionId"), i = ue();
    if (!o || !i) {
      jc();
      return;
    }
    const c = await i.getFromStorage(
      o,
      v.MEMBER_STATUS
    ), l = String(c || "").toLowerCase();
    if (l !== "admin" && l !== "securityadmin")
      return;
    for (; ; ) {
      let d;
      try {
        d = await Be.fetchAutoApproveMembers();
      } catch (u) {
        const m = zr(u);
        m || (r = !0);
        const p = m ? ur : Kr(u, Bt);
        s(p, m ? "info" : "error"), console.error("Auto-approve fetch failed:", u);
        return;
      }
      if (d.length > 0) {
        const u = await Jr(
          d,
          i,
          o,
          !1
        );
        if (u.errors.length > 0) {
          const m = ((n = u.errors.find((y) => y.errorMessage)) == null ? void 0 : n.errorMessage) || Bt, p = Qr(m);
          p || (r = !0), s(
            p ? ur : m,
            p ? "info" : "error"
          ), console.error(
            "Background auto-activation failed; stopping flow:",
            u.errors
          );
          return;
        }
        u.successes.length > 0 && ((a = Xe == null ? void 0 : Xe.onActivateSuccess) == null || a.call(Xe, u.successes));
      }
      if (d.length < 20) {
        r = !0;
        break;
      }
    }
  } catch (o) {
    zr(o) || (r = !0), s(Kr(o, Bt)), console.error("Failed to fetch auto-approve members:", o);
  } finally {
    if (_r = !1, r)
      try {
        await Be.releaseAutoApproveMembersLock();
      } catch (o) {
        s(
          Kr(o, Bt)
        ), console.error("Failed to release auto-approve members lock:", o);
      }
  }
}
async function is(r) {
  Xe = r;
  const t = O("bayunSessionId"), s = ue();
  if (!t || !s)
    return;
  const n = await s.getFromStorage(
    t,
    v.MEMBER_STATUS
  ), a = String(n || "").toLowerCase();
  a !== "admin" && a !== "securityadmin" || Xr || (Xr = !0, ir = setInterval(() => {
    Fs();
  }, Ic), Fs());
}
const Tc = async (r) => {
  const t = O("baseURL");
  if (!t)
    throw new Error("Base URL not found in cookies");
  return (await ee.post(
    `${t}lms/admin/userRecoveryKey`,
    r
  )).data;
};
function Nc(r, t) {
  const s = new Blob([r], { type: "text/plain" }), n = URL.createObjectURL(s), a = document.createElement("a");
  a.href = n, a.download = t, document.body.appendChild(a), a.click(), document.body.removeChild(a), URL.revokeObjectURL(n);
}
async function kc({
  internal: r,
  sessionId: t
}) {
  const [s, n, a] = await Promise.all([
    r.getFromStorage(t, v.USER_PRIVATE_KEY),
    r.getFromStorage(t, v.USER_PUBLIC_KEY),
    r.getFromStorage(t, v.USER_ID)
  ]);
  if (!s || !n || !a)
    throw new Error("Required user key material is unavailable in storage.");
  const o = await r.generateAesKey(), i = ns(r, o), c = await r.aeadEncryptWithAssociatedData(
    s,
    a,
    o
  ), l = await r.encryptAsymmetric(
    i,
    n,
    a
  ), d = await r.context.getUserKeyKekContext(
    t
  ), u = await r.signData(
    l.keyEncryptionKey,
    s,
    d
  ), m = await r.appendSignatureAndMetadata(
    l.keyEncryptionKey,
    u,
    r.signingPublicKeyTags.USER_PUBLIC_KEY_TAG,
    d
  );
  return {
    userId: a,
    recoveryKey: i,
    encryptedUserPrivateKeyByRecoveryKey: c,
    encryptedRecoveryKey: l.encryptedText,
    encryptedRecoveryKeyKek: m
  };
}
async function Gn(r, t, s) {
  const {
    userId: n,
    recoveryKey: a,
    encryptedUserPrivateKeyByRecoveryKey: o,
    encryptedRecoveryKey: i,
    encryptedRecoveryKeyKek: c
  } = await kc({ internal: r, sessionId: t }), { recoveryKeyId: l } = await Tc({
    encryptedUserPrivateKey: o,
    userRecoveryKey: i,
    userRecoveryKeyKek: c
  }), d = r.serializeUserRecoveryKeyFile(
    a,
    l
  );
  await Be.updateFirstComponentRendringStatus(!0), Nc(d, "bayun-recovery-key.txt"), r.saveInStorage(t, v.FIRST_TIME_LOG_IN, !1), s && s();
}
function Yn({
  isOpen: r,
  onClose: t
}) {
  const [s, n] = b(!1), [a, o] = b(!1), i = O("bayunSessionId"), c = ue();
  if (!r) return null;
  const l = async () => {
    if (!c || !i) {
      console.error("Bayun internal bridge or session is unavailable.");
      return;
    }
    try {
      n(!0), await Gn(c, i, t);
    } catch (u) {
      console.error("Failed to prepare recovery key download.", u);
    } finally {
      n(!1);
    }
  }, d = async () => {
    try {
      o(!0), await Be.updateFirstComponentRendringStatus(!0);
    } catch (u) {
      console.error("Failed to update first component rendering status.", u);
    } finally {
      o(!1);
    }
    c == null || c.saveInStorage(
      i,
      v.FIRST_TIME_LOG_IN,
      !1
    ), t();
  };
  return /* @__PURE__ */ e.jsx("div", { className: "add-participant-popup-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "add-participant-popup-content recovery-key-popup-content", children: [
    /* @__PURE__ */ e.jsx("div", { className: "recovery-key-popup-header", children: /* @__PURE__ */ e.jsxs("div", { children: [
      /* @__PURE__ */ e.jsx("h3", { className: "recovery-key-popup-title", children: "Recovery Key" }),
      /* @__PURE__ */ e.jsx("p", { className: "recovery-key-popup-subtitle", children: "In case you forget your credentials, your recovery key can help you regain access to your account. If you download it, make sure you keep it in a safe place, because a stolen recovery key can be used to compromise your account and data." })
    ] }) }),
    /* @__PURE__ */ e.jsx("div", { className: "popup-form", children: /* @__PURE__ */ e.jsxs("div", { className: "recovery-key-options-row", children: [
      /* @__PURE__ */ e.jsxs("div", { className: "recovery-key-option-box", children: [
        /* @__PURE__ */ e.jsx("h4", { className: "recovery-key-option-title", children: "Download" }),
        /* @__PURE__ */ e.jsx("p", { className: "recovery-key-option-description", children: "Save recovery key in a local folder so you can transfer it out later, or in a cloud drive where it can be used from another device in case this device is no longer available." }),
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            type: "button",
            className: "popup-button-submit recovery-key-option-button",
            onClick: l,
            loading: s,
            loadingText: "Downloading...",
            children: "Download Key"
          }
        )
      ] }),
      /* @__PURE__ */ e.jsx("div", { className: "recovery-key-or-separator", children: "OR" }),
      /* @__PURE__ */ e.jsxs("div", { className: "recovery-key-option-box", children: [
        /* @__PURE__ */ e.jsx("h4", { className: "recovery-key-option-title", children: "Skip" }),
        /* @__PURE__ */ e.jsxs("div", { className: "recovery-key-skip-section", children: [
          /* @__PURE__ */ e.jsx(
            "span",
            {
              className: "recovery-key-option-description",
              children: "WARNING: While this is the best option if you are sure you will never forget answers to your minimum required Security Questions, it may permanently lock you out if you do forget your credentials. You can still decide to download the recovery key later from under Security Settings."
            }
          ),
          /* @__PURE__ */ e.jsx("div", { className: "recovery-key-skip-actions", children: /* @__PURE__ */ e.jsx(
            Pe,
            {
              type: "button",
              className: "popup-button-submit",
              onClick: d,
              loading: a,
              loadingText: "Skipping...",
              children: "Skip"
            }
          ) })
        ] })
      ] })
    ] }) })
  ] }) });
}
const ht = "ALL", Vn = [
  { value: ht, label: "All" },
  { value: ye.REGISTERED, label: "Registered" },
  { value: ye.APPROVED, label: "Approved" },
  { value: ye.CANCELLED, label: "Cancelled" },
  { value: ye.ADMIN, label: "Admin" },
  { value: ye.SECURITY_ADMIN, label: "SecurityAdmin" },
  { value: ye.AUTO_APPROVED, label: "AutoApproved" }
], Bs = (r) => {
  var t;
  return ((t = Vn.find((s) => s.value === r)) == null ? void 0 : t.label) ?? r;
}, qn = (r) => {
  if (!r) return !1;
  const t = r.trim();
  return t !== "" && t !== "N/A" && t !== "null";
}, Rc = (r) => {
  const t = qn(r.linkedUserId), s = !!r.memberHaveAppsWithPasscode;
  return !(t && !s);
};
function Cc() {
  var vs;
  const { getLoader: r } = De(), [t, s] = b(""), [n, a] = b(ht), [o, i] = b(!1), [c, l] = b(null), [d, u] = b(
    null
  ), [m, p] = b(!0), [y, g] = b(!1), [w, h] = b(null), [M, x] = b(null), [T, R] = b(null), [D, U] = b(
    null
  ), [q, N] = b(!1), [P, Y] = b(!1), [re, J] = b(null), [le, Q] = b(null), [de, te] = b(null), [K, X] = b(null), [I, f] = b(""), [j, C] = b(""), [k, H] = b(""), [V, F] = b(
    /* @__PURE__ */ new Set()
  ), [_, B] = b(!1), [oe, fe] = b(!1), [G, ne] = b(!1), [me, E] = b(null), [Z, z] = b(!1), [ce, he] = b(!1), [Ie, xe] = b(""), [A, se] = b("info"), {
    snackbarOpen: ie,
    snackbarMessage: Ee,
    setSnackbarOpen: je
  } = wr(!0), Ae = (S, W = "info") => {
    xe(S), se(W), he(!0);
  }, pe = O("bayunSessionId"), Me = ue(), He = Re(null), Ue = Re(null), Oe = Re(null), Qe = Re(null), Je = Re(!0), $e = Re(!0), Ge = Re(n);
  Ge.current = n;
  const wt = Re(t);
  wt.current = t;
  const Pt = Re(null), Ct = Re(!1), zt = Re(!1), Ar = Re(!0), Qt = Re(0), ds = Re(null), us = Re(null), vr = Re(async () => {
  }), ra = (S, W) => {
    const ae = new Set(S.map((Te) => Te.id)), ge = W.filter((Te) => !ae.has(Te.id));
    return [...S, ...ge];
  }, ms = (S) => ee.isCancel(S) || S instanceof Error && S.name === "AbortError", Er = () => {
    var S, W;
    (S = He.current) == null || S.abort(), (W = Ue.current) == null || W.abort();
  }, xr = () => {
    Er();
    const S = new AbortController();
    return He.current = S, S;
  }, sa = () => {
    var W;
    (W = Ue.current) == null || W.abort();
    const S = new AbortController();
    return Ue.current = S, S;
  }, ps = async (S) => {
    const W = await (Me == null ? void 0 : Me.getFromStorage(
      pe,
      v.ORG_NAME
    )), ae = await Ce(Me, pe), ge = await (Me == null ? void 0 : Me.aeadDecryptWithAssociatedData(
      S.minimumApprovalCount,
      W,
      ae
    ));
    return S.minimumApprovalCount = ge, S;
  }, ys = (S) => {
    Pt.current = S.nextCursor ?? null, Ct.current = !!S.hasMore;
  }, Sr = () => {
    Pt.current = null, Ct.current = !1;
  };
  ve(() => {
    oa(), na();
  }, []), ve(() => (is({
    onNotification: (S, W) => {
      Ae(S, W ?? "error");
    },
    onActivateSuccess: (S) => {
      for (const W of S)
        ft(
          u,
          W.member.id,
          ye.APPROVED,
          (ae) => Ge.current === ht || ae.memberStatus === Ge.current
        ), Cr(
          u,
          W.member.id,
          W.trimmedUpdatedMemberPublicKey
        );
    }
  }), () => os()), []);
  const na = async () => {
    const S = await Me.getFromStorage(pe, v.FIRST_TIME_LOG_IN);
    z(S);
  }, aa = (S, W = "error") => {
    var Te;
    if (S.some(
      (ke) => Qr(ke.errorMessage)
    )) {
      Ae(ur, "info");
      return;
    }
    const ge = (Te = S.find((ke) => ke.errorMessage)) == null ? void 0 : Te.errorMessage;
    ge && Ae(ge, W);
  };
  ve(() => {
    if (T && D) {
      const S = Je.current, W = Qe.current !== null && Qe.current !== n;
      if (S || W) {
        S && (Je.current = !1), Qe.current = n, Oe.current && (clearTimeout(Oe.current), Oe.current = null);
        const ae = xr();
        F(/* @__PURE__ */ new Set()), Mr(t, ae.signal);
      } else
        Qe.current = n;
    }
  }, [T, D, n]), ve(() => {
    if ($e.current && t.length === 0)
      return;
    if (!(t.length === 0 || t.length >= 3)) {
      Oe.current && (clearTimeout(Oe.current), Oe.current = null);
      return;
    }
    return Oe.current && clearTimeout(Oe.current), Er(), T && D && (Oe.current = setTimeout(() => {
      const W = xr();
      F(/* @__PURE__ */ new Set()), Mr(t, W.signal);
    }, 400)), () => {
      Oe.current && clearTimeout(Oe.current);
    };
  }, [t, T, D]), ve(() => () => {
    Oe.current && clearTimeout(Oe.current), Er();
  }, []), ve(() => {
    const S = ds.current, W = us.current, ae = !!(d != null && d.hasMore);
    if (!S || !W || m || !ae)
      return;
    const ge = new IntersectionObserver(
      (Le) => {
        var Ot;
        (Ot = Le[0]) != null && Ot.isIntersecting && vr.current();
      },
      { root: S, rootMargin: "120px", threshold: 0 }
    );
    ge.observe(W);
    const ke = requestAnimationFrame(() => {
      const Le = S.getBoundingClientRect();
      W.getBoundingClientRect().top <= Le.bottom + 120 && vr.current();
    });
    return () => {
      cancelAnimationFrame(ke), ge.disconnect();
    };
  }, [m, d == null ? void 0 : d.hasMore, (vs = d == null ? void 0 : d.memberResponses) == null ? void 0 : vs.length]), ve(() => {
    ie && (Ae(
      Ee || "You have pending approvals",
      "info"
    ), je(!1));
  }, [ie, Ee, je]);
  const oa = async () => {
    if (!Me) {
      console.warn("Bayun internal bridge not available");
      return;
    }
    try {
      const [S, W, ae, ge] = await Promise.all([
        Me.getFromStorage(pe, v.MEMBER_APP_ID),
        Me.getFromStorage(pe, v.ORG_NAME),
        Me.getFromStorage(
          pe,
          v.LMS_TRANSACTION_KEY
        ),
        Me.getFromStorage(pe, v.MEMBER_STATUS)
      ]), Te = ae || await Me.generateHMacHash(
        await Ce(Me, pe),
        "lms" + W
      );
      R(S), U(Te), N(ge === ye.SECURITY_ADMIN);
    } catch (S) {
      console.error("Error loading keys", S);
    }
  };
  ve(() => {
    if (!le && !o) return;
    const S = () => {
      Q(null), te(null), i(!1), l(null);
    };
    return document.addEventListener("mousedown", S), () => {
      document.removeEventListener("mousedown", S);
    };
  }, [le, o]);
  const ia = (S, W) => {
    if (le === W.id) {
      Q(null), te(null);
      return;
    }
    const ge = S.currentTarget.getBoundingClientRect();
    Q(W.id), te({
      top: ge.bottom + 4,
      left: ge.left - 220
    });
  }, Mr = async (S = "", W) => {
    var Te;
    if (!T || !D)
      return;
    const ae = ++Qt.current, ge = () => ae === Qt.current;
    try {
      p(!0), Ar.current = !0, g(!1), zt.current = !1, x(null), h(null), Sr();
      const ke = await Be.fetchMembers(
        {
          memberAppId: T,
          lmsTransactionKey: D,
          searchParameter: S,
          memberStatus: n === ht ? null : n
        },
        W
      );
      if (!ge() || W != null && W.aborted || (await ps(ke), !ge() || W != null && W.aborted))
        return;
      u(ke), f(ke.minimumApprovalCount || ""), ys(ke), typeof ke.totalNoOfMember == "number" ? h(ke.totalNoOfMember) : h(null);
    } catch (ke) {
      if (ms(ke) || W != null && W.aborted || !ge())
        return;
      if (console.error("Error fetching members", ke), ee.isAxiosError(ke) && ((Te = ke.response) != null && Te.data)) {
        const Le = ke.response.data;
        if (Le.errorType === "ACCESS_DENIED") {
          if (!ge())
            return;
          x({
            kind: "access_denied",
            message: Le.errorMessage || "Access Denied"
          }), u(null), h(null), Sr();
          return;
        }
      }
      if (!ge())
        return;
      x({
        kind: "generic",
        message: "Failed to load members. Please try again."
      }), u(null), h(null), Sr();
    } finally {
      if (W != null && W.aborted || !ge())
        return;
      $e.current = !1, p(!1), Ar.current = !1;
    }
  }, ca = async () => {
    if (!Ct.current || zt.current || Ar.current || Pt.current == null || !T || !D)
      return;
    const S = ++Qt.current, W = () => S === Qt.current;
    zt.current = !0, g(!0);
    const ae = sa();
    try {
      const ge = await Be.fetchMembers(
        {
          memberAppId: T,
          lmsTransactionKey: D,
          cursor: Pt.current,
          searchParameter: wt.current,
          memberStatus: Ge.current === ht ? null : Ge.current
        },
        ae.signal
      );
      if (!W() || ae.signal.aborted || (await ps(ge), !W() || ae.signal.aborted))
        return;
      u((Te) => Te ? {
        ...ge,
        memberResponses: ra(
          Te.memberResponses || [],
          ge.memberResponses || []
        ),
        totalNoOfMember: ge.totalNoOfMember ?? Te.totalNoOfMember
      } : ge), f(ge.minimumApprovalCount || ""), ys(ge);
    } catch (ge) {
      if (ms(ge) || ae.signal.aborted || !W())
        return;
      console.error("Error loading more members", ge), Ae("Failed to load more members. Please try again.", "error");
    } finally {
      if (ae.signal.aborted || !W())
        return;
      zt.current = !1, g(!1);
    }
  };
  vr.current = ca;
  const la = (S) => {
    s(S), F(/* @__PURE__ */ new Set());
  }, hs = (S) => {
    a(S), F(/* @__PURE__ */ new Set());
  }, da = (S) => {
    if (o) {
      i(!1), l(null);
      return;
    }
    const W = S.currentTarget.getBoundingClientRect();
    l({
      top: W.bottom + 8,
      left: W.left
    }), i(!0);
  }, gs = (S) => n === ht || S.memberStatus === n, fs = (S) => {
    S.length !== 0 && F((W) => {
      const ae = new Set(W);
      return S.forEach((ge) => ae.delete(ge)), ae;
    });
  }, Jt = () => d != null && d.memberResponses ? d.memberResponses : [], _t = async (S, W) => {
    if (!me) {
      E(S);
      try {
        await W();
      } finally {
        E(null);
      }
    }
  }, ua = async (S) => {
    const W = await Jr([S], Me, pe, !0), ae = [];
    for (const ge of W.successes)
      ae.push(ge.member.id), ft(
        u,
        ge.member.id,
        ye.APPROVED,
        gs
      ), Cr(
        u,
        ge.member.id,
        ge.trimmedUpdatedMemberPublicKey
      ), Ae(
        `Member ${ge.member.orgMemberId} activated successfully!`,
        "success"
      );
    fs(ae), aa(W.errors, "error");
  }, ma = async (S) => {
    await pc(
      S,
      Me,
      pe,
      u,
      Ae
    );
  }, pa = (S) => {
    X(S), J("promote"), C(""), H("");
    const W = (d == null ? void 0 : d.minimumApprovalCount) || "1";
    f(W), Kt(W, "submitPromoteAdmin"), Y(!0);
  }, Kt = (S, W) => {
    const ae = (d == null ? void 0 : d.securityAdminCount) || 0, ge = new RegExp("^[0-9]*$");
    if (H(""), C(""), S !== "") {
      if (isNaN(Number(S)) || !ge.test(S))
        return H("Please enter a numeric value"), !1;
      if (S === "1")
        C(
          ae === 2 && W === "submitDemoteSecurityAdmin" ? "You would be the only Security Admin left when this transaction is completed" : "Any Security Admin will be able to complete a transaction without consent from anyone else"
        );
      else {
        if (Number(S) < 1)
          return H(
            "Please enter a value greater than or equal to 1"
          ), !1;
        if (W === "submitPromoteAdmin") {
          if (Number(S) === Number(ae) + 1)
            C(
              "All the Security Admins will be required to approve any future transaction"
            );
          else if (Number(S) > Number(ae) + 1)
            return H(
              `Please enter a value less than or equal to the future number of Security Admins (i.e. ${Number(ae) + 1})`
            ), !1;
        } else if (W === "submitDemoteSecurityAdmin") {
          if (Number(S) === ae - 1)
            C(
              "All the Security Admins will be required to approve any future transaction"
            );
          else if (Number(S) > ae - 1)
            return H(
              `Please enter a value less than or equal to the future number of Security Admins (i.e. ${ae - 1})`
            ), !1;
        }
      }
    }
    return !0;
  }, ya = (S) => {
    const W = S.replace(/[^0-9]/g, "");
    f(W), Kt(W, re === "promote" ? "submitPromoteAdmin" : "submitDemoteSecurityAdmin");
  }, Pr = () => {
    Y(!1), X(null), J(null), f(""), C(""), H("");
  }, ha = async () => {
    if (K && Kt(I, "submitPromoteAdmin")) {
      ne(!0);
      try {
        await yc(
          K,
          I,
          T,
          Me,
          pe,
          d,
          u,
          Ae
        ), Pr();
      } finally {
        ne(!1);
      }
    }
  }, ga = async () => {
    if (K && Kt(I, "submitDemoteSecurityAdmin")) {
      ne(!0);
      try {
        await hc(
          K,
          I,
          T,
          Me,
          pe,
          d,
          u,
          Ae,
          Pr
        );
      } finally {
        ne(!1);
      }
    }
  }, fa = async (S) => {
    await gc(S, u, Ae);
  }, ba = async (S) => {
    await fc(
      S,
      u,
      Ae
    );
  }, wa = (S, W, ae) => {
    X(S), J("demote"), C(""), H("");
    const ge = parseInt(W, 10);
    let Te;
    ge === ae ? Te = (ae - 1).toString() : Te = W, f(Te), Kt(Te, "submitDemoteSecurityAdmin"), Y(!0);
  }, Aa = async (S) => {
    await wc(S, Ae, () => {
      const W = xr();
      return Mr(t, W.signal);
    });
  }, va = async (S) => {
    await _t(
      S.id,
      () => ua(S)
    );
  }, Ea = async (S) => {
    await _t(
      S.id,
      () => ma(S)
    );
  }, xa = async (S) => {
    await _t(
      S.id,
      () => fa(S)
    );
  }, Sa = async (S) => {
    await _t(
      S.id,
      () => ba(S)
    );
  }, Ma = async (S) => {
    await _t(
      S.id,
      () => Aa(S)
    );
  }, Pa = (S) => Ac({
    row: S,
    filteredData: d,
    isSecurityAdmin: q,
    handleActivateMember: va,
    handlePromoteMember: Ea,
    handlePromoteAdmin: pa
  }), Ia = (S) => vc({
    row: S,
    filteredData: d,
    isSecurityAdmin: q,
    handleDemoteAdmin: xa,
    handleDeactivateMember: Sa,
    handleDemoteSecurityAdmin: wa
  }), ja = (S) => Ec({
    row: S,
    filteredData: d,
    deleteMember: Ma,
    setOpenActionMenuMemberId: Q,
    setActionMenuPosition: te
  }), Ta = (S) => {
    F((W) => {
      const ae = new Set(W);
      return ae.has(S) ? ae.delete(S) : ae.add(S), ae;
    });
  }, Na = () => {
    if (!(d != null && d.memberResponses)) return;
    const S = Jt();
    if (S.length > 0 && S.every((ae) => V.has(ae.id)))
      F(/* @__PURE__ */ new Set());
    else {
      const ae = new Set(S.map((ge) => ge.id));
      F(ae);
    }
  }, bs = () => {
    const S = Jt();
    return S.length === 0 ? [] : S.filter((W) => V.has(W.id));
  }, yt = () => {
    const S = bs();
    return S.length === 0 ? [] : S.filter(
      (W) => mr(W) && (W.memberStatus === ye.AUTO_APPROVED || W.memberStatus === ye.REGISTERED || W.memberStatus === ye.CANCELLED)
    );
  }, ws = () => yt().some(
    (S) => S.memberStatus === ye.CANCELLED
  ), As = () => {
    const S = bs();
    return S.length === 0 ? !1 : S.every(
      (W) => mr(W) && (W.memberStatus === ye.AUTO_APPROVED || W.memberStatus === ye.REGISTERED || W.memberStatus === ye.CANCELLED)
    );
  }, ka = () => {
    if (!As()) {
      Ae(
        "This action works only when all selected members are Registered, AutoApproved, or Cancelled.",
        "info"
      );
      return;
    }
    if (yt().length === 0) {
      Ae("No approvable members selected.", "info");
      return;
    }
    B(!0);
  }, Ir = () => {
    B(!1);
  }, Ra = async () => {
    const S = yt();
    if (S.length === 0) {
      Ae("No approvable members selected.", "info"), Ir();
      return;
    }
    fe(!0);
    const W = S.some(
      (Le) => Le.memberStatus === ye.CANCELLED
    ), ae = await Jr(
      S,
      Me,
      pe,
      !1
    ), ge = [];
    for (const Le of ae.successes)
      ge.push(Le.member.id), ft(
        u,
        Le.member.id,
        ye.APPROVED,
        gs
      ), Cr(
        u,
        Le.member.id,
        Le.trimmedUpdatedMemberPublicKey
      );
    fe(!1), Ir(), fs(ge);
    const Te = ae.successes.length, ke = ae.errors.length;
    if (ke === 0)
      Ae(
        W ? `Successfully activated ${Te} member(s)!` : `Successfully approved ${Te} member(s)!`,
        "success"
      );
    else {
      if (ae.errors.every(
        (Ot) => Qr(Ot.errorMessage)
      )) {
        Ae(ur, "info");
        return;
      }
      Ae(
        W ? `Activated ${Te} member(s). Failed to activate ${ke} member(s).` : `Approved ${Te} member(s). Failed to approve ${ke} member(s).`,
        "error"
      );
    }
  }, Ca = () => P ? /* @__PURE__ */ e.jsx("div", { className: "add-participant-popup-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "add-participant-popup-content promote-admin-popup-content", children: [
    /* @__PURE__ */ e.jsxs("div", { className: "promote-admin-popup-header", children: [
      /* @__PURE__ */ e.jsx("h3", { className: "promote-admin-popup-title", children: re === "promote" ? "Promote to Security Admin" : "Demote Security Admin to Admin" }),
      K && /* @__PURE__ */ e.jsx("p", { className: "promote-admin-popup-subtitle", children: K.orgMemberId })
    ] }),
    /* @__PURE__ */ e.jsxs("div", { className: "popup-form", children: [
      /* @__PURE__ */ e.jsxs("div", { className: "approval-count-display", children: [
        /* @__PURE__ */ e.jsxs("div", { className: "approval-count-label-wrapper", children: [
          /* @__PURE__ */ e.jsx(
            "span",
            {
              className: "approval-count-label-icon",
              "aria-hidden": "true"
            }
          ),
          /* @__PURE__ */ e.jsx("span", { className: "approval-count-label-text", children: "No. of Approvals Required For this Transaction" })
        ] }),
        /* @__PURE__ */ e.jsx("div", { className: "approval-count-value", children: (d == null ? void 0 : d.minimumApprovalCount) || "1" })
      ] }),
      /* @__PURE__ */ e.jsx("p", { className: "approval-count-description", children: "Specify the new minimum number of Security Admins required for approvals. (This will take effect after the transaction is completed.)" }),
      /* @__PURE__ */ e.jsxs("div", { className: "approval-count-input-wrapper", children: [
        /* @__PURE__ */ e.jsx(
          "label",
          {
            htmlFor: "minimumApprovalCount",
            className: "approval-count-input-label",
            children: "Edit New Minimum Approval Count"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "input",
          {
            type: "text",
            id: "minimumApprovalCount",
            value: I,
            defaultValue: d == null ? void 0 : d.minimumApprovalCount,
            onChange: (S) => ya(S.target.value),
            placeholder: "Enter number",
            className: `approval-count-input ${k ? "error" : ""}`
          }
        )
      ] }),
      j && /* @__PURE__ */ e.jsxs("div", { id: "warningMessagePopUp", className: "approval-count-warning", children: [
        /* @__PURE__ */ e.jsx(
          "span",
          {
            className: "approval-count-warning-icon",
            "aria-hidden": "true"
          }
        ),
        /* @__PURE__ */ e.jsx("span", { children: j })
      ] }),
      k && /* @__PURE__ */ e.jsxs("div", { id: "errorMessagePopUp", className: "approval-count-error", children: [
        /* @__PURE__ */ e.jsx(
          "span",
          {
            className: "approval-count-error-icon",
            "aria-hidden": "true"
          }
        ),
        /* @__PURE__ */ e.jsx("span", { children: k })
      ] }),
      /* @__PURE__ */ e.jsxs("div", { className: "popup-actions", children: [
        /* @__PURE__ */ e.jsx(
          "button",
          {
            type: "button",
            onClick: Pr,
            className: "popup-button-cancel",
            disabled: G,
            children: "Cancel"
          }
        ),
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            type: "button",
            onClick: re === "promote" ? ha : ga,
            disabled: !!k || !I,
            className: "popup-button-submit",
            loading: G,
            loadingText: "Submitting...",
            children: "Submit"
          }
        )
      ] })
    ] })
  ] }) }) : null, _a = () => {
    if (!_) return null;
    const S = ws();
    return /* @__PURE__ */ e.jsx("div", { className: "add-participant-popup-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "add-participant-popup-content approve-all-popup-content", children: [
      /* @__PURE__ */ e.jsxs("div", { className: "approve-all-popup-header", children: [
        /* @__PURE__ */ e.jsx("h3", { className: "approve-all-popup-title", children: S ? "Activate All Members" : "Approve All Members" }),
        /* @__PURE__ */ e.jsxs(
          "div",
          {
            className: "approval-count-warning",
            style: { marginTop: "var(--space-2)" },
            children: [
              /* @__PURE__ */ e.jsx(
                "span",
                {
                  className: "approval-count-warning-icon",
                  "aria-hidden": "true"
                }
              ),
              /* @__PURE__ */ e.jsx("span", { children: S ? "Are you sure you want to activate all these selected members?" : "Are you sure you want to approve all these selected members?" })
            ]
          }
        )
      ] }),
      /* @__PURE__ */ e.jsxs("div", { className: "popup-form", children: [
        /* @__PURE__ */ e.jsxs("div", { className: "approve-all-member-list", children: [
          /* @__PURE__ */ e.jsx("div", { className: "approve-all-list-header", children: /* @__PURE__ */ e.jsxs("span", { className: "approve-all-list-title", children: [
            "Selected Members (",
            yt().length,
            ")"
          ] }) }),
          /* @__PURE__ */ e.jsx("div", { className: "approve-all-list-container", children: yt().length > 0 ? /* @__PURE__ */ e.jsx("ul", { className: "approve-all-member-list-items", children: yt().map((W) => /* @__PURE__ */ e.jsx("li", { className: "approve-all-member-item", children: /* @__PURE__ */ e.jsx("span", { className: "approve-all-member-id", children: W.orgMemberId }) }, W.id)) }) : /* @__PURE__ */ e.jsx("div", { className: "approve-all-empty-state", children: /* @__PURE__ */ e.jsx("p", { children: "No approvable members selected." }) }) })
        ] }),
        /* @__PURE__ */ e.jsxs("div", { className: "popup-actions", children: [
          /* @__PURE__ */ e.jsx(
            "button",
            {
              type: "button",
              onClick: Ir,
              className: "popup-button-cancel",
              disabled: oe,
              children: "Cancel"
            }
          ),
          /* @__PURE__ */ e.jsx(
            Pe,
            {
              type: "button",
              onClick: Ra,
              disabled: yt().length === 0,
              className: "popup-button-submit",
              loading: oe,
              loadingText: S ? "Activating..." : "Approving...",
              children: S ? "Activate All" : "Approve All"
            }
          )
        ] })
      ] })
    ] }) });
  }, Ka = () => {
    if (!le || !de || !d)
      return null;
    const S = d.memberResponses.find(
      (Le) => Le.id === le
    ) || null;
    if (!S) return null;
    const W = Pa(S), ae = Ia(S), ge = () => S.memberStatus === ye.CANCELLED ? "Activate" : S.memberStatus === ye.APPROVED ? "Promote to Admin" : S.memberStatus === ye.ADMIN ? "Promote to Security Admin" : "Approve", Te = () => S.memberStatus === ye.SECURITY_ADMIN ? "Demote to Admin" : S.memberStatus === ye.ADMIN ? "Demote to Regular Member" : S.memberStatus === ye.APPROVED || S.memberStatus === ye.AUTO_APPROVED ? "Deactivate" : "Demote", ke = me === S.id;
    return /* @__PURE__ */ e.jsxs(
      "div",
      {
        className: "action-menu",
        style: {
          position: "fixed",
          top: de.top,
          left: de.left
        },
        onMouseDown: (Le) => Le.stopPropagation(),
        children: [
          W.show && /* @__PURE__ */ e.jsxs(
            "button",
            {
              type: "button",
              className: "action-menu-item",
              onClick: () => {
                ke || (Q(null), te(null), W.onClick());
              },
              title: W.title,
              disabled: W.disabled || !!me,
              style: W.style,
              children: [
                ke && /* @__PURE__ */ e.jsx("div", { className: "btn-spinner", "aria-hidden": "true" }),
                ge()
              ]
            }
          ),
          ae.show && /* @__PURE__ */ e.jsxs(
            "button",
            {
              type: "button",
              className: "action-menu-item",
              onClick: () => {
                ke || (Q(null), te(null), ae.onClick());
              },
              title: ae.title,
              disabled: ae.disabled || !!me,
              style: ae.style,
              children: [
                ke && /* @__PURE__ */ e.jsx("div", { className: "btn-spinner", "aria-hidden": "true" }),
                Te()
              ]
            }
          ),
          (() => {
            const Le = ja(S);
            return /* @__PURE__ */ e.jsxs(
              "button",
              {
                type: "button",
                className: "action-menu-item",
                onClick: () => {
                  ke || Le.onClick();
                },
                disabled: Le.disabled || !!me,
                title: Le.title,
                style: Le.style,
                children: [
                  ke && /* @__PURE__ */ e.jsx("div", { className: "btn-spinner", "aria-hidden": "true" }),
                  "Delete"
                ]
              }
            );
          })()
        ]
      }
    );
  }, Oa = () => !o || !c ? null : /* @__PURE__ */ e.jsxs(
    "div",
    {
      className: "header-filter-menu",
      role: "menu",
      style: {
        position: "fixed",
        top: c.top,
        left: c.left
      },
      onMouseDown: (S) => S.stopPropagation(),
      children: [
        /* @__PURE__ */ e.jsx("div", { className: "header-filter-title", children: "Status" }),
        Vn.map((S) => /* @__PURE__ */ e.jsx(
          "button",
          {
            type: "button",
            role: "menuitemradio",
            "aria-checked": n === S.value,
            className: `header-filter-item ${n === S.value ? "active" : ""}`,
            onClick: () => {
              hs(S.value), i(!1), l(null);
            },
            children: S.label
          },
          S.value
        ))
      ]
    }
  ), La = () => n === ht ? null : /* @__PURE__ */ e.jsxs("div", { className: "active-status-filter-bar", children: [
    /* @__PURE__ */ e.jsxs("span", { className: "active-status-filter-label", children: [
      "Showing status:",
      /* @__PURE__ */ e.jsx("span", { className: "active-status-filter-value", children: Bs(n) })
    ] }),
    /* @__PURE__ */ e.jsx(
      "button",
      {
        type: "button",
        className: "active-status-filter-clear",
        onClick: () => hs(ht),
        children: "Clear filter"
      }
    )
  ] }), Da = () => {
    const S = Jt().length;
    if (!d) return null;
    const W = w != null ? `Showing ${S} of ${w} members` : `Showing ${S} members`;
    return /* @__PURE__ */ e.jsx("div", { className: "members-list-count", children: /* @__PURE__ */ e.jsx("span", { className: "page-info", children: W }) });
  }, Ua = () => {
    const S = Jt(), W = (ae) => ae === ye.CANCELLED ? "Deactivated" : ae;
    return /* @__PURE__ */ e.jsxs("table", { className: "custom-table", children: [
      /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("th", { style: { width: "40px" }, children: /* @__PURE__ */ e.jsxs(
          "div",
          {
            className: "table-header-select",
            onMouseDown: (ae) => ae.stopPropagation(),
            children: [
              /* @__PURE__ */ e.jsx(
                "input",
                {
                  type: "checkbox",
                  checked: S.length > 0 && S.every(
                    (ae) => V.has(ae.id)
                  ),
                  onChange: Na,
                  title: "Select all members"
                }
              ),
              /* @__PURE__ */ e.jsx("div", { className: "header-filter-wrapper", children: /* @__PURE__ */ e.jsx(
                "button",
                {
                  type: "button",
                  className: "header-filter-trigger",
                  onClick: da,
                  title: `Filter members by status (current: ${Bs(n)})`,
                  "aria-haspopup": "menu",
                  "aria-expanded": o,
                  children: /* @__PURE__ */ e.jsx("span", { className: "header-filter-icon", "aria-hidden": "true", children: "▾" })
                }
              ) })
            ]
          }
        ) }),
        /* @__PURE__ */ e.jsx("th", { children: "Member ID" }),
        /* @__PURE__ */ e.jsx("th", { children: /* @__PURE__ */ e.jsxs(
          "div",
          {
            style: {
              display: "flex",
              alignItems: "center"
            },
            children: [
              /* @__PURE__ */ e.jsx("div", { children: "Status" }),
              /* @__PURE__ */ e.jsx(Ke, { content: oc })
            ]
          }
        ) }),
        /* @__PURE__ */ e.jsx("th", { children: "Linked User ID" }),
        /* @__PURE__ */ e.jsx("th", { children: "Passphrase enabled" }),
        /* @__PURE__ */ e.jsx("th", { children: /* @__PURE__ */ e.jsxs(
          "div",
          {
            style: {
              display: "flex",
              alignItems: "center"
            },
            children: [
              "MFA Setting",
              /* @__PURE__ */ e.jsx(Ke, { content: ic, wide: !0 })
            ]
          }
        ) }),
        /* @__PURE__ */ e.jsx("th", { style: { width: "5%" } })
      ] }) }),
      /* @__PURE__ */ e.jsx("tbody", { children: S.length > 0 ? S.map((ae) => {
        var ge;
        return /* @__PURE__ */ e.jsxs("tr", { children: [
          /* @__PURE__ */ e.jsx("td", { style: { width: "40px", textAlign: "center" }, children: /* @__PURE__ */ e.jsx(
            "input",
            {
              type: "checkbox",
              checked: V.has(ae.id),
              onChange: () => Ta(ae.id),
              title: "Select member"
            }
          ) }),
          /* @__PURE__ */ e.jsx("td", { className: "actions-cell", children: /* @__PURE__ */ e.jsx("div", { className: "member-cell", children: /* @__PURE__ */ e.jsx("span", { className: "member-id", children: ae.orgMemberId }) }) }),
          /* @__PURE__ */ e.jsx("td", { className: "actions-cell", children: ae.isAuthorized === "true" ? /* @__PURE__ */ e.jsx("div", { className: "member-status-active", children: /* @__PURE__ */ e.jsx("span", { className: "member-status-text", children: W(ae.memberStatus) }) }) : /* @__PURE__ */ e.jsx("div", { className: "member-status-inactive", children: /* @__PURE__ */ e.jsx("span", { className: "member-status-text", children: "Authorization Pending" }) }) }),
          /* @__PURE__ */ e.jsx("td", { children: ae.linkedUserId || "—" }),
          /* @__PURE__ */ e.jsx("td", { children: qn(ae.linkedUserId) ? ae.isPassphraseSet ? "Yes" : "No" : "N/A" }),
          /* @__PURE__ */ e.jsx("td", { children: Rc(ae) ? /* @__PURE__ */ e.jsx(
            "span",
            {
              className: `mfa-badge mfa-${(ge = ae.multiFactorAuthentication) == null ? void 0 : ge.toLowerCase()}`,
              children: ae.multiFactorAuthentication
            }
          ) : "N/A" }),
          /* @__PURE__ */ e.jsx("td", { style: { width: "5%" }, children: /* @__PURE__ */ e.jsx("div", { className: "action-buttons", children: /* @__PURE__ */ e.jsx(
            "div",
            {
              className: "action-menu-wrapper",
              onMouseDown: (Te) => Te.stopPropagation(),
              children: /* @__PURE__ */ e.jsx(
                "button",
                {
                  type: "button",
                  className: "more-actions",
                  onClick: (Te) => ia(Te, ae),
                  title: "More actions",
                  children: /* @__PURE__ */ e.jsx("span", { className: "more-actions-icon", children: "⋮" })
                }
              )
            }
          ) }) })
        ] }, ae.id);
      }) : /* @__PURE__ */ e.jsx("tr", { children: /* @__PURE__ */ e.jsx("td", { colSpan: 7, className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
        /* @__PURE__ */ e.jsx("div", { className: "empty-icon", "aria-hidden": "true" }),
        /* @__PURE__ */ e.jsx("h3", { children: "No members found" }),
        /* @__PURE__ */ e.jsx("p", { children: "Try adjusting your search criteria or add new members." })
      ] }) }) }) })
    ] });
  }, Fa = (S) => {
    const W = S.kind === "access_denied";
    return /* @__PURE__ */ e.jsx("div", { className: "error-state", children: /* @__PURE__ */ e.jsxs("div", { className: "error-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "error-icon", children: "🚫" }),
      /* @__PURE__ */ e.jsx("h3", { children: W ? "Access Denied" : "Unable to load members" }),
      /* @__PURE__ */ e.jsx("p", { children: S.message }),
      W && /* @__PURE__ */ e.jsx("p", { className: "error-hint", children: "You don't have permission to view the member list. Please contact your administrator." })
    ] }) });
  }, Ba = () => r("Loading members..."), Ga = () => {
    const S = yt(), W = As(), ae = ws();
    return /* @__PURE__ */ e.jsxs("div", { className: "search-member", children: [
      /* @__PURE__ */ e.jsx(
        "button",
        {
          type: "button",
          className: "btn approve approve-all-btn",
          onClick: ka,
          disabled: !W,
          style: {
            display: W ? "block" : "none"
          },
          title: W ? ae ? `Activate ${S.length} selected member(s)` : `Approve ${S.length} selected member(s)` : "Select members to approve or activate",
          children: ae ? "Activate All" : "Approve All"
        }
      ),
      /* @__PURE__ */ e.jsx(
        "input",
        {
          type: "text",
          placeholder: "Search by Member ID",
          value: t,
          onChange: (ge) => la(ge.target.value)
        }
      )
    ] });
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Members",
        subtitle: "Manage member permissions and access",
        actions: Ga()
      }
    ),
    /* @__PURE__ */ e.jsx("div", { className: "table-container members-list-container", children: m ? Ba() : M ? Fa(M) : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
      La(),
      /* @__PURE__ */ e.jsxs("div", { className: "members-list-scroll", ref: ds, children: [
        Ua(),
        /* @__PURE__ */ e.jsx(
          "div",
          {
            ref: us,
            className: "members-list-sentinel",
            "aria-hidden": "true"
          }
        ),
        y && /* @__PURE__ */ e.jsx("div", { className: "members-list-load-more", children: r("Loading more...") })
      ] }),
      Da()
    ] }) }),
    Ca(),
    _a(),
    Oa(),
    Ka(),
    /* @__PURE__ */ e.jsx(
      Yn,
      {
        isOpen: Z,
        onClose: () => z(!1)
      }
    ),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: ce,
        message: Ie,
        onClose: () => he(!1),
        type: A
      }
    )
  ] });
}
const _c = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: Cc
}, Symbol.toStringTag, { value: "Module" })), Gs = (r) => {
  try {
    return new Date(r).toLocaleString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit"
    });
  } catch {
    return r;
  }
}, tr = (r) => {
  const t = r.match(/name=([^)]+)/);
  return t ? t[1] : r;
}, Ys = (r) => [...r].sort((t, s) => {
  const n = new Date(t.actionAt).getTime();
  return new Date(s.actionAt).getTime() - n;
});
function Kc() {
  const { renderLoader: r } = De(), [t, s] = b(!0), [n, a] = b(null), [o, i] = b(null);
  ve(() => {
    c();
  }, []);
  const c = async () => {
    var l, d;
    try {
      s(!0), i(null);
      const u = await kn.getApprovalHistoryList();
      a(u);
    } catch (u) {
      console.error("Error fetching approval history:", u), i(
        ((d = (l = u == null ? void 0 : u.response) == null ? void 0 : l.data) == null ? void 0 : d.message) || "Failed to load approval history. Please try again."
      );
    } finally {
      s(!1);
    }
  };
  return /* @__PURE__ */ e.jsxs("div", { className: "notifications-page", children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Notifications",
        subtitle: "View admin approval requests and recent action items"
      }
    ),
    /* @__PURE__ */ e.jsx("div", { className: "notifications-content", children: t ? r(t, "Loading approval history...") : o ? /* @__PURE__ */ e.jsxs("div", { className: "notifications-error", children: [
      /* @__PURE__ */ e.jsx("p", { children: o }),
      /* @__PURE__ */ e.jsx(
        "button",
        {
          className: "btn btn-primary",
          onClick: c,
          style: { marginTop: "var(--space-4)" },
          children: "Retry"
        }
      )
    ] }) : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
      /* @__PURE__ */ e.jsxs("section", { className: "notifications-section", children: [
        /* @__PURE__ */ e.jsx("h2", { className: "notifications-section-title", children: "Application Approval History" }),
        n != null && n.orgApplicationApprovalHistoryList && n.orgApplicationApprovalHistoryList.length > 0 ? /* @__PURE__ */ e.jsx("div", { className: "table-container", children: /* @__PURE__ */ e.jsxs("table", { className: "custom-table", children: [
          /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
            /* @__PURE__ */ e.jsx("th", { children: "App Name" }),
            /* @__PURE__ */ e.jsx("th", { children: "App ID" }),
            /* @__PURE__ */ e.jsx("th", { children: "Org" }),
            /* @__PURE__ */ e.jsx("th", { children: "Member ID" }),
            /* @__PURE__ */ e.jsx("th", { children: "Status" }),
            /* @__PURE__ */ e.jsx("th", { children: "Auto Approved" }),
            /* @__PURE__ */ e.jsx("th", { children: "Action Date" })
          ] }) }),
          /* @__PURE__ */ e.jsx("tbody", { children: Ys(
            n.orgApplicationApprovalHistoryList
          ).map(
            (l, d) => /* @__PURE__ */ e.jsxs("tr", { children: [
              /* @__PURE__ */ e.jsx("td", { children: l.applicationName || "—" }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "member-id", children: l.applicationId || "—" }) }),
              /* @__PURE__ */ e.jsx("td", { children: l.orgName || "—" }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "member-id", children: l.orgMemberId || "—" }) }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx(
                "span",
                {
                  className: `status-badge status-${tr(
                    l.status
                  ).toLowerCase().replace(/\s+/g, "-")}`,
                  children: tr(l.status)
                }
              ) }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx(
                "span",
                {
                  className: `auto-approved-badge ${l.autoApproved ? "auto-approved" : "manual"}`,
                  children: l.autoApproved ? "Yes" : "No"
                }
              ) }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "operation-time", children: Gs(l.actionAt) }) })
            ] }, d)
          ) })
        ] }) }) : /* @__PURE__ */ e.jsx("p", { className: "notifications-empty-state", children: "No application approval history available." })
      ] }),
      /* @__PURE__ */ e.jsxs("section", { className: "notifications-section", children: [
        /* @__PURE__ */ e.jsx("h2", { className: "notifications-section-title", children: "Member Approval History" }),
        n != null && n.memberApprovalHistoryList && n.memberApprovalHistoryList.length > 0 ? /* @__PURE__ */ e.jsx("div", { className: "table-container", children: /* @__PURE__ */ e.jsxs("table", { className: "custom-table", children: [
          /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
            /* @__PURE__ */ e.jsx("th", { children: "Approved For Member" }),
            /* @__PURE__ */ e.jsx("th", { children: "Action By Member" }),
            /* @__PURE__ */ e.jsx("th", { children: "Status" }),
            /* @__PURE__ */ e.jsx("th", { children: "Action Date" })
          ] }) }),
          /* @__PURE__ */ e.jsx("tbody", { children: Ys(
            n.memberApprovalHistoryList
          ).map(
            (l, d) => /* @__PURE__ */ e.jsxs("tr", { children: [
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "member-id", children: l.approvedForOrgMemberId || "—" }) }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "member-id", children: l.actionByOrgMemberId || "—" }) }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx(
                "span",
                {
                  className: `status-badge status-${tr(
                    l.status
                  ).toLowerCase().replace(/\s+/g, "-")}`,
                  children: tr(l.status)
                }
              ) }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "operation-time", children: Gs(l.actionAt) }) })
            ] }, d)
          ) })
        ] }) }) : /* @__PURE__ */ e.jsx("p", { className: "notifications-empty-state", children: "No member approval history available." })
      ] })
    ] }) })
  ] });
}
const Oc = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: Kc
}, Symbol.toStringTag, { value: "Module" }));
function bt() {
  const [r, t] = b(!1), [s, n] = b(""), [a, o] = b("info"), i = Xs(
    (c, l = "info") => {
      n(c), o(l), t(!0);
    },
    []
  );
  return {
    snackbarOpen: r,
    snackbarMessage: s,
    snackbarType: a,
    setSnackbarOpen: t,
    showSnackbar: i
  };
}
const rr = (r) => {
  if (!r) return "";
  const t = new Date(r);
  if (isNaN(t.getTime())) return "";
  const s = t.getDate().toString().padStart(2, "0"), a = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ][t.getMonth()], o = t.getFullYear().toString().slice(-2);
  let i = t.getHours();
  const c = t.getMinutes().toString().padStart(2, "0"), l = i >= 12 ? "PM" : "AM";
  i = i % 12 || 12;
  const d = i.toString().padStart(2, "0");
  return `${s} ${a} ${o}, ${d}:${c} ${l}`;
};
function Rt({
  transaction: r,
  showAcceptanceStep: t = !1
}) {
  const s = r.transactionStatus === $.DECLINED && !!r.declinedByMember, n = t && !!r.acceptedDate;
  return /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-cards-grid", children: [
    r.initiator && /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-card security-admin-transactions-card-initiated", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-name", children: r.initiator }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-action", children: "Initiated" }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-date", children: rr(r.initiatedOn) })
    ] }),
    r.approvedByMembers && Object.entries(r.approvedByMembers).map(
      ([a, o]) => /* @__PURE__ */ e.jsxs(
        "div",
        {
          className: "security-admin-transactions-card security-admin-transactions-card-approved",
          children: [
            /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-name", children: a }),
            /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-action", children: "Approved" }),
            /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-date", children: rr(o) })
          ]
        },
        a
      )
    ),
    s && /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-card security-admin-transactions-card-declined", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-name", children: r.declinedByMember }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-action", children: "Declined" }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-date", children: rr(r.declineDate) })
    ] }),
    n && /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-card security-admin-transactions-card-accepted", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-name", children: r.targetUserEmailAddress || r.targetOrgMemberId }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-action", children: "Accepted" }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-card-date", children: rr(r.acceptedDate) })
    ] })
  ] });
}
const Lc = (r) => r === be.PROMOTE_ADMIN ? "Promotion to Security Admin" : r === be.DEMOTE_SECURITY_ADMIN ? "Demotion to Admin" : r, Dc = (r) => r === $.IN_PROGRESS ? "In Progress" : r;
function Uc({
  transactions: r,
  isLoading: t = !1,
  onTransactionsUpdated: s
}) {
  const { renderLoader: n } = De(), [a, o] = b(/* @__PURE__ */ new Set()), [i, c] = b(""), [l, d] = b(!1), [u, m] = b(!1), [p, y] = b(null), [g, w] = b(!1), {
    snackbarOpen: h,
    snackbarMessage: M,
    snackbarType: x,
    setSnackbarOpen: T,
    showSnackbar: R
  } = bt(), [D, U] = b(!1), [q, N] = b(!1);
  ve(() => {
    (async () => {
      try {
        const j = ue(), C = O("bayunSessionId");
        if (j && C) {
          const k = await j.getFromStorage(
            C,
            v.ORG_MEMBER_ID
          );
          k && c(k);
        }
      } catch (j) {
        console.error("Error fetching logged in org member ID:", j);
      }
    })();
  }, []);
  const P = (f) => {
    const j = new Set(a);
    j.has(f) ? j.delete(f) : j.add(f), o(j);
  }, Y = (f) => {
    y(f), d(!0);
  }, re = () => {
    d(!1), y(null), w(!1);
  }, J = () => {
    U(!1), y(null), N(!1);
  }, le = async () => {
    if (!p) return;
    w(!0);
    const f = ue();
    if (!f)
      throw new Error("Internal not found");
    const j = O("bayunSessionId");
    if (!j)
      throw new Error("Session ID not found in cookies");
    const C = await f.getFromStorage(
      j,
      v.MEMBER_PRIVATE_KEY
    ), k = await f.getFromStorage(
      j,
      v.ORG_NAME
    ), H = await _e.getAdminPrivateKey(), V = O("baseURL");
    if (!V)
      throw new Error("Base URL not found in cookies");
    if (!await f.retrieveAndverifyLastSignature(
      j,
      p.signedTransactionId
    ))
      throw new Error("Signed transaction ID verification failed");
    let F = null, _ = null, B = [];
    if (p.createTransactionEncryptionKeys === "true") {
      F = await f.generateAesKey();
      const he = await rt(
        j,
        k,
        f
      );
      B = await pt(
        F,
        he,
        H,
        C,
        k,
        f
      ), _ = await We(
        j,
        V,
        C,
        null,
        F,
        f
      );
    } else
      _ = await We(
        j,
        V,
        C,
        p.transactionId,
        null,
        f
      );
    const oe = await Ce(f, j), fe = await f.generateHMacHash(
      oe,
      "lms" + k
    ), G = await f.getFromStorage(
      j,
      v.MEMBER_APP_ID
    ) || "";
    if (!_)
      throw new Error("Backdoor private key part not found");
    let ne = await f.signData(
      p.transactionId,
      H,
      f.context.getTransactionIdContext(p.transactionId, $.IN_PROGRESS, p.transactionLabel, k, i)
    );
    ne = await f.appendSignatureAndMetadata(
      p.signedTransactionId,
      ne,
      f.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      f.context.getTransactionIdContext(p.transactionId, $.IN_PROGRESS, p.transactionLabel, k, i)
    );
    const me = {
      transactionId: p.transactionId,
      backdoorPrivateKeyPart: _,
      authPasscodeHash: null,
      memberAppId: G,
      lmsTransactionKey: fe,
      transactionEncryptionKeyRequestList: B,
      signedTransactionId: ne
    }, E = Object.keys(
      p.approvedByMembers || {}
    ).length, Z = p.transactionLabel === be.PROMOTE_ADMIN || p.transactionLabel === be.DEMOTE_SECURITY_ADMIN, z = p.targetOrgMemberId === i, ce = Z && z && E + 1 === Number(p.minimumApprovalCount);
    try {
      const he = await we.approveTransaction(me);
      await $t(
        j,
        he,
        p.transactionId,
        oe,
        fe,
        F,
        C,
        i,
        k,
        E.toString(),
        H,
        ne,
        p.transactionLabel
      ), re(), ce ? m(!0) : s && await s();
    } catch (he) {
      console.error("Error approving transaction:", he), R("Failed to approve transaction. Please try again.", "error"), w(!1);
    }
  }, Q = () => p ? p.warningMessage ? p.warningMessage.trim() === "" ? "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to " + (p.newMinimumApprovalCount || p.minimumApprovalCount) + ". Would you still like to approve this transaction?" : p.warningMessage + " Would you still like to approve this transaction?" : "Would you like to approve this transaction?" : "", de = (f) => {
    y(f), U(!0);
  }, te = async () => {
    var f, j;
    if (p) {
      N(!0);
      try {
        const C = ue();
        if (!C)
          throw new Error("Internal not found");
        const k = O("bayunSessionId");
        if (!k)
          throw new Error("Session ID not found in cookies");
        const H = await C.getFromStorage(
          k,
          v.ORG_NAME
        ), V = await _e.getAdminPrivateKey(), F = await Ce(C, k), _ = await C.generateHMacHash(
          F,
          "lms" + H
        ), B = await C.aeadEncryptWithAssociatedData(
          $.DECLINED,
          "lms" + H,
          _
        );
        if (!await C.retrieveAndverifyLastSignature(
          k,
          p.signedTransactionId
        ))
          throw new Error("Signed transaction ID verification failed");
        let oe = await C.signData(
          p.transactionId,
          V,
          C.context.getTransactionIdContext(
            p.transactionId,
            $.DECLINED,
            p.transactionLabel,
            H,
            i
          )
        );
        oe = await C.appendSignatureAndMetadata(
          p.signedTransactionId,
          oe,
          C.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          C.context.getTransactionIdContext(
            p.transactionId,
            $.DECLINED,
            p.transactionLabel,
            H,
            i
          )
        ), await we.declineTransaction({
          transactionId: p.transactionId,
          lmsTransactionKey: _,
          transactionStatus: B,
          signedTransactionId: oe
        }), J(), s ? await s() : window.location.reload();
      } catch (C) {
        console.error("Error declining transaction:", C);
        const k = ((j = (f = C == null ? void 0 : C.response) == null ? void 0 : f.data) == null ? void 0 : j.errorMessage) || (C == null ? void 0 : C.message) || "Failed to decline transaction. Please try again.";
        alert(k), N(!1);
      }
    }
  }, K = (f) => {
    let j = f.approvedByMembers ? Object.keys(f.approvedByMembers).length : 0;
    return f.declinedByMember && f.approvedByMembers && Object.keys(f.approvedByMembers).includes(
      f.declinedByMember
    ) && j--, j;
  }, X = (f) => f.approvedByMembers ? Object.keys(f.approvedByMembers).includes(
    i
  ) : !1, I = (f) => f.transactionStatus !== $.COMPLETED && f.transactionStatus !== $.DECLINED;
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    l && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: Q() }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: le,
            loading: g,
            loadingText: "Approving...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: re,
            disabled: g,
            children: "No"
          }
        )
      ] })
    ] }) }),
    u && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: "Your user status has changed. Please reload the application." }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-buttons", children: /* @__PURE__ */ e.jsx(
        "button",
        {
          className: "security-admin-transactions-modal-button-yes",
          onClick: () => window.location.reload(),
          children: "Reload"
        }
      ) })
    ] }) }),
    D && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: "Would you like to decline this transaction?" }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: te,
            loading: q,
            loadingText: "Declining...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: J,
            disabled: q,
            children: "No"
          }
        )
      ] })
    ] }) }),
    /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-title", children: "Security Admin Promotion/Demotion Transactions" }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-list", children: t ? n(t, "Loading security admin transactions...") : /* @__PURE__ */ e.jsxs("table", { className: "security-admin-transactions-table", children: [
        /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
          /* @__PURE__ */ e.jsx("th", { children: "Operation" }),
          /* @__PURE__ */ e.jsx("th", { children: "Target Member" }),
          /* @__PURE__ */ e.jsx("th", { children: "Initiator" }),
          /* @__PURE__ */ e.jsx("th", { children: "Status" }),
          /* @__PURE__ */ e.jsx("th", { children: "Action" }),
          /* @__PURE__ */ e.jsx("th", { children: "Approvals" })
        ] }) }),
        /* @__PURE__ */ e.jsx("tbody", { children: r.map((f) => {
          const j = K(f), C = X(f), k = I(f);
          return /* @__PURE__ */ e.jsxs(lt.Fragment, { children: [
            /* @__PURE__ */ e.jsxs("tr", { children: [
              /* @__PURE__ */ e.jsx("td", { children: Lc(f.transactionLabel) }),
              /* @__PURE__ */ e.jsx("td", { children: f.targetOrgMemberId }),
              /* @__PURE__ */ e.jsx("td", { children: f.initiator }),
              /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx(
                "span",
                {
                  className: `status-badge ${f.transactionStatus === $.IN_PROGRESS ? "status-in-progress" : f.transactionStatus === $.COMPLETED ? "status-completed" : f.transactionStatus === $.DECLINED ? "status-declined" : ""}`,
                  children: Dc(f.transactionStatus)
                }
              ) }),
              /* @__PURE__ */ e.jsx("td", { children: k ? C ? /* @__PURE__ */ e.jsx(
                "button",
                {
                  className: "security-admin-transactions-decline",
                  onClick: () => de(f),
                  title: "Decline",
                  children: "✕"
                }
              ) : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                /* @__PURE__ */ e.jsx(
                  "button",
                  {
                    className: "security-admin-transactions-approve",
                    onClick: () => Y(f),
                    title: "Approve",
                    children: "✓"
                  }
                ),
                /* @__PURE__ */ e.jsx(
                  "button",
                  {
                    className: "security-admin-transactions-decline",
                    onClick: () => de(f),
                    title: "Decline",
                    children: "✕"
                  }
                )
              ] }) : "N/A" }),
              /* @__PURE__ */ e.jsxs("td", { children: [
                /* @__PURE__ */ e.jsxs("span", { children: [
                  "(",
                  j,
                  "/",
                  f.minimumApprovalCount,
                  ")"
                ] }),
                /* @__PURE__ */ e.jsx(
                  "button",
                  {
                    className: "security-admin-transactions-more-info",
                    onClick: () => P(f.transactionId),
                    title: "More info",
                    children: a.has(f.transactionId) ? "▲" : "▼"
                  }
                ),
                f.warningMessage && /* @__PURE__ */ e.jsx(
                  "span",
                  {
                    className: "security-admin-transactions-warning",
                    title: f.warningMessage,
                    children: "⚠"
                  }
                )
              ] })
            ] }),
            a.has(f.transactionId) && /* @__PURE__ */ e.jsx("tr", { className: "security-admin-transactions-info-row", children: /* @__PURE__ */ e.jsx("td", { colSpan: 6, children: /* @__PURE__ */ e.jsx(Rt, { transaction: f }) }) })
          ] }, f.transactionId);
        }) })
      ] }) })
    ] }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: h,
        message: M,
        onClose: () => T(!1),
        type: x
      }
    )
  ] });
}
const Fc = /* @__PURE__ */ e.jsx(e.Fragment, { children: "Copy this passphrase and give it to the user whose account is being recovered. After all approvals, they will be notified to reset their security questions using this passphrase." });
function Wn({
  isOpen: r,
  passphrase: t,
  onClose: s,
  title: n = "One-time recovery passphrase",
  description: a = Fc,
  targetUserEmail: o,
  isLoading: i = !1,
  loadingMessage: c = "Fetching and decrypting passphrase...",
  errorMessage: l = "",
  closeButtonLabel: d = "Close",
  copyButtonLabel: u = "Copy",
  copySuccessText: m = "Copied",
  copyErrorText: p = "Copy failed",
  onCopySuccess: y,
  onCopyError: g
}) {
  const [w, h] = b(u), M = Re(null);
  if (ve(() => {
    h(u), M.current && (window.clearTimeout(M.current), M.current = null);
  }, [u, r, t]), ve(() => () => {
    M.current && window.clearTimeout(M.current);
  }, []), !r) return null;
  const x = () => {
    M.current && window.clearTimeout(M.current), M.current = window.setTimeout(() => {
      h(u), M.current = null;
    }, 1500);
  }, T = async () => {
    if (t) {
      try {
        await navigator.clipboard.writeText(t), h(m), y == null || y();
      } catch (R) {
        console.error("Error copying passphrase:", R), h(p), g == null || g();
      }
      x();
    }
  };
  return /* @__PURE__ */ e.jsx(
    "div",
    {
      className: "security-admin-transactions-modal-overlay",
      role: "dialog",
      "aria-modal": "true",
      children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content security-admin-transactions-passphrase-modal", children: [
        /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-title", children: n }),
        /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-message", children: [
          o && /* @__PURE__ */ e.jsxs("div", { children: [
            "Target user: ",
            o
          ] }),
          a && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-passphrase-description", children: a }),
          i ? /* @__PURE__ */ e.jsx("div", { children: c }) : l ? /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-passphrase-error", children: l }) : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
            /* @__PURE__ */ e.jsx("label", { className: "security-admin-transactions-passphrase-label", children: "Passphrase" }),
            /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-passphrase-field", children: [
              /* @__PURE__ */ e.jsx(
                "textarea",
                {
                  readOnly: !0,
                  value: t,
                  className: "security-admin-transactions-passphrase-textarea",
                  "aria-label": "User recovery passphrase"
                }
              ),
              /* @__PURE__ */ e.jsx(
                "button",
                {
                  type: "button",
                  className: "security-admin-transactions-modal-button-yes security-admin-transactions-copy-button",
                  onClick: T,
                  disabled: !t,
                  children: w
                }
              )
            ] })
          ] })
        ] }),
        /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-buttons", children: /* @__PURE__ */ e.jsx(
          "button",
          {
            type: "button",
            className: "security-admin-transactions-modal-button-no",
            onClick: s,
            children: d
          }
        ) })
      ] })
    }
  );
}
const Bc = (r) => r === $.IN_PROGRESS ? "In Progress" : r, Gc = (r) => r.transactionStatus === $.DECLINED && r.userMemberDeletedMidTransaction === !0 ? "Only member linked to user got deleted" : null;
function Zr({
  transactions: r,
  isLoading: t = !1,
  onTransactionsUpdated: s
}) {
  console.log("transactions", r);
  const { renderLoader: n } = De(), [a, o] = b(/* @__PURE__ */ new Set()), [i, c] = b(""), [l, d] = b(!1), [u, m] = b(!1), [p, y] = b(!1), [g, w] = b(null), [h, M] = b(!1), [x, T] = b(!1), {
    snackbarOpen: R,
    snackbarMessage: D,
    snackbarType: U,
    setSnackbarOpen: q,
    showSnackbar: N
  } = bt(), [P, Y] = b(!1), [re, J] = b(null), [le, Q] = b(""), [de, te] = b(""), [K, X] = b(null);
  ve(() => {
    (async () => {
      try {
        const Z = ue(), z = O("bayunSessionId");
        if (Z && z) {
          const [ce, he] = await Promise.all([
            Z.getFromStorage(
              z,
              v.ORG_MEMBER_ID
            ),
            Z.getFromStorage(
              z,
              v.MEMBER_STATUS
            )
          ]);
          ce && c(ce);
          const Ie = mt(he);
          d(
            Ie.memberStatus === ct.ADMIN
          );
        }
      } catch (Z) {
        console.error("Error fetching logged in member info:", Z);
      }
    })();
  }, []);
  const I = (E) => {
    const Z = new Set(a);
    Z.has(E) ? Z.delete(E) : Z.add(E), o(Z);
  }, f = (E) => {
    w(E), m(!0);
  }, j = () => {
    m(!1), w(null), M(!1);
  }, C = async () => {
    if (!g) return;
    M(!0);
    const E = ue();
    if (!E)
      throw new Error("Internal not found");
    const Z = O("bayunSessionId");
    if (!Z)
      throw new Error("Session ID not found in cookies");
    const z = await E.getFromStorage(
      Z,
      v.MEMBER_PRIVATE_KEY
    ), ce = await E.getFromStorage(
      Z,
      v.ORG_NAME
    ), he = await _e.getAdminPrivateKey(), Ie = O("baseURL");
    if (!Ie)
      throw new Error("Base URL not found in cookies");
    if (!await E.retrieveAndverifyLastSignature(
      Z,
      g.signedTransactionId
    ))
      throw new Error("Signed transaction ID verification failed");
    let xe = null, A = null, se = [];
    if (g.createTransactionEncryptionKeys === "true") {
      xe = await E.generateAesKey();
      const Me = await rt(
        Z,
        ce,
        E
      );
      se = await pt(
        xe,
        Me,
        he,
        z,
        ce,
        E
      ), A = await We(
        Z,
        Ie,
        z,
        null,
        xe,
        E
      );
    } else
      A = await We(
        Z,
        Ie,
        z,
        g.transactionId,
        null,
        E
      );
    const ie = await Ce(E, Z), Ee = await E.generateHMacHash(
      ie,
      "lms" + ce
    ), je = await E.getFromStorage(
      Z,
      v.MEMBER_APP_ID
    ) || "";
    if (!A)
      throw new Error("Backdoor private key part not found");
    let Ae = await E.signData(
      g.transactionId,
      he,
      E.context.getTransactionIdContext(g.transactionId, $.IN_PROGRESS, g.transactionLabel, ce, i)
    );
    Ae = await E.appendSignatureAndMetadata(
      g.signedTransactionId,
      Ae,
      E.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      E.context.getTransactionIdContext(g.transactionId, $.IN_PROGRESS, g.transactionLabel, ce, i)
    );
    const pe = {
      transactionId: g.transactionId,
      backdoorPrivateKeyPart: A,
      authPasscodeHash: null,
      memberAppId: je,
      lmsTransactionKey: Ee,
      transactionEncryptionKeyRequestList: se,
      signedTransactionId: Ae
    };
    try {
      const Me = await we.approveTransaction(pe);
      await $t(
        Z,
        Me,
        g.transactionId,
        ie,
        Ee,
        xe,
        z,
        i,
        ce,
        Object.keys(g.approvedByMembers).length.toString(),
        he,
        Ae,
        g.transactionLabel
      ), j(), s && await s();
    } catch (Me) {
      console.error("Error approving transaction:", Me), N("Failed to approve transaction. Please try again.", "error"), M(!1);
    }
  }, k = () => g ? g.warningMessage ? g.warningMessage.trim() === "" ? "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to " + (g.newMinimumApprovalCount || g.minimumApprovalCount) + ". Would you still like to approve this transaction?" : g.warningMessage + " Would you still like to approve this transaction?" : "Would you like to approve this transaction?" : "", H = (E) => {
    w(E), y(!0);
  }, V = () => {
    y(!1), w(null), T(!1);
  }, F = async () => {
    var E, Z;
    if (g) {
      T(!0);
      try {
        const z = ue();
        if (!z)
          throw new Error("Internal not found");
        const ce = O("bayunSessionId");
        if (!ce)
          throw new Error("Session ID not found in cookies");
        const he = await z.getFromStorage(
          ce,
          v.ORG_NAME
        ), Ie = await Ce(z, ce), xe = await _e.getAdminPrivateKey(), A = await z.generateHMacHash(
          Ie,
          "lms" + he
        ), se = await z.aeadEncryptWithAssociatedData(
          $.DECLINED,
          "lms" + he,
          A
        );
        if (!g.signedTransactionId)
          throw new Error("Signed transaction ID not found");
        if (!await z.retrieveAndverifyLastSignature(
          ce,
          g.signedTransactionId
        ))
          throw new Error("Signed transaction ID verification failed");
        let ie = await z.signData(
          g.transactionId,
          xe,
          z.context.getTransactionIdContext(g.transactionId, $.DECLINED, g.transactionLabel, he, i)
        );
        ie = await z.appendSignatureAndMetadata(
          g.signedTransactionId,
          ie,
          z.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          z.context.getTransactionIdContext(g.transactionId, $.DECLINED, g.transactionLabel, he, i)
        ), await we.declineTransaction({
          transactionId: g.transactionId,
          lmsTransactionKey: A,
          transactionStatus: se,
          signedTransactionId: ie
        }), V(), s ? await s() : window.location.reload();
      } catch (z) {
        console.error("Error declining transaction:", z);
        const ce = ((Z = (E = z == null ? void 0 : z.response) == null ? void 0 : E.data) == null ? void 0 : Z.errorMessage) || (z == null ? void 0 : z.message) || "Failed to decline transaction. Please try again.";
        N(ce, "error"), T(!1);
      }
    }
  }, _ = (E) => {
    let Z = E.approvedByMembers ? Object.keys(E.approvedByMembers).length : 0;
    return E.declinedByMember && E.approvedByMembers && Object.keys(E.approvedByMembers).includes(
      E.declinedByMember
    ) && Z--, Z;
  }, B = (E) => E.transactionStatus === $.APPROVED ? !0 : E.approvedByMembers ? Object.keys(E.approvedByMembers).includes(
    i
  ) : !1, oe = (E) => E.transactionStatus !== $.COMPLETED && E.transactionStatus !== $.DECLINED, fe = (E) => E.transactionStatus !== $.COMPLETED && E.transactionStatus !== $.DECLINED, G = (E) => E.initiator === i, ne = async (E) => {
    var Z, z;
    if (G(E)) {
      J(E), Q(""), te(""), Y(!0), X(E.transactionId);
      try {
        const ce = ue();
        if (!ce)
          throw new Error("Internal not found");
        const he = O("bayunSessionId");
        if (!he)
          throw new Error("Session ID not found in cookies");
        const Ie = await we.getUserAccountRecoveryPassphraseDetails({
          transactionId: E.transactionId,
          userEmailAddress: E.targetUserEmailAddress
        }), xe = await ce.getFromStorage(
          he,
          v.ADMIN_PUBLIC_KEY
        );
        if (!xe)
          throw new Error("Admin public key not found");
        if (!await ce.verifyMessageForPublicKeyTag(
          he,
          Ie.adminEncryptedTargetUserPassphrase_kek,
          xe,
          ce.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG
        ))
          throw new Error(
            "Signature verification failed for target user passphrase kek"
          );
        const se = await _e.getAdminPrivateKey(), ie = await ce.decryptAsymmetric(
          Ie.adminEncryptedTargetUserPassphrase,
          se,
          Ie.adminEncryptedTargetUserPassphrase_kek.split(
            Ne
          )[0],
          E.targetUserEmailAddress
        );
        Q(ie);
      } catch (ce) {
        console.error("Error fetching user recovery passphrase:", ce), te(
          ((z = (Z = ce == null ? void 0 : ce.response) == null ? void 0 : Z.data) == null ? void 0 : z.errorMessage) || (ce == null ? void 0 : ce.message) || "Failed to fetch passphrase. Please try again."
        );
      } finally {
        X(null);
      }
    }
  }, me = () => {
    Y(!1), J(null), Q(""), te("");
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    u && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: k() }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: C,
            loading: h,
            loadingText: "Approving...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: j,
            disabled: h,
            children: "No"
          }
        )
      ] })
    ] }) }),
    p && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: "Would you like to decline this transaction?" }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: F,
            loading: x,
            loadingText: "Declining...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: V,
            disabled: x,
            children: "No"
          }
        )
      ] })
    ] }) }),
    /* @__PURE__ */ e.jsx(
      Wn,
      {
        isOpen: P,
        title: "User Recovery Passphrase",
        description: null,
        targetUserEmail: re == null ? void 0 : re.targetUserEmailAddress,
        passphrase: le,
        isLoading: !!K,
        errorMessage: de,
        onClose: me
      }
    ),
    /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-title", children: "User Account Recovery Transactions" }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-list", children: t ? n(t, "Loading user account recovery transactions...") : r.length > 0 ? /* @__PURE__ */ e.jsxs("table", { className: "security-admin-transactions-table", children: [
        /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
          /* @__PURE__ */ e.jsx("th", { children: "Target user email" }),
          /* @__PURE__ */ e.jsx("th", { children: "Initiator" }),
          /* @__PURE__ */ e.jsxs("th", { children: [
            "Status",
            /* @__PURE__ */ e.jsx(
              Ke,
              {
                variant: "dark",
                wide: !0,
                content: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                  /* @__PURE__ */ e.jsx("b", { children: "In Progress: " }),
                  " The transaction is currently in progress and requires minimum number of approvals to complete.",
                  /* @__PURE__ */ e.jsx("br", {}),
                  /* @__PURE__ */ e.jsx("b", { children: "Approved: " }),
                  " The transaction has received the required number of approvals and the user is required to reset their security questions using the recovery passphrase.",
                  /* @__PURE__ */ e.jsx("br", {}),
                  /* @__PURE__ */ e.jsx("b", { children: "Completed: " }),
                  " The user account recovery has been successfully completed.",
                  /* @__PURE__ */ e.jsx("br", {}),
                  /* @__PURE__ */ e.jsx("b", { children: "Declined: " }),
                  " The transaction is declined by one of the Security Admins."
                ] })
              }
            )
          ] }),
          !l && /* @__PURE__ */ e.jsx("th", { children: "Action" }),
          /* @__PURE__ */ e.jsx("th", { children: "Passphrase" }),
          !l && /* @__PURE__ */ e.jsx("th", { children: "Approvals" })
        ] }) }),
        /* @__PURE__ */ e.jsx("tbody", { children: r.map((E) => {
          const Z = _(E), z = B(E), ce = oe(E), he = fe(E), Ie = G(E), xe = Gc(E);
          return /* @__PURE__ */ e.jsxs(lt.Fragment, { children: [
            /* @__PURE__ */ e.jsxs("tr", { children: [
              /* @__PURE__ */ e.jsx("td", { children: E.targetUserEmailAddress }),
              /* @__PURE__ */ e.jsx("td", { children: E.initiator }),
              /* @__PURE__ */ e.jsxs("td", { children: [
                /* @__PURE__ */ e.jsx(
                  "span",
                  {
                    className: `status-badge ${E.transactionStatus === $.IN_PROGRESS ? "status-in-progress" : E.transactionStatus === $.COMPLETED ? "status-completed" : E.transactionStatus === $.DECLINED ? "status-declined" : ""}`,
                    children: Bc(E.transactionStatus)
                  }
                ),
                xe && /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    content: xe
                  }
                )
              ] }),
              !l && /* @__PURE__ */ e.jsx("td", { children: ce ? z ? /* @__PURE__ */ e.jsx(
                "button",
                {
                  className: "security-admin-transactions-decline",
                  onClick: () => H(E),
                  title: "Decline",
                  children: "✕"
                }
              ) : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                /* @__PURE__ */ e.jsx(
                  "button",
                  {
                    className: "security-admin-transactions-approve",
                    onClick: () => f(E),
                    title: "Approve",
                    children: "✓"
                  }
                ),
                /* @__PURE__ */ e.jsx(
                  "button",
                  {
                    className: "security-admin-transactions-decline",
                    onClick: () => H(E),
                    title: "Decline",
                    children: "✕"
                  }
                )
              ] }) : "N/A" }),
              /* @__PURE__ */ e.jsx("td", { children: he ? /* @__PURE__ */ e.jsx(
                Pe,
                {
                  className: "security-admin-transactions-passphrase",
                  onClick: () => ne(E),
                  disabled: !Ie,
                  loading: K === E.transactionId,
                  loadingText: "Loading...",
                  title: Ie ? "Show passphrase" : "Only the initiator can view the passphrase",
                  children: "Show"
                }
              ) : "N/A" }),
              !l && /* @__PURE__ */ e.jsxs("td", { children: [
                /* @__PURE__ */ e.jsxs("span", { children: [
                  "(",
                  Z,
                  "/",
                  E.minimumApprovalCount,
                  ")"
                ] }),
                /* @__PURE__ */ e.jsx(
                  "button",
                  {
                    className: "security-admin-transactions-more-info",
                    onClick: () => I(E.transactionId),
                    title: "More info",
                    children: a.has(E.transactionId) ? "▲" : "▼"
                  }
                ),
                E.warningMessage && /* @__PURE__ */ e.jsx(
                  "span",
                  {
                    className: "security-admin-transactions-warning",
                    title: E.warningMessage,
                    children: "⚠"
                  }
                )
              ] })
            ] }),
            a.has(E.transactionId) && /* @__PURE__ */ e.jsx("tr", { className: "security-admin-transactions-info-row", children: /* @__PURE__ */ e.jsx("td", { colSpan: l ? 4 : 6, children: /* @__PURE__ */ e.jsx(
              Rt,
              {
                transaction: E,
                showAcceptanceStep: !0
              }
            ) }) })
          ] }, E.transactionId);
        }) })
      ] }) : /* @__PURE__ */ e.jsx("div", { className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
        /* @__PURE__ */ e.jsx("div", { className: "empty-icon" }),
        /* @__PURE__ */ e.jsx("h3", { children: "No recovery transactions" }),
        /* @__PURE__ */ e.jsx("p", { children: "There are no user account recovery transactions to display." })
      ] }) }) })
    ] }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: R,
        message: D,
        onClose: () => q(!1),
        type: U
      }
    )
  ] });
}
const Yc = (r) => r === $.IN_PROGRESS ? "In Progress" : r;
function Vs({
  transactions: r,
  isLoading: t = !1,
  onTransactionsUpdated: s,
  readOnly: n = !1
}) {
  const { renderLoader: a } = De(), [o, i] = b(/* @__PURE__ */ new Set()), [c, l] = b(""), [d, u] = b(!1), [m, p] = b(!1), [y, g] = b(null), [w, h] = b(!1), [M, x] = b(!1), {
    snackbarOpen: T,
    snackbarMessage: R,
    snackbarType: D,
    setSnackbarOpen: U,
    showSnackbar: q
  } = bt();
  ve(() => {
    (async () => {
      try {
        const j = ue(), C = O("bayunSessionId");
        if (!j || !C) return;
        const k = await j.getFromStorage(
          C,
          v.ORG_MEMBER_ID
        );
        k && l(k);
      } catch (j) {
        console.error("Error fetching logged in org member ID:", j);
      }
    })();
  }, []);
  const N = (f) => {
    const j = new Set(o);
    j.has(f) ? j.delete(f) : j.add(f), i(j);
  }, P = (f) => {
    g(f), u(!0);
  }, Y = (f) => {
    g(f), p(!0);
  }, re = () => {
    u(!1), g(null), h(!1);
  }, J = () => {
    p(!1), g(null), x(!1);
  }, le = async () => {
    s ? await s() : window.location.reload();
  }, Q = (f) => {
    let j = f.approvedByMembers ? Object.keys(f.approvedByMembers).length : 0;
    return f.declinedByMember && f.approvedByMembers && Object.keys(f.approvedByMembers).includes(
      f.declinedByMember
    ) && j--, j;
  }, de = (f) => f.transactionStatus !== $.COMPLETED && f.transactionStatus !== $.DECLINED, te = (f) => {
    let j = !1, C = "";
    return f.approvedByMembers && (j = Object.keys(f.approvedByMembers).includes(
      c
    )), f.transactionStatus === $.APPROVED && (j = !0), j || (!f.sourceMemberExist && !f.targetMemberExist ? (j = !0, C = "Transaction cannot proceed because: Old Owner and New Owner do not exist anymore") : f.sourceMemberExist ? f.targetMemberExist || (j = !0, C = "Transaction cannot proceed because: New Owner does not exist anymore") : (j = !0, C = "Transaction cannot proceed because: Old Owner does not exist anymore")), { showDecline: j, approveDisabledReason: C };
  }, K = () => y != null && y.warningMessage ? y.warningMessage.trim() === "" ? "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to " + (y.newMinimumApprovalCount || y.minimumApprovalCount) + ". Would you still like to approve this transaction?" : `${y.warningMessage} Would you still like to approve this transaction?` : "Would you like to approve this transaction?", X = async () => {
    if (y) {
      h(!0);
      try {
        const f = ue();
        if (!f)
          throw new Error("Internal not found");
        const j = O("bayunSessionId");
        if (!j)
          throw new Error("Session ID not found in cookies");
        const C = await f.getFromStorage(
          j,
          v.MEMBER_PRIVATE_KEY
        ), k = await _e.getAdminPrivateKey(), H = await f.getFromStorage(
          j,
          v.ORG_NAME
        ), V = await Ce(f, j), F = await f.getFromStorage(
          j,
          v.MEMBER_APP_ID
        ) || "", _ = O("baseURL");
        if (!_)
          throw new Error("Base URL not found in cookies");
        if (!await f.retrieveAndverifyLastSignature(
          j,
          y.signedTransactionId
        ))
          throw new Error("Signed transaction ID verification failed");
        let B = null, oe = null, fe = [];
        if (y.createTransactionEncryptionKeys === "true") {
          B = await f.generateAesKey();
          const Z = await rt(
            j,
            H,
            f
          );
          fe = await pt(
            B,
            Z,
            k,
            C,
            H,
            f
          ), oe = await We(
            j,
            _,
            C,
            null,
            B,
            f
          );
        } else
          oe = await We(
            j,
            _,
            C,
            y.transactionId,
            null,
            f
          );
        if (!oe)
          throw new Error("Backdoor private key part not found");
        const G = await f.generateHMacHash(
          V,
          "lms" + H
        );
        let ne = await f.signData(
          y.transactionId,
          k,
          f.context.getTransactionIdContext(y.transactionId, $.IN_PROGRESS, y.transactionLabel, H, c)
        );
        ne = await f.appendSignatureAndMetadata(
          y.signedTransactionId,
          ne,
          f.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          f.context.getTransactionIdContext(y.transactionId, $.IN_PROGRESS, y.transactionLabel, H, c)
        );
        const me = {
          transactionId: y.transactionId,
          backdoorPrivateKeyPart: oe,
          authPasscodeHash: null,
          memberAppId: F,
          lmsTransactionKey: G,
          transactionEncryptionKeyRequestList: fe,
          currentApprovalCount: Object.keys(
            y.approvedByMembers || {}
          ).length,
          minimumApprovalCount: y.minimumApprovalCount,
          signedTransactionId: ne
        }, E = await we.approveTransaction(me);
        await $t(
          j,
          E,
          y.transactionId,
          V,
          G,
          B,
          C,
          c,
          H,
          Object.keys(
            y.approvedByMembers || {}
          ).length.toString(),
          k,
          ne,
          y.transactionLabel
        ), re(), await le();
      } catch (f) {
        console.error("Error approving transaction:", f), q("Failed to approve transaction. Please try again.", "error"), h(!1);
      }
    }
  }, I = async () => {
    var f, j;
    if (y) {
      x(!0);
      try {
        const C = ue();
        if (!C)
          throw new Error("Internal not found");
        const k = O("bayunSessionId");
        if (!k)
          throw new Error("Session ID not found in cookies");
        const H = await C.getFromStorage(
          k,
          v.ORG_NAME
        ), V = await Ce(C, k), F = await _e.getAdminPrivateKey(), _ = await C.generateHMacHash(
          V,
          "lms" + H
        ), B = await C.aeadEncryptWithAssociatedData(
          $.DECLINED,
          "lms" + H,
          _
        );
        if (!await C.retrieveAndverifyLastSignature(
          k,
          y.signedTransactionId
        ))
          throw new Error("Signed transaction ID verification failed");
        let oe = await C.signData(
          y.transactionId,
          F,
          C.context.getTransactionIdContext(y.transactionId, $.DECLINED, y.transactionLabel, H, c)
        );
        oe = await C.appendSignatureAndMetadata(
          y.signedTransactionId,
          oe,
          C.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          C.context.getTransactionIdContext(y.transactionId, $.DECLINED, y.transactionLabel, H, c)
        ), await we.declineTransaction({
          transactionId: y.transactionId,
          lmsTransactionKey: _,
          transactionStatus: B,
          signedTransactionId: oe
        }), J(), await le();
      } catch (C) {
        console.error("Error declining transaction:", C);
        const k = ((j = (f = C == null ? void 0 : C.response) == null ? void 0 : f.data) == null ? void 0 : j.errorMessage) || (C == null ? void 0 : C.message) || "Failed to decline transaction. Please try again.";
        q(k, "error"), x(!1);
      }
    }
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    d && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: K() }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: X,
            loading: w,
            loadingText: "Approving...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: re,
            disabled: w,
            children: "No"
          }
        )
      ] })
    ] }) }),
    m && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: "Would you like to decline this transaction?" }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: I,
            loading: M,
            loadingText: "Declining...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: J,
            disabled: M,
            children: "No"
          }
        )
      ] })
    ] }) }),
    /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-title", children: "Lockbox Ownership Transfer Transactions" }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-list", children: t ? a(t, "Loading lockbox ownership transfer transactions...") : /* @__PURE__ */ e.jsxs(
        "table",
        {
          className: "security-admin-transactions-table",
          id: "lockbox-transfer-transactions-table",
          children: [
            /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
              /* @__PURE__ */ e.jsx("th", { children: "Initiator" }),
              /* @__PURE__ */ e.jsx("th", { children: "Old Owner" }),
              /* @__PURE__ */ e.jsx("th", { children: "New Owner" }),
              /* @__PURE__ */ e.jsxs("th", { children: [
                "Status",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    wide: !0,
                    content: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                      /* @__PURE__ */ e.jsx("b", { children: "In Progress: " }),
                      " The transaction is currently in progress and requires minimum number of approvals to complete.",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Approved: " }),
                      " The transaction has received the required number of approvals and is waiting for the new owner to accept the lockbox.",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Completed: " }),
                      " The lockbox has been successfully transferred to the new owner.",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Declined: " }),
                      " The transaction is declined by one of the Security Admins."
                    ] })
                  }
                )
              ] }),
              !n && /* @__PURE__ */ e.jsxs("th", { children: [
                "Action",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    wide: !0,
                    content: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                      /* @__PURE__ */ e.jsx("b", { children: "Approve: " }),
                      " Approval is registered for the transaction.",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Decline: " }),
                      " The transaction is completely scrapped if declined.",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "N/A: " }),
                      " No Pending Actions."
                    ] })
                  }
                )
              ] }),
              /* @__PURE__ */ e.jsxs("th", { children: [
                "Approvals",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    content: /* @__PURE__ */ e.jsx(e.Fragment, { children: "Approvals / Approvals Required." })
                  }
                )
              ] })
            ] }) }),
            /* @__PURE__ */ e.jsx("tbody", { children: r.filter(
              (f) => f.transactionLabel === be.TRANSFER_LOCK_BOX
            ).map((f) => {
              const j = Q(f), C = de(f), { showDecline: k, approveDisabledReason: H } = te(f);
              return /* @__PURE__ */ e.jsxs(lt.Fragment, { children: [
                /* @__PURE__ */ e.jsxs("tr", { children: [
                  /* @__PURE__ */ e.jsx("td", { children: f.initiator }),
                  /* @__PURE__ */ e.jsx("td", { children: f.sourceOrgMemberId }),
                  /* @__PURE__ */ e.jsx("td", { children: f.targetOrgMemberId }),
                  /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx(
                    "span",
                    {
                      className: `status-badge ${f.transactionStatus === $.IN_PROGRESS ? "status-in-progress" : f.transactionStatus === $.COMPLETED ? "status-completed" : f.transactionStatus === $.DECLINED ? "status-declined" : ""}`,
                      children: Yc(f.transactionStatus)
                    }
                  ) }),
                  !n && /* @__PURE__ */ e.jsx("td", { id: `approve-${f.transactionId}`, children: C ? k ? /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-decline",
                        onClick: () => Y(f),
                        title: "Decline",
                        children: "✕"
                      }
                    ),
                    H && /* @__PURE__ */ e.jsx(
                      Ke,
                      {
                        variant: "dark",
                        content: H
                      }
                    )
                  ] }) : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-approve",
                        onClick: () => P(f),
                        title: "Approve",
                        children: "✓"
                      }
                    ),
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-decline",
                        onClick: () => Y(f),
                        title: "Decline",
                        children: "✕"
                      }
                    )
                  ] }) : "N/A" }),
                  /* @__PURE__ */ e.jsxs("td", { id: `icon-${f.transactionId}`, children: [
                    /* @__PURE__ */ e.jsxs("span", { children: [
                      "(",
                      j,
                      "/",
                      f.minimumApprovalCount,
                      ")"
                    ] }),
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-more-info",
                        onClick: () => N(f.transactionId),
                        title: "More info",
                        children: o.has(f.transactionId) ? "▲" : "▼"
                      }
                    )
                  ] })
                ] }),
                o.has(f.transactionId) && /* @__PURE__ */ e.jsx("tr", { className: "security-admin-transactions-info-row", children: /* @__PURE__ */ e.jsx("td", { colSpan: n ? 5 : 6, children: /* @__PURE__ */ e.jsx(
                  Rt,
                  {
                    transaction: f,
                    showAcceptanceStep: !0
                  }
                ) }) })
              ] }, f.transactionId);
            }) })
          ]
        }
      ) })
    ] }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: T,
        message: R,
        onClose: () => U(!1),
        type: D
      }
    )
  ] });
}
const Vc = (r) => r === $.IN_PROGRESS ? "In Progress" : r;
function qc({
  transactions: r,
  isLoading: t = !1
}) {
  const { renderLoader: s } = De(), [n, a] = b(/* @__PURE__ */ new Set()), [o, i] = b(""), [c, l] = b(!1), [d, u] = b(!1), [m, p] = b(null), [y, g] = b(!1), [w, h] = b(!1), {
    snackbarOpen: M,
    snackbarMessage: x,
    snackbarType: T,
    setSnackbarOpen: R,
    showSnackbar: D
  } = bt();
  ve(() => {
    (async () => {
      try {
        const X = ue(), I = O("bayunSessionId");
        if (X && I) {
          const f = await X.getFromStorage(
            I,
            v.ORG_MEMBER_ID
          );
          f && i(f);
        }
      } catch (X) {
        console.error("Error fetching logged in org member ID:", X);
      }
    })();
  }, []);
  const U = (K) => {
    const X = new Set(n);
    X.has(K) ? X.delete(K) : X.add(K), a(X);
  }, q = (K) => {
    p(K), l(!0);
  }, N = () => {
    l(!1), p(null), g(!1);
  }, P = () => {
    u(!1), p(null), h(!1);
  }, Y = async () => {
    if (!m) return;
    g(!0);
    const K = ue();
    if (!K)
      throw new Error("Internal not found");
    const X = O("bayunSessionId");
    if (!X)
      throw new Error("Session ID not found in cookies");
    const I = await K.getFromStorage(
      X,
      v.MEMBER_PRIVATE_KEY
    ), f = await K.getFromStorage(
      X,
      v.ORG_NAME
    ), j = await _e.getAdminPrivateKey(), C = O("baseURL");
    if (!C)
      throw new Error("Base URL not found in cookies");
    let k = null, H = null, V = [];
    if (m.createTransactionEncryptionKeys === "true") {
      k = await K.generateAesKey();
      const G = await rt(
        X,
        f,
        K
      );
      V = await pt(
        k,
        G,
        j,
        I,
        f,
        K
      ), H = await We(
        X,
        C,
        I,
        null,
        k,
        K
      );
    } else
      H = await We(
        X,
        C,
        I,
        m.transactionId,
        null,
        K
      );
    const F = await Ce(K, X), _ = await K.generateHMacHash(
      F,
      "lms" + f
    ), B = await K.getFromStorage(
      X,
      v.MEMBER_APP_ID
    ) || "";
    if (!H)
      throw new Error("Backdoor private key part not found");
    if (!await K.retrieveAndverifyLastSignature(
      X,
      m.signedTransactionId
    ))
      throw new Error("Signed transaction ID verification failed");
    let oe = await K.signData(
      m.transactionId,
      j,
      K.context.getTransactionIdContext(m.transactionId, $.IN_PROGRESS, m.transactionLabel, f, o)
    );
    oe = await K.appendSignatureAndMetadata(
      m.signedTransactionId,
      oe,
      K.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      K.context.getTransactionIdContext(m.transactionId, $.IN_PROGRESS, m.transactionLabel, f, o)
    );
    const fe = {
      transactionId: m.transactionId,
      backdoorPrivateKeyPart: H,
      authPasscodeHash: null,
      memberAppId: B,
      lmsTransactionKey: _,
      transactionEncryptionKeyRequestList: V,
      minimumApprovalCount: m.minimumApprovalCount,
      signedTransactionId: oe
    };
    try {
      const G = await we.approveTransaction(fe);
      await $t(
        X,
        G,
        m.transactionId,
        F,
        _,
        k,
        I,
        o,
        f,
        Object.keys(
          m.approvedByMembers || {}
        ).length.toString(),
        j,
        oe,
        m.transactionLabel
      ), N(), window.location.reload();
    } catch (G) {
      console.error("Error approving transaction:", G), D("Failed to approve transaction. Please try again.", "error"), g(!1);
    }
  }, re = () => m ? m.warningMessage ? m.warningMessage.trim() === "" ? "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to " + (m.newMinimumApprovalCount || m.minimumApprovalCount) + ". Would you still like to approve this transaction?" : m.warningMessage + " Would you still like to approve this transaction?" : "Would you like to approve this transaction?" : "", J = (K) => {
    p(K), u(!0);
  }, le = async () => {
    var K, X;
    if (m) {
      h(!0);
      try {
        const I = ue();
        if (!I)
          throw new Error("Internal not found");
        const f = O("bayunSessionId");
        if (!f)
          throw new Error("Session ID not found in cookies");
        const j = await I.getFromStorage(
          f,
          v.ORG_NAME
        ), C = await _e.getAdminPrivateKey(), k = await Ce(I, f), H = await I.generateHMacHash(
          k,
          "lms" + j
        ), V = await I.aeadEncryptWithAssociatedData(
          $.DECLINED,
          "lms" + j,
          H
        );
        if (!await I.retrieveAndverifyLastSignature(
          f,
          m.signedTransactionId
        ))
          throw new Error("Signed transaction ID verification failed");
        let F = await I.signData(
          m.transactionId,
          C,
          I.context.getTransactionIdContext(m.transactionId, $.DECLINED, m.transactionLabel, j, o)
        );
        F = await I.appendSignatureAndMetadata(
          m.signedTransactionId,
          F,
          I.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          I.context.getTransactionIdContext(m.transactionId, $.DECLINED, m.transactionLabel, j, o)
        ), await we.declineTransaction({
          transactionId: m.transactionId,
          lmsTransactionKey: H,
          transactionStatus: V,
          signedTransactionId: F
        }), P(), window.location.reload();
      } catch (I) {
        console.error("Error declining transaction:", I);
        const f = ((X = (K = I == null ? void 0 : I.response) == null ? void 0 : K.data) == null ? void 0 : X.errorMessage) || (I == null ? void 0 : I.message) || "Failed to decline transaction. Please try again.";
        D(f, "error"), h(!1);
      }
    }
  }, Q = (K) => {
    let X = K.approvedByMembers ? Object.keys(K.approvedByMembers).length : 0;
    return K.declinedByMember && K.approvedByMembers && Object.keys(K.approvedByMembers).includes(
      K.declinedByMember
    ) && X--, X;
  }, de = (K) => K.approvedByMembers ? Object.keys(K.approvedByMembers).includes(
    o
  ) : !1, te = (K) => K.transactionStatus !== $.COMPLETED && K.transactionStatus !== $.DECLINED;
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    c && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: re() }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: Y,
            loading: y,
            loadingText: "Approving...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: N,
            disabled: y,
            children: "No"
          }
        )
      ] })
    ] }) }),
    d && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: "Would you like to decline this transaction?" }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: le,
            loading: w,
            loadingText: "Declining...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: P,
            disabled: w,
            children: "No"
          }
        )
      ] })
    ] }) }),
    /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-title", children: /* @__PURE__ */ e.jsxs("span", { children: [
        "Transactions to Update Minimum Approvals Required",
        /* @__PURE__ */ e.jsx(
          Ke,
          {
            variant: "dark",
            wide: !0,
            content: /* @__PURE__ */ e.jsx(e.Fragment, { children: "This transaction only changes the minimum number of security admins' approval required for all the future transactions." })
          }
        )
      ] }) }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-list", children: t ? s(t, "Loading minimum approval transactions...") : /* @__PURE__ */ e.jsxs(
        "table",
        {
          className: "security-admin-transactions-table",
          id: "edit-minimum-approval-count-transactions-table",
          children: [
            /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
              /* @__PURE__ */ e.jsx("th", { children: "Initiator" }),
              /* @__PURE__ */ e.jsx("th", { children: "Previous Count" }),
              /* @__PURE__ */ e.jsx("th", { children: "New Count" }),
              /* @__PURE__ */ e.jsxs("th", { children: [
                "Status",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    wide: !0,
                    content: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                      /* @__PURE__ */ e.jsx("b", { children: "In Progress: " }),
                      " The transaction is currently in progress and requires minimum number of approvals to get complete. ",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Completed: " }),
                      " The transaction has received the required number of approvals and is completed. ",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Declined: " }),
                      " The transaction is declined by one of the Security Admins."
                    ] })
                  }
                )
              ] }),
              /* @__PURE__ */ e.jsxs("th", { children: [
                "Action",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    wide: !0,
                    content: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                      /* @__PURE__ */ e.jsx("b", { children: "Approve: " }),
                      " Approval is registered for the transaction. ",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Decline: " }),
                      " The transaction is completely scrapped if declined. ",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "N/A: " }),
                      " No Pending Actions."
                    ] })
                  }
                )
              ] }),
              /* @__PURE__ */ e.jsxs("th", { children: [
                "Approvals",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    content: /* @__PURE__ */ e.jsx(e.Fragment, { children: "Approvals / Approvals Required." })
                  }
                )
              ] })
            ] }) }),
            /* @__PURE__ */ e.jsx("tbody", { children: r.map((K) => {
              const X = Q(K), I = de(K), f = te(K);
              return /* @__PURE__ */ e.jsxs(lt.Fragment, { children: [
                /* @__PURE__ */ e.jsxs("tr", { children: [
                  /* @__PURE__ */ e.jsx("td", { children: K.initiator }),
                  /* @__PURE__ */ e.jsx("td", { children: K.minimumApprovalCount }),
                  /* @__PURE__ */ e.jsx("td", { children: K.newMinimumApprovalCount }),
                  /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx(
                    "span",
                    {
                      className: `status-badge ${K.transactionStatus === $.IN_PROGRESS ? "status-in-progress" : K.transactionStatus === $.COMPLETED ? "status-completed" : K.transactionStatus === $.DECLINED ? "status-declined" : K.transactionStatus === $.APPROVED ? "status-approved" : ""}`,
                      children: Vc(K.transactionStatus)
                    }
                  ) }),
                  /* @__PURE__ */ e.jsx("td", { id: `approve-${K.transactionId}`, children: f ? I ? /* @__PURE__ */ e.jsx(
                    "button",
                    {
                      className: "security-admin-transactions-decline",
                      onClick: () => J(K),
                      title: "Decline",
                      children: "✕"
                    }
                  ) : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-approve",
                        onClick: () => q(K),
                        title: "Approve",
                        children: "✓"
                      }
                    ),
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-decline",
                        onClick: () => J(K),
                        title: "Decline",
                        children: "✕"
                      }
                    )
                  ] }) : "N/A" }),
                  /* @__PURE__ */ e.jsxs("td", { id: `icon-${K.transactionId}`, children: [
                    /* @__PURE__ */ e.jsxs("span", { children: [
                      "(",
                      X,
                      "/",
                      K.minimumApprovalCount,
                      ")"
                    ] }),
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-more-info",
                        onClick: () => U(K.transactionId),
                        title: "More info",
                        children: n.has(K.transactionId) ? "▲" : "▼"
                      }
                    ),
                    K.warningMessage && /* @__PURE__ */ e.jsx(
                      "span",
                      {
                        className: "security-admin-transactions-warning",
                        title: K.warningMessage,
                        children: "⚠"
                      }
                    )
                  ] })
                ] }),
                n.has(K.transactionId) && /* @__PURE__ */ e.jsx("tr", { className: "security-admin-transactions-info-row", children: /* @__PURE__ */ e.jsx("td", { colSpan: 6, children: /* @__PURE__ */ e.jsx(Rt, { transaction: K }) }) })
              ] }, K.transactionId);
            }) })
          ]
        }
      ) })
    ] }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: M,
        message: x,
        onClose: () => R(!1),
        type: T
      }
    )
  ] });
}
const Wc = (r) => r === $.IN_PROGRESS ? "In Progress" : r;
function Hc({
  transactions: r,
  isLoading: t = !1
}) {
  const { renderLoader: s } = De(), [n, a] = b(/* @__PURE__ */ new Set()), [o, i] = b(""), [c, l] = b(!1), [d, u] = b(!1), [m, p] = b(null), [y, g] = b(!1), [w, h] = b(!1), {
    snackbarOpen: M,
    snackbarMessage: x,
    snackbarType: T,
    setSnackbarOpen: R,
    showSnackbar: D
  } = bt(), [U, q] = b(!1);
  ve(() => {
    (async () => {
      var f;
      try {
        const j = ue(), C = O("bayunSessionId");
        if (j && C) {
          const k = await j.getFromStorage(
            C,
            v.ORG_MEMBER_ID
          );
          k && i(k);
          const H = await j.getFromStorage(
            C,
            v.MEMBER_STATUS
          ), V = mt(H), F = (f = V == null ? void 0 : V.memberStatus) == null ? void 0 : f.toLowerCase();
          q(F === "securityadmin");
        }
      } catch (j) {
        console.error("Error fetching logged in org member ID:", j);
      }
    })();
  }, []);
  const N = (I) => {
    const f = new Set(n);
    f.has(I) ? f.delete(I) : f.add(I), a(f);
  }, P = (I) => {
    p(I), l(!0);
  }, Y = () => {
    l(!1), p(null), g(!1);
  }, re = () => {
    u(!1), p(null), h(!1);
  }, J = async () => {
    if (!m) return;
    g(!0);
    const I = ue();
    if (!I)
      throw new Error("Internal not found");
    const f = O("bayunSessionId");
    if (!f)
      throw new Error("Session ID not found in cookies");
    const j = await I.getFromStorage(
      f,
      v.MEMBER_PRIVATE_KEY
    ), C = await I.getFromStorage(
      f,
      v.ORG_NAME
    ), k = await _e.getAdminPrivateKey(), H = O("baseURL");
    if (!H)
      throw new Error("Base URL not found in cookies");
    let V = null, F = null, _ = [];
    if (m.createTransactionEncryptionKeys === "true") {
      V = await I.generateAesKey();
      const me = await rt(
        f,
        C,
        I
      );
      _ = await pt(
        V,
        me,
        k,
        j,
        C,
        I
      ), F = await We(
        f,
        H,
        j,
        null,
        V,
        I
      );
    } else
      F = await We(
        f,
        H,
        j,
        m.transactionId,
        null,
        I
      );
    if (!await I.retrieveAndverifyLastSignature(
      f,
      m.signedTransactionId
    ))
      throw new Error("Signed transaction ID verification failed");
    const B = await Ce(I, f), oe = await I.generateHMacHash(
      B,
      "lms" + C
    ), fe = await I.getFromStorage(
      f,
      v.MEMBER_APP_ID
    ) || "";
    if (!F)
      throw new Error("Backdoor private key part not found");
    let G = await I.signData(
      m.transactionId,
      k,
      I.context.getTransactionIdContext(m.transactionId, $.IN_PROGRESS, m.transactionLabel, C, o)
    );
    G = await I.appendSignatureAndMetadata(
      m.signedTransactionId,
      G,
      I.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
      I.context.getTransactionIdContext(m.transactionId, $.IN_PROGRESS, m.transactionLabel, C, o)
    );
    const ne = {
      transactionId: m.transactionId,
      backdoorPrivateKeyPart: F,
      authPasscodeHash: null,
      memberAppId: fe,
      lmsTransactionKey: oe,
      transactionEncryptionKeyRequestList: _,
      signedTransactionId: G
    };
    try {
      const me = await we.approveTransaction(ne);
      await $t(
        f,
        me,
        m.transactionId,
        B,
        oe,
        V,
        j,
        o,
        C,
        Object.keys(
          m.approvedByMembers || {}
        ).length.toString(),
        k,
        G,
        m.transactionLabel
      ), Y(), window.location.reload();
    } catch (me) {
      console.error("Error approving transaction:", me), D("Failed to approve transaction. Please try again.", "error"), g(!1);
    }
  }, le = () => m ? m.warningMessage ? m.warningMessage + " Would you still like to approve this transaction?" : "Would you like to approve this transaction?" : "", Q = (I) => {
    p(I), u(!0);
  }, de = async () => {
    var I, f;
    if (m) {
      h(!0);
      try {
        const j = ue();
        if (!j)
          throw new Error("Internal not found");
        const C = O("bayunSessionId");
        if (!C)
          throw new Error("Session ID not found in cookies");
        const k = await j.getFromStorage(
          C,
          v.ORG_NAME
        ), H = await _e.getAdminPrivateKey(), V = await Ce(j, C), F = await j.generateHMacHash(
          V,
          "lms" + k
        );
        if (!await j.retrieveAndverifyLastSignature(
          C,
          m.signedTransactionId
        ))
          throw new Error("Signed transaction ID verification failed");
        let _ = await j.signData(
          m.transactionId,
          H,
          j.context.getTransactionIdContext(m.transactionId, $.DECLINED, m.transactionLabel, k, o)
        );
        _ = await j.appendSignatureAndMetadata(
          m.signedTransactionId,
          _,
          j.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          j.context.getTransactionIdContext(m.transactionId, $.DECLINED, m.transactionLabel, k, o)
        );
        const B = await j.aeadEncryptWithAssociatedData(
          $.DECLINED,
          "lms" + k,
          F
        );
        await we.declineTransaction({
          transactionId: m.transactionId,
          lmsTransactionKey: F,
          transactionStatus: B,
          signedTransactionId: _
        }), re(), window.location.reload();
      } catch (j) {
        console.error("Error declining transaction:", j);
        const C = ((f = (I = j == null ? void 0 : j.response) == null ? void 0 : I.data) == null ? void 0 : f.errorMessage) || (j == null ? void 0 : j.message) || "Failed to decline transaction. Please try again.";
        D(C, "error"), h(!1);
      }
    }
  }, te = (I) => {
    let f = I.approvedByMembers ? Object.keys(I.approvedByMembers).length : 0;
    return I.declinedByMember && I.approvedByMembers && Object.keys(I.approvedByMembers).includes(
      I.declinedByMember
    ) && f--, f;
  }, K = (I) => I.approvedByMembers ? Object.keys(I.approvedByMembers).includes(
    o
  ) : !1, X = (I) => I.transactionStatus !== $.COMPLETED && I.transactionStatus !== $.DECLINED;
  return U ? /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    c && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: le() }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: J,
            loading: y,
            loadingText: "Approving...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: Y,
            disabled: y,
            children: "No"
          }
        )
      ] })
    ] }) }),
    d && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: "Would you like to decline this transaction?" }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "security-admin-transactions-modal-button-yes",
            onClick: de,
            loading: w,
            loadingText: "Declining...",
            children: "Yes"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "security-admin-transactions-modal-button-no",
            onClick: re,
            disabled: w,
            children: "No"
          }
        )
      ] })
    ] }) }),
    /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-title", children: /* @__PURE__ */ e.jsxs("span", { children: [
        "Transactions to Add Participants in Group",
        /* @__PURE__ */ e.jsx(
          Ke,
          {
            variant: "dark",
            wide: !0,
            content: /* @__PURE__ */ e.jsx(e.Fragment, { children: "This transaction add participants in a group." }),
            children: /* @__PURE__ */ e.jsx("i", { className: "fa fa-info-circle" })
          }
        )
      ] }) }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-list", children: t ? s(t, "Loading add participant transactions...") : /* @__PURE__ */ e.jsxs(
        "table",
        {
          className: "security-admin-transactions-table",
          id: "edit-minimum-approval-count-transactions-table",
          children: [
            /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
              /* @__PURE__ */ e.jsx("th", { children: "Initiator" }),
              /* @__PURE__ */ e.jsx("th", { children: "Add Participant" }),
              /* @__PURE__ */ e.jsx("th", { children: "To Group" }),
              /* @__PURE__ */ e.jsxs("th", { children: [
                "Status",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    wide: !0,
                    content: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                      /* @__PURE__ */ e.jsx("b", { children: "In Progress: " }),
                      " The transaction is currently in progress and requires minimum number of approvals to get complete. ",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Completed: " }),
                      " The transaction has received the required number of approvals and is completed. ",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Declined: " }),
                      " The transaction is declined by one of the Security Admins."
                    ] }),
                    children: /* @__PURE__ */ e.jsx("i", { className: "fa fa-info-circle" })
                  }
                )
              ] }),
              /* @__PURE__ */ e.jsxs("th", { children: [
                "Action",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    wide: !0,
                    content: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                      /* @__PURE__ */ e.jsx("b", { children: "Approve: " }),
                      " Approval is registered for the transaction. ",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "Decline: " }),
                      " The transaction is completely scrapped if declined. ",
                      /* @__PURE__ */ e.jsx("br", {}),
                      /* @__PURE__ */ e.jsx("b", { children: "N/A: " }),
                      " No Pending Actions."
                    ] }),
                    children: /* @__PURE__ */ e.jsx("i", { className: "fa fa-info-circle" })
                  }
                )
              ] }),
              /* @__PURE__ */ e.jsxs("th", { children: [
                "Approvals",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    variant: "dark",
                    content: /* @__PURE__ */ e.jsx(e.Fragment, { children: "Approvals / Approvals Required." }),
                    children: /* @__PURE__ */ e.jsx("i", { className: "fa fa-info-circle" })
                  }
                )
              ] })
            ] }) }),
            /* @__PURE__ */ e.jsx("tbody", { children: r.map((I) => {
              const f = te(I);
              let j = K(I);
              const C = X(I), k = I.groupExist === !1;
              return k && !j && (j = !0), /* @__PURE__ */ e.jsxs(lt.Fragment, { children: [
                /* @__PURE__ */ e.jsxs("tr", { children: [
                  /* @__PURE__ */ e.jsx("td", { children: I.initiator }),
                  /* @__PURE__ */ e.jsx("td", { children: I.targetOrgMemberId }),
                  /* @__PURE__ */ e.jsx("td", { children: I.groupId }),
                  /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx(
                    "span",
                    {
                      className: `status-badge ${I.transactionStatus === $.IN_PROGRESS ? "status-in-progress" : I.transactionStatus === $.COMPLETED ? "status-completed" : I.transactionStatus === $.DECLINED ? "status-declined" : I.transactionStatus === $.APPROVED ? "status-approved" : ""}`,
                      children: Wc(I.transactionStatus)
                    }
                  ) }),
                  /* @__PURE__ */ e.jsx("td", { id: `approve-${I.transactionId}`, children: C ? k && !K(I) ? /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                    /* @__PURE__ */ e.jsx(
                      "i",
                      {
                        className: "fa fa-check inactive",
                        title: "Group does not exist"
                      }
                    ),
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-decline",
                        onClick: () => Q(I),
                        title: "Decline",
                        children: "✕"
                      }
                    )
                  ] }) : j ? /* @__PURE__ */ e.jsx(
                    "button",
                    {
                      className: "security-admin-transactions-decline",
                      onClick: () => Q(I),
                      title: "Decline",
                      children: "✕"
                    }
                  ) : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-approve",
                        onClick: () => P(I),
                        title: "Approve",
                        children: "✓"
                      }
                    ),
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-decline",
                        onClick: () => Q(I),
                        title: "Decline",
                        children: "✕"
                      }
                    )
                  ] }) : "N/A" }),
                  /* @__PURE__ */ e.jsxs("td", { id: `icon-${I.transactionId}`, children: [
                    /* @__PURE__ */ e.jsxs("span", { children: [
                      "(",
                      f,
                      "/",
                      I.minimumApprovalCount,
                      ")"
                    ] }),
                    /* @__PURE__ */ e.jsx(
                      "button",
                      {
                        className: "security-admin-transactions-more-info",
                        onClick: () => N(I.transactionId),
                        title: "More info",
                        children: n.has(I.transactionId) ? "▲" : "▼"
                      }
                    ),
                    I.warningMessage && /* @__PURE__ */ e.jsx(
                      "span",
                      {
                        className: "security-admin-transactions-warning",
                        title: I.warningMessage,
                        children: "⚠"
                      }
                    )
                  ] })
                ] }),
                n.has(I.transactionId) && /* @__PURE__ */ e.jsx("tr", { className: "security-admin-transactions-info-row", children: /* @__PURE__ */ e.jsx("td", { colSpan: 6, children: /* @__PURE__ */ e.jsx(Rt, { transaction: I }) }) })
              ] }, I.transactionId);
            }) })
          ]
        }
      ) })
    ] }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: M,
        message: x,
        onClose: () => R(!1),
        type: T
      }
    )
  ] }) : null;
}
const qs = (r, t) => !r && t;
function Hn({
  transactions: r,
  loading: t,
  onTransactionsUpdated: s
}) {
  const { renderLoader: n } = De(), [a, o] = b(!1), [i, c] = b(null), [l, d] = b(""), [u, m] = b(""), [p, y] = b(""), [g, w] = b(""), [h, M] = b(!1), [x, T] = b(!1);
  console.log("transactions", r), ve(() => {
    (async () => {
      const P = ue(), Y = O("bayunSessionId");
      if (!P || !Y) {
        T(!1), M(!1);
        return;
      }
      const re = await P.getFromStorage(
        Y,
        v.USER_PRIVATE_KEY
      ), J = await P.getFromStorage(
        Y,
        v.EMAIL_ADDRESS
      );
      T(!!J && String(J).trim() !== ""), M(!!re && String(re).trim() !== "");
    })();
  }, []);
  const R = async (N, P) => {
    var Y, re;
    console.log("completeTransfer", N, P);
    try {
      const J = N.sourceCompanyMemberId || N.sourceOrgMemberId;
      w(N.transactionId), await we.completeLockBoxTransfer({
        transactionId: N.transactionId,
        sourceCompanyMemberId: J,
        passcode: P,
        signedTransactionId: N.signedTransactionId
      }), U(), s == null || s();
    } catch (J) {
      const le = ((re = (Y = J == null ? void 0 : J.response) == null ? void 0 : Y.data) == null ? void 0 : re.errorMessage) || (J == null ? void 0 : J.message) || "Failed to accept lockbox transfer request.";
      y(le);
    } finally {
      w("");
    }
  }, D = async (N) => {
    if (y(""), qs(h, x))
      return;
    if (N.sourceMemberHaveAppsWithPasscode === !0 || String(N.sourceMemberHaveAppsWithPasscode) === "true") {
      c(N);
      return;
    }
    await R(N);
  }, U = () => {
    c(null), d(""), m(""), y("");
  }, q = async () => {
    if (i) {
      if (!l) {
        y("Passcode cannot be empty");
        return;
      }
      if (l !== u) {
        y("Passcodes do not match");
        return;
      }
      await R(i, l);
    }
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    i && /* @__PURE__ */ e.jsx(
      "div",
      {
        className: "security-admin-transactions-modal-overlay",
        role: "dialog",
        "aria-modal": "true",
        "aria-labelledby": "lockbox-passcode-modal-title",
        children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content security-admin-transactions-passcode-modal", children: [
          /* @__PURE__ */ e.jsx(
            "div",
            {
              id: "lockbox-passcode-modal-title",
              className: "security-admin-transactions-modal-title",
              children: "New Passcode"
            }
          ),
          /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-message", children: [
            /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-passphrase-description", children: [
              "To acquire",
              " ",
              /* @__PURE__ */ e.jsx("strong", { children: i.sourceOrgMemberId }),
              "'s lockbox, you need to provide a new passcode. Remember this passcode to login with the account of",
              " ",
              i.sourceOrgMemberId,
              "."
            ] }),
            /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-passcode-fields", children: [
              /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-passcode-field", children: [
                /* @__PURE__ */ e.jsx(
                  "label",
                  {
                    htmlFor: "passcode",
                    className: "security-admin-transactions-passphrase-label",
                    children: "Passcode"
                  }
                ),
                /* @__PURE__ */ e.jsx(
                  "input",
                  {
                    type: "password",
                    className: "security-admin-transactions-passcode-input",
                    id: "passcode",
                    name: "passcode",
                    placeholder: "Enter new passcode",
                    value: l,
                    onChange: (N) => d(N.target.value),
                    autoComplete: "new-password"
                  }
                )
              ] }),
              /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-passcode-field", children: [
                /* @__PURE__ */ e.jsx(
                  "label",
                  {
                    htmlFor: "confirmPasscode",
                    className: "security-admin-transactions-passphrase-label",
                    children: "Confirm Passcode"
                  }
                ),
                /* @__PURE__ */ e.jsx(
                  "input",
                  {
                    type: "password",
                    className: "security-admin-transactions-passcode-input",
                    id: "confirmPasscode",
                    name: "confirmPasscode",
                    placeholder: "Re-enter passcode",
                    value: u,
                    onChange: (N) => m(N.target.value),
                    autoComplete: "new-password"
                  }
                )
              ] })
            ] }),
            p && /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-passphrase-error", children: p })
          ] }),
          /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
            /* @__PURE__ */ e.jsx(
              Pe,
              {
                className: "security-admin-transactions-modal-button-yes",
                onClick: q,
                loading: g === i.transactionId,
                loadingText: "Submitting...",
                children: "Submit"
              }
            ),
            /* @__PURE__ */ e.jsx(
              "button",
              {
                type: "button",
                className: "security-admin-transactions-modal-button-no",
                onClick: U,
                disabled: g === i.transactionId,
                children: "Cancel"
              }
            )
          ] })
        ] })
      }
    ),
    /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-title", children: "Lockbox Ownership Transfer Requests" }),
      /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-list", children: t ? n(a, "Loading lockbox transfer requests...") : r.length > 0 ? /* @__PURE__ */ e.jsxs("table", { className: "security-admin-transactions-table", id: "accept-table", children: [
        /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
          /* @__PURE__ */ e.jsx("th", { children: "Old Owner" }),
          /* @__PURE__ */ e.jsxs("th", { children: [
            "Action",
            /* @__PURE__ */ e.jsx(
              Ke,
              {
                variant: "dark",
                wide: !0,
                content: /* @__PURE__ */ e.jsx(e.Fragment, { children: "By clicking this button, you are accepting the lockbox of the member that was transferred to you." })
              }
            )
          ] })
        ] }) }),
        /* @__PURE__ */ e.jsx("tbody", { children: r.filter((N) => N.sourceMemberExist).map((N) => /* @__PURE__ */ e.jsxs("tr", { children: [
          /* @__PURE__ */ e.jsx("td", { children: N.sourceOrgMemberId }),
          /* @__PURE__ */ e.jsx("td", { id: `accept-${N.transactionId}`, children: qs(h, x) ? /* @__PURE__ */ e.jsx(
            Ke,
            {
              variant: "dark",
              wide: !0,
              content: "Accept this lockbox through the Bayun Developer Portal.",
              children: /* @__PURE__ */ e.jsx("span", { children: /* @__PURE__ */ e.jsx(
                Pe,
                {
                  className: "submitButton approveButton",
                  disabled: !0,
                  children: "Accept"
                }
              ) })
            }
          ) : /* @__PURE__ */ e.jsx(
            Pe,
            {
              className: "submitButton approveButton",
              onClick: () => D(N),
              loading: g === N.transactionId,
              loadingText: "Accepting...",
              children: "Accept"
            }
          ) })
        ] }, N.transactionId)) })
      ] }) : /* @__PURE__ */ e.jsx("div", { className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
        /* @__PURE__ */ e.jsx("div", { className: "empty-icon" }),
        /* @__PURE__ */ e.jsx("h3", { children: "No transfer requests" }),
        /* @__PURE__ */ e.jsx("p", { children: "There are no pending lockbox ownership transfer requests." })
      ] }) }) })
    ] })
  ] });
}
const $c = (r) => !r || Object.keys(r).length === 0 ? "0" : String(Object.keys(r).length);
function $n({
  transactions: r,
  loading: t,
  summaryMode: s = !1
}) {
  const { renderLoader: n } = De(), [a, o] = b(/* @__PURE__ */ new Set()), i = (c) => {
    const l = new Set(a);
    l.has(c) ? l.delete(c) : l.add(c), o(l);
  };
  return /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions", children: [
    /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-title", children: "Acquired Lockboxes" }),
    /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-list", children: t ? n(t, "Loading acquired lockboxes...") : r.length > 0 ? /* @__PURE__ */ e.jsxs(
      "table",
      {
        className: "security-admin-transactions-table",
        id: "acquired-lockboxes-table",
        children: [
          /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
            /* @__PURE__ */ e.jsx("th", { children: "Transaction ID" }),
            /* @__PURE__ */ e.jsx("th", { children: "Old Owner" }),
            /* @__PURE__ */ e.jsx("th", { children: "Current Owner" }),
            /* @__PURE__ */ e.jsx("th", { children: "Initiated By" }),
            !s && /* @__PURE__ */ e.jsx("th", { children: "Approvals" }),
            /* @__PURE__ */ e.jsx("th", { children: "Status" })
          ] }) }),
          /* @__PURE__ */ e.jsx("tbody", { children: r.map((c) => /* @__PURE__ */ e.jsxs(lt.Fragment, { children: [
            /* @__PURE__ */ e.jsxs("tr", { children: [
              /* @__PURE__ */ e.jsx("td", { children: c.transactionId }),
              /* @__PURE__ */ e.jsx("td", { children: c.sourceCompanyMemberId || c.sourceOrgMemberId }),
              /* @__PURE__ */ e.jsx("td", { children: c.targetOrgMemberId }),
              /* @__PURE__ */ e.jsx("td", { children: c.initiator || "-" }),
              !s && /* @__PURE__ */ e.jsxs("td", { children: [
                /* @__PURE__ */ e.jsx("span", { children: $c(c.approvedByMembers) }),
                /* @__PURE__ */ e.jsx(
                  "button",
                  {
                    className: "security-admin-transactions-more-info",
                    onClick: () => i(c.transactionId),
                    title: "More info",
                    children: a.has(c.transactionId) ? "▲" : "▼"
                  }
                )
              ] }),
              /* @__PURE__ */ e.jsx("td", { children: c.transactionStatus || "-" })
            ] }),
            !s && a.has(c.transactionId) && /* @__PURE__ */ e.jsx("tr", { className: "security-admin-transactions-info-row", children: /* @__PURE__ */ e.jsx("td", { colSpan: 6, children: /* @__PURE__ */ e.jsx(
              Rt,
              {
                transaction: c,
                showAcceptanceStep: !0
              }
            ) }) })
          ] }, c.transactionId)) })
        ]
      }
    ) : /* @__PURE__ */ e.jsx("div", { className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "empty-icon" }),
      /* @__PURE__ */ e.jsx("h3", { children: "No acquired lockboxes" }),
      /* @__PURE__ */ e.jsx("p", { children: "There are no acquired lockboxes to display." })
    ] }) }) })
  ] });
}
const zc = (r) => [...r].sort((t, s) => {
  const n = Number(t.transactionId), a = Number(s.transactionId);
  return !isNaN(n) && !isNaN(a) ? a - n : s.transactionId.localeCompare(t.transactionId);
}), Qc = async () => {
  const r = ue(), t = O("bayunSessionId");
  if (!r) throw new Error("Internal not found");
  const s = await Ce(r, t), n = await r.getFromStorage(
    t,
    v.ORG_NAME
  ), a = await r.getFromStorage(
    t,
    v.ORG_MEMBER_ID
  ), o = await r.generateHMacHash(
    s,
    "lms" + n
  ), i = await r.getFromStorage(
    t,
    v.ADMIN_PUBLIC_KEY
  );
  return {
    internal: r,
    sessionId: t,
    orgKey: s,
    orgName: n,
    orgMemberId: a,
    lmsTransactionKey: o,
    adminPublicKey: i
  };
}, Jc = async (r, t) => {
  const s = await we.getApprovalTransactionStatus({
    orgName: r,
    lmsTransactionKey: t
  });
  return zc(s);
}, Xc = async (r, t) => {
  const {
    internal: s,
    sessionId: n,
    orgName: a,
    orgMemberId: o,
    lmsTransactionKey: i
  } = t, c = await (s == null ? void 0 : s.aeadDecryptWithAssociatedData(
    r.transactionStatus,
    "lms" + a,
    i
  ));
  if (c === $.IN_PROGRESS) {
    if (r.approvedByMembers != null) {
      for (const u of Object.keys(
        r.approvedByMembers
      ))
        if (u === o) {
          t.pendingTransaction--;
          break;
        }
    }
    t.pendingTransaction++;
  }
  const l = await (s == null ? void 0 : s.aeadDecryptWithAssociatedData(
    r.transactionLabel,
    "lms" + a,
    i
  ));
  r.transactionLabel = l, r.transactionStatus = c;
  const d = await s.getFromStorage(
    n,
    v.MEMBER_STATUS
  );
  if ((d == null ? void 0 : d.toLowerCase()) === ye.SECURITY_ADMIN.toLowerCase()) {
    const u = await _e.getAdminPrivateKey().catch(() => null);
    if (u) {
      const m = await (s == null ? void 0 : s.decryptAsymmetric(
        r.minimumApprovalCount,
        u,
        r.minimumApprovalCount_kek,
        a
      ));
      if (r.minimumApprovalCount = m, r.newMinimumApprovalCount) {
        const p = await (s == null ? void 0 : s.decryptAsymmetric(
          r.newMinimumApprovalCount,
          u,
          r.newMinimumApprovalCount_kek,
          a
        ));
        r.newMinimumApprovalCount = p;
      }
    }
  }
  return r.approvedByMembers && Object.keys(r.approvedByMembers).includes(
    o
  ) ? r.approvedByMember = "true" : r.approvedByMember = "false", { label: l, status: c, approvalTransactionStatusResponse: r };
}, Zc = (r, t, s, n, a) => {
  if (r === be.TRANSFER_LOCK_BOX && s.targetOrgMemberId === n && (t === $.APPROVED ? (a.pendingTransaction++, a.lockBoxTransferRequests.push(s)) : t === $.COMPLETED && a.acquiredLockboxes.push(s)), r === be.TRANSFER_LOCK_BOX)
    a.lockBoxTransferTransactionList.push(
      s
    );
  else if (r === be.EDIT_MINIMUM_APPROVAL_COUNT) {
    if (t === $.IN_PROGRESS) {
      const o = Number(
        s.securityAdminCount
      );
      s.newMinimumApprovalCount === "1" ? s.warningMessage = "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to 1. Hence any security admin can approve and complete a transaction with their own consent." : String(o) === s.newMinimumApprovalCount && (s.warningMessage = "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to the number of security admins. Hence all security admins must approve the transaction for its completion.");
    }
    a.editMinimumApprovalCountTransactionList.push(
      s
    );
  } else if (r === be.ADD_GROUP_PARTICIPANT)
    a.addParticipantInGroupTransactionList.push(
      s
    );
  else if (r === be.RECOVER_USER)
    a.recoverUserTransactionList.push(s);
  else {
    if (t === $.IN_PROGRESS) {
      let o = Number(
        s.securityAdminCount
      );
      s.newMinimumApprovalCount === "1" ? s.warningMessage = "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to 1. Hence any security admin can approve and complete a transaction with their own consent." : r === be.PROMOTE_ADMIN ? (o++, String(o) === s.newMinimumApprovalCount && (s.warningMessage = "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to the number of security admins. Hence all security admins must approve the transaction for its completion.")) : r === be.DEMOTE_SECURITY_ADMIN && (o--, o === 1 ? s.warningMessage = "There would remain only 1 security admin on completion of this transaction" : String(o) === s.newMinimumApprovalCount && (s.warningMessage = "Upon initiation of this transaction, value of minimum number of approvals required for all future transactions was set to the number of security admins. Hence all security admins must approve the transaction for its completion."));
    }
    a.securityAdminTransactionList.push(s);
  }
}, el = () => ({
  lockBoxTransferRequests: [],
  acquiredLockboxes: [],
  securityAdminTransactionList: [],
  recoverUserTransactionList: [],
  lockBoxTransferTransactionList: [],
  editMinimumApprovalCountTransactionList: [],
  addParticipantInGroupTransactionList: [],
  pendingTransaction: 0
}), zn = async () => {
  const r = await Qc(), { orgName: t, orgMemberId: s, lmsTransactionKey: n } = r, a = await Jc(
    t,
    n
  ), o = el();
  for (const i of a) {
    const {
      label: c,
      status: l,
      approvalTransactionStatusResponse: d
    } = await Xc(i, {
      ...r,
      pendingTransaction: o.pendingTransaction
    });
    Zc(c, l, d, s, o);
  }
  return o;
};
function cs(r, t) {
  const [s, n] = b(
    () => sessionStorage.getItem(r) || t
  );
  return ve(() => {
    sessionStorage.setItem(r, s);
  }, [r, s]), [s, n];
}
function tl() {
  const [r, t] = b(!0), [s, n] = b(!1), [a, o] = b(!1), [i, c] = b(""), [l, d] = cs(
    "transactionsTab",
    "all"
  ), [u, m] = b([]), [p, y] = b([]), [g, w] = b([]), [h, M] = b([]), [x, T] = b([]), [
    R,
    D
  ] = b([]), [
    U,
    q
  ] = b([]), [N, P] = qa(), { renderLoader: Y } = De(), re = It(() => a ? h.filter(
    (te) => te.initiator === i
  ) : [], [a, h, i]), J = It(() => a ? x.filter(
    (te) => te.initiator === i
  ) : [], [a, x, i]), le = It(() => s ? g.length > 0 || h.length > 0 || x.length > 0 || R.length > 0 || U.length > 0 : a ? re.length > 0 || J.length > 0 : !1, [
    s,
    a,
    g,
    h,
    x,
    R,
    U,
    re,
    J
  ]), Q = It(() => u.length > 0 || p.length > 0, [u, p]);
  ve(() => {
    de();
  }, []);
  const de = async () => {
    try {
      t(!0);
      const te = ue(), K = O("bayunSessionId"), X = te && K ? await te.getFromStorage(K, v.MEMBER_STATUS) : null, I = te && K ? await te.getFromStorage(K, v.ORG_MEMBER_ID) : "", j = mt(X).memberStatus || null;
      c(I || ""), n(j === ct.SECURITY_ADMIN), o(j === ct.ADMIN), d((k) => j === ct.SECURITY_ADMIN || j === ct.ADMIN ? k : "your");
      const C = await zn();
      console.log("Approval transactions loaded"), console.log("Lockbox transfer requests:", C.lockBoxTransferRequests), console.log("Acquired lockboxes:", C.acquiredLockboxes), console.log("Security admin transactions:", C.securityAdminTransactionList), console.log("User account recovery transactions:", C.recoverUserTransactionList), console.log(
        "Lockbox transfer transactions:",
        C.lockBoxTransferTransactionList
      ), console.log(
        "Edit minimum approval count transactions:",
        C.editMinimumApprovalCountTransactionList
      ), console.log(
        "Add participant in group transactions:",
        C.addParticipantInGroupTransactionList
      ), P(() => {
        m(C.lockBoxTransferRequests), y(C.acquiredLockboxes), w(C.securityAdminTransactionList), M(C.recoverUserTransactionList), T(C.lockBoxTransferTransactionList), D(
          C.editMinimumApprovalCountTransactionList
        ), q(
          C.addParticipantInGroupTransactionList
        );
      });
    } catch (te) {
      console.error("Error loading transactions:", te);
    } finally {
      t(!1);
    }
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Transactions",
        subtitle: s || a ? "View organization and personal transaction activity" : "View transactions activity"
      }
    ),
    (r || N) && Y(r || N, "Loading transactions..."),
    /* @__PURE__ */ e.jsxs("div", { className: "transactions-container", children: [
      (s || a) && /* @__PURE__ */ e.jsx("div", { className: "tabs", children: /* @__PURE__ */ e.jsxs("div", { children: [
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: `tab-button ${l === "all" ? "active" : ""}`,
            onClick: () => d("all"),
            children: "All Transactions"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: `tab-button ${l === "your" ? "active" : ""}`,
            onClick: () => d("your"),
            children: "Your Transactions"
          }
        )
      ] }) }),
      l === "all" && /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
        s && g.length > 0 && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx(
          Uc,
          {
            transactions: g,
            isLoading: r,
            onTransactionsUpdated: de
          }
        ) }),
        s && h.length > 0 && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx(
          Zr,
          {
            transactions: h,
            isLoading: r,
            onTransactionsUpdated: de
          }
        ) }),
        s && x.length > 0 && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx(
          Vs,
          {
            transactions: x,
            isLoading: r,
            onTransactionsUpdated: de
          }
        ) }),
        s && R.length > 0 && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx(
          qc,
          {
            transactions: R,
            isLoading: r
          }
        ) }),
        s && U.length > 0 && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx(
          Hc,
          {
            transactions: U,
            isLoading: r
          }
        ) }),
        a && re.length > 0 && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx(
          Zr,
          {
            transactions: re,
            isLoading: r,
            onTransactionsUpdated: de
          }
        ) }),
        a && J.length > 0 && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx(
          Vs,
          {
            transactions: J,
            isLoading: r,
            onTransactionsUpdated: de,
            readOnly: !0
          }
        ) }),
        !r && !N && !le && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx("div", { className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
          /* @__PURE__ */ e.jsx("div", { className: "empty-icon" }),
          /* @__PURE__ */ e.jsx("h3", { children: "No transactions" }),
          /* @__PURE__ */ e.jsx("p", { children: "There are no organization-level transactions to display at this time." })
        ] }) }) })
      ] }),
      l === "your" && /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
        u.length > 0 && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx(
          Hn,
          {
            transactions: u,
            onTransactionsUpdated: de,
            loading: r
          }
        ) }),
        p.length > 0 && /* @__PURE__ */ e.jsx(
          $n,
          {
            transactions: p,
            loading: r,
            summaryMode: !0
          }
        ),
        !r && !N && !Q && /* @__PURE__ */ e.jsx("div", { className: "transaction-section", children: /* @__PURE__ */ e.jsx("div", { className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
          /* @__PURE__ */ e.jsx("div", { className: "empty-icon" }),
          /* @__PURE__ */ e.jsx("h3", { children: "No transactions" }),
          /* @__PURE__ */ e.jsx("p", { children: "There are no personal lockbox transactions to display at this time." })
        ] }) }) })
      ] })
    ] })
  ] });
}
const rl = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: tl
}, Symbol.toStringTag, { value: "Module" }));
function sl({
  applications: r,
  loading: t,
  onStatusUpdateSuccess: s,
  onNotification: n
}) {
  const { renderLoader: a } = De(), [o, i] = b(null), [c, l] = b(null), [d, u] = b(
    null
  ), [m, p] = b(null);
  ve(() => {
    (async () => {
      const M = O("bayunSessionId"), x = ue();
      if (x && M)
        try {
          const T = await x.getFromStorage(
            M,
            v.APP_ID
          );
          l(T);
        } catch (T) {
          console.error("Error loading application ID:", T);
        }
    })();
  }, []), ve(() => {
    if (!d) return;
    const h = () => {
      u(null), p(null);
    };
    return document.addEventListener("mousedown", h), () => {
      document.removeEventListener("mousedown", h);
    };
  }, [d]);
  const y = async (h) => {
    try {
      i(h), await xt.approveOrgApplication(h), s && s(h, "Approved");
    } catch (M) {
      console.error("Error approving application:", M), n == null || n("Failed to approve application. Please try again.", "error");
    } finally {
      i(null);
    }
  }, g = async (h) => {
    try {
      i(h), await xt.rejectOrgApplication(h), s && s(h, "Rejected");
    } catch (M) {
      console.error("Error rejecting application:", M), n == null || n("Failed to reject application. Please try again.", "error");
    } finally {
      i(null);
    }
  }, w = (h, M) => {
    if (d === M) {
      u(null), p(null);
      return;
    }
    const T = h.currentTarget.getBoundingClientRect();
    u(M), p({
      top: T.bottom + 4,
      left: T.left - 220
    });
  };
  return /* @__PURE__ */ e.jsxs("div", { children: [
    /* @__PURE__ */ e.jsx("div", { className: "table-container", children: t ? a(t) : /* @__PURE__ */ e.jsxs("table", { className: "custom-table", children: [
      /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("th", { children: "Application Name" }),
        /* @__PURE__ */ e.jsx("th", { children: "Application Id" }),
        /* @__PURE__ */ e.jsx("th", { children: "Application Approval" }),
        /* @__PURE__ */ e.jsx("th", { children: "Users" }),
        /* @__PURE__ */ e.jsx("th", { style: { width: "5%" } })
      ] }) }),
      /* @__PURE__ */ e.jsx("tbody", { children: r.length > 0 ? r.map((h, M) => /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("div", { className: "app-cell", children: /* @__PURE__ */ e.jsx("span", { className: "app-name", children: h.appName }) }) }),
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "app-id", children: h.appId }) }),
        /* @__PURE__ */ e.jsx("td", { children: (() => {
          const x = h.isFirstApplication === "true", T = h.appApprovalStatus;
          let R, D;
          return T === "Approved" ? (R = "Approved", D = "status-approved") : T === "Rejected" && !x ? (R = "Deactivated", D = "status-rejected") : (R = "Pending", D = "status-pending"), /* @__PURE__ */ e.jsx("span", { className: `status-badge ${D}`, children: R });
        })() }),
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "user-count", children: h.noOfUsers }) }),
        /* @__PURE__ */ e.jsx("td", { style: { width: "5%" }, children: /* @__PURE__ */ e.jsx("div", { className: "action-buttons", children: /* @__PURE__ */ e.jsx(
          "div",
          {
            className: "action-menu-wrapper",
            onMouseDown: (x) => x.stopPropagation(),
            children: /* @__PURE__ */ e.jsx(
              "button",
              {
                type: "button",
                className: "more-actions",
                onClick: (x) => w(x, h.appId),
                title: "More actions",
                children: /* @__PURE__ */ e.jsx("span", { className: "more-actions-icon", children: "⋮" })
              }
            )
          }
        ) }) })
      ] }, M)) : /* @__PURE__ */ e.jsx("tr", { children: /* @__PURE__ */ e.jsx("td", { colSpan: 5, className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
        /* @__PURE__ */ e.jsx("div", { className: "empty-icon", children: "📱" }),
        /* @__PURE__ */ e.jsx("h3", { children: "No applications found" }),
        /* @__PURE__ */ e.jsx("p", { children: "No applications are currently registered in the system." })
      ] }) }) }) })
    ] }) }),
    d && m && (() => {
      const h = r.find((q) => q.appId === d);
      if (!h) return null;
      const M = h.appApprovalStatus === "Approved";
      h.appApprovalStatus;
      const x = h.appApprovalStatus === "Pending", T = h.appId === c, R = o === h.appId, D = M || R, U = x || !M || T || R;
      return /* @__PURE__ */ e.jsxs(
        "div",
        {
          className: "action-menu",
          style: {
            position: "fixed",
            top: m.top,
            left: m.left
          },
          onMouseDown: (q) => q.stopPropagation(),
          children: [
            /* @__PURE__ */ e.jsxs(
              "button",
              {
                type: "button",
                className: "action-menu-item",
                onClick: () => {
                  D || (u(null), p(null), y(h.appId));
                },
                disabled: D,
                children: [
                  R && /* @__PURE__ */ e.jsx("div", { className: "btn-spinner", "aria-hidden": "true" }),
                  x ? "Approve Application" : "Activate Application"
                ]
              }
            ),
            /* @__PURE__ */ e.jsxs(
              "button",
              {
                type: "button",
                className: "action-menu-item",
                onClick: () => {
                  U || (u(null), p(null), g(h.appId));
                },
                disabled: U,
                children: [
                  R && /* @__PURE__ */ e.jsx("div", { className: "btn-spinner", "aria-hidden": "true" }),
                  "Deactivate Application"
                ]
              }
            )
          ]
        }
      );
    })()
  ] });
}
class Qn {
  /**
   * Fetch member statistics
   */
  static async fetchMemberStatistics() {
    try {
      return (await ee.get(
        O("baseURL") + "lms/admin/memberStatistics"
      )).data || [];
    } catch (t) {
      throw t;
    }
  }
}
function nl({
  applications: r,
  loading: t,
  onLinkSuccess: s,
  onNotification: n
}) {
  const { renderLoader: a } = De(), [o, i] = b(null), c = async (l, d, u, m) => {
    i(l);
    try {
      const p = ue();
      if (!p)
        throw new Error("Internal not found");
      const y = O("bayunSessionId");
      if (!y)
        throw new Error("Session ID not found in cookies");
      if (!await p.retrieveAndverifyLastSignature(
        y,
        d
      ))
        throw new Error("MemberAppId signature verification failed");
      d = d.split(Ne)[0];
      const g = await p.getFromStorage(
        y,
        v.USER_ID
      ), w = await p.getFromStorage(
        y,
        v.MULTI_FACTOR_AUTH
      );
      if (m === jr && (!g || g === ""))
        throw new Error(
          "Member should be linked to an email account if an member app that was created without passcode needs to be linked to it."
        );
      if (m === jr && !(w === Ze.SINGLE_FA_WITH_SECURITY_QUESTIONS || w === Ze.SINGLE_FA_WITH_SECURITY_QUESTIONS_AND_PASSPHRASE))
        throw new Error(
          'Multifactor authentication needs to be either "Single Factor Authentication with Security Questions" or "Single Factor Authentication with Security Questions and Passphrase" to link an application that was created without using passcode.'
        );
      const h = await p.getFromStorage(
        y,
        v.MEMBER_PRIVATE_KEY
      ), M = await p.getFromStorage(
        y,
        v.MEMBER_KEY
      ), x = await xt.getMemberApps(), T = await p.getFromStorage(
        y,
        v.MEMBER_APP_ID
      );
      let R;
      for (const k of x.memberApps)
        if (T === k.memberAppId.split("#")[0]) {
          R = k.appId;
          break;
        }
      const D = await p.getFromStorage(
        y,
        v.ORG_NAME
      ), U = await p.getFromStorage(
        y,
        v.ORG_MEMBER_ID
      ), q = p.asRawKey(M);
      if (!q)
        throw new Error("Member key not found or invalid");
      const N = D + U + R, P = await p.generateHMacHash(
        q,
        "lms" + N
      ), Y = await p.getFromStorage(
        y,
        v.MEMBER_ID
      ), re = await Qn.fetchMemberStatistics();
      let J = "";
      for (const k of re)
        k.appId === R && k.orgMemberId === U && (J = k.lmsEncryptedStatisticsKey);
      const le = await p.aeadDecryptWithAssociatedData(
        J,
        "lms" + N,
        P
      ), Q = D + U + l, de = await p.generateHMacHash(
        q,
        "lms" + Q
      ), te = await p.aeadEncryptWithAssociatedData(
        le,
        "lms" + Q,
        de
      ), K = await p.getFromStorage(
        y,
        v.ADMIN_PUBLIC_KEY
      ), X = await p.encryptAsymmetric(
        le,
        K,
        Q
      );
      if (!X)
        throw new Error("Failed to encrypt statistics key");
      const I = X.encryptedText, f = X.keyEncryptionKey, j = await p.aeadEncryptWithAssociatedData(
        "0",
        Q,
        le
      ), C = await p.aeadEncryptWithAssociatedData(
        "0",
        Q,
        le
      );
      if (m === jr)
        await xt.linkApplication(
          l,
          d,
          T,
          null,
          // encryptedMemberPrivateKey
          null,
          // memberPrivateKeyInnerDEK
          null,
          // memberPrivateKeyOuterDEK
          I,
          f,
          te,
          "",
          // signatureOnMemberAppPublicKey
          j,
          C
        );
      else {
        const k = u.split(Ne)[0];
        let H = null, V = null, F = null, _ = null;
        if (!(w === Ze.SINGLE_FA_WITH_SECURITY_QUESTIONS || w === Ze.SINGLE_FA_WITH_SECURITY_QUESTIONS_AND_PASSPHRASE)) {
          const B = await p.getFromStorage(
            y,
            v.USER_PUBLIC_KEY
          );
          if (w === Ze.TWO_FACTOR_AUTHENTICATION_WITH_PASSPHRASE || w === Ze.TWO_FACTOR_AUTHENTICATION_WITHOUT_PASSPHRASE) {
            const me = await p.encryptAsymmetric(
              h,
              k,
              U
            );
            H = me.encryptedText, V = me.keyEncryptionKey;
            const E = await p.encryptAsymmetric(
              H,
              B,
              g
            );
            H = E.encryptedText, F = E.keyEncryptionKey;
          } else {
            const me = await p.encryptAsymmetric(
              h,
              k,
              U
            );
            H = me.encryptedText, V = me.keyEncryptionKey;
          }
          if (V) {
            const me = tt.getContextForMemberPrivateKeyInnerKek(
              D,
              U,
              l
            ), E = await p.signData(
              V,
              h,
              me
            );
            V = await p.appendSignatureAndMetadata(
              V,
              E,
              p.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG,
              me
            );
          }
          if (F) {
            const me = await p.getFromStorage(
              y,
              v.EMAIL_ADDRESS
            ), E = tt.getContextForMemberPrivateKeyOuterKek(me), Z = await p.getFromStorage(
              y,
              v.USER_PRIVATE_KEY
            ), z = await p.signData(
              F,
              Z,
              E
            );
            F = await p.appendSignatureAndMetadata(
              F,
              z,
              p.signingPublicKeyTags.USER_PUBLIC_KEY_TAG,
              E
            );
          }
          if (!await p.retrieveAndverifyLastSignature(
            y,
            u
          ))
            throw new Error(
              "Signature verification failed for memberAppPublicKey"
            );
          _ = u.substring(
            u.indexOf(Ne) + 1
          );
          const oe = _.split(Ne), fe = oe[oe.length - 1].split("$")[0], G = tt.getContextForMemberAppPublicKeyLayer3(
            D,
            U,
            l,
            fe
          ), ne = await p.signData(
            k,
            h,
            G
          );
          _ = await p.appendSignatureAndMetadata(
            u,
            ne,
            p.signingPublicKeyTags.MEMBER_PUBLIC_KEY_TAG,
            G
          );
        }
        await xt.linkApplication(
          l,
          d,
          T,
          H,
          V,
          F,
          I,
          f,
          te,
          _,
          j,
          C
        );
      }
      s && s(l);
    } catch (p) {
      console.error("Error linking application:", p), n == null || n("Failed to link application. Please try again.", "error");
    } finally {
      i(null);
    }
  };
  return /* @__PURE__ */ e.jsx("div", { children: /* @__PURE__ */ e.jsx("div", { className: "table-container", children: t ? a(t, "Loading applications...") : /* @__PURE__ */ e.jsxs("table", { className: "custom-table", children: [
    /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
      /* @__PURE__ */ e.jsx("th", { children: "Application Name" }),
      /* @__PURE__ */ e.jsx("th", { children: "Application Id" }),
      /* @__PURE__ */ e.jsx("th", { children: "Application Approval" }),
      /* @__PURE__ */ e.jsx("th", { children: /* @__PURE__ */ e.jsxs(
        "div",
        {
          style: {
            display: "flex",
            alignItems: "center"
          },
          children: [
            /* @__PURE__ */ e.jsx("div", { children: "Application Status" }),
            /* @__PURE__ */ e.jsx(
              Ke,
              {
                content: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
                  /* @__PURE__ */ e.jsx("strong", { children: "Linked: " }),
                  "An application, if linked, is ready for use by the member.",
                  /* @__PURE__ */ e.jsx("br", {}),
                  /* @__PURE__ */ e.jsx("br", {}),
                  /* @__PURE__ */ e.jsx("strong", { children: "Unlinked: " }),
                  "An unlinked application has its member-app key pair, but it hasn't been linked to the member yet.",
                  /* @__PURE__ */ e.jsx("br", {}),
                  /* @__PURE__ */ e.jsx("br", {}),
                  /* @__PURE__ */ e.jsx("strong", { children: "MemberAppNotExist: " }),
                  "This means that the member-app key pair for this application doesn't exist. The SDK needs to create an application key pair which can then be linked to the member via Admin Panel."
                ] })
              }
            )
          ]
        }
      ) })
    ] }) }),
    /* @__PURE__ */ e.jsx("tbody", { children: r.length > 0 ? r.map((l, d) => /* @__PURE__ */ e.jsxs("tr", { children: [
      /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("div", { className: "app-cell", children: /* @__PURE__ */ e.jsx("span", { className: "app-name", children: l.appName }) }) }),
      /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "app-id", children: l.appId }) }),
      /* @__PURE__ */ e.jsx("td", { children: (() => {
        const u = l.isFirstApplication === "true", m = l.appApprovalStatus;
        let p, y;
        return m === "Approved" ? (p = "Approved", y = "status-approved") : m === "Rejected" && !u ? (p = "Deactivated", y = "status-rejected") : (p = "Pending", y = "status-pending"), /* @__PURE__ */ e.jsx("span", { className: `status-badge ${y}`, children: p });
      })() }),
      /* @__PURE__ */ e.jsx("td", { id: `link-${l.appId}`, children: /* @__PURE__ */ e.jsxs("div", { className: "app-link-cell", children: [
        /* @__PURE__ */ e.jsx("span", { className: "middle", children: l.appStatus }),
        l.appStatus === "Unlinked" && l.memberAppType === "withPasscode" && /* @__PURE__ */ e.jsx(e.Fragment, { children: l.appApprovalStatus === "Approved" ? /* @__PURE__ */ e.jsx(
          Pe,
          {
            type: "button",
            className: "submitButton linkButton",
            onClick: () => c(
              l.appId,
              l.memberAppId,
              l.memberAppPublicKey,
              l.memberAppType
            ),
            loading: o === l.appId,
            loadingText: "Linking...",
            children: "Link"
          }
        ) : /* @__PURE__ */ e.jsx(
          "button",
          {
            type: "button",
            className: "submitButton linkButton disabledAppLinkingButton",
            disabled: !0,
            children: "Link"
          }
        ) })
      ] }) })
    ] }, d)) : /* @__PURE__ */ e.jsx("tr", { children: /* @__PURE__ */ e.jsx("td", { colSpan: 4, className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
      /* @__PURE__ */ e.jsx("div", { className: "empty-icon", children: "📱" }),
      /* @__PURE__ */ e.jsx("h3", { children: "No applications found" }),
      /* @__PURE__ */ e.jsx("p", { children: "You don't have any applications linked to your account yet." })
    ] }) }) }) })
  ] }) }) });
}
function al() {
  const [r, t] = b({
    applicationResponse: [],
    orgApplicationResponse: []
  }), [s, n] = b(!1), [a, o] = b(!1), [i, c] = cs(
    "applicationsTab",
    "all"
  ), { snackbarOpen: l, snackbarMessage: d, setSnackbarOpen: u } = wr(!0), {
    snackbarOpen: m,
    snackbarMessage: p,
    snackbarType: y,
    setSnackbarOpen: g,
    showSnackbar: w
  } = bt();
  ve(() => {
    M(), h();
  }, []);
  const h = async () => {
    var re;
    const D = O("bayunSessionId"), U = ue(), q = await (U == null ? void 0 : U.getFromStorage(
      D,
      v.MEMBER_STATUS
    )), N = mt(q), P = (re = N == null ? void 0 : N.memberStatus) == null ? void 0 : re.toLowerCase(), Y = P === "admin" || P === "securityadmin";
    o(Y), Y || c("your");
  }, M = async () => {
    try {
      n(!0);
      const D = await xt.fetchApplicationList();
      t(D);
    } catch (D) {
      console.error("Error fetching applications:", D);
    } finally {
      n(!1);
    }
  }, x = r.applicationResponse.filter(
    (D) => D.isOtherMember === "false"
  ), T = (D, U) => {
    t((q) => ({
      ...q,
      orgApplicationResponse: q.orgApplicationResponse.map(
        (N) => N.appId === D ? { ...N, appApprovalStatus: U } : N
      )
    }));
  }, R = (D) => {
    t((U) => ({
      ...U,
      applicationResponse: U.applicationResponse.map(
        (q) => q.appId === D ? { ...q, appStatus: "Linked" } : q
      )
    }));
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Applications",
        subtitle: "Manage and organize applications"
      }
    ),
    /* @__PURE__ */ e.jsxs("div", { className: "all-groups-container", children: [
      /* @__PURE__ */ e.jsx("div", { className: "tabs", children: /* @__PURE__ */ e.jsxs("div", { children: [
        a && /* @__PURE__ */ e.jsx(
          "button",
          {
            className: `tab-button ${i === "all" ? "active" : ""}`,
            onClick: () => c("all"),
            children: "All Org Applications"
          }
        ),
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: `tab-button ${i === "your" ? "active" : ""}`,
            onClick: () => c("your"),
            children: "Your Applications"
          }
        )
      ] }) }),
      /* @__PURE__ */ e.jsxs("div", { className: "tab-content", children: [
        a && i === "all" && /* @__PURE__ */ e.jsx(
          sl,
          {
            applications: r.orgApplicationResponse,
            loading: s,
            onStatusUpdateSuccess: T,
            onNotification: w
          }
        ),
        i === "your" && /* @__PURE__ */ e.jsx(
          nl,
          {
            applications: x,
            loading: s,
            onLinkSuccess: R,
            onNotification: w
          }
        )
      ] })
    ] }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: l,
        message: d || "You have pending approvals",
        onClose: () => u(!1),
        type: "info"
      }
    ),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: m,
        message: p,
        onClose: () => g(!1),
        type: y
      }
    )
  ] });
}
const ol = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: al
}, Symbol.toStringTag, { value: "Module" }));
function il(r, t) {
  return String(r ?? "") + String(t ?? "");
}
function Jn(r) {
  return r ? r.split(Ne)[0] : "";
}
async function cl(r, t, s, n, a, o) {
  if (o) {
    const i = await r.getFromStorage(
      O("bayunSessionId"),
      v.MEMBER_PRIVATE_KEY
    ), c = Jn(s.groupKey_kek), l = await r.decryptAsymmetric(
      s.groupKey,
      i,
      c,
      a
    ), d = r.asRawKey(l);
    if (!d)
      return "";
    const u = await r.generateHMacHash(
      d,
      "lms" + n
    );
    return await r.aeadDecryptWithAssociatedData(
      s.lmsEncryptedGroupInfoKey,
      "lms" + n,
      u
    );
  } else if (t)
    return s.adminEncryptedGroupInfoKey_kek = s.adminEncryptedGroupInfoKey_kek.split("#")[0], await r.decryptAsymmetric(
      s.adminEncryptedGroupInfoKey,
      t,
      s.adminEncryptedGroupInfoKey_kek,
      n
    );
  return "";
}
async function ll(r, t, s, n) {
  const a = Jn(t.type);
  t.name && (t.name = await r.aeadDecryptWithAssociatedData(
    t.name,
    s,
    n
  )), t.type = await r.aeadDecryptWithAssociatedData(
    a,
    s,
    n
  );
}
async function Xn(r, t = !1) {
  if (!Array.isArray(r) || r.length === 0)
    return r;
  const s = ue();
  if (!s)
    return r;
  const n = O("bayunSessionId");
  if (!n)
    return r;
  const a = await s.getFromStorage(
    n,
    v.ORG_MEMBER_ID
  );
  let o;
  const i = await s.getFromStorage(
    n,
    v.MEMBER_STATUS
  );
  (i === ye.SECURITY_ADMIN || i === ye.ADMIN) && (o = await _e.getAdminPrivateKey());
  const c = [];
  for (const l of r) {
    const d = il(
      l.creatorOrgName,
      l.creatorOrgMemberId
    );
    let u = "";
    try {
      u = await cl(
        s,
        o ?? null,
        l,
        d,
        a,
        t
      );
    } catch (m) {
      console.error("Failed to derive group info key", {
        groupId: l.id,
        error: m
      });
      continue;
    }
    if (!u) {
      console.error("Failed to derive group info key for group:", l.id);
      continue;
    }
    try {
      await ll(s, l, d, u), c.push(l);
    } catch (m) {
      console.error("Failed to decrypt group data", {
        groupId: l.id,
        error: m
      });
    }
  }
  return c;
}
function dl({ onNotification: r }) {
  const { renderLoader: t } = De(), [s, n] = b([]), [a, o] = b(!0), [i, c] = b(0), [l, d] = b(0);
  return ve(() => {
    const u = async () => {
      const m = O("bayunSessionId"), p = ue();
      if (!(!m || !p))
        try {
          o(!0);
          const y = await jt.fetchOrgAllGroups({
            pageNumber: i
          });
          if (!await p.getFromStorage(
            m,
            v.ORG_MEMBER_ID
          ))
            throw new Error("Org member ID not found");
          const w = await Xn(
            y.groupMemberResponses,
            !1
            // isMemberGroups = false (org groups)
          );
          n(w || []), d(y.totalPages || 0);
        } catch (y) {
          console.error("Failed to load org groups", y), r == null || r(
            y instanceof Error ? y.message : "Failed to load groups",
            "error"
          );
        } finally {
          o(!1);
        }
    };
    i >= 0 && u();
  }, [i]), /* @__PURE__ */ e.jsx("div", { className: "table-container", children: a ? t(a, "Loading groups...") : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsxs("table", { className: "custom-table", children: [
      /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("th", { children: "Group ID" }),
        /* @__PURE__ */ e.jsx("th", { children: "Group Name" }),
        /* @__PURE__ */ e.jsx("th", { children: "Group Type" }),
        /* @__PURE__ */ e.jsx("th", { children: "Date Created" }),
        /* @__PURE__ */ e.jsx("th", { children: "Participants" })
      ] }) }),
      /* @__PURE__ */ e.jsx("tbody", { children: s.length > 0 ? s.map((u, m) => /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("td", { children: u.id }),
        /* @__PURE__ */ e.jsx("td", { children: u.name }),
        /* @__PURE__ */ e.jsx("td", { children: u.type }),
        /* @__PURE__ */ e.jsx("td", { children: new Date(u.date).toLocaleString() }),
        /* @__PURE__ */ e.jsx("td", { children: u.totalParticipants ?? "-" })
      ] }, m)) : /* @__PURE__ */ e.jsx("tr", { children: /* @__PURE__ */ e.jsx("td", { colSpan: 5, className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
        /* @__PURE__ */ e.jsx("div", { className: "empty-icon", children: "👥" }),
        /* @__PURE__ */ e.jsx("h3", { children: "No org groups found" }),
        /* @__PURE__ */ e.jsx("p", { children: "There are no groups available in your org." })
      ] }) }) }) })
    ] }),
    /* @__PURE__ */ e.jsxs("div", { className: "pagination", children: [
      /* @__PURE__ */ e.jsx(
        "button",
        {
          className: "btn-pagination",
          disabled: i <= 0,
          onClick: () => c((u) => Math.max(0, u - 1)),
          children: "Prev"
        }
      ),
      /* @__PURE__ */ e.jsxs("span", { className: "page-info", children: [
        "Page ",
        l === 0 ? 0 : i + 1,
        " of ",
        l
      ] }),
      /* @__PURE__ */ e.jsx(
        "button",
        {
          className: "btn-pagination",
          disabled: l === 0 || i >= l - 1,
          onClick: () => c((u) => u + 1),
          children: "Next"
        }
      )
    ] })
  ] }) });
}
function ul({ onNotification: r }) {
  const { renderLoader: t } = De(), [s, n] = b([]), [a, o] = b(!0), [i, c] = b(0), [l, d] = b(0);
  return ve(() => {
    const u = async () => {
      const m = O("bayunSessionId"), p = ue();
      if (!(!m || !p))
        try {
          o(!0);
          const y = await jt.fetchMemberAllGroups({
            pageNumber: i
          });
          let g = [];
          try {
            g = await Xn(
              y.groupMemberResponses,
              !0
              // isMemberGroups = true
            );
          } catch (w) {
            console.error("Failed to decrypt member groups", w), r == null || r(
              w instanceof Error ? w.message : "Failed to decrypt groups",
              "error"
            );
          }
          n(g || []), d(y.totalPages || 0);
        } catch (y) {
          console.error("Failed to load member groups", y), r == null || r(
            y instanceof Error ? y.message : "Failed to load groups",
            "error"
          );
        } finally {
          o(!1);
        }
    };
    i >= 0 && u();
  }, [i]), /* @__PURE__ */ e.jsx("div", { className: "table-container", children: a ? t(a, "Loading groups...") : /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsxs("table", { className: "custom-table", children: [
      /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("th", { children: "Group ID" }),
        /* @__PURE__ */ e.jsx("th", { children: "Group Name" }),
        /* @__PURE__ */ e.jsx("th", { children: "Group Type" }),
        /* @__PURE__ */ e.jsx("th", { children: "Date Created" }),
        /* @__PURE__ */ e.jsx("th", { children: "Participants" })
      ] }) }),
      /* @__PURE__ */ e.jsx("tbody", { children: s.length > 0 ? s.map((u, m) => /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("td", { children: u.id }),
        /* @__PURE__ */ e.jsx("td", { children: u.name }),
        /* @__PURE__ */ e.jsx("td", { children: u.type }),
        /* @__PURE__ */ e.jsx("td", { children: new Date(u.date).toLocaleString() }),
        /* @__PURE__ */ e.jsx("td", { children: u.totalParticipants ?? "-" })
      ] }, m)) : /* @__PURE__ */ e.jsx("tr", { children: /* @__PURE__ */ e.jsx("td", { colSpan: 5, className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
        /* @__PURE__ */ e.jsx("div", { className: "empty-icon", children: "👤" }),
        /* @__PURE__ */ e.jsx("h3", { children: "No personal groups found" }),
        /* @__PURE__ */ e.jsx("p", { children: "You are not a participant of any groups yet." })
      ] }) }) }) })
    ] }),
    /* @__PURE__ */ e.jsxs("div", { className: "pagination", children: [
      /* @__PURE__ */ e.jsx(
        "button",
        {
          className: "btn-pagination",
          disabled: i <= 0,
          onClick: () => c((u) => Math.max(0, u - 1)),
          children: "Prev"
        }
      ),
      /* @__PURE__ */ e.jsxs("span", { className: "page-info", children: [
        "Page ",
        l === 0 ? 0 : i + 1,
        " of ",
        l
      ] }),
      /* @__PURE__ */ e.jsx(
        "button",
        {
          className: "btn-pagination",
          disabled: l === 0 || i >= l - 1,
          onClick: () => c((u) => u + 1),
          children: "Next"
        }
      )
    ] })
  ] }) });
}
function ml({
  handleCloseClickCallback: r,
  onNotification: t
}) {
  const [s, n] = b(""), [a, o] = b(""), [i, c] = b([]), [l, d] = b(
    []
  ), [u, m] = b(!1), [p, y] = b(""), [g, w] = b(!1), [h, M] = b([]), [x, T] = b([]), [R, D] = b(!1), [U, q] = b(""), [N, P] = b(!1), [Y, re] = b(
    null
  ), [J, le] = b(null), [Q, de] = b(!1), te = Re(null), K = Re(null);
  ve(() => {
    (async () => {
      m(!0), y("");
      try {
        const ne = O("bayunSessionId"), me = ue();
        if (!ne || !me)
          throw new Error("Session ID or Internal API not found");
        const E = await jt.getOrgAllGroupInfo();
        if (!E || E.length === 0) {
          c([]);
          return;
        }
        const Z = await _e.getAdminPrivateKey(), z = [];
        for (const ce of E)
          try {
            const he = ce.creatorOrgName + ce.creatorOrgMemberId, Ie = ce.adminEncryptedGroupInfoKey_kek.split("#")[0], xe = await me.decryptAsymmetric(
              ce.adminEncryptedGroupInfoKey,
              Z,
              Ie,
              he
            );
            if (!xe) {
              console.error(
                "Failed to decrypt groupInfoKey for group:",
                ce.id
              );
              continue;
            }
            const A = await me.aeadDecryptWithAssociatedData(
              ce.name,
              he,
              xe
            );
            if (!A) {
              console.error(
                "Failed to decrypt group name for group:",
                ce.id
              );
              continue;
            }
            const se = `${ce.id} (${A})`;
            z.push({
              id: ce.id,
              name: se,
              originalData: ce
            });
          } catch (he) {
            console.error(`Error processing group ${ce.id}:`, he);
          }
        c(z);
      } catch (ne) {
        console.error("Error fetching groups:", ne), y(
          ne instanceof Error ? ne.message : "Failed to load group data. Please try again."
        );
      } finally {
        m(!1);
      }
    })();
  }, []), ve(() => {
    (async () => {
      D(!0), q("");
      try {
        const ne = await we.getAllMembers();
        M(ne);
      } catch (ne) {
        console.error("Error fetching members:", ne), q(
          ne instanceof Error ? ne.message : "Failed to load member data. Please try again."
        );
      } finally {
        D(!1);
      }
    })();
  }, []), ve(() => {
    const G = (ne) => {
      te.current && !te.current.contains(ne.target) && (w(!1), d([])), K.current && !K.current.contains(ne.target) && (P(!1), T([]));
    };
    return document.addEventListener("mousedown", G), document.addEventListener("click", G), () => {
      document.removeEventListener("mousedown", G), document.removeEventListener("click", G);
    };
  }, []);
  const X = (G, ne) => G.toLowerCase() === ne.trim().toLowerCase(), I = (G) => {
    if (n(G), (!G.trim() || !Y || !X(Y.name, G)) && re(null), !G.trim())
      d(i.slice(0, 5));
    else {
      const ne = i.filter(
        (me) => me.name.toLowerCase().includes(G.toLowerCase()) || me.id.toLowerCase().includes(G.toLowerCase())
      );
      d(ne);
    }
  }, f = (G, ne) => G.toLowerCase() === ne.trim().toLowerCase(), j = (G) => {
    const ne = G.trim();
    if (ne.length < 1)
      return [];
    const me = ne.toLowerCase();
    return h.filter(
      (E) => E.orgMemberId.toLowerCase().includes(me)
    );
  }, C = (G) => {
    const ne = G.trim();
    if (ne)
      return h.find(
        (me) => f(me.orgMemberId, ne)
      );
  }, k = (G) => {
    T([]), P(!1);
    const ne = C(G);
    return ne ? (le(ne), o(ne.orgMemberId), ne) : (le(null), null);
  }, H = (G) => {
    o(G), (!G.trim() || !J || !f(J.orgMemberId, G)) && le(null), G.trim() ? T(j(G)) : T(h.slice(0, 5));
  }, V = (G) => {
    if (G.key === "Escape") {
      G.preventDefault(), T([]), P(!1);
      return;
    }
    G.key === "Enter" && (G.preventDefault(), k(a) || t == null || t(
      a.trim() ? `Member "${a.trim()}" not found` : "Please enter a member ID",
      "error"
    ));
  }, F = async () => {
    if (!Y)
      return;
    const G = C(a) ?? null;
    if (!G) {
      t == null || t(
        `Member "${a.trim()}" not found`,
        "error"
      );
      return;
    }
    try {
      de(!0);
      const ne = O("bayunSessionId"), me = ue();
      if (!ne || !me)
        throw new Error("Session ID or Internal API not found");
      await Tt.initiateAddGroupParticipant(
        ne,
        me,
        Y.id,
        G.id
      ), r(!1), t == null || t(
        `Successfully added ${G.orgMemberId} to group ${Y.name}`,
        "success"
      );
    } catch (ne) {
      console.error("Error adding participant to group:", ne), t == null || t(
        ne instanceof Error ? ne.message : "Failed to add participant to group. Please try again.",
        "error"
      );
    } finally {
      de(!1);
    }
  }, _ = () => /* @__PURE__ */ e.jsxs("div", { className: "key-value-row", children: [
    /* @__PURE__ */ e.jsx("div", { className: "label", children: "Group" }),
    /* @__PURE__ */ e.jsxs(
      "div",
      {
        className: "addparticipant-dropdown-wrapper",
        style: { flex: "1 1 60%" },
        ref: te,
        children: [
          /* @__PURE__ */ e.jsx(
            "input",
            {
              type: "text",
              value: s,
              placeholder: "Search Group by Name or ID",
              onChange: (G) => {
                I(G.target.value), w(!0);
              },
              onFocus: () => {
                w(!0), !s.trim() && i.length > 0 && d(i.slice(0, 5));
              },
              disabled: u
            }
          ),
          u && /* @__PURE__ */ e.jsx("div", { className: "dropdown-loading-message", children: "Loading groups..." }),
          p && /* @__PURE__ */ e.jsx("div", { className: "dropdown-error-message", children: p }),
          g && !u && !p && /* @__PURE__ */ e.jsx(e.Fragment, { children: l.length > 0 ? /* @__PURE__ */ e.jsx("ul", { className: "dropdown-list", children: l.map((G) => /* @__PURE__ */ e.jsx(
            "li",
            {
              onClick: () => {
                re(G), n(G.name), d([]), w(!1);
              },
              children: /* @__PURE__ */ e.jsx("span", { className: "dropdown-item-name", children: G.name })
            },
            G.id
          )) }) : s.trim() && i.length > 0 ? /* @__PURE__ */ e.jsxs("div", { className: "dropdown-empty-message", children: [
            'No groups found matching "',
            s,
            '"'
          ] }) : null })
        ]
      }
    )
  ] }), B = () => /* @__PURE__ */ e.jsxs("div", { className: "key-value-row", children: [
    /* @__PURE__ */ e.jsx("div", { className: "label", children: "Member" }),
    /* @__PURE__ */ e.jsxs(
      "div",
      {
        className: "addparticipant-dropdown-wrapper",
        style: { flex: "1 1 60%" },
        ref: K,
        children: [
          /* @__PURE__ */ e.jsx(
            "input",
            {
              type: "text",
              value: a,
              placeholder: "Search Member by ID",
              onChange: (G) => {
                H(G.target.value), P(!0);
              },
              onFocus: () => {
                P(!0), !a.trim() && h.length > 0 && T(h.slice(0, 5));
              },
              onKeyDown: V,
              disabled: R
            }
          ),
          R && /* @__PURE__ */ e.jsx("div", { className: "dropdown-loading-message", children: "Loading members..." }),
          U && /* @__PURE__ */ e.jsx("div", { className: "dropdown-error-message", children: U }),
          N && !R && !U && /* @__PURE__ */ e.jsx(e.Fragment, { children: x.length > 0 ? /* @__PURE__ */ e.jsx("ul", { className: "dropdown-list", children: x.map((G) => /* @__PURE__ */ e.jsx(
            "li",
            {
              onClick: () => {
                le(G), o(G.orgMemberId), T([]), P(!1);
              },
              children: /* @__PURE__ */ e.jsxs("div", { className: "member-option", children: [
                /* @__PURE__ */ e.jsx("div", { className: "member-name", children: G.orgMemberId }),
                /* @__PURE__ */ e.jsxs("div", { className: "member-details", children: [
                  "ID: ",
                  G.id
                ] })
              ] })
            },
            G.id
          )) }) : a.trim() && h.length > 0 ? /* @__PURE__ */ e.jsxs("div", { className: "dropdown-empty-message", children: [
            'No members found matching "',
            a,
            '"'
          ] }) : null })
        ]
      }
    )
  ] }), oe = !!Y && !!a.trim() && !u && !R && !p && !U, fe = oe ? void 0 : u ? "Loading groups..." : R ? "Loading members..." : p || U || (Y ? "Please enter a member ID" : "Please select a group from the dropdown");
  return /* @__PURE__ */ e.jsx("div", { className: "add-participant-popup-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "add-participant-popup-content add-participant-modal", children: [
    /* @__PURE__ */ e.jsxs("div", { className: "popup-header", children: [
      /* @__PURE__ */ e.jsxs("div", { children: [
        /* @__PURE__ */ e.jsx("h2", { children: "Add Participant to Group" }),
        /* @__PURE__ */ e.jsx("p", { className: "popup-subtitle", children: "Search and select a group and member to initiate the add participant transaction." })
      ] }),
      /* @__PURE__ */ e.jsx(
        "button",
        {
          className: "btn close",
          onClick: () => r(!1),
          "aria-label": "Close",
          children: "×"
        }
      )
    ] }),
    /* @__PURE__ */ e.jsxs("div", { className: "popup-form passphrase-form", children: [
      /* @__PURE__ */ e.jsxs("div", { className: "form-section add-participant-form-section", children: [
        _(),
        B()
      ] }),
      /* @__PURE__ */ e.jsxs("div", { className: "popup-actions", children: [
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "btn secondary",
            onClick: () => r(!1),
            children: "Cancel"
          }
        ),
        /* @__PURE__ */ e.jsx("span", { title: fe, style: { display: "inline-block" }, children: /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "btn primary",
            onClick: F,
            disabled: !oe,
            loading: Q,
            loadingText: "Adding...",
            children: "Add Participant"
          }
        ) })
      ] })
    ] })
  ] }) });
}
function pl() {
  const [r, t] = cs(
    "groupsTab",
    "all"
  ), [s, n] = b(!1), [a, o] = b(null), {
    snackbarOpen: i,
    snackbarMessage: c,
    snackbarType: l,
    setSnackbarOpen: d,
    showSnackbar: u
  } = bt(), { snackbarOpen: m, snackbarMessage: p, setSnackbarOpen: y } = wr(!0);
  ve(() => ((async () => {
    var D;
    const h = O("bayunSessionId"), M = ue(), x = await (M == null ? void 0 : M.getFromStorage(
      h,
      v.MEMBER_STATUS
    )), T = mt(x), R = (D = T == null ? void 0 : T.memberStatus) == null ? void 0 : D.toLowerCase();
    o(R || null), R !== "admin" && R !== "securityadmin" && t("your");
  })(), is({
    onNotification: (h, M) => {
      u(h, M ?? "error");
    }
  }), () => os()), []);
  const g = a === "admin" || a === "securityadmin";
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Groups",
        subtitle: "Manage and organize member groups"
      }
    ),
    /* @__PURE__ */ e.jsxs("div", { className: "all-groups-container", children: [
      /* @__PURE__ */ e.jsxs("div", { className: "tabs", children: [
        /* @__PURE__ */ e.jsxs("div", { children: [
          g && /* @__PURE__ */ e.jsxs(
            "button",
            {
              className: `tab-button ${r === "all" ? "active" : ""}`,
              onClick: () => t("all"),
              children: [
                "All Groups",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    wide: !0,
                    placement: "bottom",
                    content: "All groups created and owned by any member of your own organization are listed here."
                  }
                )
              ]
            }
          ),
          /* @__PURE__ */ e.jsxs(
            "button",
            {
              className: `tab-button ${r === "your" ? "active" : ""}`,
              onClick: () => t("your"),
              children: [
                "Your Groups",
                /* @__PURE__ */ e.jsx(
                  Ke,
                  {
                    wide: !0,
                    placement: "bottom",
                    content: "All groups you are yourself a participant of are listed here, irrespective of who the owner of each group is. Note that in some cases, the group could also be owned by a different organization."
                  }
                )
              ]
            }
          )
        ] }),
        g && /* @__PURE__ */ e.jsx("div", { className: "button-wrapper", children: /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "btn add-participant",
            onClick: () => {
              n(!0);
            },
            children: "Add Participant"
          }
        ) })
      ] }),
      /* @__PURE__ */ e.jsxs("div", { className: "tab-content", children: [
        g && r === "all" && /* @__PURE__ */ e.jsx(dl, { onNotification: u }),
        r === "your" && /* @__PURE__ */ e.jsx(ul, { onNotification: u })
      ] }),
      s && /* @__PURE__ */ e.jsx(
        ml,
        {
          handleCloseClickCallback: n,
          onNotification: u
        }
      )
    ] }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: m,
        message: p || "You have pending approvals",
        onClose: () => y(!1),
        type: "info"
      }
    ),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: i,
        message: c,
        onClose: () => d(!1),
        type: l
      }
    )
  ] });
}
const yl = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: pl
}, Symbol.toStringTag, { value: "Module" }));
function hl(r, t, s) {
  return String(r ?? "") + String(t ?? "") + String(s ?? "");
}
async function gl(r, t, s, n, a) {
  if (t)
    return await r.decryptAsymmetric(
      n.adminEncryptedStatisticsKey,
      t,
      n.adminEncryptedStatisticsKey_kek,
      a
    );
  if (s) {
    const o = r.asRawKey(s);
    if (!o)
      return "";
    const i = await r.generateHMacHash(
      o,
      "lms" + a
    );
    return await r.aeadDecryptWithAssociatedData(
      n.lmsEncryptedStatisticsKey,
      "lms" + a,
      i
    );
  }
  return "";
}
async function fl(r, t, s, n) {
  t.encryptionCount && (t.encryptionCount = await r.aeadDecryptWithAssociatedData(
    t.encryptionCount,
    s,
    n
  )), t.decryptionCount && (t.decryptionCount = await r.aeadDecryptWithAssociatedData(
    t.decryptionCount,
    s,
    n
  )), t.lastOperationTime && (t.lastOperationTime = await r.aeadDecryptWithAssociatedData(
    t.lastOperationTime,
    s,
    n
  ));
}
async function bl(r, t, s, n, a, o) {
  return t ? await r.decryptAsymmetric(
    n.adminEncryptedDeviceKey,
    t,
    n.adminEncryptedDeviceKey_kek,
    a
  ) : s && o && n.memberEncryptedDeviceKey && n.memberEncryptedDeviceKey_kek ? await r.decryptAsymmetric(
    n.memberEncryptedDeviceKey,
    s,
    n.memberEncryptedDeviceKey_kek,
    a
  ) : "";
}
async function wl(r, t, s, n) {
  t.uniqueDeviceId && (t.uniqueDeviceId = await r.aeadDecryptWithAssociatedData(
    t.uniqueDeviceId,
    s,
    n
  )), t.operatingSystem && (t.operatingSystem = await r.aeadDecryptWithAssociatedData(
    t.operatingSystem,
    s,
    n
  )), t.version && (t.version = await r.aeadDecryptWithAssociatedData(
    t.version,
    s,
    n
  )), t.model && (t.model = await r.aeadDecryptWithAssociatedData(
    t.model,
    s,
    n
  )), t.brand && (t.brand = await r.aeadDecryptWithAssociatedData(
    t.brand,
    s,
    n
  ), t.manufacturer = await r.aeadDecryptWithAssociatedData(
    t.manufacturer,
    s,
    n
  )), t.versionIncremental && (t.versionIncremental = await r.aeadDecryptWithAssociatedData(
    t.versionIncremental,
    s,
    n
  )), t.versionSdkNumber && (t.versionSdkNumber = await r.aeadDecryptWithAssociatedData(
    t.versionSdkNumber,
    s,
    n
  )), t.macAddress && (t.macAddress = await r.aeadDecryptWithAssociatedData(
    t.macAddress,
    s,
    n
  )), t.host && (t.host = await r.aeadDecryptWithAssociatedData(
    t.host,
    s,
    n
  )), t.display && (t.display = await r.aeadDecryptWithAssociatedData(
    t.display,
    s,
    n
  )), t.board && (t.board = await r.aeadDecryptWithAssociatedData(
    t.board,
    s,
    n
  )), t.bootloader && (t.bootloader = await r.aeadDecryptWithAssociatedData(
    t.bootloader,
    s,
    n
  )), t.fingerprint && (t.fingerprint = await r.aeadDecryptWithAssociatedData(
    t.fingerprint,
    s,
    n
  )), t.hardware && (t.hardware = await r.aeadDecryptWithAssociatedData(
    t.hardware,
    s,
    n
  ));
}
async function Al(r) {
  if (!Array.isArray(r) || r.length === 0)
    return r;
  const t = ue();
  if (!t)
    return r;
  const s = O("bayunSessionId");
  if (!s)
    return r;
  const n = await t.getFromStorage(
    s,
    v.ORG_NAME
  ), a = await t.getFromStorage(
    s,
    v.MEMBER_KEY
  ), o = await t.getFromStorage(
    s,
    v.MEMBER_PRIVATE_KEY
  ), i = await t.getFromStorage(
    s,
    v.ORG_MEMBER_ID
  ), c = await t.getFromStorage(
    s,
    v.STATISTICS_KEY
  );
  let l = null;
  const d = (await t.getFromStorage(
    s,
    v.MEMBER_STATUS
  ) || "").toLowerCase();
  (d === "securityadmin" || d === "admin") && (l = await _e.getAdminPrivateKey());
  for (const u of r) {
    const m = hl(
      n,
      u.orgMemberId,
      u.appId
    ), p = u.orgMemberId === i;
    let y = p ? c : null;
    if (!y)
      try {
        console.info("deriving statistics key for", u.orgMemberId), y = await gl(
          t,
          l,
          a,
          u,
          m
        );
      } catch (g) {
        return console.error("Failed to derive statistics key", { error: g }), r;
      }
    if (!y) return r;
    try {
      console.info("decrypting item counters"), await fl(t, u, m, y);
    } catch (g) {
      return console.error("Failed to decrypt analytics data", { error: g }), r;
    }
    for (const g of u.deviceInfoResponses) {
      let w = "";
      try {
        w = await bl(
          t,
          l,
          o,
          g,
          m,
          p
        );
      } catch {
        return r;
      }
      if (w)
        try {
          await wl(
            t,
            g,
            m,
            w
          );
        } catch (h) {
          return console.error("Failed to decrypt analytics data", { error: h }), r;
        }
    }
  }
  return r;
}
function vl() {
  const { renderLoader: r } = De(), [t, s] = b(""), [n, a] = b([]), [o, i] = b([]), [c, l] = b(!0), [d, u] = b(null);
  ve(() => {
    (async () => {
      try {
        l(!0), u(null);
        const h = await Qn.fetchMemberStatistics(), M = await Al(h);
        a(M), i(M);
      } catch (h) {
        console.error("Failed to fetch member statistics:", h), u("Failed to load analytics data. Please try again.");
      } finally {
        l(!1);
      }
    })();
  }, []);
  const m = (w) => {
    const h = w.toLowerCase(), M = n.filter(
      (x) => x.orgMemberId.toLowerCase().includes(h) || x.appName.toLowerCase().includes(h)
    );
    i(M);
  }, p = (w) => {
    if (!w || w.length === 0)
      return "No device info";
    const h = w[0] || {};
    return `${h.operatingSystem} ${h.version} - ${h.model}`;
  }, y = (w) => {
    if (!w || w.length === 0)
      return "No device information available";
    const h = w[0] || {};
    return `${h.operatingSystem} ${h.version} - ${h.model}`;
  }, g = (w) => {
    if (!w || w.trim() === "")
      return "No recent operations";
    const h = Number(w);
    if (!isNaN(h) && h > 0) {
      const M = new Date(h);
      if (!isNaN(M.getTime()))
        return M.toLocaleString(void 0, {
          year: "2-digit",
          month: "short",
          day: "numeric",
          hour: "2-digit",
          minute: "2-digit",
          second: "2-digit",
          hour12: !0
        });
    }
    return w;
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Analytics",
        subtitle: "View encryption and decryption analytics",
        actions: /* @__PURE__ */ e.jsx("div", { className: "search-member", children: /* @__PURE__ */ e.jsx(
          "input",
          {
            type: "text",
            placeholder: "Search by member ID or app name",
            value: t,
            onChange: (w) => {
              s(w.target.value), m(w.target.value);
            }
          }
        ) })
      }
    ),
    /* @__PURE__ */ e.jsx("div", { className: "table-container", children: c ? r(c, "Loading analytics...") : d ? /* @__PURE__ */ e.jsx("div", { className: "error-container", children: /* @__PURE__ */ e.jsx("div", { className: "error-message", children: d }) }) : /* @__PURE__ */ e.jsxs("table", { className: "custom-table", children: [
      /* @__PURE__ */ e.jsx("thead", { children: /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("th", { children: "Member ID" }),
        /* @__PURE__ */ e.jsx("th", { children: "Application Name" }),
        /* @__PURE__ */ e.jsx("th", { children: "Encryption Count" }),
        /* @__PURE__ */ e.jsx("th", { children: "Decryption Count" }),
        /* @__PURE__ */ e.jsx("th", { children: "Last Operation" }),
        /* @__PURE__ */ e.jsx("th", { children: "Device Information" })
      ] }) }),
      /* @__PURE__ */ e.jsx("tbody", { children: o.length > 0 ? o.map((w, h) => /* @__PURE__ */ e.jsxs("tr", { children: [
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "member-id", children: w.orgMemberId }) }),
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "app-name", children: w.appName }) }),
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "count-badge encryption-count", children: w.encryptionCount }) }),
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "count-badge decryption-count", children: w.decryptionCount }) }),
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx("span", { className: "operation-time", children: g(w.lastOperationTime) }) }),
        /* @__PURE__ */ e.jsx("td", { children: /* @__PURE__ */ e.jsx(
          "span",
          {
            className: "device-info",
            title: y(w.deviceInfoResponses),
            children: p(w.deviceInfoResponses)
          }
        ) })
      ] }, h)) : /* @__PURE__ */ e.jsx("tr", { children: /* @__PURE__ */ e.jsx("td", { colSpan: 6, className: "empty-state", children: /* @__PURE__ */ e.jsxs("div", { className: "empty-content", children: [
        /* @__PURE__ */ e.jsx("div", { className: "empty-icon", children: "📊" }),
        /* @__PURE__ */ e.jsx("h3", { children: "No analytics data found" }),
        /* @__PURE__ */ e.jsx("p", { children: "No analytics data available for the current search criteria." })
      ] }) }) }) })
    ] }) })
  ] });
}
const El = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: vl
}, Symbol.toStringTag, { value: "Module" }));
function xl() {
  const [r, t] = b([]), [s, n] = b([]), [a, o] = b(!1), [i, c] = b([]);
  ve(() => {
    l();
  }, []);
  const l = async () => {
    o(!0);
    try {
      const d = await zn();
      t(d.acquiredLockboxes), n(
        d.lockBoxTransferRequests
      ), c(
        d.recoverUserTransactionList
      ), console.log("categorizedTransactions", d);
    } catch (d) {
      console.error("Error loading acquired lockboxes:", d), t([]), n([]), c([]);
    } finally {
      o(!1);
    }
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Lockbox Requests",
        subtitle: "View and manage incoming lockbox access requests"
      }
    ),
    /* @__PURE__ */ e.jsx(
      Hn,
      {
        loading: a,
        transactions: s,
        onTransactionsUpdated: () => {
          l();
        }
      }
    ),
    /* @__PURE__ */ e.jsx("br", {}),
    /* @__PURE__ */ e.jsx("br", {}),
    /* @__PURE__ */ e.jsx(
      $n,
      {
        transactions: r,
        loading: a
      }
    ),
    /* @__PURE__ */ e.jsx("br", {}),
    /* @__PURE__ */ e.jsx("br", {}),
    /* @__PURE__ */ e.jsx(
      Zr,
      {
        transactions: i,
        isLoading: a,
        onTransactionsUpdated: l
      }
    ),
    " "
  ] });
}
const Sl = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: xl
}, Symbol.toStringTag, { value: "Module" })), es = (r) => {
  if (!r) return !1;
  const t = r.trim();
  return t !== "" && t !== "N/A" && t !== "null";
}, Ml = (r, t, s) => r.filter(
  (n) => es(n.linkedUserId) && n.linkedUserId === t.linkedUserId && n.id !== t.id && n.id !== s.id && n.memberStatus !== ye.REGISTERED && !n.memberHaveAppsWithPasscode
);
function Pl() {
  const { renderLoader: r } = De(), [t, s] = b(""), [n, a] = b(""), [o, i] = b([]), [c, l] = b([]), [d, u] = b(null), [m, p] = b(null), [y, g] = b(!1), [w, h] = b(""), [M, x] = b(""), [T, R] = b(!1), [D, U] = b([]), [q, N] = b(!1), [P, Y] = b(""), re = Re(null), J = Re(null), le = async () => {
    N(!0), Y("");
    try {
      const _ = await we.getAllMembers();
      U(_);
    } catch (_) {
      console.error("Error fetching members:", _), Y(
        _ instanceof Error ? _.message : "Failed to load member data. Please try again."
      );
    } finally {
      N(!1);
    }
  };
  ve(() => {
    le();
  }, []);
  const Q = (_, B) => _.toLowerCase() === B.trim().toLowerCase(), de = (_) => {
    const B = _.trim();
    if (B.length < 1)
      return [];
    const oe = B.toLowerCase();
    return D.filter(
      (fe) => fe.orgMemberId.toLowerCase().includes(oe)
    );
  }, te = (_) => {
    const B = _.trim();
    if (B)
      return D.find((oe) => Q(oe.orgMemberId, B));
  }, K = (_, B, oe, fe) => {
    fe([]);
    const G = te(_);
    return G ? (B(G), oe(G.orgMemberId), G) : (B(null), null);
  }, X = (_) => {
    if (_.key === "Escape") {
      _.preventDefault(), i([]);
      return;
    }
    if (_.key === "Enter") {
      _.preventDefault();
      const B = K(
        t,
        u,
        s,
        i
      );
      h(B ? "" : t.trim() ? `Member "${t.trim()}" not found` : "Please select Current Owner");
    }
  }, I = (_) => {
    if (_.key === "Escape") {
      _.preventDefault(), l([]);
      return;
    }
    if (_.key === "Enter") {
      _.preventDefault();
      const B = K(
        n,
        p,
        a,
        l
      );
      h(B ? "" : n.trim() ? `Member "${n.trim()}" not found` : "Please select New Owner");
    }
  };
  ve(() => {
    const _ = (B) => {
      re.current && !re.current.contains(B.target) && i([]), J.current && !J.current.contains(B.target) && l([]);
    };
    return document.addEventListener("mousedown", _), document.addEventListener("click", _), () => {
      document.removeEventListener("mousedown", _), document.removeEventListener("click", _);
    };
  }, []);
  const f = (_, B, oe, fe, G) => {
    B(_), h(""), x(""), (!_.trim() || !fe || !Q(fe.orgMemberId, _)) && G(null), oe(de(_));
  }, j = async () => {
    var ne;
    const _ = d && Q(d.orgMemberId, t) ? d : te(t) ?? null, B = m && Q(m.orgMemberId, n) ? m : te(n) ?? null;
    _ && (u(_), t !== _.orgMemberId && s(_.orgMemberId)), B && (p(B), n !== B.orgMemberId && a(B.orgMemberId)), i([]), l([]);
    const oe = !!_ && _.id !== "" && _.id !== "null", fe = !!B && B.id !== "" && B.id !== "null";
    if (!oe && !fe) {
      t.trim() || n.trim() ? h("Entered member(s) not found. Please enter a valid member ID.") : h("Please select Current and New Owners");
      return;
    }
    if (!oe) {
      h(
        t.trim() ? `Member "${t.trim()}" not found` : "Please select Current Owner"
      );
      return;
    }
    if (!fe) {
      h(
        n.trim() ? `Member "${n.trim()}" not found` : "Please select New Owner"
      );
      return;
    }
    if (!_ || !B)
      return;
    if (_.id === B.id) {
      h("Source and Target cannot be same");
      return;
    }
    if ((!B.linkedUserId || B.linkedUserId === "null" || B.linkedUserId.trim() === "") && _.memberHaveAppsWithoutPasscode) {
      h("New Owner does not have a user linked");
      return;
    }
    if (_.memberStatus === ye.REGISTERED) {
      h("Current Owner is in Registered state");
      return;
    }
    if (B.memberStatus === ye.REGISTERED) {
      h("New Owner is in Registered state");
      return;
    }
    if (!es(B.linkedUserId) && _.memberHaveAppsWithoutPasscode) {
      h("New Owner does not have a user linked");
      return;
    }
    const G = ue();
    if (G && (G.requestSource, (ne = G.SOURCE) == null || ne.BASE_KIT), es(B.linkedUserId) && B.memberHaveAppsWithPasscode) {
      const me = Ml(
        D,
        B,
        _
      );
      if (me.length > 0) {
        const E = me.map((Z) => Z.orgMemberId).join(", ");
        h(
          `Choose another member of the same user that does not have a passcode: ${E}.`
        );
        return;
      }
      h(""), x(""), R(!0);
      return;
    }
    await C(_, B);
  }, C = async (_, B) => {
    if (B.memberStatus === ye.AUTO_APPROVED) {
      h("New Owner must be approved.");
      return;
    }
    g(!0), h(""), x("");
    try {
      const oe = {
        primaryOwnerId: _.id,
        newOwnerId: B.id
      };
      await we.initiateLockBoxTransfer(oe), x(
        `Transaction to transfer lockbox initiated from ${_.orgMemberId} to ${B.orgMemberId}.`
      ), s(""), a(""), u(null), p(null);
    } catch (oe) {
      const fe = oe instanceof Error ? oe.message : "Failed to transfer lockbox ownership. Please try again.";
      h(fe);
    } finally {
      g(!1);
    }
  }, k = async () => {
    R(!1), !(!d || !m) && await C(d, m);
  }, H = () => {
    R(!1);
  }, V = () => /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs("div", { className: "key-value-row", children: [
    /* @__PURE__ */ e.jsx("div", { className: "label", children: "Current Owner" }),
    /* @__PURE__ */ e.jsxs(
      "div",
      {
        className: "transfer-lockbox-dropdown-wrapper",
        style: { flex: "1 1 50%" },
        ref: re,
        children: [
          /* @__PURE__ */ e.jsx(
            "input",
            {
              type: "text",
              value: t,
              placeholder: "Search by member ID (min 1 characters)",
              onChange: (_) => f(
                _.target.value,
                s,
                i,
                d,
                u
              ),
              onFocus: () => {
                i(de(t));
              },
              onKeyDown: X
            }
          ),
          o.length > 0 && /* @__PURE__ */ e.jsx("ul", { className: "dropdown-list", children: o.map((_) => /* @__PURE__ */ e.jsx(
            "li",
            {
              onClick: () => {
                u(_), s(_.orgMemberId), i([]);
              },
              children: /* @__PURE__ */ e.jsx("div", { className: "member-option", children: /* @__PURE__ */ e.jsx("div", { className: "member-name", children: _.orgMemberId }) })
            },
            _.id
          )) })
        ]
      }
    )
  ] }) }), F = () => /* @__PURE__ */ e.jsx(e.Fragment, { children: /* @__PURE__ */ e.jsxs("div", { className: "key-value-row", children: [
    /* @__PURE__ */ e.jsx("div", { className: "label", children: "New Owner" }),
    /* @__PURE__ */ e.jsxs(
      "div",
      {
        className: "transfer-lockbox-dropdown-wrapper",
        style: { flex: "1 1 50%" },
        ref: J,
        children: [
          /* @__PURE__ */ e.jsx(
            "input",
            {
              type: "text",
              value: n,
              placeholder: "Search by member ID (min 1 characters)",
              onChange: (_) => f(
                _.target.value,
                a,
                l,
                m,
                p
              ),
              onFocus: () => {
                l(de(n));
              },
              onKeyDown: I
            }
          ),
          c.length > 0 && /* @__PURE__ */ e.jsx("ul", { className: "dropdown-list", children: c.map((_) => /* @__PURE__ */ e.jsx(
            "li",
            {
              onClick: () => {
                p(_), a(_.orgMemberId), l([]);
              },
              children: /* @__PURE__ */ e.jsx("div", { className: "member-option", children: /* @__PURE__ */ e.jsx("div", { className: "member-name", children: _.orgMemberId }) })
            },
            _.id
          )) })
        ]
      }
    )
  ] }) });
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    T && /* @__PURE__ */ e.jsx(
      "div",
      {
        className: "security-admin-transactions-modal-overlay",
        role: "dialog",
        "aria-modal": "true",
        "aria-labelledby": "dev-portal-warning-title",
        children: /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-content", children: [
          /* @__PURE__ */ e.jsx(
            "div",
            {
              id: "dev-portal-warning-title",
              className: "security-admin-transactions-modal-title",
              children: "Accept through Developer Portal"
            }
          ),
          /* @__PURE__ */ e.jsx("div", { className: "security-admin-transactions-modal-message", children: "The selected new owner has a passcode, and this user has no other member without a passcode. The new owner might* need to accept this transfer through the Bayun Developer Portal. Continue?" }),
          /* @__PURE__ */ e.jsxs("div", { className: "security-admin-transactions-modal-buttons", children: [
            /* @__PURE__ */ e.jsx(
              Pe,
              {
                className: "security-admin-transactions-modal-button-yes",
                onClick: k,
                loading: y,
                loadingText: "Continuing...",
                children: "Continue"
              }
            ),
            /* @__PURE__ */ e.jsx(
              "button",
              {
                type: "button",
                className: "security-admin-transactions-modal-button-no",
                onClick: H,
                disabled: y,
                children: "Deny"
              }
            )
          ] })
        ] })
      }
    ),
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Transfer Lockbox Ownership",
        subtitle: "Transfer ownership of lockbox from one member to another"
      }
    ),
    /* @__PURE__ */ e.jsxs("div", { className: "transfer-container", children: [
      w && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
        /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
        w
      ] }),
      M && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-success", children: [
        /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "✓" }),
        M
      ] }),
      P && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
        /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
        P
      ] }),
      r(q, "Loading member data..."),
      V(),
      F(),
      /* @__PURE__ */ e.jsx("div", { className: "button-wrapper", children: /* @__PURE__ */ e.jsx(
        Pe,
        {
          className: "btn transfer",
          onClick: j,
          loading: y,
          loadingText: "Initiating transaction...",
          children: "Transfer Ownership"
        }
      ) })
    ] })
  ] });
}
const Il = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: Pl
}, Symbol.toStringTag, { value: "Module" }));
function Ws(r) {
  return r.trim().toLowerCase();
}
function jl(r) {
  return r ? /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(r) : !1;
}
function Tl() {
  const { renderLoader: r } = De(), [t, s] = b(""), [n, a] = b([]), [o, i] = b([]), [c, l] = b(null), [d, u] = b(!1), [m, p] = b(""), [y, g] = b(!1), [w, h] = b(!1), [M, x] = b(!1), [T, R] = b(""), [D, U] = b("info"), [q, N] = b(!1), [P, Y] = b(null), re = Re(null), J = O("bayunSessionId"), le = ue(), Q = async () => {
    u(!0), p("");
    try {
      const k = await we.getAllUsers();
      a(k);
    } catch (k) {
      console.error("Error fetching users:", k), p(
        k instanceof Error ? k.message : "Failed to load user emails. Please try again."
      );
    } finally {
      u(!1);
    }
  };
  ve(() => {
    Q();
  }, []), ve(() => {
    const k = (H) => {
      re.current && !re.current.contains(H.target) && i([]);
    };
    return document.addEventListener("mousedown", k), document.addEventListener("click", k), () => {
      document.removeEventListener("mousedown", k), document.removeEventListener("click", k);
    };
  }, []);
  const de = (k, H) => k.toLowerCase() === H.trim().toLowerCase(), te = (k) => {
    const H = k.trim();
    if (H.length < 1)
      return [];
    const V = H.toLowerCase();
    return n.filter((F) => F.toLowerCase().includes(V));
  }, K = (k) => {
    const H = k.trim();
    if (H)
      return n.find((V) => de(V, H));
  }, X = (k, H) => {
    U(H), R(k), x(!0);
  }, I = (k) => {
    s(k), x(!1), R(""), (!k.trim() || !c || !de(c, k)) && l(null), i(te(k));
  }, f = (k) => {
    i([]);
    const H = K(k);
    return H ? (l(H), s(H), H) : (l(null), null);
  }, j = (k) => {
    if (k.key === "Escape") {
      k.preventDefault(), i([]);
      return;
    }
    k.key === "Enter" && (k.preventDefault(), f(t) || X(
      t.trim() ? `User "${t.trim()}" not found` : "Please enter a user email",
      "error"
    ));
  }, C = async () => {
    var F;
    const k = K(t), H = k ?? t;
    k && t !== k && (l(k), s(k)), i([]);
    const V = Ws(H);
    if (!jl(V)) {
      X("Please enter a valid email address.", "error");
      return;
    }
    g(!0), h(!0), x(!1);
    try {
      const _ = await le.getFromStorage(
        J,
        v.EMAIL_ADDRESS
      );
      if (_ && Ws(_) === V) {
        X(
          "You cannot initiate account recovery for your own account.",
          "error"
        );
        return;
      }
      const B = await Be.checkUserRecoveryEligibility(V);
      if (!B.eligible) {
        const fe = ((F = B.reasonForNonEligibility) == null ? void 0 : F.trim()) || "This account is not eligible for recovery at this time.";
        X(fe, "error");
        return;
      }
      if (h(!1), !await le.retrieveAndverifyLastSignature(
        J,
        B.backdoorPublicKey
      ))
        throw new Error("Backdoor public key signature verification failed");
      const { temporaryPassphrase: oe } = await we.initiateUserAccountRecovery({
        targetUserEmail: V,
        backdoorPublicKey: B.backdoorPublicKey
      });
      X(
        `User account recovery initiated for ${V}.`,
        "success"
      ), Y(oe), N(!0), s(""), l(null), i([]);
    } catch (_) {
      const B = _ instanceof Error ? _.message : "Failed to initiate user account recovery. Please try again.";
      X(B, "error");
    } finally {
      g(!1), h(!1);
    }
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "User Account Recovery",
        subtitle: "Enter the user's email to initiate assisted recovery"
      }
    ),
    /* @__PURE__ */ e.jsxs("div", { className: "transfer-container", children: [
      m && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
        /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
        m
      ] }),
      r(d, "Loading user emails..."),
      /* @__PURE__ */ e.jsxs("div", { className: "key-value-row", children: [
        /* @__PURE__ */ e.jsx("div", { className: "label", children: "User email" }),
        /* @__PURE__ */ e.jsxs(
          "div",
          {
            className: "transfer-lockbox-dropdown-wrapper",
            style: { flex: "1 1 50%" },
            ref: re,
            children: [
              /* @__PURE__ */ e.jsx(
                "input",
                {
                  type: "email",
                  autoComplete: "off",
                  value: t,
                  placeholder: "Search by email (min 1 characters)",
                  onChange: (k) => I(k.target.value),
                  onFocus: () => {
                    i(te(t));
                  },
                  onKeyDown: j
                }
              ),
              o.length > 0 && /* @__PURE__ */ e.jsx("ul", { className: "dropdown-list", children: o.map((k) => /* @__PURE__ */ e.jsx(
                "li",
                {
                  onClick: () => {
                    l(k), s(k), i([]);
                  },
                  children: /* @__PURE__ */ e.jsx("div", { className: "member-option", children: /* @__PURE__ */ e.jsx("div", { className: "member-name", children: k }) })
                },
                k
              )) })
            ]
          }
        )
      ] }),
      /* @__PURE__ */ e.jsx("div", { className: "button-wrapper", children: /* @__PURE__ */ e.jsx(
        Pe,
        {
          className: "btn transfer",
          type: "button",
          onClick: C,
          loading: y,
          loadingText: w ? "Checking..." : "Initiating...",
          children: "Initiate recovery"
        }
      ) })
    ] }),
    /* @__PURE__ */ e.jsx(
      Wn,
      {
        isOpen: q && !!P,
        passphrase: P || "",
        closeButtonLabel: "Understand",
        copySuccessText: "Copy",
        copyErrorText: "Copy",
        onCopySuccess: () => X("Passphrase copied to clipboard.", "success"),
        onCopyError: () => X(
          "Could not copy automatically. Please copy manually.",
          "error"
        ),
        onClose: () => {
          N(!1), Y(null);
        }
      }
    ),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: M,
        message: T,
        onClose: () => x(!1),
        type: D
      }
    )
  ] });
}
const Nl = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: Tl
}, Symbol.toStringTag, { value: "Module" }));
function Hs({
  label: r,
  name: t,
  value: s,
  onChange: n,
  error: a,
  placeholder: o,
  tooltip: i
}) {
  return /* @__PURE__ */ e.jsxs("div", { className: "key-value-row", children: [
    /* @__PURE__ */ e.jsx("div", { className: "label", children: /* @__PURE__ */ e.jsxs("div", { style: { display: "flex", alignItems: "center" }, children: [
      /* @__PURE__ */ e.jsx("div", { children: r }),
      i && /* @__PURE__ */ e.jsx(Ke, { content: i })
    ] }) }),
    /* @__PURE__ */ e.jsxs("div", { className: "settings-text-input", children: [
      /* @__PURE__ */ e.jsx(
        "input",
        {
          type: "text",
          value: s,
          placeholder: o,
          onChange: (c) => n(t, c.target.value)
        }
      ),
      a && /* @__PURE__ */ e.jsx("div", { className: "error-message", children: a })
    ] })
  ] });
}
function At({
  label: r,
  name: t,
  value: s,
  options: n,
  onChange: a,
  error: o,
  tooltip: i
}) {
  return /* @__PURE__ */ e.jsxs("div", { className: "key-value-row", children: [
    /* @__PURE__ */ e.jsx("div", { className: "label", children: /* @__PURE__ */ e.jsxs("div", { style: { display: "flex", alignItems: "center" }, children: [
      /* @__PURE__ */ e.jsx("div", { children: r }),
      i && /* @__PURE__ */ e.jsx(Ke, { content: i })
    ] }) }),
    /* @__PURE__ */ e.jsxs("div", { className: "settings-dropdown-wrapper", children: [
      /* @__PURE__ */ e.jsx(
        "select",
        {
          className: "custom-select",
          value: s,
          onChange: (c) => a(t, c.target.value),
          children: n.map((c) => /* @__PURE__ */ e.jsx("option", { value: c.value, children: c.label }, c.value))
        }
      ),
      o && /* @__PURE__ */ e.jsx("div", { className: "error-message", children: o })
    ] })
  ] });
}
const $s = {
  lockboxExpiryMinutes: "",
  statsSyncTime: "",
  memberApproval: "",
  appApproval: "",
  encryptionStatus: "",
  defaultEncryptionPolicy: "",
  encryptionMode: "",
  defaultKeyGenerationPolicy: "",
  defaultKeyValidationPolicy: ""
}, zs = (r, t) => Object.keys(r).some(
  (s) => r[s] !== t[s]
);
function kl() {
  const { renderLoader: r } = De(), [t, s] = b($s), [n, a] = b($s), [o, i] = b(""), [c, l] = b(""), [d, u] = b(""), [m, p] = b(""), [y, g] = b(""), [w, h] = b({}), [M, x] = b(!0), [T, R] = b(!1), [D, U] = b(!1), [q, N] = b(!1), [P, Y] = b(null), {
    snackbarOpen: re,
    snackbarMessage: J,
    snackbarType: le,
    setSnackbarOpen: Q,
    showSnackbar: de
  } = bt(), te = (E) => E === !0 || E === "true" ? "true" : E === !1 || E === "false" ? "false" : E != null ? String(E) : "";
  ve(() => {
    const E = async () => {
      try {
        x(!0);
        const Z = O("bayunSessionId"), z = ue(), ce = await (z == null ? void 0 : z.getFromStorage(
          Z,
          v.ORG_NAME
        ));
        if (!ce) {
          console.error("Org name not found"), x(!1);
          return;
        }
        const he = await Ce(z, Z), Ie = await z.generateHMacHash(
          he,
          "lms" + ce
        ), xe = await z.getFromStorage(
          Z,
          v.MEMBER_STATUS
        );
        N(xe === ye.SECURITY_ADMIN);
        const A = await Wr.fetchOrgSettings(Ie), se = await Ln(A);
        Y(se);
        const ie = se.minimumApprovalCount || "";
        i(ie), l(ie);
        const Ee = {
          lockboxExpiryMinutes: se.lockboxExpiry || "",
          statsSyncTime: se.statsSyncTime || "",
          memberApproval: se.memberApproval || "",
          appApproval: se.appApproval || "",
          encryptionStatus: te(
            se.encryptionStatus
          ),
          defaultEncryptionPolicy: se.encryptionPolicy || "",
          encryptionMode: se.encryptionMode || "",
          defaultKeyGenerationPolicy: se.keyGenerationPolicy || "",
          defaultKeyValidationPolicy: se.keyValidationPolicy || ""
        };
        s(Ee), a(Ee);
      } catch (Z) {
        console.error("Failed to fetch org settings:", Z);
      } finally {
        x(!1);
      }
    };
    return is({
      onNotification: (Z, z) => {
        de(Z, z ?? "error");
      }
    }), E(), () => os();
  }, []);
  const K = zs(t, n);
  ve(() => {
    if (!K) return;
    const E = (Z) => {
      Z.preventDefault(), Z.returnValue = "";
    };
    return window.addEventListener("beforeunload", E), () => window.removeEventListener("beforeunload", E);
  }, [K]);
  const X = (E, Z) => {
    s((z) => ({ ...z, [E]: Z }));
  }, I = () => {
    const E = {};
    return ["lockboxExpiryMinutes", "statsSyncTime"].forEach((z) => {
      const ce = parseInt(t[z], 10);
      (isNaN(ce) || ce < 0 || ce > 1e3) && (E[z] = "Value must be between 0 and 1000");
    }), h(E), Object.keys(E).length === 0;
  }, f = (E) => {
    u(""), p(""), g("");
    const Z = /^[0-9]*$/, z = P != null && P.securityAdminCount ? parseInt(P.securityAdminCount, 10) : 0;
    if (E !== "") {
      if (isNaN(Number(E)) || !Z.test(E))
        return u("Please enter a numeric value"), !1;
      if (Number(E) < 1)
        return u(
          "Please enter a value greater than or equal to 1"
        ), !1;
      if (z > 0 && Number(E) > z)
        return u(
          `Please enter a value less than or equal to the number of Security Admins (i.e. ${z})`
        ), !1;
      if (Number(E) === 1 && z !== 1 && z > 0)
        return p(
          "Any Security Admin will be able to complete a transaction without consent from anyone else"
        ), !0;
      if (Number(E) === z && z !== 1 && z > 0)
        return p(
          "All the Security Admins will be required to approve any future transaction"
        ), !0;
    }
    return !(E === "" || Number(E) < 1 || z > 0 && Number(E) > z);
  }, j = () => f(o), C = (E) => {
    i(E), f(E);
  }, k = () => {
    if (!o || o === "")
      return !1;
    const E = Number(o), Z = P != null && P.securityAdminCount ? parseInt(P.securityAdminCount, 10) : 0;
    return !(isNaN(E) || E < 1 || Z > 0 && E > Z || o === c);
  }, H = async () => {
    if (j())
      try {
        U(!0);
        const E = O("bayunSessionId"), Z = O("baseURL"), z = ue();
        if (!z || !E || !Z) {
          console.error(
            "Missing required data for saving minimum approval count"
          );
          return;
        }
        const ce = await z.getFromStorage(
          E,
          v.ORG_NAME
        );
        if (!ce)
          throw new Error("Org name not found");
        const he = await Ce(z, E), Ie = await z.generateAesKey(), xe = await rt(
          E,
          ce,
          z
        ), A = await z.getFromStorage(
          E,
          v.MEMBER_PRIVATE_KEY
        );
        if (!A)
          throw new Error("Member private key not found");
        const se = await We(
          E,
          Z,
          A,
          null,
          Ie,
          z
        ), ie = await _e.getAdminPrivateKey(), Ee = await z.generateHMacHash(
          he,
          "lms" + ce
        ), je = await z.aeadEncryptWithAssociatedData(
          $.IN_PROGRESS,
          "lms" + ce,
          Ee
        ), Ae = await z.aeadEncryptWithAssociatedData(
          be.EDIT_MINIMUM_APPROVAL_COUNT,
          "lms" + ce,
          Ee
        ), pe = await we.getMinimumApprovalCount(), Me = await z.aeadDecryptWithAssociatedData(
          pe.minimumApprovalCount,
          ce,
          he
        );
        if (!Me)
          throw new Error("Failed to decrypt current minimum approval count");
        const He = await z.getFromStorage(
          E,
          v.ADMIN_PUBLIC_KEY
        );
        if (!He)
          throw new Error("Admin public key not found");
        const Ue = await z.encryptAsymmetric(
          Me,
          He,
          ce
        ), Oe = await z.encryptAsymmetric(
          o,
          He,
          ce
        ), Qe = await pt(
          Ie,
          xe,
          ie,
          A,
          ce,
          z
        ), Je = await z.getFromStorage(
          E,
          v.MEMBER_APP_ID
        ), { transactionId: $e } = await we.initiateTransaction(), Ge = await z.getFromStorage(
          E,
          v.ORG_MEMBER_ID
        );
        let wt = await z.signData(
          $e,
          ie,
          z.context.getTransactionIdContext($e, $.IN_PROGRESS, be.EDIT_MINIMUM_APPROVAL_COUNT, ce, Ge)
        );
        wt = await z.appendSignatureAndMetadata(
          $e,
          wt,
          z.signingPublicKeyTags.ADMIN_PUBLIC_KEY_TAG,
          z.context.getTransactionIdContext($e, $.IN_PROGRESS, be.EDIT_MINIMUM_APPROVAL_COUNT, ce, Ge)
        );
        const Pt = {
          transactionEncryptionKeyRequestList: Qe,
          backdoorPrivateKeyPart: se || "",
          authPasscodeHash: "",
          minimumApprovalCount: Ue.encryptedText,
          minimumApprovalCount_kek: Ue.keyEncryptionKey,
          newMinimumApprovalCount: Oe.encryptedText,
          newMinimumApprovalCount_kek: Oe.keyEncryptionKey,
          lmsTransactionKey: Ee,
          transactionStatus: je,
          transactionLabel: Ae,
          transactionId: $e,
          signedTransactionId: wt
        }, Ct = await we.initiateEditMinimumApprovalCount(
          Pt
        );
        await uc(
          E,
          Ct,
          A,
          ce,
          ie,
          Z,
          z,
          wt
        ), l(o), de(
          "Transaction to change minimum approval count is initiated.",
          "success"
        );
      } catch (E) {
        console.error("Failed to save minimum approval count:", E), de(
          "Failed to save minimum approval count. Please try again.",
          "error"
        );
      } finally {
        U(!1);
      }
  }, V = async () => {
    if (I() && zs(t, n))
      try {
        R(!0);
        const E = O("bayunSessionId"), Z = ue();
        if (!Z || !E) {
          console.error("Missing required data for saving settings");
          return;
        }
        const z = await Z.getFromStorage(
          E,
          v.ORG_NAME
        );
        if (!z)
          throw new Error("Org name not found");
        const ce = await Ce(Z, E), he = {
          appApproval: t.appApproval,
          encryptionMode: t.encryptionMode,
          encryptionPolicy: t.defaultEncryptionPolicy,
          encryptionStatus: t.encryptionStatus,
          keyGenerationPolicy: t.defaultKeyGenerationPolicy,
          keyValidationPolicy: t.defaultKeyValidationPolicy,
          lockboxExpiry: t.lockboxExpiryMinutes,
          minimumApprovalCount: o,
          statsSyncTime: t.statsSyncTime,
          memberApproval: t.memberApproval
        }, Ie = (je) => Z.aeadEncryptWithAssociatedData(je, z, ce), xe = {};
        t.memberApproval !== n.memberApproval && (xe.memberApproval = he.memberApproval), t.appApproval !== n.appApproval && (xe.appApproval = he.appApproval), t.lockboxExpiryMinutes !== n.lockboxExpiryMinutes && (xe.lockboxExpiry = await Ie(he.lockboxExpiry)), t.statsSyncTime !== n.statsSyncTime && (xe.statsSyncTime = await Ie(he.statsSyncTime)), t.encryptionStatus !== n.encryptionStatus && (xe.encryptionStatus = await Ie(
          he.encryptionStatus
        )), t.defaultEncryptionPolicy !== n.defaultEncryptionPolicy && (xe.encryptionPolicy = await Ie(
          he.encryptionPolicy
        )), t.encryptionMode !== n.encryptionMode && (xe.encryptionMode = await Ie(
          he.encryptionMode
        )), t.defaultKeyGenerationPolicy !== n.defaultKeyGenerationPolicy && (xe.keyGenerationPolicy = await Ie(
          he.keyGenerationPolicy
        )), t.defaultKeyValidationPolicy !== n.defaultKeyValidationPolicy && (xe.keyValidationPolicy = he.keyValidationPolicy);
        const A = await Dn(
          Z,
          E,
          z,
          P == null ? void 0 : P.orgSettingsLastUpdatedAt
        ), se = Fn(
          A,
          Object.keys(xe)
        ), ie = await _e.getAdminPrivateKey(), { signedSettings: Ee } = await Z.signOrgSettingsFromLastUpdatedAt(
          se,
          ie,
          E,
          z
        );
        if (await Wr.updateOrgSettings({
          orgName: z,
          signedSettings: Ee,
          settingLastUpdatedAt: Un(
            Z,
            se
          ),
          ...xe
        }), await Z.saveInStorage(
          E,
          Z.getSettingLastUpdatedAtStorageKey(z),
          se
        ), "encryptionMode" in xe && await Z.saveInStorage(
          E,
          v.DEFAULT_ENCRYPTION_MODE,
          he.encryptionMode
        ), "encryptionPolicy" in xe && await Z.saveInStorage(
          E,
          v.DEFAULT_ENCRYPTION_POLICY,
          he.encryptionPolicy
        ), "keyGenerationPolicy" in xe && await Z.saveInStorage(
          E,
          v.DEFAULT_KEY_GENERATION_POLICY,
          he.keyGenerationPolicy
        ), "encryptionStatus" in xe && await Z.saveInStorage(
          E,
          v.IS_ENCRYPTION_ENABLED,
          he.encryptionStatus
        ), "keyValidationPolicy" in xe && await Z.saveInStorage(
          E,
          v.KEY_VALIDATION_POLICY,
          he.keyValidationPolicy
        ), "statsSyncTime" in xe) {
          await Z.saveInStorage(
            E,
            v.STATS_SYNC_TIME_DURATION,
            he.statsSyncTime
          );
          const je = Number(he.statsSyncTime);
          Number.isFinite(je) && await Z.saveInStorage(
            E,
            v.STATS_SYNC_EXPIRY_TIME,
            Date.now() + je * 60 * 1e3
          );
        }
        Y(
          (je) => je && {
            ...je,
            ...he,
            signedSettings: Ee,
            orgSettingsLastUpdatedAt: se
          }
        ), a({ ...t }), Nn(), de("Settings saved successfully!", "success");
      } catch (E) {
        console.error("Failed to save org settings:", E), de("Failed to save settings. Please try again.", "error");
      } finally {
        R(!1);
      }
  };
  if (M)
    return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
      /* @__PURE__ */ e.jsx(
        st,
        {
          heading: "Org Settings",
          subtitle: "Configure org-wide settings and policies"
        }
      ),
      /* @__PURE__ */ e.jsx("div", { className: "settings-container", children: r(M, "Loading org settings...") })
    ] });
  const F = () => P != null && P.memberApprovalValues && P.memberApprovalValues.length > 0 ? P.memberApprovalValues.map((E) => ({
    label: E,
    value: E
  })) : [], _ = () => P != null && P.appApprovalValues && P.appApprovalValues.length > 0 ? P.appApprovalValues.map((E) => ({
    label: E,
    value: E
  })) : [], B = () => P != null && P.encryptionStatusValues && P.encryptionStatusValues.length > 0 ? P.encryptionStatusValues.map((E) => {
    const Z = te(E);
    let z = Z;
    return Z === "true" ? z = "Enabled" : Z === "false" && (z = "Disabled"), {
      label: z,
      value: Z
    };
  }) : [], oe = () => P != null && P.encryptionPolicyValues && P.encryptionPolicyValues.length > 0 ? P.encryptionPolicyValues.map((E) => ({
    label: E,
    value: E
  })) : [], fe = () => P != null && P.encryptionModeValues && P.encryptionModeValues.length > 0 ? P.encryptionModeValues.map((E) => ({
    label: E,
    value: E
  })) : [], G = () => P != null && P.keyGenerationPolicyValues && P.keyGenerationPolicyValues.length > 0 ? P.keyGenerationPolicyValues.map((E) => ({
    label: E,
    value: E
  })) : [], ne = () => P != null && P.keyValidationPolicyValues && P.keyValidationPolicyValues.length > 0 ? P.keyValidationPolicyValues.map((E) => ({
    label: E,
    value: E
  })) : [], me = () => /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx("hr", { style: { margin: "0px 0px 3px 0px", border: "1px solid #e0e0e0" } }),
    /* @__PURE__ */ e.jsx("br", {})
  ] });
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Org Settings",
        subtitle: "Configure org-wide settings and policies"
      }
    ),
    q && /* @__PURE__ */ e.jsx("div", { className: "minimum-approval-container", children: /* @__PURE__ */ e.jsxs("div", { className: "minimum-approval-form", children: [
      /* @__PURE__ */ e.jsx("div", { className: "minimum-approval-label-wrapper", children: /* @__PURE__ */ e.jsxs("div", { className: "label", children: [
        "Minimum Approval Count",
        /* @__PURE__ */ e.jsx(
          Ke,
          {
            content: /* @__PURE__ */ e.jsx(e.Fragment, { children: "The minimum number of Security Admins whose approval is required to complete a transaction. You can change the value for all future transactions" })
          }
        )
      ] }) }),
      /* @__PURE__ */ e.jsxs("div", { className: "minimum-approval-input-wrapper", children: [
        /* @__PURE__ */ e.jsx(
          "input",
          {
            type: "text",
            value: o,
            placeholder: "",
            onChange: (E) => C(E.target.value),
            onKeyUp: (E) => C(E.currentTarget.value),
            className: "minimum-approval-input"
          }
        ),
        P != null && P.onGoingSecurityAdminTransaction && P.onGoingSecurityAdminTransaction.trim() !== "" ? /* @__PURE__ */ e.jsx(
          Ke,
          {
            content: /* @__PURE__ */ e.jsx(e.Fragment, { children: "You cannot edit the minimum approval count for the transactions if another approval transaction is in progress" }),
            children: /* @__PURE__ */ e.jsx(
              Pe,
              {
                className: "btn save minimum-approval-save-btn",
                onClick: H,
                disabled: !0,
                loading: D,
                loadingText: "Saving...",
                children: "Save"
              }
            )
          }
        ) : /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "btn save minimum-approval-save-btn",
            onClick: H,
            disabled: !k(),
            loading: D,
            loadingText: "Saving...",
            children: "Save"
          }
        ),
        d && /* @__PURE__ */ e.jsx("div", { className: "error-message minimum-approval-error-message", children: d }),
        m && /* @__PURE__ */ e.jsxs("div", { className: "warning-message minimum-approval-warning-message", children: [
          /* @__PURE__ */ e.jsx("span", { style: { marginRight: "5px" }, children: "⚠" }),
          m
        ] }),
        y && /* @__PURE__ */ e.jsx("div", { className: "success-message minimum-approval-success-message", children: y })
      ] })
    ] }) }),
    /* @__PURE__ */ e.jsxs("div", { className: "settings-container", children: [
      /* @__PURE__ */ e.jsx(
        At,
        {
          label: "Member Approval",
          name: "memberApproval",
          value: t.memberApproval,
          onChange: X,
          options: F(),
          tooltip: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
            /* @__PURE__ */ e.jsx("strong", { children: "Explicit-Approve:" }),
            " Every newly registered member requires explicit approval by an admin before becoming active.",
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("strong", { children: "Auto-Approve:" }),
            " A new member is automatically approved while registering for a Bayun-enabled application, thus becoming immediately active"
          ] })
        }
      ),
      /* @__PURE__ */ e.jsx(
        At,
        {
          label: "App Approval",
          name: "appApproval",
          value: t.appApproval,
          onChange: X,
          options: _(),
          tooltip: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
            /* @__PURE__ */ e.jsx("strong", { children: "Explicit-Approve:" }),
            " Every newly created application requires explicit approval by an admin before becoming active.",
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("strong", { children: "Auto-Approve:" }),
            " A new application is automatically approved when created, thus becoming immediately active"
          ] })
        }
      ),
      me(),
      /* @__PURE__ */ e.jsx(
        At,
        {
          label: "Default Key Validation Policy",
          name: "defaultKeyValidationPolicy",
          value: t.defaultKeyValidationPolicy,
          onChange: X,
          options: ne(),
          tooltip: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
            /* @__PURE__ */ e.jsx("strong", { children: "AutoApproval:" }),
            " User data can be shared with any other member that has been on-boarded via automatic approval, even if the member is not yet approved by an organization's admin.",
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("strong", { children: "OrgAdminApproval:" }),
            " User data can only be shared with other members that have been explicitly approved by an organization's admin during on-boarding. So a new member's public key will not be trusted before the member is approved by the organization's admin."
          ] })
        }
      ),
      /* @__PURE__ */ e.jsx(
        At,
        {
          label: "Default Encryption Policy",
          name: "defaultEncryptionPolicy",
          value: t.defaultEncryptionPolicy,
          onChange: X,
          options: oe(),
          tooltip: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
            'Encryption policy determines the encryption key that is used for encrypting user data. For example, data encrypted with encryption policy of "Org" is accessible to all members of that org, while data encrypted with encryption policy of "Member" is accessible only to that particular user.',
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("br", {}),
            "This default encryption policy is used for encrypting all application data that does not have an explicit policy attached to it (as provided by the application developer)."
          ] })
        }
      ),
      /* @__PURE__ */ e.jsx(
        At,
        {
          label: "Default Key Generation Policy",
          name: "defaultKeyGenerationPolicy",
          value: t.defaultKeyGenerationPolicy,
          onChange: X,
          options: G(),
          tooltip: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
            /* @__PURE__ */ e.jsx("strong", { children: "Static:" }),
            " Encryption of every data object is done with same key, that is derived from the Base Key. The Base Key is determined by the Policy tied to the object being locked (e.g. OrgKey, MemberKey, GroupKey).",
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("strong", { children: "Envelope:" }),
            " Every data object is encrypted with its own unique key that is randomly generated. The random key itself is kept encrypted with a key derived from the Base Key.",
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("strong", { children: "Chain:" }),
            " Every data object is encrypted with its own unique key, that is derived from the Base Key using a multi-dimensional chaining mechanism."
          ] })
        }
      ),
      me(),
      /* @__PURE__ */ e.jsx(
        Hs,
        {
          label: "Lockbox Expiry (In Minutes)",
          name: "lockboxExpiryMinutes",
          value: t.lockboxExpiryMinutes,
          onChange: X,
          error: w.lockboxExpiryMinutes,
          placeholder: "",
          tooltip: /* @__PURE__ */ e.jsx(e.Fragment, { children: "Maximum time period for which a lockbox containing encryption keys is leased to an application to allow temporary dis-connected operation." })
        }
      ),
      /* @__PURE__ */ e.jsx(
        Hs,
        {
          label: "Stats Sync Time (In Minutes)",
          name: "statsSyncTime",
          value: t.statsSyncTime,
          onChange: X,
          error: w.statsSyncTime,
          placeholder: "",
          tooltip: /* @__PURE__ */ e.jsx(e.Fragment, { children: "How often statistics are collected from the applications for visibility." })
        }
      ),
      me(),
      /* @__PURE__ */ e.jsx(
        At,
        {
          label: "Encryption Status",
          name: "encryptionStatus",
          value: t.encryptionStatus,
          onChange: X,
          options: B(),
          tooltip: /* @__PURE__ */ e.jsx(e.Fragment, { children: "Application data is encrypted only when Encryption Status is On. While Encryption Status is Off, no encryption is done by the application, irrespective of encryption policy specified (by the application developer, or default policy provided by the admin)." })
        }
      ),
      /* @__PURE__ */ e.jsx(
        At,
        {
          label: "Encryption Mode",
          name: "encryptionMode",
          value: t.encryptionMode,
          onChange: X,
          options: fe(),
          tooltip: /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
            /* @__PURE__ */ e.jsx("strong", { children: "ECB:" }),
            " Electronic Code Book",
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("strong", { children: "CBC:" }),
            " Cipher Block Chaining",
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("br", {}),
            /* @__PURE__ */ e.jsx("strong", { children: "AES-256-GCM:" }),
            " This mode provides Authenticated-Encryption with Associated-Data."
          ] })
        }
      ),
      /* @__PURE__ */ e.jsxs(
        "div",
        {
          className: `button-wrapper${K ? " has-unsaved-changes" : ""}`,
          children: [
            K && /* @__PURE__ */ e.jsxs("span", { className: "unsaved-changes-indicator", role: "status", children: [
              /* @__PURE__ */ e.jsx("span", { className: "unsaved-changes-dot", "aria-hidden": "true" }),
              "You have unsaved changes. Click Save to apply them."
            ] }),
            /* @__PURE__ */ e.jsx(
              Pe,
              {
                className: "btn save",
                onClick: V,
                disabled: !K,
                loading: T,
                loadingText: "Saving...",
                children: "Save"
              }
            )
          ]
        }
      )
    ] }),
    /* @__PURE__ */ e.jsx(
      ze,
      {
        open: re,
        message: J,
        onClose: () => Q(!1),
        type: le
      }
    )
  ] });
}
const Rl = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: kl
}, Symbol.toStringTag, { value: "Module" }));
class at {
  /**
   * Fetch two-factor authentication data
   */
  static async fetchTwoFAData() {
    try {
      return (await ee.get(
        O("baseURL") + "lms/admin/twofa/twoFAData"
      )).data;
    } catch (t) {
      throw t;
    }
  }
  /**
   * Validate security questions answers
   */
  static async validateSecurityQuestions(t) {
    try {
      return await ee.post(
        O("baseURL") + "lms/admin/twofa/validateSecurityQuestions",
        t
      );
    } catch (s) {
      throw s;
    }
  }
  /**
   * Set security questions
   */
  static async setSecurityQuestions(t) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/twofa/setSecurityQuestions",
        t
      )).data;
    } catch (s) {
      throw s;
    }
  }
  /**
   * Validate passphrase
   */
  static async validatePassphrase(t) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/twofa/validatePassphrase",
        t
      )).data;
    } catch (s) {
      throw s;
    }
  }
  /**
   * Set (create/update) passphrase
   */
  static async setPassphrase(t) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/twofa/setPassphrase",
        t
      )).data;
    } catch (s) {
      throw s;
    }
  }
  /**
   * Delete passphrase
   */
  static async deletePassphrase(t) {
    try {
      return (await ee.post(
        O("baseURL") + "lms/admin/deletePassphrase",
        t
      )).data;
    } catch (s) {
      throw s;
    }
  }
  /**
   * Fetch encrypted user recovery key and KEK metadata.
   */
  static async fetchUserRecoveryKeyData() {
    try {
      return (await ee.get(
        O("baseURL") + "lms/admin/userRecoveryKeyData"
      )).data;
    } catch (t) {
      throw t;
    }
  }
  /**
   * Revoke user recovery key.
   */
  static async revokeRecoveryKey() {
    try {
      await ee.post(O("baseURL") + "lms/revokeRecoveryKey");
    } catch (t) {
      throw t;
    }
  }
}
async function Zn({
  internal: r,
  sessionId: t,
  answers: s,
  minAnswersRequired: n = 3,
  insufficientAnswersMessage: a = "Please answer at least 3 security questions.",
  invalidAnswersMessage: o = "Invalid security question answers. Please try again."
}) {
  const i = s.filter((m) => m.answer.trim());
  if (i.length < n)
    throw new Error(a);
  const c = typeof r.getUserValidationSecretFromStorage == "function" ? await r.getUserValidationSecretFromStorage(
    t,
    i
  ) : null;
  let l;
  l = await at.validateSecurityQuestions({
    userValidationSecret: c
  });
  const d = await r.decryptAndGetUserPrivateKey(
    t,
    i,
    l
  ), u = await r.getFromStorage(
    t,
    v.USER_PRIVATE_KEY
  );
  if (d !== u)
    throw new Error(o);
  return { userValidationSecret: c, providedAnswers: i };
}
function Gt({
  value: r,
  onChange: t,
  className: s = "answer-input",
  visibilityLabel: n = "answer",
  disabled: a = !1,
  ...o
}) {
  const [i, c] = b(!1);
  return /* @__PURE__ */ e.jsxs("div", { className: "secret-answer-input-wrap", children: [
    /* @__PURE__ */ e.jsx(
      "input",
      {
        ...o,
        type: i ? "text" : "password",
        className: s,
        value: r,
        onChange: (l) => t(l.target.value),
        disabled: a,
        autoComplete: "off",
        autoCorrect: "off",
        autoCapitalize: "off",
        spellCheck: !1
      }
    ),
    /* @__PURE__ */ e.jsxs(
      "button",
      {
        type: "button",
        className: `secret-answer-visibility-toggle${i ? " is-visible" : ""}`,
        onClick: () => c((l) => !l),
        onMouseDown: (l) => l.preventDefault(),
        "aria-label": i ? `Hide ${n}` : `Show ${n}`,
        "aria-pressed": i,
        disabled: a,
        children: [
          /* @__PURE__ */ e.jsx("span", { className: "icon-eye-closed", "aria-hidden": "true", children: /* @__PURE__ */ e.jsxs("svg", { viewBox: "0 0 24 24", children: [
            /* @__PURE__ */ e.jsx("path", { d: "M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6z" }),
            /* @__PURE__ */ e.jsx("circle", { cx: "12", cy: "12", r: "3" })
          ] }) }),
          /* @__PURE__ */ e.jsx("span", { className: "icon-eye-open", "aria-hidden": "true", children: /* @__PURE__ */ e.jsxs("svg", { viewBox: "0 0 24 24", children: [
            /* @__PURE__ */ e.jsx("path", { d: "M3 3l18 18" }),
            /* @__PURE__ */ e.jsx("path", { d: "M10.6 10.7a3 3 0 0 0 4.2 4.2" }),
            /* @__PURE__ */ e.jsx("path", { d: "M9.9 5.2A10.8 10.8 0 0 1 12 5c6.5 0 10 7 10 7a16.2 16.2 0 0 1-4.2 4.7" }),
            /* @__PURE__ */ e.jsx("path", { d: "M6.4 6.4C3.8 8.2 2 12 2 12s3.5 6 10 6c1.7 0 3.2-.4 4.5-1" })
          ] }) })
        ]
      }
    )
  ] });
}
function ea({
  securityQuestions: r,
  answers: t,
  onAnswerChange: s,
  disabled: n = !1,
  title: a = "Validate Security Questions",
  description: o = "Answer at least 3 security questions"
}) {
  return /* @__PURE__ */ e.jsxs("div", { className: "form-section", children: [
    a ? /* @__PURE__ */ e.jsx("h3", { children: a }) : null,
    /* @__PURE__ */ e.jsx("p", { className: "form-description", children: o }),
    /* @__PURE__ */ e.jsx("div", { className: "question-group", children: r.map((i, c) => {
      var l;
      return /* @__PURE__ */ e.jsxs("div", { className: "security-question-item", children: [
        /* @__PURE__ */ e.jsxs("label", { className: "question-text", htmlFor: `security-answer-${i.questionId}`, children: [
          "Question ",
          c + 1,
          ": ",
          i.questionText
        ] }),
        /* @__PURE__ */ e.jsx(
          Gt,
          {
            id: `security-answer-${i.questionId}`,
            placeholder: "Enter your answer",
            value: ((l = t.find((d) => d.questionId === i.questionId)) == null ? void 0 : l.answer) || "",
            onChange: (d) => s(i.questionId, d),
            disabled: n,
            visibilityLabel: `answer ${c + 1}`
          }
        )
      ] }, i.questionId);
    }) })
  ] });
}
function ta({
  isOpen: r,
  onClose: t,
  onDeleted: s,
  title: n,
  subtitle: a,
  loaderMessage: o,
  successMessage: i,
  inactiveMessage: c,
  confirmMessage: l,
  warningMessage: d,
  deleteAction: u,
  isActionEnabled: m = () => !0
}) {
  const { renderLoader: p } = De(), [y, g] = b(!1), [w, h] = b(null), [M, x] = b(null), [T, R] = b(null), [D, U] = b(!1), [q, N] = b(!1), [P, Y] = b(!1), [re, J] = b(3), [le, Q] = b(null), [de, te] = b([]), [K, X] = b(
    []
  ), I = Re(null);
  ve(() => {
    r ? j() : f();
  }, [r]);
  const f = () => {
    g(!1), h(null), x(null), R(null), U(!1), N(!1), Y(!1), te([]), X([]);
  }, j = async () => {
    var V;
    g(!0), h(null), x(null), R(null);
    try {
      const F = ue(), _ = O("bayunSessionId"), B = await at.fetchTwoFAData();
      J(B.minimumCorrectQuestions), await (F == null ? void 0 : F.saveInStorage(
        _,
        v.USER_AUTH_SALT,
        B.userAuthSalt
      )), await (F == null ? void 0 : F.saveInStorage(
        _,
        v.IS_PASSPHRASE_ACTIVE,
        B.isPassphraseActive
      )), await (F == null ? void 0 : F.saveInStorage(
        _,
        v.ANSWER_AUTH_SALT,
        JSON.stringify(B.answerAuthSalt)
      )), B.minimumCorrectQuestions != null && await (F == null ? void 0 : F.saveInStorage(
        _,
        v.MINIMUM_CORRECT_QUESTIONS,
        String(B.minimumCorrectQuestions)
      )), (V = B.validationSecretDataRequest) != null && V.length && await (F == null ? void 0 : F.saveInStorage(
        _,
        v.VALIDATION_SECRET_DATA_REQUEST,
        JSON.stringify(B.validationSecretDataRequest)
      ));
      const oe = m(B);
      if (U(oe), !oe) {
        x(c);
        return;
      }
      const fe = B.securityQuestions || [];
      te(fe), X(
        fe.map((G) => ({
          questionId: G.questionId,
          answer: ""
        }))
      ), fe.length === 0 && x("No security questions available for verification.");
    } catch (F) {
      h("Failed to load security settings. Please try again."), console.error("DeleteProtectedActionPopup init error:", F);
    } finally {
      g(!1), I.current && I.current.scrollTo({ top: 0, behavior: "smooth" });
    }
  }, C = async () => {
    var V, F, _, B, oe, fe;
    try {
      if (h(null), R(null), x(null), !D) {
        x(c);
        return;
      }
      const G = ue(), ne = O("bayunSessionId");
      if (!G || !ne) {
        h("Session is unavailable. Please sign in again.");
        return;
      }
      Y(!0);
      const { userValidationSecret: me } = await Zn({
        internal: G,
        sessionId: ne,
        answers: K,
        minAnswersRequired: re,
        insufficientAnswersMessage: `Please answer at least ${re} security questions.`,
        invalidAnswersMessage: "Invalid security question answers. Please try again."
      });
      Q(me || ""), N(!0), R("Security questions validated. Please confirm deletion below.");
    } catch (G) {
      console.error("Error validating security questions:", G);
      const ne = ((F = (V = G == null ? void 0 : G.response) == null ? void 0 : V.data) == null ? void 0 : F.errorMessage) || ((B = (_ = G == null ? void 0 : G.response) == null ? void 0 : _.data) == null ? void 0 : B.message), E = ((fe = (oe = G == null ? void 0 : G.response) == null ? void 0 : oe.data) == null ? void 0 : fe.errorType) === "ACCESS_DENIED" && ne ? ne : ne || (G instanceof Error ? G.message : "Failed to validate security questions. Please try again.");
      h(E);
    } finally {
      Y(!1), I.current && I.current.scrollTo({ top: 0, behavior: "smooth" });
    }
  }, k = (V, F) => {
    X(
      (_) => _.map(
        (B) => B.questionId === V ? { ...B, answer: F } : B
      )
    );
  }, H = async () => {
    try {
      if (h(null), R(null), !q) {
        h("Please validate your security questions before deleting.");
        return;
      }
      g(!0), await u(le), R(i), X((V) => V.map((F) => ({ ...F, answer: "" }))), s && s();
    } catch (V) {
      console.error("Error deleting protected action:", V), h(
        V instanceof Error ? V.message : "Failed to complete delete action. Please try again."
      );
    } finally {
      g(!1), I.current && I.current.scrollTo({ top: 0, behavior: "smooth" });
    }
  };
  return r ? /* @__PURE__ */ e.jsx("div", { className: "add-participant-popup-overlay", children: /* @__PURE__ */ e.jsxs(
    "div",
    {
      className: "add-participant-popup-content security-settings-modal",
      ref: I,
      children: [
        /* @__PURE__ */ e.jsxs("div", { className: "popup-header", children: [
          /* @__PURE__ */ e.jsxs("div", { children: [
            /* @__PURE__ */ e.jsx("h2", { children: n }),
            /* @__PURE__ */ e.jsx("p", { className: "popup-subtitle", children: a })
          ] }),
          /* @__PURE__ */ e.jsx("button", { className: "btn close", onClick: t, children: "×" })
        ] }),
        d && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
          /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
          d
        ] }),
        p(y, o),
        w && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
          /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
          w
        ] }),
        T && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-success", children: [
          /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "✓" }),
          T
        ] }),
        M && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-info", children: [
          /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "ℹ" }),
          M
        ] }),
        /* @__PURE__ */ e.jsxs("div", { className: "passphrase-form", children: [
          D && /* @__PURE__ */ e.jsx(
            ea,
            {
              securityQuestions: de,
              answers: K,
              onAnswerChange: k,
              disabled: y || P || q,
              title: "Security Questions Verification",
              description: `Answer at least ${re} security questions`
            }
          ),
          q && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-info", children: [
            /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "ℹ" }),
            l
          ] }),
          /* @__PURE__ */ e.jsxs("div", { className: "popup-actions", children: [
            /* @__PURE__ */ e.jsx(
              "button",
              {
                className: "btn secondary",
                onClick: t,
                disabled: y || P,
                children: "Close"
              }
            ),
            D && !q && /* @__PURE__ */ e.jsx(
              Pe,
              {
                className: "btn primary",
                onClick: C,
                disabled: de.length === 0,
                loading: P,
                loadingText: "Validating...",
                children: "Validate"
              }
            ),
            D && q && /* @__PURE__ */ e.jsx(
              Pe,
              {
                className: "btn danger",
                onClick: H,
                loading: y,
                loadingText: "Deleting...",
                children: "Confirm Delete"
              }
            )
          ] })
        ] })
      ]
    }
  ) }) : null;
}
function Cl({
  isOpen: r,
  onClose: t,
  onDeleted: s
}) {
  const n = async (a) => {
    await at.deletePassphrase({
      origin: window.location.origin,
      userValidationSecret: a
    });
  };
  return /* @__PURE__ */ e.jsx(
    ta,
    {
      isOpen: r,
      onClose: t,
      onDeleted: s,
      title: "Delete Passphrase",
      subtitle: "Validate with security questions before deleting your passphrase.",
      loaderMessage: "Checking passphrase status...",
      successMessage: "Passphrase deleted successfully.",
      inactiveMessage: "No active passphrase found to delete.",
      confirmMessage: "Are you sure you want to delete your passphrase? This action cannot be undone.",
      deleteAction: n,
      isActionEnabled: (a) => a.isPassphraseActive === "true"
    }
  );
}
function _l({
  isOpen: r,
  onClose: t
}) {
  const { renderLoader: s } = De(), [n, a] = b(null), [o, i] = b(!1), [c, l] = b(null), [d, u] = b([]), [m, p] = b(!1), [y, g] = b(!1), [w, h] = b(!1), [M, x] = b(null), [T, R] = b(
    []
  ), [D, U] = b(5), [q, N] = b(3), P = ue(), Y = O("bayunSessionId"), re = Re(null), J = (V) => Math.min(10, Math.max(3, V)), le = (V) => Math.ceil(V / 2), Q = (V, F) => Math.min(F, Math.max(le(F), V)), de = () => Q(
    Number((n == null ? void 0 : n.minimumCorrectQuestions) ?? 3),
    J((n == null ? void 0 : n.securityQuestions.length) || 5)
  );
  ve(() => {
    r && te();
  }, [r]);
  const te = async () => {
    var V;
    i(!0), l(null);
    try {
      const F = await at.fetchTwoFAData();
      await P.saveInStorage(
        Y,
        v.USER_AUTH_SALT,
        F.userAuthSalt
      ), await P.saveInStorage(
        Y,
        v.IS_PASSPHRASE_ACTIVE,
        F.isPassphraseActive
      ), await P.saveInStorage(
        Y,
        v.EMAIL_ADDRESS,
        F.email
      ), await P.saveInStorage(
        Y,
        v.ANSWER_AUTH_SALT,
        JSON.stringify(F.answerAuthSalt)
      ), await P.saveInStorage(
        Y,
        v.SECURITY_QUESTIONS,
        JSON.stringify(F.securityQuestions)
      ), F.minimumCorrectQuestions != null && await P.saveInStorage(
        Y,
        v.MINIMUM_CORRECT_QUESTIONS,
        String(F.minimumCorrectQuestions)
      ), (V = F.validationSecretDataRequest) != null && V.length && await P.saveInStorage(
        Y,
        v.VALIDATION_SECRET_DATA_REQUEST,
        JSON.stringify(F.validationSecretDataRequest)
      ), a(F);
      const _ = F.securityQuestions.map((G) => ({
        questionId: G.questionId,
        answer: ""
      }));
      u(_);
      const B = J(
        F.securityQuestions.length || 5
      ), oe = Q(
        Number(F.minimumCorrectQuestions ?? 3),
        B
      ), fe = Array.from(
        { length: B },
        (G, ne) => {
          var me;
          return {
            question: ((me = F.securityQuestions[ne]) == null ? void 0 : me.questionText) ?? "",
            answer: ""
          };
        }
      );
      U(B), N(oe), R(fe);
    } catch (F) {
      l("Failed to fetch security questions data"), console.error("Error fetching twoFA data:", F);
    } finally {
      i(!1);
    }
  }, K = (V, F) => {
    u(
      (_) => _.map(
        (B) => B.questionId === V ? { ...B, answer: F } : B
      )
    );
  }, X = async () => {
    g(!0), x(null);
    try {
      await Zn({
        internal: P,
        sessionId: Y,
        answers: d,
        minAnswersRequired: de(),
        insufficientAnswersMessage: `Please answer at least ${de()} security questions.`,
        invalidAnswersMessage: "Invalid security questions. Please try again."
      }), p(!0), x(null), re.current && re.current.scrollTo({ top: 0, behavior: "smooth" });
    } catch (V) {
      console.error("Error validating security questions:", V), x(
        V instanceof Error ? V.message : "Failed to validate security questions. Please check your answers and try again."
      );
    } finally {
      g(!1);
    }
  }, I = (V, F) => {
    R(
      (_) => _.map(
        (B, oe) => oe === V ? { ...B, question: F } : B
      )
    );
  }, f = (V, F) => {
    R(
      (_) => _.map(
        (B, oe) => oe === V ? { ...B, answer: F } : B
      )
    );
  }, j = (V) => {
    const F = J(V), _ = Q(
      q,
      F
    );
    U(F), N(_), R(
      (B) => Array.from({ length: F }, (oe, fe) => {
        var G, ne;
        return {
          question: ((G = B[fe]) == null ? void 0 : G.question) ?? "",
          answer: ((ne = B[fe]) == null ? void 0 : ne.answer) ?? ""
        };
      })
    );
  }, C = (V) => {
    N(
      Q(V, D)
    );
  }, k = async () => {
    try {
      h(!0), l(null);
      const V = await P.getFromStorage(
        Y,
        v.EMAIL_ADDRESS
      ), F = () => {
        console.error("Failed to prepare set security questions request"), l("Failed to prepare security questions request");
      }, _ = J(D), B = Q(
        q,
        _
      ), oe = T.slice(
        0,
        _
      ), fe = oe.some(
        (ce) => !ce.question.trim()
      ), G = oe.some(
        (ce) => !ce.answer.trim()
      );
      if (fe || G) {
        l(
          "All questions and answers are mandatory before saving settings"
        );
        return;
      }
      const {
        securityQuestionsDataRequest: ne,
        validationSecretDataRequest: me,
        userValidationSecret: E,
        signedUserPublicKeyWithMetadata: Z
      } = await P.prepareSetSecurityQuestionsRequest(
        Y,
        V,
        oe,
        B,
        F
      );
      await at.setSecurityQuestions({
        securityQuestionsDataRequest: ne,
        validationSecretDataRequest: me,
        userValidationSecret: E,
        userPublicKey: Z,
        totalQuestions: oe.length,
        minimumCorrectQuestions: B
      }) && H();
    } catch (V) {
      console.error("Error setting security questions:", V), l(
        V instanceof Error ? V.message : "Failed to set security questions. Please try again."
      );
    } finally {
      h(!1);
    }
  }, H = () => {
    a(null), u([]), R([]), l(null), p(!1), g(!1), h(!1), x(null), U(5), N(3), t();
  };
  return r ? /* @__PURE__ */ e.jsx("div", { className: "add-participant-popup-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "add-participant-popup-content security-settings-modal", ref: re, children: [
    /* @__PURE__ */ e.jsxs("div", { className: "popup-header", children: [
      /* @__PURE__ */ e.jsxs("div", { children: [
        /* @__PURE__ */ e.jsx("h2", { children: m ? "Edit Security Questions" : "Validate Security Questions" }),
        /* @__PURE__ */ e.jsx("p", { className: "popup-subtitle", children: "Verify existing answers, then update questions and answers." })
      ] }),
      /* @__PURE__ */ e.jsx("button", { className: "btn close", onClick: H, children: "×" })
    ] }),
    s(o, "Loading security questions..."),
    c && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
      /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
      c
    ] }),
    M && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
      /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
      M
    ] }),
    m && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-success", children: [
      /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "✓" }),
      "Security questions validated successfully! You can now edit your questions and answers."
    ] }),
    n && !o && /* @__PURE__ */ e.jsxs("div", { className: "security-questions-form", children: [
      m ? /* @__PURE__ */ e.jsxs("div", { className: "form-section", children: [
        /* @__PURE__ */ e.jsx("h3", { children: "Security Questions" }),
        /* @__PURE__ */ e.jsx("p", { className: "form-description", children: "Configure your security question requirements, then provide all questions and answers." }),
        /* @__PURE__ */ e.jsxs("div", { className: "threshold-controls-row", children: [
          /* @__PURE__ */ e.jsxs("div", { className: "question-group total-questions-control", children: [
            /* @__PURE__ */ e.jsxs("label", { className: "question-label", children: [
              "Total questions: ",
              D
            ] }),
            /* @__PURE__ */ e.jsx(
              "select",
              {
                className: "answer-input",
                value: D,
                onChange: (V) => j(Number(V.target.value)),
                children: [3, 4, 5, 6, 7, 8, 9, 10].map((V) => /* @__PURE__ */ e.jsx("option", { value: V, children: V }, V))
              }
            )
          ] }),
          /* @__PURE__ */ e.jsxs("div", { className: "question-group minimum-correct-control", children: [
            /* @__PURE__ */ e.jsxs("label", { className: "question-label", children: [
              "Minimum correct answers: ",
              q
            ] }),
            /* @__PURE__ */ e.jsx(
              "input",
              {
                type: "range",
                min: le(D),
                max: D,
                value: q,
                onChange: (V) => C(Number(V.target.value))
              }
            )
          ] })
        ] }),
        T.slice(0, D).map((V, F) => /* @__PURE__ */ e.jsxs("div", { className: "question-group", children: [
          /* @__PURE__ */ e.jsxs("label", { className: "question-label", children: [
            "Question ",
            F + 1,
            ":"
          ] }),
          /* @__PURE__ */ e.jsx(
            "input",
            {
              type: "text",
              className: "answer-input",
              placeholder: `Edit question ${F + 1}`,
              value: V.question,
              onChange: (_) => I(F, _.target.value)
            }
          ),
          /* @__PURE__ */ e.jsx(
            Gt,
            {
              placeholder: "Enter your answer",
              value: V.answer,
              onChange: (_) => f(F, _),
              visibilityLabel: `answer ${F + 1}`
            }
          )
        ] }, `setup-question-${F}`))
      ] }) : /* @__PURE__ */ e.jsx(
        ea,
        {
          securityQuestions: n.securityQuestions,
          answers: d,
          onAnswerChange: K,
          disabled: y,
          title: "",
          description: `Please answer at least ${Number(
            de()
          )} of the following security questions:`
        }
      ),
      /* @__PURE__ */ e.jsxs("div", { className: "popup-actions", children: [
        /* @__PURE__ */ e.jsx("button", { className: "btn secondary", onClick: H, disabled: y || w, children: "Cancel" }),
        m ? /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "btn success",
            onClick: k,
            loading: w,
            loadingText: "Saving...",
            children: "Set Security Questions"
          }
        ) : /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "btn primary",
            onClick: X,
            loading: y,
            loadingText: "Validating...",
            children: "Validate"
          }
        )
      ] })
    ] })
  ] }) }) : null;
}
function Kl({
  isOpen: r,
  onClose: t
}) {
  const { renderLoader: s } = De(), [n, a] = b(null), [o, i] = b(!1), [c, l] = b(null), [d, u] = b(""), [m, p] = b(""), [y, g] = b(""), [w, h] = b(!1), [M, x] = b(!1), [T, R] = b(!1), [D, U] = b(null), q = ue(), N = O("bayunSessionId"), P = Re(null);
  ve(() => {
    r && Y();
  }, [r]);
  const Y = async () => {
    i(!0), l(null);
    try {
      const Q = await at.fetchTwoFAData();
      await q.saveInStorage(
        N,
        v.USER_AUTH_SALT,
        Q.userAuthSalt
      ), await q.saveInStorage(
        N,
        v.IS_PASSPHRASE_ACTIVE,
        Q.isPassphraseActive
      ), await q.saveInStorage(
        N,
        v.EMAIL_ADDRESS,
        Q.email
      ), a(Q);
    } catch (Q) {
      l("Failed to fetch passphrase data"), console.error("Error fetching twoFA data:", Q);
    } finally {
      i(!1);
    }
  }, re = async () => {
    var Q, de, te, K, X, I;
    if (n) {
      if (n.isPassphraseActive !== "true") {
        h(!0), P.current && P.current.scrollTo({ top: 0, behavior: "smooth" });
        return;
      }
      if (!d.trim()) {
        U("Please enter your current passphrase to validate.");
        return;
      }
      x(!0), U(null);
      try {
        const f = n.userAuthSalt;
        if (!f) {
          U("Missing userAuthSalt required for validation.");
          return;
        }
        const j = await q.derivePbkdf2Encoded(
          d,
          f
        );
        if (!j) {
          U("Failed to generate passphrase hash.");
          return;
        }
        await at.validatePassphrase({ authPassphraseHash: j }), h(!0), P.current && P.current.scrollTo({ top: 0, behavior: "smooth" });
      } catch (f) {
        console.error("Error validating passphrase:", f);
        const j = ((de = (Q = f == null ? void 0 : f.response) == null ? void 0 : Q.data) == null ? void 0 : de.errorMessage) || ((K = (te = f == null ? void 0 : f.response) == null ? void 0 : te.data) == null ? void 0 : K.message), k = ((I = (X = f == null ? void 0 : f.response) == null ? void 0 : X.data) == null ? void 0 : I.errorType) === "ACCESS_DENIED" && j ? j : j || (f instanceof Error ? f.message : "Failed to validate passphrase. Please try again.");
        U(k);
      } finally {
        x(!1);
      }
    }
  }, J = async () => {
    try {
      if (R(!0), l(null), !n) {
        l("Passphrase data not loaded");
        return;
      }
      if (!m.trim()) {
        l("New passphrase cannot be empty");
        return;
      }
      if (m !== y) {
        l("New passphrase and confirm passphrase do not match");
        return;
      }
      if (n.isPassphraseActive === "true" && !w) {
        l("Please validate your current passphrase first");
        return;
      }
      const {
        authPassphraseHash: Q,
        encryptedUserPrivateKey: de,
        userAuthSalt: te,
        userKeySalt: K
      } = await q.prepareSetNewPassphraseRequest(
        N,
        m
      );
      await at.setPassphrase({
        authPassphraseHash: Q,
        encryptedUserPrivateKey: de,
        userAuthSalt: te,
        userKeySalt: K
      }), le();
    } catch (Q) {
      console.error("Error saving new passphrase:", Q), l(
        Q instanceof Error ? Q.message : "Failed to save new passphrase. Please try again."
      );
    } finally {
      R(!1);
    }
  }, le = () => {
    a(null), u(""), p(""), l(null), h(!1), x(!1), R(!1), U(null), t();
  };
  return r ? /* @__PURE__ */ e.jsx("div", { className: "add-participant-popup-overlay", children: /* @__PURE__ */ e.jsxs("div", { className: "add-participant-popup-content security-settings-modal", ref: P, children: [
    /* @__PURE__ */ e.jsxs("div", { className: "popup-header", children: [
      /* @__PURE__ */ e.jsxs("div", { children: [
        /* @__PURE__ */ e.jsx("h2", { children: (n == null ? void 0 : n.isPassphraseActive) === "true" ? w ? "Edit Passphrase" : "Validate Passphrase" : "Set Passphrase" }),
        /* @__PURE__ */ e.jsx("p", { className: "popup-subtitle", children: (n == null ? void 0 : n.isPassphraseActive) === "true" ? "Validate your current passphrase to continue." : "Create a new passphrase for additional account security." })
      ] }),
      /* @__PURE__ */ e.jsx("button", { className: "btn close", onClick: le, children: "×" })
    ] }),
    s(o, "Loading passphrase data..."),
    c && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
      /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
      c
    ] }),
    D && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-error", children: [
      /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "⚠" }),
      D
    ] }),
    w && /* @__PURE__ */ e.jsxs("div", { className: "alert alert-success", children: [
      /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "✓" }),
      (n == null ? void 0 : n.isPassphraseActive) === "true" ? "Passphrase validated successfully! You can now set a new passphrase." : "You can now set your passphrase."
    ] }),
    n && !o && /* @__PURE__ */ e.jsxs("div", { className: "passphrase-form", children: [
      /* @__PURE__ */ e.jsxs("div", { className: "form-section", children: [
        /* @__PURE__ */ e.jsxs("div", { className: "passphrase-info", children: [
          /* @__PURE__ */ e.jsxs("p", { children: [
            /* @__PURE__ */ e.jsx("strong", { children: "Attempts:" }),
            " ",
            n.passphraseAttempts
          ] }),
          /* @__PURE__ */ e.jsxs("p", { children: [
            /* @__PURE__ */ e.jsx("strong", { children: "Email:" }),
            " ",
            n.email
          ] })
        ] }),
        w ? /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
          /* @__PURE__ */ e.jsxs("div", { className: "question-group", children: [
            /* @__PURE__ */ e.jsx("label", { className: "question-label", children: n.isPassphraseActive === "true" ? "Edit your passphrase" : "Set your passphrase" }),
            /* @__PURE__ */ e.jsx(
              Gt,
              {
                placeholder: "Enter new passphrase",
                value: m,
                onChange: p,
                visibilityLabel: "new passphrase"
              }
            )
          ] }),
          /* @__PURE__ */ e.jsxs("div", { className: "question-group", children: [
            /* @__PURE__ */ e.jsx("label", { className: "question-label", children: "Confirm new passphrase" }),
            /* @__PURE__ */ e.jsx(
              Gt,
              {
                placeholder: "Re-enter new passphrase",
                value: y,
                onChange: g,
                visibilityLabel: "confirm passphrase"
              }
            )
          ] })
        ] }) : n.isPassphraseActive === "true" ? /* @__PURE__ */ e.jsxs("div", { className: "question-group", children: [
          /* @__PURE__ */ e.jsx("label", { className: "question-label", children: "Enter your existing passphrase to validate" }),
          /* @__PURE__ */ e.jsx(
            Gt,
            {
              placeholder: "Enter your existing passphrase",
              value: d,
              onChange: u,
              visibilityLabel: "passphrase"
            }
          )
        ] }) : /* @__PURE__ */ e.jsxs("div", { className: "alert alert-info", children: [
          /* @__PURE__ */ e.jsx("span", { className: "alert-icon", children: "ℹ" }),
          "No passphrase is currently set. You can set a new passphrase below."
        ] })
      ] }),
      /* @__PURE__ */ e.jsxs("div", { className: "popup-actions", children: [
        /* @__PURE__ */ e.jsx("button", { className: "btn secondary", onClick: le, disabled: M || T, children: "Cancel" }),
        w ? /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "btn success",
            onClick: J,
            loading: T,
            loadingText: n.isPassphraseActive === "true" ? "Saving..." : "Setting...",
            children: n.isPassphraseActive === "true" ? "Save" : "Set"
          }
        ) : n.isPassphraseActive === "true" ? /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "btn primary",
            onClick: re,
            loading: M,
            loadingText: "Validating...",
            children: "Validate"
          }
        ) : /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "btn success",
            onClick: re,
            loading: M,
            loadingText: "Continuing...",
            children: "Continue"
          }
        )
      ] })
    ] })
  ] }) }) : null;
}
function Ol({
  isOpen: r,
  onClose: t,
  onDeleted: s
}) {
  const n = async () => {
    await at.revokeRecoveryKey();
  };
  return /* @__PURE__ */ e.jsx(
    ta,
    {
      isOpen: r,
      onClose: t,
      onDeleted: s,
      title: "Delete Recovery Key",
      subtitle: "Validate with security questions before deleting your recovery key.",
      loaderMessage: "Checking recovery key status...",
      successMessage: "Recovery key deleted successfully.",
      inactiveMessage: "No active recovery key found to delete.",
      confirmMessage: "Are you sure you want to delete your recovery key? This action cannot be undone.",
      warningMessage: "WARNING: Deleting your recovery key removes an important account recovery option. If you forget your credentials and cannot answer your security questions, you may permanently lose access to your account.",
      deleteAction: n,
      isActionEnabled: (a) => !0
    }
  );
}
async function Qs() {
  const r = ue(), t = O("bayunSessionId");
  if (!r || !t)
    return null;
  const { userRecoveryKey: s, userRecoveryKeyKek: n, recoveryKeyId: a } = await at.fetchUserRecoveryKeyData();
  if (!s || !n || a == null)
    return null;
  const [o, i] = await Promise.all([
    r.getFromStorage(t, v.USER_PRIVATE_KEY),
    r.getFromStorage(t, v.USER_ID)
  ]);
  if (!o || !i || !await r.retrieveAndverifyLastSignature(
    t,
    n
  ))
    return null;
  const l = await r.decryptAsymmetric(
    s,
    o,
    n,
    i
  );
  return l ? {
    userId: i,
    recoveryKey: l,
    recoveryKeyId: a
  } : null;
}
function Ll(r, t) {
  const s = new Blob([r], { type: "text/plain" }), n = URL.createObjectURL(s), a = document.createElement("a");
  a.href = n, a.download = t, document.body.appendChild(a), a.click(), document.body.removeChild(a), URL.revokeObjectURL(n);
}
function Dl() {
  const [r, t] = b(!1), [s, n] = b(!0), [a, o] = b(!1), [i, c] = b(!1), [l, d] = b(!1), [u, m] = b(!1);
  ve(() => {
    (async () => {
      try {
        n(!0);
        const w = await Qs();
        t(!!(w != null && w.recoveryKey));
      } catch (w) {
        console.error("Error verifying recovery key details:", w), t(!1);
      } finally {
        n(!1);
      }
    })();
  }, []), ve(() => {
    (async () => {
      const w = O("bayunSessionId"), h = ue();
      if (!w || !h)
        return;
      const M = await h.getFromStorage(
        w,
        v.FIRST_TIME_LOG_IN
      );
      c(!!M);
    })();
  }, []);
  const p = async () => {
    const g = ue();
    if (!g) {
      console.error("Bayun internal bridge is unavailable.");
      return;
    }
    try {
      d(!0);
      const w = await Qs();
      if (!w) {
        console.error("Unable to download recovery key: verification failed."), t(!1);
        return;
      }
      const h = g.serializeUserRecoveryKeyFile(
        w.recoveryKey,
        w.recoveryKeyId
      );
      Ll(
        h,
        "bayun-recovery-key.txt"
      );
    } catch (w) {
      console.error("Failed to download recovery key.", w);
    } finally {
      d(!1);
    }
  }, y = async () => {
    const g = ue(), w = O("bayunSessionId");
    if (!g || !w) {
      console.error("Bayun internal bridge or session is unavailable.");
      return;
    }
    try {
      m(!0), await Gn(g, w), t(!0);
    } catch (h) {
      console.error("Failed to create recovery key.", h);
    } finally {
      m(!1);
    }
  };
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsxs("div", { className: "security-setting-card", children: [
      /* @__PURE__ */ e.jsxs("div", { className: "security-setting-copy", children: [
        /* @__PURE__ */ e.jsx("h4", { children: "Recovery Key" }),
        /* @__PURE__ */ e.jsx("p", { children: "Manage your recovery key for account recovery if primary credentials are unavailable." })
      ] }),
      s ? /* @__PURE__ */ e.jsx("button", { className: "btn edit", disabled: !0, children: "Checking..." }) : r ? /* @__PURE__ */ e.jsxs("div", { className: "security-settings-recovery-actions", children: [
        /* @__PURE__ */ e.jsx(
          "button",
          {
            className: "btn delete",
            type: "button",
            onClick: () => o(!0),
            children: "Delete Key"
          }
        ),
        /* @__PURE__ */ e.jsx(
          Pe,
          {
            className: "btn edit",
            type: "button",
            onClick: p,
            loading: l,
            loadingText: "Downloading...",
            children: "Download Key"
          }
        )
      ] }) : /* @__PURE__ */ e.jsx(
        Pe,
        {
          className: "btn edit",
          type: "button",
          onClick: y,
          loading: u,
          loadingText: "Creating...",
          children: "Create New Key"
        }
      )
    ] }),
    /* @__PURE__ */ e.jsx(
      Ol,
      {
        isOpen: a,
        onClose: () => o(!1),
        onDeleted: () => {
          o(!1), t(!1);
        }
      }
    ),
    /* @__PURE__ */ e.jsx(
      Yn,
      {
        isOpen: i,
        onClose: () => c(!1)
      }
    )
  ] });
}
function Ul() {
  const { renderLoader: r } = De(), [t, s] = b(!1), [n, a] = b(!1), [o, i] = b(!1), [c, l] = b(null), [d, u] = b(!0), [m, p] = b(""), [y, g] = b(""), [w, h] = b(""), [M, x] = b(""), [T, R] = b(!1);
  ve(() => {
    D(), U();
  }, []);
  const D = async () => {
    try {
      u(!0);
      const te = await at.fetchTwoFAData();
      l(te);
    } catch (te) {
      console.error("Error fetching twoFA data:", te);
    } finally {
      u(!1);
    }
  }, U = async () => {
    try {
      const te = ue(), K = O("bayunSessionId");
      if (!te || !K)
        return;
      const [
        X,
        I,
        f,
        j,
        C
      ] = await Promise.all([
        te.getFromStorage(K, v.ORG_MEMBER_ID),
        te.getFromStorage(K, v.ORG_NAME),
        te.getFromStorage(K, v.MEMBER_STATUS),
        te.getFromStorage(K, v.EMAIL_ADDRESS),
        te.getFromStorage(K, v.IS_DEVELOPER)
      ]);
      p(X || ""), g(I || ""), h(f || ""), x(j || ""), R(C === "true");
    } catch (te) {
      console.error("Error fetching logged-in user details:", te);
    }
  }, q = () => {
    s(!0);
  }, N = () => {
    a(!0);
  }, P = () => {
    a(!0);
  }, Y = async () => {
    i(!0);
  }, re = () => {
    a(!1), D();
  }, J = (c == null ? void 0 : c.isPassphraseActive) === "true", le = T ? "N/A" : m || "-", Q = T ? "N/A" : y || "-", de = T ? "Developer" : w || "-";
  return /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
    /* @__PURE__ */ e.jsx(
      st,
      {
        heading: "Security Settings",
        subtitle: "Manage security questions and passphrase settings"
      }
    ),
    /* @__PURE__ */ e.jsxs("div", { className: "settings-container security-settings-container", children: [
      /* @__PURE__ */ e.jsx("div", { className: "security-settings-account-info", children: /* @__PURE__ */ e.jsxs("div", { className: "security-settings-account-row", children: [
        /* @__PURE__ */ e.jsx("div", { className: "security-settings-member-icon", "aria-hidden": "true", children: (m || M || y || "M").trim().charAt(0).toUpperCase() }),
        /* @__PURE__ */ e.jsxs("div", { className: "security-settings-member-primary", children: [
          /* @__PURE__ */ e.jsxs("div", { className: "security-settings-member-line", children: [
            /* @__PURE__ */ e.jsx("span", { className: "security-settings-account-label", children: "Member ID" }),
            /* @__PURE__ */ e.jsx("span", { className: "security-settings-account-value", children: le })
          ] }),
          /* @__PURE__ */ e.jsxs("div", { className: "security-settings-member-line", children: [
            /* @__PURE__ */ e.jsx("span", { className: "security-settings-account-label", children: "Org Name" }),
            /* @__PURE__ */ e.jsx("span", { className: "security-settings-account-value", children: Q })
          ] })
        ] }),
        /* @__PURE__ */ e.jsxs("div", { className: "security-settings-member-secondary", children: [
          M ? /* @__PURE__ */ e.jsxs("div", { className: "security-settings-member-line security-settings-member-line-right", children: [
            /* @__PURE__ */ e.jsx("span", { className: "security-settings-account-label", children: "User Email" }),
            /* @__PURE__ */ e.jsx("span", { className: "security-settings-account-value", children: M })
          ] }) : null,
          /* @__PURE__ */ e.jsxs("div", { className: "security-settings-member-line security-settings-member-line-right", children: [
            /* @__PURE__ */ e.jsx("span", { className: "security-settings-account-label", children: "Member Status" }),
            /* @__PURE__ */ e.jsx("span", { className: "security-settings-account-status", children: de })
          ] })
        ] })
      ] }) }),
      /* @__PURE__ */ e.jsxs("div", { className: "security-settings-actions", children: [
        /* @__PURE__ */ e.jsxs("div", { className: "security-setting-card", children: [
          /* @__PURE__ */ e.jsxs("div", { className: "security-setting-copy", children: [
            /* @__PURE__ */ e.jsx("h4", { children: "Security Questions" }),
            /* @__PURE__ */ e.jsx("p", { children: "Review and update your challenge questions and answers." })
          ] }),
          /* @__PURE__ */ e.jsx("button", { className: "btn edit", onClick: q, children: "Edit" })
        ] }),
        d ? /* @__PURE__ */ e.jsx("div", { className: "security-settings-loading", children: r(d, "Loading Security Settings...") }) : J ? /* @__PURE__ */ e.jsxs(e.Fragment, { children: [
          /* @__PURE__ */ e.jsxs("div", { className: "security-setting-card", children: [
            /* @__PURE__ */ e.jsxs("div", { className: "security-setting-copy", children: [
              /* @__PURE__ */ e.jsx("h4", { children: "Passphrase" }),
              /* @__PURE__ */ e.jsx("p", { children: "Change your current passphrase after validating it." })
            ] }),
            /* @__PURE__ */ e.jsx("button", { className: "btn edit", onClick: N, children: "Edit" })
          ] }),
          /* @__PURE__ */ e.jsxs("div", { className: "security-setting-card security-setting-card-danger", children: [
            /* @__PURE__ */ e.jsxs("div", { className: "security-setting-copy", children: [
              /* @__PURE__ */ e.jsx("h4", { children: "Delete Passphrase" }),
              /* @__PURE__ */ e.jsx("p", { children: "Remove your active passphrase after security question verification." })
            ] }),
            /* @__PURE__ */ e.jsx("button", { className: "btn delete", onClick: Y, children: "Delete" })
          ] })
        ] }) : /* @__PURE__ */ e.jsxs("div", { className: "security-setting-card", children: [
          /* @__PURE__ */ e.jsxs("div", { className: "security-setting-copy", children: [
            /* @__PURE__ */ e.jsx("h4", { children: "Set Passphrase" }),
            /* @__PURE__ */ e.jsx("p", { children: "Add a passphrase to strengthen account recovery and key protection." })
          ] }),
          /* @__PURE__ */ e.jsx("button", { className: "btn edit", onClick: P, children: "Set Passphrase" })
        ] }),
        /* @__PURE__ */ e.jsx(Dl, {})
      ] })
    ] }),
    /* @__PURE__ */ e.jsx(
      _l,
      {
        isOpen: t,
        onClose: () => s(!1)
      }
    ),
    /* @__PURE__ */ e.jsx(
      Kl,
      {
        isOpen: n,
        onClose: re
      }
    ),
    /* @__PURE__ */ e.jsx(
      Cl,
      {
        isOpen: o,
        onClose: () => i(!1),
        onDeleted: () => {
          i(!1), D();
        }
      }
    )
  ] });
}
const Fl = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: Ul
}, Symbol.toStringTag, { value: "Module" }));
export {
  Xi as BayunFullApp,
  qr as adminMenuConfig,
  id as getAvailableBayunPageMap,
  ac as getAvailableBayunPages
};
