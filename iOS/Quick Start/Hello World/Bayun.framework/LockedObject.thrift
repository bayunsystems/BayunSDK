
struct LockedObject {
    1: required binary encryptedData
    2: required i32 version
    3: required i32 encryptionPolicy
    4: required i32 encryptionMode
    5: optional binary iv
    6: optional i64 counter
    7: optional string groupId
    8: optional i32 keyGenerationPolicy
    9: optional binary encryptedDEK
   10: optional i64 chainKGPRandomNo
   11: optional i32 iterationNumber
   12: optional i32 senderId
   13: optional i32 recipientId
   14: optional string senderDetail
}
