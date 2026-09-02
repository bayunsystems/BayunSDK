# Bayun Admin Integration Demo

A minimal demo application that integrates **BayunCore SDK** and the **Bayun Admin Component**, built exclusively from the official programming guide:

[BayunCoreSDK JavaScript Programming Guide](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide)

## What this demo shows

1. **Initialize BayunCore** — [Integrate Bayun SDK](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/4.-integrate-bayun-sdk)
2. **Login** with `loginAgenticMember` and `autoCreateMember: true` — [Quick Start](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/master-1) and [Login Agentic Member](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/5.3-login-agentic-member)
3. **Lock / unlock text** with `MEMBER` encryption policy — [Lock/Unlock Text](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/bayuncoresdk-operations/lock-unlock-text)
4. **Mount the Admin Component** via `BayunFullApp` after login — [Integrate Bayun Admin Component](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/8.-integrate-bayun-admin-component)
5. **Logout** — [Logout](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/3-authentication/5.5-logout)

## Prerequisites

Follow [Getting Started](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/getting-started):

1. Register as a developer on the [Bayun Developer Program](https://www.digilockbox.com/admin/showRegisterEmail)
2. Create an application in the [Bayun Console](https://www.digilockbox.com/admin/developer/showCreateApplication)
3. Create an application secret with **all available roles enabled** for testing:
   - **Consumer apps:** Access, Authorization, MemberCreation
   - **Enterprise apps:** Access, Authorization, MemberCreation, OrgCreation

## Setup

### 1. Copy Bayun SDK

Per [section 4 — Integrate Bayun SDK](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/4.-integrate-bayun-sdk):

```text
Copy bayun.js → lib/bayun.js
```

### 2. Copy Admin Component assets

Per [section 8 — Integrate Bayun Admin Component](https://bayun.gitbook.io/bayuncoresdk-javascript-programming-guide/8.-integrate-bayun-admin-component):

```text
Copy into admincomponent/:
  - bayun-admin.es.js
  - bayun-admin-component.css
  - (optional) bayun-admin.umd.js
```

### 3. Configure credentials

```bash
cp config.example.js config.js
```

Edit `config.js` with values from your Bayun Developer Console:

| Field | Source |
| --- | --- |
| `bayunAppId` | Application Id |
| `bayunAppSecret` | Application Secret |
| `baseURL` | Base URL |
| `bayunServerPublicKey` | Bayun Server Public Key |

### 4. Run with a local web server

ES modules and the Admin Component require HTTP (not `file://`):

```bash
npx --yes serve .
```

Open the URL shown (typically `http://localhost:3000`).

## Usage

1. Enter **org name**, **org member id**, and **passcode**
2. Click **Login with Bayun**
3. After login, use **Lock text** / **Unlock text** to verify encryption
4. Scroll to the **Bayun Admin Component** section — the built-in sidebar opens on **Members**
5. Click **Logout** when finished

## File layout

```text
NewFolder/
├── index.html
├── app.js
├── config.example.js
├── admin-theme-overrides.css
├── styles.css
├── lib/
│   └── bayun.js                 ← copy from Bayun SDK package
└── admincomponent/
    ├── bayun-admin.es.js        ← copy from Admin Component build
    └── bayun-admin-component.css
```
