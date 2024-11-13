//
//  Copyright © 2024 Bayun Systems, Inc. All rights reserved.
//

#include "BayunCore.h"
#include <iostream>
#include <string>
#include <stdio.h>
#include <unistd.h>

std::string sessionId;

//appId is provided when your app is registered with Bayun.
const std::string appSalt = "<appSalt>";
//appId is provided when your app is registered with Bayun.
const std::string appId = "<appId>";
//app secret is provided when your app is registered with Bayun.
const std::string appSecret = "<appSecret>";
//baseURL is provided when your app is registered with Bayun.
const std::string baseURL = "<baseURL>";
//bayunServerPublicKey is provided when your app is registered with Bayun.
const std::string bayunServerPublicKey = "<bayunServerPublicKey>";


class Test {
  static Bayun::ShBayunCore bayunCore;
  
public:
  
  Test(Bayun::ShBayunCore bayunCore_) {
    bayunCore = bayunCore_;
  }
  
  Bayun::ShBayunCore
  getBayunCore() {
    return bayunCore;
  }
  
  void
  handleException(const Bayun::BayunException e) {
    LOG(LOG_DEBUG, stderr, "Got Exception %s\n", e.getErrMsg());
  }
};

using ShTestArgs = std::shared_ptr<Test>;
Bayun::ShBayunCore Test::bayunCore = nullptr;

int validatePassphrase(ShTestArgs test, std::string sessionId, std::string passphrase);
int validateSecurityQuestions(ShTestArgs test, const std::string& sessionId,
                              const std::vector<Bayun::ShSecurityQuestionAnswer>& answers);
int authorizeEmployee(ShTestArgs test);

std::string testAuthentication(ShTestArgs test,
                               std::string email,
                               std::string companyName,
                               std::string companyEmployeeId,
                               std::string password,
                               std::string passphrase,
                               std::vector<Bayun::ShSecurityQuestionAnswer> answers);

/**
 Registers with password  with Bayun Lockbox Management Server.
 @param test Test class pointer.
 @param companyName Unique  name of the company the authenticating employee belongs to or logs-in with,
 e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
 @param companyEmployeeId EmployeeId Unique  within the company. E.g. "username" username portion from loginId.
 @param password Password of the user.
 @return Status.
 */
int
testRegisterEmployeeWithPassword(ShTestArgs test,
                                 std::string companyName,
                                 std::string companyEmployeeId,
                                 std::string password) {
  std::vector<Bayun::ShSecurityQuestionAnswer> answers;
  
  try {
    
    std::vector<Bayun::ShSecurityQuestionAnswer> answers;
    
    Bayun::ShAuthenticateResponse authenticateResponse = test->getBayunCore()->registerEmployeeWithPassword("", companyName, companyEmployeeId, password);
    sessionId = authenticateResponse->sessionId;
    
    if (!sessionId.empty()) {
      if (authenticateResponse->responseCode == Bayun::BayunAuthResponseCode::Success) {
        
        return 1;
      } else if (authenticateResponse->responseCode == Bayun::BayunAuthResponseCode::EmployeeAuthorizationPending) {
        LOG(LOG_ERR, stderr, "EmployeeAuthorizationPending\n");
        LOG(LOG_ERR, stderr, "EmployeePublicKey : %s\n",authenticateResponse->employeePublicKey.c_str());
        return 1;
      }
    }
  } catch (Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}



/**
 Registers without password with Bayun Lockbox Management Server.
 @param test Test class pointer.
 @param email Email of the user.
 @param companyName Unique  name of the company the authenticating employee belongs to or logs-in with,
 e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
 @param companyEmployeeId EmployeeId Unique  within the company. E.g. "username" username portion from loginId.
 @param passphrase Passphrase to be validated.
 @param answers Security questions' answers to be validated.
 @return Status.
 */
int
testRegisterEmployeeWithoutPassword(ShTestArgs test,
                                    std::string email,
                                    std::string companyName,
                                    std::string companyEmployeeId,
                                    std::string passphrase,
                                    std::vector<Bayun::ShSecurityQuestionAnswer> questionsanswers) {
  try {
    
    Bayun::ShAuthenticateResponse authenticateResponse = test->getBayunCore()->registerEmployeeWithoutPassword("", companyName, companyEmployeeId, email, true, questionsanswers, passphrase);
    sessionId = authenticateResponse->sessionId;
    
    if (!sessionId.empty()) {
      if (authenticateResponse->responseCode == Bayun::BayunAuthResponseCode::Success) {
        return 1;
      }
      else if (authenticateResponse->responseCode == Bayun::BayunAuthResponseCode::VerifyPassphrase) {
        // Two Factor Authentication is enabled, security questions and passphrase both are active for the user
        
        if (!passphrase.empty()) {
          int status = validatePassphrase(test, sessionId, passphrase);
          if (status == 0) {
            LOG(LOG_ERR, stderr, "Passphrase Verification Failed\n");
          }
        } else {
          LOG(LOG_ERR, stderr, "Two FA Failed\n");
        }
      } else if (authenticateResponse->responseCode == Bayun::BayunAuthResponseCode::VerifySecurityQuestions)  {
        
        std::vector<Bayun::ShSecurityQuestionAnswer> answers;
        answers.push_back(std::make_shared<Bayun::SecurityQuestionAnswer>("<questionId1>", "", "<answer1>"));
        answers.push_back(std::make_shared<Bayun::SecurityQuestionAnswer>("<questionId2>", "", "<answer2>"));
        answers.push_back(std::make_shared<Bayun::SecurityQuestionAnswer>("<questionId3>", "", "<answer3>"));
        answers.push_back(std::make_shared<Bayun::SecurityQuestionAnswer>("<questionId4>", "", "<answer4>"));
        answers.push_back(std::make_shared<Bayun::SecurityQuestionAnswer>("<questionId5>", "", "<answer5>"));
        
        
        // Two Factor Authentication is enabled, only security questions are enabled for the user
        if(!answers.empty()) {
          int  status = validateSecurityQuestions(test, sessionId, answers);
          if (status == 0) {
            LOG(LOG_ERR, stderr, "Security Questions Verification Failed\n");
          }
        } else {
          LOG(LOG_ERR, stderr, "Two FA Failed\n");
        }
      } else if (authenticateResponse->responseCode == Bayun::BayunAuthResponseCode::EmployeeAuthorizationPending) {
        LOG(LOG_ERR, stderr, "EmployeeAuthorizationPending\n");
        LOG(LOG_ERR, stderr, "EmployeePublicKey : %s\n",authenticateResponse->employeePublicKey.c_str());
        return 1;
      }
    }
  } catch (Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Logs in with password with Bayun's Lockbox Management Server.
 @param test Test class pointer.
 @param email Email of the user.
 @param companyName Unique  name of the company the authenticating employee belongs to or logs-in with,
 e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
 @param companyEmployeeId EmployeeId Unique  within the company. E.g. "username" username portion from loginId.
 @param password Password of the user.
 @param passphrase Passphrase to be validated.
 @param answers Security questions' answers to be validated.
 @return Status.
 */
int
testLoginWithPassword(ShTestArgs test,
                      std::string companyName,
                      std::string companyEmployeeId,
                      std::string password,
                      std::string passphrase,
                      std::vector<Bayun::ShSecurityQuestionAnswer> answers) {
  try {
    std::string sessionId = testAuthentication(test,
                                               "",
                                               companyName,
                                               companyEmployeeId,
                                               password,
                                               passphrase,
                                               answers);
    if (!sessionId.empty()) {
      return 1;
    }
  } catch (Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Logs in without password  with Bayun's Lockbox Management Server.
 @param test Test class pointer.
 @param companyName Unique  name of the company the authenticating employee belongs to or logs-in with,
 e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
 @param companyEmployeeId EmployeeId Unique  within the company. E.g. "username" username portion from loginId.
 @param email Email of the user.
 @param passphrase Passphrase to be validated.
 @param answers Security questions' answers to be validated.
 @return Status.
 */
int
testLoginWithoutPassword(ShTestArgs test,
                         std::string companyName,
                         std::string companyEmployeeId,
                         std::string email,
                         std::string passphrase,
                         std::vector<Bayun::ShSecurityQuestionAnswer> answers) {
  
  try {
    std::string sessionId = testAuthentication(test,
                                               email,
                                               companyName,
                                               companyEmployeeId,
                                               "",
                                               passphrase,
                                               answers);
    if (!sessionId.empty()) {
      return 1;
    }
  } catch (Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 * Authorizes employee public key. This API is to be used on the server side.
 * @param employeePublicKey EmployeePublicKey to be authorized along with the metadata.
 * @param companyName CompanyName of the employee.
 * @param companyEmployeeId CompanyEmployeeId of the employee.
 * @return Status.
 */
int authorizeEmployee(ShTestArgs test, std::string employeePublicKey, std::string companyName, std::string companyEmployeeId) {
  Bayun::ShBayunCore bayunCore = test->getBayunCore();
  try {
    Bayun::BayunAuthResponseCode authResponseCode = bayunCore->authorizeEmployee(employeePublicKey, companyName, companyEmployeeId);
    LOG(LOG_INFO, stderr, "\nAuthorizeEmployee BayunAuthResponseCode : %d\n", authResponseCode);
    if (authResponseCode == Bayun::BayunAuthResponseCode::Success) {
      return 1;
    }
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 * Used to get employee public of the employee to be authorized. This API is to be used on the server side.
 * @param companyName CompanyName of the employee.
 * @param companyEmployeeId CompanyEmployeeId of the employee.
 * @return Status.
 */
int getUnauthorizeEmployeePublicKey(ShTestArgs test, std::string companyName, std::string companyEmployeeId) {
  Bayun::ShBayunCore bayunCore = test->getBayunCore();
  try {
    std::string employeePublicKey = bayunCore->unauthorizedEmployeePublicKey(companyName, companyEmployeeId);
    
    if (!employeePublicKey.empty()) {
      LOG(LOG_INFO, stderr, "\nUnauthorizeEmployeePublicKey : %s\n", employeePublicKey.c_str());
      //authorizeEmployee(test);
      return 1;
    }
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Validates passphrase.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param passphrase Passphrase to validate.
 @return Status.
 */
int validatePassphrase(ShTestArgs test, std::string sessionId, std::string passphrase) {
  Bayun::ShBayunCore bayunCore = test->getBayunCore();
  
  try {
    Bayun::ShAuthenticateResponse response = bayunCore->validatePassphrase(sessionId, passphrase);
    if (response->responseCode == Bayun::BayunAuthResponseCode::EmployeeAuthorizationPending) {
      LOG(LOG_ERR, stderr, "EmployeeAuthorizationPending\n");
      LOG(LOG_ERR, stderr, "EmployeePublicKey : %s\n",response->employeePublicKey.c_str());
      return 1;
    }
    //response->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  
  return 0;
}

/**
 Validates security questions' answers.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param answers Security questions' answers.
 @return Status.
 */
int validateSecurityQuestions(ShTestArgs test,
                              const std::string& sessionId,
                              const std::vector<Bayun::ShSecurityQuestionAnswer>& answers) {
  
  Bayun::ShBayunCore bayunCore = test->getBayunCore();
  try {
    Bayun::ShAuthenticateResponse response =
    bayunCore->validateSecurityQuestions(sessionId, answers);
    // response->printResponse();
    if (response->responseCode == Bayun::BayunAuthResponseCode::EmployeeAuthorizationPending) {
      LOG(LOG_ERR, stderr, "EmployeeAuthorizationPending\n");
      LOG(LOG_ERR, stderr, "EmployeePublicKey : %s\n",response->employeePublicKey.c_str());
      return 1;
    }
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Creates a new group.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param groupName Group name(Optional).
 @param groupType Type of group i.e Public or Private.
 @return groupId.
 */
std::string testCreateGroup(ShTestArgs test,
                            std::string sessionId,
                            std::string groupName,
                            Bayun::GroupType groupType) {
  
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running test Create Group\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  
  Bayun::ShBayunCore bayunCore = test->getBayunCore();
  try{
    Bayun::ShCreateGroupResponse createGroupResponse = bayunCore->createGroup(sessionId, groupName, groupType);
    
    const std::string& groupId = createGroupResponse->getGroupId();
    createGroupResponse->printResponse();
    return groupId;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return "";
}

/**
 Fetches all user groups.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @return Status.
 */
int testMyGroups(ShTestArgs test, std::string sessionId) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running test My Groups\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  
  try{
    Bayun::ShMyGroupsResponse myGroupsResponse = test->getBayunCore()->myGroups(sessionId);
    std::vector<Bayun::ShGroupInfo> groups = myGroupsResponse->getGroups();
    myGroupsResponse->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Fetches all the public groups of the company the employee is not a member of.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @return Status.
 */
int testUnjoinedGroups(ShTestArgs test, std::string sessionId) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Unjoined Group\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  try{
    Bayun::ShUnjoinedPublicGroupsResponse unjoinedGroupsResp = test->getBayunCore()->unjoinedPublicGroups(sessionId);
    unjoinedGroupsResp->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Joins a public group.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param groupId GroupId of the public group.
 @return Status.
 */
int testJoinPublicGroup(ShTestArgs test, std::string sessionId, std::string groupId, std::string creatorCompanyName, std::string creatorCompanyEmployeeId) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Join Public Group\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  try{
    Bayun::ShJoinPublicGroupResponse joinPublicGroupResp = test->getBayunCore()->joinPublicGroup(sessionId, groupId, creatorCompanyName, creatorCompanyEmployeeId);
    joinPublicGroupResp->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Fetches a group information i.e groupId, name, type, groupMembers.
 Any existing member of the group can retrieve details of the group, including the list of all the group members.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param groupId GroupId of the group.
 @return Status.
 */
int testGroupById(ShTestArgs test, std::string sessionId, std::string groupId) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Group By Id\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  try{
    Bayun::ShGroupByIdResponse groupByIdResp = test->getBayunCore()->groupById(sessionId, groupId);
    std::string groupId  = groupByIdResp->getGroupId() ;
    std::string name = groupByIdResp->getName();
    Bayun::GroupType type = groupByIdResp->getType();
    
    std::vector<Bayun::ShGroupMember> groupMembers = groupByIdResp->getGroupMembers();
    groupByIdResp->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Adds a new member to the group.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param groupId GroupId of the group.
 @param companyEmployeeId CompanyEmployeeId of the member to be added in the group.
 @param companyName  Name of the company of the member to be added in the group.
 @return Status.
 */
int testAddGroupMember(ShTestArgs test,
                       std::string sessionId,
                       std::string groupId,
                       std::string companyEmployeeId,
                       std::string companyName) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Add Group Member\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  try{
    
    LOG(LOG_INFO, stderr, "Adding companyEmployeeId : %s companyName %s\n", companyEmployeeId.c_str(), companyName.c_str());
    Bayun::GroupMember groupMember(companyEmployeeId, companyName);
    Bayun::ShAddGroupMemberResponse addGroupMemberResp = test->getBayunCore()->addGroupMember(sessionId, groupId, groupMember);
    addGroupMemberResp->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Adds new members to the group.
 @param testArgs TestAddMembersArgs class pointer.
 @return Status.
 */
int testAddGroupMembers(ShTestArgs test, std::string sessionId, std::string groupId, std::vector<Bayun::GroupMember> groupMembers) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test to add multiple Group Members\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  try{
    Bayun::ShAddGroupMembersResponse addGroupMembersResp =
    test->getBayunCore()->addGroupMembers(sessionId, groupId, groupMembers);
    addGroupMembersResp->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Removes an existing group member.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param groupId GroupId of the group.
 @param companyEmployeeId CompanyEmployeeId of the member to be removed from the group.
 @param companyName  Name of the company of the member to be removed from the group.
 @return Status.
 */
int testRemoveGroupMember(ShTestArgs test,
                          std::string sessionId,
                          std::string groupId,
                          std::string companyEmployeeId,
                          std::string companyName) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Remove Group Member\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  try{
    LOG(LOG_INFO, stderr, "Removing companyEmployeeId : %s companyName : %s\n", companyEmployeeId.c_str(), companyName.c_str());
    Bayun::GroupMember groupMember(companyEmployeeId, companyName);
    Bayun::ShRemoveGroupMemberResponse removeGroupMemberResp = test->getBayunCore()->removeGroupMember(sessionId, groupId, groupMember);
    removeGroupMemberResp->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Deletes a group the user is a member of. Any existing member of the group can delete the group.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param groupId GroupId of the group.
 @return Status.
 */
int testDeleteGroup(ShTestArgs test, std::string sessionId, std::string groupId) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Delete Group\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  try{
    Bayun::ShDeleteGroupResponse testDeleteGroupResp = test->getBayunCore()->deleteGroup(sessionId, groupId);
    testDeleteGroupResp->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Leave any joined group.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param groupId GroupId of the group.
 @return Status.
 */
int testLeaveGroup(ShTestArgs test, std::string sessionId, std::string groupId) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Leave Group\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  try{
    Bayun::ShLeaveGroupResponse leaveGroupResp = test->getBayunCore()->leaveGroup(sessionId, groupId);
    leaveGroupResp->printResponse();
    return 1;
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return 0;
}

/**
 Locks text with encryption-policy, keyGenerationPolicy.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param plainText  text to be locked.
 @param encryptionPolicy  BayunEncryptionPolicy determines the key to be used to generate the lockingKey.
 @param keyGenerationPolicy BayunKeyGenerationPolicy determines the policy to generate the data encryption key.
 @param groupId  GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 If encryption-policy is other than BayunEncryptionPolicyGroup then groupId should be empty string.
 @return locked text.
 */
std::string testLockText(ShTestArgs test,
                         std::string sessionId,
                         std::string plainText,
                         Bayun::BayunEncryptionPolicy encryptionPolicy,
                         Bayun::BayunKeyGenerationPolicy keyGenerationPolicy,
                         std::string groupId) {
  
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Lock Text\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  
  std::string lockedText =  test->getBayunCore()->lockText(sessionId, plainText, encryptionPolicy, keyGenerationPolicy, groupId);
  
  return lockedText;
}

/**
 Unlocks the locked text.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param lockedText Locked text to be unlocked.
 @return Returns unlocked text.
 */
std::string testUnlockText(ShTestArgs test, std::string sessionId, std::string lockedText) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Unlock Text\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  
  std::string plainText =  test->getBayunCore()->unlockText(sessionId, lockedText);
  return plainText;
}

/**
 Locks file.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param filePath  Path of the file to be locked.
 @param encryptionPolicy  BayunEncryptionPolicy determines the key to be used to generate the lockingKey.
 @param keyGenerationPolicy BayunKeyGenerationPolicy determines the policy to generate the data encryption key.
 @param groupId  GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.  If encryption-policy is other than BayunEncryptionPolicyGroup then groupId should be empty string.
 @return locked file path.
 */
std::string testLockFile(ShTestArgs test,
                         std::string sessionId,
                         std::string filePath,
                         Bayun::BayunEncryptionPolicy encryptionPolicy,
                         Bayun::BayunKeyGenerationPolicy keyGenerationPolicy,
                         std::string groupId) {
  
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Lock File\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  
  std::string lockedFilePath =  test->getBayunCore()->lockFile(sessionId, filePath, encryptionPolicy, keyGenerationPolicy, groupId);
  return lockedFilePath;
}

/**
 Unlocks a locked file.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param lockedFilePath  Path of the file to be unlocked.
 @return unlocked file path.
 */
std::string testUnlockFile(ShTestArgs test, std::string sessionId, std::string lockedFilePath) {
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  LOG(LOG_INFO, stderr, "Running Test Unlock File\n");
  LOG(LOG_INFO, stderr, "---------------------------------------------------------\n");
  
  std::string unlockedFilePath =  test->getBayunCore()->unlockFile(sessionId, lockedFilePath);
  return unlockedFilePath;
}

/**
 Locks binary data with encryption-policy, keyGenerationPolicy.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param plainString  plainString is converted to binary data to be locked.
 @param encryptionPolicy  BayunEncryptionPolicy determines the key to be used to generate the lockingKey.
 @param keyGenerationPolicy BayunKeyGenerationPolicy determines the policy to generate the data encryption key.
 @param groupId  GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 If encryption-policy is other than BayunEncryptionPolicyGroup then groupId should be empty string.
 @return locked binary data.
 */
Bayun::ShLockedData testLockBinaryData(ShTestArgs test,
                                       std::string sessionId,
                                       std::string plainString,
                                       Bayun::BayunEncryptionPolicy encryptionPolicy,
                                       Bayun::BayunKeyGenerationPolicy keyGenerationPolicy,
                                       std::string groupId) {
  
  unsigned char* data = (unsigned char*)plainString.c_str();
  Bayun::ShLockedData lockedData = test->getBayunCore()->lockData(sessionId, data, plainString.length(), encryptionPolicy, keyGenerationPolicy, groupId);
  return lockedData;
}

/**
 Unlocks binary data.
 @param test TestArgs class pointer.
 @param sessionId Unique  sessionId which is received in the authenticate function response.
 @param lockedData  Data to be unlocked.
 @param lockedDataLength  Length of data to be unlocked.
 @return unlocked data.
 */
Bayun::ShUnlockedData testUnlockData(ShTestArgs test,
                                     std::string sessionId,
                                     unsigned char* lockedData,
                                     size_t lockedDataLength) {
  Bayun::ShUnlockedData unlockedData =  test->getBayunCore()->unlockData(sessionId, lockedData, lockedDataLength);
  
  std::string plainString( reinterpret_cast<char const*>(unlockedData->data_), unlockedData->dataLen_);
  return unlockedData;
}

/**
 This function is internally used by testLoginWithPassword and testLoginWithoutPassword functions.  Authenticates a user  with Bayun Lockbox Management Server.
 @param test TestArgs class pointer.
 @param companyName Unique  name of the company the authenticating employee belongs to or logs-in with,
 e.g. “bayunsystems.com” if the login-id is “username@bayunsystems.com”.
 @param companyEmployeeId EmployeeId Unique  within the company. E.g. "username" username portion from loginId.
 @param password Password of the user.
 @param passphrase Passphrase to be validated.
 @param answers Security questions' answers to be validated.
 @return SessionId.
 */
std::string testAuthentication(ShTestArgs test,
                               std::string email,
                               std::string companyName,
                               std::string companyEmployeeId,
                               std::string password,
                               std::string passphrase,
                               std::vector<Bayun::ShSecurityQuestionAnswer> answers) {
  int status = 0;
  std::string sessionId;
  Bayun::ShBayunCore bayunCore = test->getBayunCore();
  LOG(LOG_INFO, stderr, "========================================================\n");
  if (!passphrase.empty()) {
    LOG(LOG_INFO, stderr, "Running test Authenticate With Passphrase\n");
  } else if( !answers.empty()) {
    LOG(LOG_INFO, stderr, "Running test Authenticate With SecurityQuestionAnswer\n");
  } else {
    LOG(LOG_INFO, stderr, "Running test Authenticate With Two Factor Authentication Disabled\n");
  }
  LOG(LOG_INFO, stderr, "========================================================\n");
  
  try {
    
    Bayun::ShAuthenticateResponse authResponse;
    
    if (!password.empty()) {
      authResponse = bayunCore->loginWithPassword("", companyName, companyEmployeeId, password, false);
      
    } else if(!email.empty()) {
      authResponse = bayunCore->loginWithoutPassword("", companyName, companyEmployeeId);
    }
    
    
    if (authResponse != nullptr) {
      
      sessionId = authResponse->sessionId.c_str();
      Bayun::BayunAuthResponseCode responseCode = authResponse->responseCode;
      LOG(LOG_INFO, stderr, "\nAuthResponse sessionId : %s\n", sessionId.c_str());
      LOG(LOG_INFO, stderr, "\nAuthResponse BayunAuthResponseCode : %d\n", responseCode);
      
      if (responseCode == Bayun::BayunAuthResponseCode::VerifyPassphrase) {
        // Two Factor Authentication is enabled, security questions and passphrase both are active for the user
        
        if (!passphrase.empty()) {
          status = validatePassphrase(test, sessionId, passphrase);
          if (status == 0) {
            LOG(LOG_ERR, stderr, "Passphrase Verification Failed\n");
          }
        } else {
          LOG(LOG_ERR, stderr, "Passphrase is required for Two FA Verification.\n");
        }
      } else if (responseCode == Bayun::BayunAuthResponseCode::VerifySecurityQuestions)  {
        // Two Factor Authentication is enabled, only security questions are enabled for the user
        if(!answers.empty()) {
          status = validateSecurityQuestions(test, sessionId, answers);
          if (status == 0) {
            LOG(LOG_ERR, stderr, "Security Questions Verification Failed\n");
          }
        } else {
          LOG(LOG_ERR, stderr, "Two Factor Authentication Failed\n");
        }
      } else if (responseCode == Bayun::BayunAuthResponseCode::EmployeeAuthorizationPending) {
        LOG(LOG_ERR, stderr, "EmployeeAuthorizationPending\n");
        LOG(LOG_ERR, stderr, "EmployeePublicKey : %s\n",authResponse->employeePublicKey.c_str());
      } else if (responseCode == Bayun::BayunAuthResponseCode::Success) {
        status = 1;
      }
    }
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  return sessionId;
}


using Testf = int (*)(ShTestArgs);

int runtest(Testf testf, ShTestArgs test) {
  return testf(test);
}

int main(int argc, char *argv[]) {
  try {

    //Initialise BayunCore
    Bayun::ShBayunCore bayunCore =  Bayun::BayunCore::getInstance(baseURL, appId, appSecret, appSalt, "", bayunServerPublicKey);
    
    //Configure BayunCore with TracingStatus as Disabled
    Bayun::BayunCoreConfiguration *config =
    new Bayun::BayunCoreConfiguration(Bayun::TracingStatus::Disabled);
    bayunCore->configure(config);
    
    //Run Test
    ShTestArgs test = std::make_shared<Test>(bayunCore);
    testRegisterEmployeeWithPassword(test, "<CompanyName>","<CompanyEmployeeId>","<Password>");
    
  } catch(Bayun::BayunException const &e) {
    LOG(LOG_ERR, stderr, "Exception: %s\n", e.getErrMsg());
  }
  LOG(LOG_INFO, stderr, "Before Exit\n");
  exit(0);
}

