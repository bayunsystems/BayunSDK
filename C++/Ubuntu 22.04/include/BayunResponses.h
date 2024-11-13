/*
 *  Copyright © 2022 Bayun Systems, Inc. All rights reserved.
 */

#ifndef AuthenticateResponse_h
#define AuthenticateResponse_h

#include <string>
#include <memory>
#include <vector>
#include "BayunEnums.h"

namespace Bayun {

/**
 * \class GroupMember
 */
class __attribute__((visibility("default"))) GroupMember {
public:
  const std::string companyEmployeeId; /**Company EmployeeId of the group member.*/
  const std::string companyName; /**Company name of the group member.*/
  
  virtual ~GroupMember() = default;
  
  GroupMember(const std::string& _companyEmployeeId,
              const std::string& _companyName)
  : companyEmployeeId(_companyEmployeeId),
  companyName(_companyName) {}
};
using ShGroupMember = std::shared_ptr<GroupMember>;


/**
 * \class AddMemberErrObject
 */
class __attribute__((visibility("default"))) AddMemberErrObject {
public:
  std::string errorMessage;
  std::vector<ShGroupMember> membersList;
  
  virtual ~AddMemberErrObject() = default;
  
  /**
   * AddMemberErrObject Constructor
   */
  AddMemberErrObject(const std::string _errorMessage, const std::vector<ShGroupMember> _membersList) :
  errorMessage(_errorMessage),
  membersList(_membersList){}
};
using ShAddMemberErrObject = std::shared_ptr<AddMemberErrObject>;


/**
 * \class SecurityQuestionInfo
 */
class  __attribute__((visibility("default"))) SecurityQuestionInfo {
public:
  const std::string questionId; // Security question id.
  const std::string question; // Security question.
  
  virtual ~SecurityQuestionInfo() = default;
protected:
  SecurityQuestionInfo(const std::string& _questionId,
                       const std::string& _question):
  questionId(_questionId),
  question(_question) {};
  
  // Default constructor is disabled.
  SecurityQuestionInfo() = delete;
};
using ShSecurityQuestionInfo = std::shared_ptr<SecurityQuestionInfo>;


/*!\class AuthenticateResponse
 * \brief Returns authentication responseCode and session if the authentication
 * is successful.
 */
class __attribute__((visibility("default"))) AuthenticateResponse {
public:
  // Bayun creates and returns a unique sessionId in the successful
  // authentication response if an empty sessionId i.e " " is provided to the
  // authenticate function call.
  // Same sessionId should be provided in all the subsequent calls to the Bayun
  // APIs as an argument.
  const std::string sessionId;
  
  // Response code is returned in the successful authentication response.
  const BayunAuthResponseCode responseCode;
  
  // Security Questions are returned if two factor authentication is enabled
  const std::vector<ShSecurityQuestionInfo> securityQuestions;
  
  // employeePublicKey is returned if its authorization is pending from the authorization server
  const std::string employeePublicKey;
  
  virtual ~AuthenticateResponse() = default;
protected:
  // Use BayunCore::authenticate to get an instance.
  AuthenticateResponse(const std::string& sessionId,
                       BayunAuthResponseCode responseCode,
                       const std::vector<ShSecurityQuestionInfo>& securityQuestions,
                       const std::string& employeePublicKey);
  
  // Default constructor is disabled.
  AuthenticateResponse() = delete;
};
using ShAuthenticateResponse = std::shared_ptr<AuthenticateResponse>;


/**
 * \class ChangePasswordResponse
 * \brief Returns response if the password is changed successfully.
 */
class __attribute__((visibility("default"))) ChangePasswordResponse {
public:
  virtual ~ChangePasswordResponse() = default;
protected:
  // Use BayunCore::changePassword to get an instance.
  ChangePasswordResponse() = default;
};
using ShChangePasswordResponse = std::shared_ptr<ChangePasswordResponse>;


/**
 * \class ValidatePassphraseResponse
 * \brief Returns BayunAuthResponseCode if the passphrase is validated successfully.
 */
class __attribute__((visibility("default"))) ValidatePassphraseResponse {
public:
  const std::string sessionId;
  
  // BayunAuthResponseCode i.e Success returned in the successful passphrase validation response.
  virtual BayunAuthResponseCode getResponseCode() const = 0;
  
  // Prints the response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~ValidatePassphraseResponse() = default;
protected:
  // Use BayunCore::validatePassphrase to get an instance.
  ValidatePassphraseResponse(const std::string& sessionId);
  
  // Default constructor is disabled.
  ValidatePassphraseResponse() = delete;
};
using ShValidatePassphraseResponse = std::shared_ptr<ValidatePassphraseResponse>;



/**
 * \class ValidateSecurityQuesResponse
 * \brief Returns BayunAuthResponseCode if the security questions are validated successfully.
 */
class __attribute__((visibility("default"))) ValidateSecurityQuesResponse {
public:
  const std::string sessionId;
  
  // BayunAuthResponseCode i.e Success is returned in the successful passphrase validation response.
  virtual BayunAuthResponseCode getResponseCode() const = 0;
  
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~ValidateSecurityQuesResponse() = default;
  
protected:
  ValidateSecurityQuesResponse(const std::string& sessionId);
  
  // Default constructor is disabled.
  ValidateSecurityQuesResponse() = delete;
};
using ShValidateSecurityQuesResponse = std::shared_ptr<ValidateSecurityQuesResponse>;

/**
 * \class EnableTwoFactorAuthenticationResponse
 * \brief Returns BayunAuthResponseCode if the two factor authentication is enabled successfully.
 */
class __attribute__((visibility("default"))) EnableTwoFactorAuthenticationResponse {
public:
  const std::string sessionId;
  
  // Response code is returned in the successful authentication response.
  const BayunAuthResponseCode responseCode;
  
  
  virtual ~EnableTwoFactorAuthenticationResponse() = default;
  
protected:
  // Use BayunCore::authenticate to get an instance.
  EnableTwoFactorAuthenticationResponse(const std::string& sessionId,
                                        BayunAuthResponseCode responseCode);
  
  // Default constructor is disabled.
  EnableTwoFactorAuthenticationResponse() = delete;
};
using ShEnableTwoFactorAuthenticationResponse = std::shared_ptr<EnableTwoFactorAuthenticationResponse>;


/**
 * \class SetSecurityQuesResponse
 * \brief Returns BayunAuthResponseCode if the security questions are set successfully.
 */
class __attribute__((visibility("default"))) SetSecurityQuestionsResponse {
public:
  // Response code is returned in the successful passphrase validation response.
  virtual BayunAuthResponseCode getResponseCode() const = 0;
  
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~SetSecurityQuestionsResponse() = default;
  
protected:
  // Use BayunCore::setSecurityQuestions to get an instance.
  SetSecurityQuestionsResponse() = default;
};
using ShSetSecurityQuestionsResponse = std::shared_ptr<SetSecurityQuestionsResponse>;

/**
 * \class SetPassphraseResponse
 * \brief Returns BayunAuthResponseCode if the security questions are set successfully.
 */
class __attribute__((visibility("default"))) SetPassphraseResponse {
public:
  // Writes a response to stderr.
  virtual void printResponse() const = 0;
  
  // Response code is returned in the successful passphrase validation response.
  virtual BayunAuthResponseCode getResponseCode() const = 0;
  
  virtual ~SetPassphraseResponse() = default;
  
protected:
  // Use BayunCore::setPassphrase to get an instance.
  SetPassphraseResponse() = default;
};
using ShSetPassphraseResponse = std::shared_ptr<SetPassphraseResponse>;

/**
 * \class CreateGroupResponse
 * \brief Returns groupId of the new group created.
 */
class __attribute__((visibility("default"))) CreateGroupResponse {
  public :
  // GroupId of the new group created
  virtual std::string getGroupId() const = 0;
  
  // Writes a response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~CreateGroupResponse() = default;
protected:
  // Use BayunCore::createGroup to get an instance.
  CreateGroupResponse() = default;
};
using ShCreateGroupResponse = std::shared_ptr<CreateGroupResponse>;

/**
 * \class GroupInfo
 */
class __attribute__((visibility("default"))) GroupInfo {
public:
  const std::string groupId; /**GroupId of the group.*/
  const std::string name; /**Name of the group.*/
  const GroupType type; /**Type of Group, Public or Private.*/
  
  virtual ~GroupInfo() = default;
protected:
  GroupInfo(const std::string& _id,
            const std::string& _name,
            GroupType _type)
  : groupId(_id),
  name(_name),
  type(_type) {};
  
  // Default constructor is disabled.
  GroupInfo() = delete;
};
using ShGroupInfo = std::shared_ptr<GroupInfo>;

/**
 * \class MyGroupsResponse
 * \brief Returns all the groups, both public and private, the user is a member of.
 */
class __attribute__((visibility("default"))) MyGroupsResponse {
public:
  /**
   * Returns all the groups, both public and private, the user is a member of.
   * @return Vector of GroupInfo objects
   */
  virtual std::vector<ShGroupInfo> getGroups() const = 0;
  
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~MyGroupsResponse() = default;
  
protected:
  // Use BayunCore::myGroups to get an instance
  MyGroupsResponse() = default;
};
using ShMyGroupsResponse = std::shared_ptr<MyGroupsResponse>;


/**
 * \class UnjoinedPublicGroupsResponse
 * \brief Returns all the public groups of the company the employee is not a member of.
 */
class __attribute__((visibility("default"))) UnjoinedPublicGroupsResponse {
public:
  /**
   * Returns all the public groups of the company the employee is not a member of.
   * @return Vector of GroupInfo objects
   */
  virtual std::vector<ShGroupInfo> getGroups() const = 0;
  
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~UnjoinedPublicGroupsResponse() = default;
protected:
  // Use BayunCore::unjoinedPublicGroups to get an instance
  UnjoinedPublicGroupsResponse() = default;
};
using ShUnjoinedPublicGroupsResponse = std::shared_ptr<UnjoinedPublicGroupsResponse>;


/*! \class JoinPublicGroupResponse
 * \brief Returns all the public groups of the company the employee is not a member of.
 */
class __attribute__((visibility("default"))) JoinPublicGroupResponse {
public:
  const std::string sessionId;
  
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~JoinPublicGroupResponse() = default;
protected:
  JoinPublicGroupResponse(const std::string& sessionId);
  
  // Default constructor is disabled.
  JoinPublicGroupResponse() = delete;
};
using ShJoinPublicGroupResponse = std::shared_ptr<JoinPublicGroupResponse>;


/**
 * \class AddGroupMemberResponse
 * \brief Returns response after adding a new member to the group.
 */
class __attribute__((visibility("default"))) AddGroupMemberResponse {
  public :
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~AddGroupMemberResponse() = default;
protected:
  // Use BayunCore::addGroupMember to get an instance.
  AddGroupMemberResponse() = default;
};
using ShAddGroupMemberResponse = std::shared_ptr<AddGroupMemberResponse>;

/**
 * \class AddGroupMembersResponse
 * \brief Returns response after adding new members to the group.
 */
class __attribute__((visibility("default"))) AddGroupMembersRespInternal {
  public :
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  // Get Error Objects for members could not be added to the group.
  virtual std::vector<ShAddMemberErrObject> getAddMemberErrObject() const = 0;
  
  // Get count of the members added in the group.
  virtual std::string getAddedMembersCount() const = 0;
  
  virtual ~AddGroupMembersRespInternal() = default;
  
  protected:
  // Use BayunCore::addGroupMembers to get an instance.
  AddGroupMembersRespInternal() = default;
};
using ShAddGroupMembersRespInternal = std::shared_ptr<AddGroupMembersRespInternal>;


/**
 * \class RemoveGroupMemberResponse
 * \brief Returns response after removing a member from the group.
 */
class __attribute__((visibility("default"))) RemoveGroupMemberResponse {
  public :
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~RemoveGroupMemberResponse() = default;
protected:
  // Use BayunCore::removeGroupMember to get an instance.
  RemoveGroupMemberResponse() = default;
};
using ShRemoveGroupMemberResponse = std::shared_ptr<RemoveGroupMemberResponse>;


/**
 * \class RemoveGroupMembersResponse
 * \brief Returns response after removing a list of members from the group.
 */
class __attribute__((visibility("default"))) RemoveGroupMembersResponse {
  public :
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~RemoveGroupMembersResponse() = default;
protected:
  // Use BayunCore::removeGroupMembers to get an instance.
  RemoveGroupMembersResponse() = default;
};
using ShRemoveGroupMembersResponse = std::shared_ptr<RemoveGroupMembersResponse>;


/**
 * \class RemoveGroupMembersExceptListResponse
 * \brief Returns response after removing a list of members from the group.
 */
class __attribute__((visibility("default"))) RemoveGroupMembersExceptListResponse {
  public :
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~RemoveGroupMembersExceptListResponse() = default;
protected:
  // Use BayunCore::removeGroupMembers to get an instance.
  RemoveGroupMembersExceptListResponse() = default;
};
using ShRemoveGroupMembersExceptListResponse = std::shared_ptr<RemoveGroupMembersExceptListResponse>;


/**
 * \class GroupByIdResponse
 * \brief Returns groupId, name, type, groupMembers.
 */
class __attribute__((visibility("default"))) GroupByIdResponse {
public:
  /**
   * Returns group members.
   * @return Vector of GroupMember objects.
   */
  
  // Get groupId of the group.
  virtual std::string getGroupId() const = 0;
  
  // Get the name of the group.
  virtual std::string getName() const = 0;
  
  // Get the group type.
  virtual GroupType getType() const = 0;
  
  // Get the group type.
  virtual std::vector<ShGroupMember> getGroupMembers() const = 0;
  
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  
  virtual ~GroupByIdResponse() = default;
protected:
  // Use BayunCore::groupById to get an instance.
  GroupByIdResponse() = default;
};
using ShGroupByIdResponse = std::shared_ptr<GroupByIdResponse>;


/**
 * \class LeaveGroupResponse
 * \brief Returns response if the group is left successfully.
 */
class __attribute__((visibility("default"))) LeaveGroupResponse {
  public :
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~LeaveGroupResponse() = default;
protected:
  // Use BayunCore::leaveGroup to get an instance.
  LeaveGroupResponse() = default;
};
using ShLeaveGroupResponse = std::shared_ptr<LeaveGroupResponse>;



/**
 * \class DeleteGroupResponse
 * \brief Returns response if the group is deleted successfully.
 */
class __attribute__((visibility("default"))) DeleteGroupResponse {
public:
  // Prints response to stderr.
  virtual void printResponse() const = 0;
  
  virtual ~DeleteGroupResponse() = default;
  protected :
  // Use BayunCore::deleteGroup to get an instance.
  DeleteGroupResponse() = default;
};
using ShDeleteGroupResponse = std::shared_ptr<DeleteGroupResponse>;


/**
 * \class SecurityQuestionAnswer
 */
class __attribute__((visibility("default"))) SecurityQuestionAnswer {
  public :
  std::string questionId; /**Security question id. QuestionId is mandatory when validating the answers and is not required when setting the security questions and answers*/
  std::string question; /**Security question. Question text is mandatory when setting security questions and answers and is not required when validating the same*/
  std::string answer; /**Security question's answer*/
  
  // Create SecurityQuestionAnswer using this constructor.
  SecurityQuestionAnswer(const std::string& _questionId,
                         const std::string& _question,
                         const std::string& _answer)
  : questionId(_questionId),
  question(_question),
  answer(_answer) {}
  
  // Default constructor is disabled.
  SecurityQuestionAnswer() = delete;
  
  virtual ~SecurityQuestionAnswer() = default;
};
using ShSecurityQuestionAnswer = std::shared_ptr<SecurityQuestionAnswer>;

/**
 * \class AddGroupMembersResponse
 */
class __attribute__((visibility("default"))) AddGroupMembersResponse {

  public :
  std::vector<ShAddMemberErrObject> addMemberErrObjects;
  std::string addedMembersCount;
  
  // Create SecurityQuestionAnswer using this constructor.
  AddGroupMembersResponse(const std::vector<ShAddMemberErrObject> _addMemberErrObjects,
                          const std::string addedMembersCount)
  : addMemberErrObjects(_addMemberErrObjects), addedMembersCount(addedMembersCount) {}

  virtual void printResponse() const = 0;
  
  // Default constructor is disabled.
  AddGroupMembersResponse() = delete;

  virtual ~AddGroupMembersResponse() = default;
};
using ShAddGroupMembersResponse = std::shared_ptr<AddGroupMembersResponse>;


}  // namespace Bayun

#endif /* AuthenticateResponse_h */
