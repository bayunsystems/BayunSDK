/*
 *  Copyright © 2022 Bayun Systems, Inc. All rights reserved.
 */

#ifndef __BAYUN_EXCEPTION_H__
#define __BAYUN_EXCEPTION_H__


#include <stdexcept>
#include <stdarg.h>
#include <syslog.h>
#include <string.h>

#include <thread>

extern int __attribute__((visibility("default"))) loglevel;
extern void printTimeNow(FILE *fp) __attribute__((visibility("default")));
extern const char* path2filename(const char *fullpath) __attribute__((visibility("default")));

/* Adds filename, function and line number to a log message and prints only if
 * current log level is not less than the log level of the message.  Log levels
 * are as per syslog.h with one addition: LOG_DEBUG1 is one level higher than
 * LOG_DEBUG. */
#define LOG(printloglevel, fp, fmt, ...) { if (loglevel >= printloglevel) { printTimeNow(fp); fprintf(fp, ("[%x]: %s:%s:%d: " fmt), std::this_thread::get_id(), path2filename(__FILE__), __FUNCTION__, __LINE__, ##__VA_ARGS__); }}

#define DETAILEDLOG LOG(LOG_ERR, stderr, "");

// LOG without filename, function and line number info
#define BARELOG(printloglevel, fp, fmt, ...) ({ if (loglevel >= printloglevel) fprintf(fp, fmt, ##__VA_ARGS__); })

// For an exception, we would like to log the filename, function and line number
// where the exception OCCURRED, whereas the message is printed only in the
// BayunException constructor.  Hence, use a macro to get this info.
#define BayunExceptionWrapper(bayunErrCode, sysErrNo) ({ DETAILEDLOG; BayunException(bayunErrCode, sysErrNo, ""); })

#define BayunExceptionWrapperS(bayunErrCode) ({ DETAILEDLOG; BayunException(bayunErrCode, 0, ""); })

// Long wrapper when a format string and variable arguments need to be printed
#define BayunExceptionWrapperL(bayunErrCode, sysErrNo, fmt, ...) ({ DETAILEDLOG; BayunException(bayunErrCode, sysErrNo, fmt, ##__VA_ARGS__); })

#define IF_LOGLEVEL_ABOVE(printloglevel, stmt) { if (loglevel >= printloglevel) stmt;}
#define SET_LOGLEVEL(setloglevel) {loglevel = setloglevel;}

#define LOG_DEBUG1 (LOG_DEBUG+1)

#define BAYUN_ERR_NONE               0
#define BAYUN_SYSERR_THREADCREATE    1
#define BAYUN_SYSERR_MUTEXINIT       2
#define BAYUN_SYSERR_MUTEXLOCK       3
#define BAYUN_SYSERR_MUTEXUNLOCK     4
#define BAYUN_SYSERR_MUTEXDESTROY    5
#define BAYUN_SYSERR_CONDINIT        6
#define BAYUN_SYSERR_CONDWAIT        7
#define BAYUN_SYSERR_CONDSIGNAL      8
#define BAYUN_SYSERR_CONDDESTROY     9
#define BAYUN_SYSERR_THREADJOIN     10
#define BAYUN_SYSERR_TIMEOUT        11
#define BAYUN_SYSERR_MALLOC         12

#define BAYUN_SYSERR_MAX            12

/* Exceptions have to be caught in BayunSDKThreadPool and
 * encapsulated in a BayunRESTResponse object because
 * non-blocking calls have already returned.  As the same
 * mechanism is used for blocking calls, in that case, the
 * exception has to be rethrown.  A flag is OR'd into the
 * error code to indicate this so that the error code is
 * not converted to string again.
 */
#define BAYUN_ERR_RETHROW                       (1<<8)
#define BAYUN_ERR_REQIDUNKN                     (BAYUN_SYSERR_MAX+1)
#define BAYUN_ERR_PARSE                         (BAYUN_SYSERR_MAX+2)
#define BAYUN_ERR_NOREQID                       (BAYUN_SYSERR_MAX+3)
#define BAYUN_ERR_RESTCALLTYPEUNKN              (BAYUN_SYSERR_MAX+4)
#define BAYUN_ERR_CURLINITFAILED                (BAYUN_SYSERR_MAX+5)
#define BAYUN_ERR_CURLNOTINITED                 (BAYUN_SYSERR_MAX+6)
#define BAYUN_ERR_CURLCALLFAILED                (BAYUN_SYSERR_MAX+7)
#define BAYUN_ERR_CURLPTRNULL                   (BAYUN_SYSERR_MAX+8)
#define BAYUN_ERR_RECVBUFOVERFLOW               (BAYUN_SYSERR_MAX+9)
#define BAYUN_ERR_URLBUFOVFLW                   (BAYUN_SYSERR_MAX+10)
#define BAYUN_ERR_THREADPOOLINIT                (BAYUN_SYSERR_MAX+11)
#define BAYUN_ERR_BAYUNAPIINIT                  (BAYUN_SYSERR_MAX+12)
#define BAYUN_ERR_SERVER                        (BAYUN_SYSERR_MAX+13)
#define BAYUN_ERR_LMSNOTINITED                  (BAYUN_SYSERR_MAX+14)
#define BAYUN_ERR_NO_AUTH_TOKEN                 (BAYUN_SYSERR_MAX+15)
#define BAYUN_ERR_UNKNOWN                       (BAYUN_SYSERR_MAX+16)
#define BAYUN_ERR_AUTH_FAILED                   (BAYUN_SYSERR_MAX+17)
#define BAYUN_ERR_COMPANY_ALREADY_EXISTS        (BAYUN_SYSERR_MAX+18)
#define BAYUN_ERR_EMPLOYEE_ALREADY_EXISTS       (BAYUN_SYSERR_MAX+19)
#define BAYUN_ERR_INVALID_APP_ID                (BAYUN_SYSERR_MAX+20)
#define BAYUN_ERR_INVALID_APP_SECRET            (BAYUN_SYSERR_MAX+21)
#define BAYUN_ERR_INVALID_PASSWORD              (BAYUN_SYSERR_MAX+22)
#define BAYUN_ERR_INVALID_PASSPHRASE            (BAYUN_SYSERR_MAX+23)
#define BAYUN_ERR_APP_NOT_LINKED                (BAYUN_SYSERR_MAX+24)
#define BAYUN_ERR_USER_INACTIVE                 (BAYUN_SYSERR_MAX+25)
#define BAYUN_ERR_INVALID_TOKEN                 (BAYUN_SYSERR_MAX+26)
#define BAYUN_ERR_SESSION_ID_NIL                (BAYUN_SYSERR_MAX+27)
#define BAYUN_ERR_PWD_NIL                       (BAYUN_SYSERR_MAX+28)
#define BAYUN_ERR_SDK                           (BAYUN_SYSERR_MAX+29)

#define BAYUN_ERR_APP_ID_NIL                    (BAYUN_SYSERR_MAX+30)
#define BAYUN_ERR_APP_SECRET_NIL                (BAYUN_SYSERR_MAX+31)
#define BAYUN_ERR_COMP_NAME_NIL                 (BAYUN_SYSERR_MAX+32)
#define BAYUN_ERR_COMP_EMP_ID_NIL               (BAYUN_SYSERR_MAX+33)

#define BAYUN_ERR_PLAIN_TEXT_NIL                (BAYUN_SYSERR_MAX+34)
#define BAYUN_ERR_CIPHER_TEXT_NIL               (BAYUN_SYSERR_MAX+35)
#define BAYUN_ERR_PLAIN_DATA_NIL                (BAYUN_SYSERR_MAX+36)
#define BAYUN_ERR_CIPHER_DATA_NIL               (BAYUN_SYSERR_MAX+37)
#define BAYUN_ERR_FILE_PATH_NIL                 (BAYUN_SYSERR_MAX+38)

#define BAYUN_ERR_PASSPHRASE_NIL                (BAYUN_SYSERR_MAX+39)
#define BAYUN_ERR_ANSWERS_NIL                   (BAYUN_SYSERR_MAX+40)

#define BAYUN_ERR_EMP_DEACTIVATED               (BAYUN_SYSERR_MAX+41)
#define BAYUN_ERR_EMP_ID_NOT_EXISTS             (BAYUN_SYSERR_MAX+42)
#define BAYUN_ERR_COMPANY_NOT_EXISTS            (BAYUN_SYSERR_MAX+43)
#define BAYUN_ERR_EMP_NOT_EXISTS_FOR_COMPANY_AND_EMPID            (BAYUN_SYSERR_MAX+44)
#define BAYUN_ERR_GROUP_ID_NIL                  (BAYUN_SYSERR_MAX+45)
#define BAYUN_ERR_GROUP_KEY_NIL                 (BAYUN_SYSERR_MAX+46)
#define BAYUN_ERR_GROUP_PRIV_KEY_NIL                 (BAYUN_SYSERR_MAX+47)
#define BAYUN_ERR_EMP_PUB_KEY_NOT_FOUND         (BAYUN_SYSERR_MAX+48)
#define BAYUN_ERR_ONE_OR_MORE_INVALID_ANS       (BAYUN_SYSERR_MAX+49)
#define BAYUN_ERR_GROUP_NOT_EXISTS_FOR_GROUPID       (BAYUN_SYSERR_MAX+50)

#define BAYUN_ERR_NOT_GROUP_MEMBER        (BAYUN_SYSERR_MAX+51)
#define BAYUN_ERR_MEMBER_ALREADY_PART_OF_GROUP             (BAYUN_SYSERR_MAX+52)
#define BAYUN_ERR_MEMBER_TO_REMOVE_NOT_EXISTS       (BAYUN_SYSERR_MAX+53)
#define BAYUN_ERR_CANNOT_JOIN_PRIVATE_GROUP       (BAYUN_SYSERR_MAX+54)
#define BAYUN_ERR_GROUP_ACCESS_DENIED       (BAYUN_SYSERR_MAX+55)
#define BAYUN_ERR_APP_SALT_NIL                    (BAYUN_SYSERR_MAX+56)
#define BAYUN_ERR_NO_GROUP_MEMBERS             (BAYUN_SYSERR_MAX+57)
#define BAYUN_ERR_ARGS                          (BAYUN_SYSERR_MAX+58)
#define BAYUN_ERR_AUTH_APP_PRIV_KEY_NOT_FOUND         (BAYUN_SYSERR_MAX+59)
#define BAYUN_ERR_CREATION_APP_PRIV_KEY_NOT_FOUND         (BAYUN_SYSERR_MAX+60)
#define BAYUN_ERR_EMP_KEYS_NOT_FOUND         (BAYUN_SYSERR_MAX+61)
#define BAYUN_ERR_APP_SECRET_HAS_NO_CREATION_ROLE         (BAYUN_SYSERR_MAX+62)
#define BAYUN_ERR_EMPLOYEE_AUTH_PENDING        (BAYUN_SYSERR_MAX+63)
#define BAYUN_ERR_EMAIL_NIL                           (BAYUN_SYSERR_MAX+64)
#define BAYUN_ERR_AUTO_CREATE_DISABLED                (BAYUN_SYSERR_MAX+65)
#define BAYUN_ERR_SET_FIVE_SECURITY_QUES_ANS       (BAYUN_SYSERR_MAX+66)
#define BAYUN_ERR_INSUFFICIENT_SQ_ANS       (BAYUN_SYSERR_MAX+67)
#define BAYUN_ERR_USER_ACCOUNT_PWD_ENABLED       (BAYUN_SYSERR_MAX+68)
#define BAYUN_ERR_INVALID_OPERATION                   (BAYUN_SYSERR_MAX+69)
#define BAYUN_ERR_NO_USER_ACCOUNT                   (BAYUN_SYSERR_MAX+70)
#define BAYUN_ERR_LINK_USER_EMP_ACCOUNT                   (BAYUN_SYSERR_MAX+71)
#define USER_ALREADY_REGISTERED                   (BAYUN_SYSERR_MAX+72)
#define BAYUN_ERR_EMP_NOT_LINKED_TO_APP                   (BAYUN_SYSERR_MAX+73)
#define BAYUN_ERR_PWD_ENABLED_FOR_EMP_ACC         (BAYUN_SYSERR_MAX+74)
#define BAYUN_ERR_EMP_APP_NOT_REGISTERED          (BAYUN_SYSERR_MAX+75)
#define BAYUN_ERR_CREATOR_COMP_NAME_NIL                 (BAYUN_SYSERR_MAX+76)
#define BAYUN_ERR_CREATOR_COMP_EMP_ID_NIL               (BAYUN_SYSERR_MAX+77)

// If another error code is added, BAYUN_ERR_MAX below must be incremented
// Note: if BAYUN_ERR_MAX exceeds BAYUN_ERR_RETHROW, left-shift it by few more bits
#define BAYUN_ERR_MAX               (BAYUN_SYSERR_MAX+78)

/* If a new exception is needed, add here, update BAYUN_ERR_MAX and
 * add a message to the end of errlist in BayunException.cc */
#define ERRBUF_SIZE              500

namespace Bayun {


/*!\class BayunException
 * \brief The BayunException class subclasses runtime_error and stores
 * information about the various exceptional situations that arise in
 * the REST call library.
 *
 * Printf style arguments can be passed to the constructor and that is
 * appended to a static message  corresponding to the error code.  The
 * constructor is  called through  a macro which  adds the  file name,
 * function name and line number.
 */
class  __attribute__((visibility("default"))) BayunException : public std::runtime_error {
  static const char *errlist[]; /**Message strings for internal errors*/
  uint32_t bayunErrCode;        /**Internal error code*/
  uint32_t sysErrNo;            /**System call error, 0 implies no error (it's an internal error)*/
  char errbuf[ERRBUF_SIZE];     /**Error message*/
public:
  static BayunException bayunExceptionNone;
  
  /**
   * BayunException Constructor
   */
  BayunException(const BayunException &e);
  
  /**
   * BayunException Constructor
   */
  BayunException(int bayunErrCode, int sysErrNo, const char *fmt, ...);
  
  /**
   * Returns Error Message
   * @return Error Message
   */
  char* getErrMsg() const;
  
  /**
   * Returns Internal Error Code
   * @return Internal Error Code
   */
  int getErrCode();
  
  /**
   * Returns System Error Code
   * @return System Error Code
   */
  int getSysErrNo();
};
}
#endif /* __BAYUN_EXCEPTION_H__ */
