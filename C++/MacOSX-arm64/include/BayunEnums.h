//
//  BayunEnums.h
//  BayunCppXproj
//
//  Created by Preeti Gaur on 04/05/20.
//  Copyright © 2022 Preeti Gaur. All rights reserved.
//

#ifndef BayunEnums_h
#define BayunEnums_h

namespace Bayun {

/**
 * BayunAuthResponseCode Enum
 */
enum class BayunAuthResponseCode: uint32_t {
  Success = 1, /**Authentication is successful*/
  VerifySecurityQuestions, /**Two Factor Authentication is enabled, need to verify security questions to complete the authentication process. */
  VerifyPassphrase, /**Two Factor Authentication is enabled, need to verify passphrase to complete the authentication process. */
  EmployeeAuthorizationPending, /**Employee authorization is pending*/
  EnableTwoFA /**Set either security questions or passphrase*/
};

/**
 * BayunOperation Enum
 */
enum class BayunOperation: uint32_t {
  Lock = 0,
  Unlock
};

/**
 * BayunEncryptionMode Enum
 */
enum class BayunEncryptionMode : uint32_t {
  CBC = 0,
  ECB,
  //CBCHMAC
  AES_GCM_256
};

/**
 * BayunEncryptionPolicy Enum
 */
enum class BayunEncryptionPolicy : uint32_t {
  None = 0, /**No encryption is performed. The lock function acts as a simple passthrough for data. But all accounting on data-access patterns is still performed for reporting in the admin-panel, so that complete visibility into all lock/unlock operations is still maintained.*/
  Default, /**Locking/unlocking is performed according to the policy dictated by the server based on admin-panel settings.*/
  Company, /**Locking/unlocking is performed using company key i.e the enterprise encryption key. Every employee of the same company will have access to this enterprise encryption key in their lockbox, and so will technically be able to access this data.*/
  Employee, /**Locking/unlocking is performed using individual employee key. Nobody other than the user herself has access to this encryption-key, and so nobody else will be able to access this data.*/
  Group /**Locking/unlocking is performed using group key. A groupId has to be specified while using this policy. Only members of the specified group will be able to access this data.*/
};

/**
 * BayunKeyGenerationPolicy Enum
 */
enum class BayunKeyGenerationPolicy : uint32_t {
  Default = 0, /**Every data object is encrypted according to the policy dictated by the server based on admin-panel settings.*/
  Static, /**Every data object is encrypted with same key, that is derived from the Base Key. The Base Key is determined by the Policy tied to the object being locked (e.g. CompanyKey, EmployeeKey, GroupKey).*/
  Envelope, /**Every data object is encrypted with its own unique key that is randomly generated. The random key itself is kept encrypted with a key derived from the Base Key.*/
  Chain /**Every data object is encrypted with its own unique key, that is derived from the Base Key using a multi-dimensional chaining mechanism.*/
};

/**
 * EncryptionType Enum
 */
enum class EncryptionType {
  RSA_AES,
  ECC
};

/**
 * EncryptionType Enum
 */
enum class ECCCurveType {
  Curve_256,
  Curve_384,
  Curve_25519,
  Curve_Unknown
};

/**
 * EmployeeStatus Enum
 */
enum class EmployeeStatus {
  SecurityAdmin,
  Admin, /**User is active and also has administrative privileges.*/
  Approved, /**User is active and approved by an admin.*/
  Registered, /**User is registered but not yet approved by an admin to become active.*/
  Cancelled /**User has been de-activated by an admin.*/
};

/**
 * GroupType Enum
 */
enum class GroupType : uint32_t {
  Public = 0, /**The group is public to the organization. Any employee of the organization can join this group, and hence get access to the shared group-key. The group's secret-key is kept encrypted in every member's own lockbox as well as kept encrypted with company's own secret-key, so that nobody outside the company can get access to it. An existing member, who already has access to the group-key, can add any other members to the group (even those outside the company).*/
  Private /**The group is private and accessible only to the existing members of the group. The group's secret-key is kept encrypted in every member's own lockbox only. An existing member can add anyone else to the member-list of the group, irrespective of whether they belong to the same company or not.*/
};

/**
 * TracingStatus Enum
 */
enum class TracingStatus : uint32_t {
  Default, /**Distributed tracing is dictated by the Bayun LMS.*/
  Enabled, /**Distributed tracing is enabled.*/
  Disabled /**Distributed tracing is disabled.*/
};
}
#endif /* BayunEnums_h */
