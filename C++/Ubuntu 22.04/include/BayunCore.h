//
//  BayunCore.h
//
//  Created by Preeti Gaur on 11/02/19.
//  Copyright © 2022 Bayun Systems, Inc. All rights reserved.
//

#ifndef BayunCore_h
#define BayunCore_h

#include <cstdint>
#include <memory>
#include <string>
#include <vector>
#include "BayunException.h"
#include "BayunEnums.h"
#include "BayunResponses.h"
#include "BinaryData.h"

namespace Bayun {

class BayunCore;
using ShBayunCore = std::shared_ptr<BayunCore>;

class BayunCoreCallback;
using ShBayunCoreCallback = std::shared_ptr<BayunCoreCallback>;

/**
 * LockingKeys Structure.
 */
struct LockingKeys {
  std::string key; /**Locking Key*/
  std::string signatureKey; /**Private Key to be used for signature generation*/
  std::string signatureVerificationKey; /**Public Key to be used for signature verification*/
};

/*! \class BayunCoreConfiguration
 * \brief BayunCoreConfiguration class to configure BayunCore with configurable settings.
 */
class __attribute__((visibility("default"))) BayunCoreConfiguration {
  
  friend class BayunCore;
  
private :
  TracingStatus tracingStatus; /**Distributed tracing status*/
  
public :
  /**
   * BayunCoreConfiguration Constructor
   * @param tracingStatus TracingStatus to enable, disable distributed tracing or use default tracing status as dictated by the server.
   */
  BayunCoreConfiguration(TracingStatus tracingStatus);
};


/*! \class BayunCore
 * \brief BayunCore class provides functions to perform locking and unlocking of binary data, file, text.
 *        It also provides functions to authenticate, deauthenticate with Bayun Lockbox Management Server, change password.
 */
class __attribute__((visibility("default"))) BayunCore {
  
private :
  const std::string baseURL;
  const std::string appId;
  const std::string appSecret;
  const std::string appSalt;
  const std::string bayunServerPublicKey;
public:
  /**
   * Configures BayunCore with configurable settings.
   * @param configuration BayunCoreConfiguration class object.
   */
  static void configure(BayunCoreConfiguration* configuration);
  
  /**
   * Initialises BayunCore with baseURL, applicationId, applicationSecret, applicationSalt.
   * @param baseURL Provided when an app is registered with Bayun
   * @param appId Provided when an app is registered with Bayun.
   * @param appSecret Provided when an app is registered with Bayun.
   * @param appSalt Provided when an app is registered with Bayun.
   * @param bayunTemp Path to be used for local storage.
   * If an empty path is provided as bayunTemp,  /tmp will be used as the default local storage location.
   * @return BayunCore shared pointer.
   */
  static ShBayunCore getInstance(const std::string& baseURL,
                                 const std::string& appId,
                                 const std::string& appSecret,
                                 const std::string& appSalt,
                                 const std::string& bayunTemp,
                                 const std::string& bayunServerPublicKey);
  
  /**
   * Registers with Password.
   * @param sessionId Unique sessionId. You can provide a unique sessionId to the register function call.
   * If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful
   * authentication response. Same sessionId should be provided in all the subsequent calls to the Bayun APIs as an argument.
   * @param companyName Unique name of the company the registering employee belongs to or logs-in with,
   * e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
   * @param companyEmployeeId EmployeeId unique within the company. E.g. "username" username portion from loginId.
   * @param password Password of the employee
   * @return A pointer to AuthenticateResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/3-authentication/3.1-register-with-password
   */
  static ShAuthenticateResponse
  registerEmployeeWithPassword(const std::string& sessionId,
                               const std::string& companyName,
                               const std::string& companyEmployeeId,
                               const std::string& password);
  
  /**
   * Registers without Password.
   * @param sessionId Unique sessionId. You can provide a unique sessionId to the register function call.
   * If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful
   * authentication response. Same sessionId should be provided in all the subsequent calls to the Bayun APIs as an argument.
   * @param companyName Unique name of the company the registering employee belongs to or logs-in with,
   * e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
   * @param companyEmployeeId EmployeeId unique within the company. E.g. "username" username portion from loginId.
   * @param email Email of the user
   * @param isCompanyOwnedEmail Whether the Email is company owned or not
   * @param questionsAnswers Security Questions and Answers
   * @param passphrase Passphrase of the user. Passphrase as input is optional
   * @return A pointer to AuthenticateResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/3-authentication/3.2-register-without-password
   */
  static ShAuthenticateResponse
  registerEmployeeWithoutPassword(const std::string& sessionId,
                              const std::string& companyName,
                              const std::string& companyEmployeeId,
                              const std::string& email,
                              bool  isCompanyOwnedEmail,
                              const std::vector<ShSecurityQuestionAnswer>& questionsAnswers,
                              const std::string& passphrase);
  
  /**
   * Logs in with Password.
   * @param sessionId Unique sessionId. You can provide a unique sessionId to the login function call.
   * If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful
   * authentication response. Same sessionId should be provided in all the subsequent calls to the Bayun APIs as an argument.
   * @param companyName Unique name of the company the authenticating employee belongs to or logs-in with,
   * e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
   * @param companyEmployeeId EmployeeId unique within the company. E.g. "username" username portion from loginId.
   * @param password password
   * @param autoCreateEmployee Determines whether or not an employee should be created on LMS if not exists in the
   * given company.
   * @return A pointer to AuthenticateResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/3-authentication/3.3-login-with-password
   */
  static ShAuthenticateResponse
  loginWithPassword(const std::string& sessionId,
                    const std::string& companyName,
                    const std::string& companyEmployeeId,
                    const std::string& password,
                    bool autoCreateEmployee);
  
  /**
   * Logs in without Password.
   * @param sessionId Unique sessionId. You can provide a unique sessionId to the login function call.
   * If an empty sessionId i.e " " is provided, Bayun creates and returns a unique sessionId in the successful
   * authentication response. Same sessionId should be provided in all the subsequent calls to the Bayun APIs as an argument.
   * @param companyName Unique name of the company the authenticating employee belongs to or logs-in with,
   * e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
   * @param companyEmployeeId EmployeeId unique within the company. E.g. "username" username portion from loginId.
   * @return A pointer to AuthenticateResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/3-authentication/3.4-login-without-password
   */
  static ShAuthenticateResponse
  loginWithoutPassword(const std::string& sessionId,
                       const std::string& companyName,
                       const std::string& companyEmployeeId);
  
  /**
   * Authorizes employee public key. This API is to be used on the server side.
   * @param employeePublicKey EmployeePublicKey to be authorized.
   * @param companyName CompanyName of the employee.
   * @param companyEmployeeId CompanyEmployeeId of the employee.
   * @return BayunAuthResponseCode.
   */
  static BayunAuthResponseCode authorizeEmployee(std::string& employeePublicKey,
                                                 std::string& companyName,
                                                 std::string& companyEmployeeId);
  
  
  /**
   * Returns employee public of the employee to be authorized. This API is to be used on the server side.
   * @param companyName CompanyName of the employee.
   * @param companyEmployeeId CompanyEmployeeId of the employee.
   * @return Unauthorized EmployeePublicKey.
   */
  static std::string unauthorizedEmployeePublicKey(std::string& companyName,
                                                   std::string& companyEmployeeId);

  /**
   * Validates user passphrase.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param passphrase Passphrase to validate.
   * @return A pointer to AuthenticateResponse.
   */
  static ShAuthenticateResponse validatePassphrase(const std::string& sessionId,
                                                   const std::string& passphrase);
  
  
  /**
   * Validates user security questions' answers
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param answers Security questions' answers.
   * @return A pointer to AuthenticateResponse.
   * @see SecurityQuestionAnswer
   */
  static ShAuthenticateResponse validateSecurityQuestions(
    const std::string& sessionId,
    const std::vector<ShSecurityQuestionAnswer>& answers);
  
  
  /**
   * Returns locking key along with keys for signature generation and signature verification for an encryption policy.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param encryptionPolicy BayunEncryptionPolicy determines the base key  to be used to generate the locking key.
   * @param keyGenerationPolicy BayunKeyGenerationPolicy determines the policy to generate the locking key.
   * @param groupId  GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
   * If encryption-policy is other than BayunEncryptionPolicyGroup then groupId should be an empty string.
   * @return Returns LockingKeys structure. The LockingKeys structure contains key, signatureKey,  signatureVerificationKey.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/4.4-get-locking-key
   */
  static LockingKeys getLockingKey(const std::string& sessionId,
                                   BayunEncryptionPolicy encryptionPolicy,
                                   BayunKeyGenerationPolicy keyGenerationPolicy,
                                   const std::string& groupId);
  
  /**
   * Locks text with default encryption-policy, key-generation-policy dictated by server settings.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param plainText  Text to be locked.
   * @return Locked text.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-text#4.2.1-lock-text
   */
  static std::string lockText(const std::string& sessionId,
                              const std::string& plainText);
  
  /**
   * Locks text based on encryption-policy, , key-generation-policy.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param plainText  Text to be locked.
   * @param encryptionPolicy  BayunEncryptionPolicy determines the base key to be used in locking operation.
   * @param keyGenerationPolicy BayunKeyGenerationPolicy determines the policy to generate the locking key.
   * @param groupId  GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
   * If encryption-policy is other than BayunEncryptionPolicyGroup then groupId should be empty string.
   * @return Locked text.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-text#4.2.2-lock-text-with-encryption-policy-key-generation-policy
   */
  static std::string lockText(const std::string& sessionId,
                              const std::string& plainText,
                              BayunEncryptionPolicy encryptionPolicy,
                              BayunKeyGenerationPolicy keyGenerationPolicy,
                              const std::string& groupId);
  
  /**
   * Unlocks the locked text.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param lockedText Locked text to be unlocked.
   * @return Returns unlocked text.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-text#4.2.3-unlock-text
   */
  static std::string unlockText(const std::string& sessionId,
                                const std::string& lockedText);
  
  /**
   * Locks binary data with default encryption-policy, key-generation-policy dictated by server settings.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param data Data to be locked.
   * @param len Length of the data to be locked.
   * @return A pointer to BinaryData.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-binarydata#4.3.1-lock-data
   */
  static ShLockedData lockData(const std::string& sessionId,
                               const unsigned char* data,
                               std::size_t len);
  
  /**
   * Locks binary data based on encryption-policy, keyGenerationPolicy.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param data  Binary data to be locked.
   * @param len Length of the data to be locked.
   * @param encryptionPolicy  BayunEncryptionPolicy determines the base key to be used in locking operation.
   * @param keyGenerationPolicy BayunKeyGenerationPolicy determines the policy to generate the locking key.
   * @param groupId  GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
   * If encryption-policy is other than BayunEncryptionPolicyGroup then groupId should be empty string.
   * @return A pointer to BinaryData.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-binarydata#4.3.2-lock-data-with-encryption-policy-key-generation-policy
   */
  static ShLockedData lockData(const std::string& sessionId,
                               const unsigned char* data,
                               std::size_t len,
                               BayunEncryptionPolicy encryptionPolicy,
                               BayunKeyGenerationPolicy keyGenerationPolicy,
                               const std::string& groupId);
  
  /**
   * Unlocks binary data.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param lockedData  Data to be unlocked.
   * @param lockedDataLength  Length of data to be unlocked.
   * @return A pointer to BinaryData.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-binarydata#4.3.3-unlock-data
   */
  static ShUnlockedData unlockData(const std::string& sessionId,
                                   const unsigned char* lockedData,
                                   std::size_t lockedDataLength);
  
  /**
   * Locks a file with default encryption-policy, key-generation-policy dictated by server settings.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param filePath  Path of the file to be locked.
   * @return Locked file path.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-file#4.1.1-lock-file
   */
  static std::string lockFile(const std::string& sessionId,
                              const std::string& filePath);
  
  /**
   * Locks a file based on encryption-policy, keyGenerationPolicy.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param filePath  Path of the file to be locked.
   * @param encryptionPolicy  BayunEncryptionPolicy determines the base key to be used in locking operation.
   * @param keyGenerationPolicy BayunKeyGenerationPolicy determines the policy to generate the locking key.
   * @param groupId  GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
   * If encryption-policy is other than BayunEncryptionPolicyGroup then groupId * should be empty string.
   * @return locked file path.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-file#4.1.2-lock-file-with-encryption-policy-key-generation-policy
   */
  static std::string lockFile(const std::string& sessionId,
                              const std::string& filePath,
                              BayunEncryptionPolicy encryptionPolicy,
                              BayunKeyGenerationPolicy keyGenerationPolicy,
                              const std::string& groupId);
  
  /**
   * Unlocks a locked file.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param filePath  Path of the file to be unlocked.
   * @return Unlocked file path.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/bayuncoresdk-operations/lock-unlock-file#4.1.3-unlock-file
   */
  static std::string unlockFile(const std::string& sessionId,
                                const std::string& filePath);
  
  /**
   * Changes password.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param currentPassword  Current password.
   * @param newPassword  New password.
   * @return A pointer to ChangePasswordResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/3-authentication/3.7-change-password
   */
  static ShChangePasswordResponse changePassword(const std::string& sessionId,
                                                 const std::string& currentPassword,
                                                 const std::string& newPassword);
  
  /**
   * Creates a new group.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupName Group name(Optional).
   * @param groupType Type of group i.e Public or Private.
   * @return A pointer to CreateGroupResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/create-group
   */
  static ShCreateGroupResponse createGroup(const std::string& sessionId,
                                           const std::string& groupName,
                                           GroupType groupType);
  
  /**
   * Returns all the groups, both public and private, the user is a member of.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @return A pointer to MyGroupsResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/get-my-groups
   */
  static ShMyGroupsResponse myGroups(const std::string& sessionId);
  
  /**
   * Returns all the public groups of the company the employee is not a member of.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @return A pointer to UnjoinedPublicGroupsResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/get-unjoined-public-groups
   */
  static ShUnjoinedPublicGroupsResponse unjoinedPublicGroups(const std::string& sessionId);

  
  /**
   * Used to join any public group of the company.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the public group.
   * @param creatorCompanyName Company name of the group creator.
   * @param creatorCompanyEmployeeId Company Employee Id of the group creator.
   * @return A pointer to JoinPublicGroupResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/join-public-group
   */
  static ShJoinPublicGroupResponse joinPublicGroup(const std::string& sessionId,
                                                   const std::string& groupId,
                                                   const std::string& creatorCompanyName,
                                                   const std::string& creatorCompanyEmployeeId);
  
  /**
   * Returns details of a group. Details include groupId, name, type, groupMembers.
   * Any existing member of the group can retrieve details of the group, including the list of all the group members.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the Group.
   * @return A pointer to GroupByIdResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/get-group-by-id
   */
  static ShGroupByIdResponse groupById(const std::string& sessionId,
                                       const std::string& groupId);
  
  /**
   * Adds a new member to the group.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the group.
   * @param groupMember Member to be added in the group.
   * @return A pointer to AddGroupMemberResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/add-group-member
   */
  static ShAddGroupMemberResponse addGroupMember(const std::string& sessionId,
                                                 const std::string& groupId,
                                                 GroupMember& groupMember);
  /**
   * Adds new members to the group.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the group.
   * @param groupMembers Members to be added in the group.
   * @return A pointer to AddGroupMembersResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/add-group-members
   */
  static ShAddGroupMembersResponse addGroupMembers(const std::string& sessionId,
                                                   const std::string& groupId,
                                                   const std::vector<GroupMember>& groupMembers);
  /**
   * Removes an existing group member.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the group.
   * @param groupMember Member to be removed from  the group.
   * @return A pointer to RemoveGroupMemberResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/remove-group-member
   */
  static ShRemoveGroupMemberResponse removeGroupMember(const std::string& sessionId,
                                                       const std::string& groupId,
                                                       GroupMember& groupMember);
  
  /**
   * Removes a list of group members from the group.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the group.
   * @param groupMembers List of members to be removed from the group.
   * @return A pointer to RemoveGroupMembersResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/remove-group-members
   */
  static ShRemoveGroupMembersResponse removeGroupMembers(const std::string& sessionId,
                                                         const std::string& groupId,
                                                         std::vector<GroupMember>& groupMembers);
  
  /**
   * Removes all the members of the group except the list of members.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the group.
   * @param groupMembers List of members should not be removed from the group.
   * @param removeCallingMember Flag to determine whether to remove the calling member from the group.
   * @return A pointer to RemoveGroupMembersResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/remove-group-members-except-list
   */
  static ShRemoveGroupMembersExceptListResponse removeGroupMembersExceptList(const std::string& sessionId,
                                                                             const std::string& groupId,
                                                                             std::vector<GroupMember>& groupMembers,
                                                                             bool removeCallingMember);
  
  /**
   * Used to leave a group the user is a member of.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the group.
   * @return A pointer to LeaveGroupResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/leave-group
   */
  static ShLeaveGroupResponse leaveGroup(const std::string& sessionId,
                                         const std::string& groupId);
  
  /**
   * Used to delete a group the user is a member of. Any existing member of the group can delete the group.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @param groupId GroupId of the group.
   * @return A pointer to DeleteGroupResponse.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/groups/delete-group
   */
  static ShDeleteGroupResponse deleteGroup(const std::string& sessionId,
                                           const std::string& groupId);
  /**
   * Logs out user. This function can be used at the time of logging out of app.
   * @param sessionId Unique SessionId which is received in the login/register function response.
   * @see https://bayun.gitbook.io/bayuncoresdk-cpp/3-authentication/3.5-logout
   */
  static void logout(const std::string& sessionId);
    
  static std::string replace_all(std::string s, std::string from, std::string to);
  
  
   /**
   * BayunCore Constructor
   * Use the getInstance method to create an instance.
   * @param baseURL Provided when an app is registered with Bayun.
   * @param appId Provided when an app is registered with Bayun.
   * @param appSecret Provided when an app is registered with Bayun.
   * @param bayunTemp Path to be used for local storage.
   * If an empty path is provided as bayunTemp,  /tmp will be used as the default local storage location.
   */
  BayunCore(const std::string& baseURL,
            const std::string& appId,
            const std::string& appSecret,
            const std::string& appSalt,
            const std::string& bayunTemp,
            const std::string& bayunServerPublicKey);
  
  /**
   BayunCore Destructor
   */
  ~BayunCore();
};

}  // namespace Bayun

#endif /* BayunCore_h */

