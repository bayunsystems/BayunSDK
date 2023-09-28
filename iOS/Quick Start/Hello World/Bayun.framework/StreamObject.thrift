
struct StreamObject {
    1: required i32 version
    2: required string streamId
    3: required i32 encryptionPolicy
    4: required i32 keyGenerationPolicy
    5: optional binary iv
    6: optional binary encryptedDEK
    7: optional i64 chainKGPRandomNo
    8: optional i32 iterationNumber
}

