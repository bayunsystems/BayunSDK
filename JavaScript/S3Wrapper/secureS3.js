let isConfigUpdate = false;
let reader = new FileReader();
let s3;
var unlocked_Text;
let fileInfoObject = {
  fileText: "",
  metaData: "",
};
let encryptionPolicy;
let keyGenerationPolicy;

class SecureS3 {
  constructor(
    bayunSessionId,
    apiVersion,
    accessKeyId,
    secretAccessKey,
    signatureVersion,
    region,
    bucket
  ) {
    if (
      bayunSessionId &&
      apiVersion &&
      accessKeyId &&
      secretAccessKey &&
      signatureVersion &&
      region &&
      bucket
    ) {
      this.bayunSessionId = bayunSessionId;
      this.apiVersion = apiVersion;
      this.accessKeyId = accessKeyId;
      this.secretAccessKey = secretAccessKey;
      this.signatureVersion = signatureVersion;
      this.region = region;
      this.bucket = bucket;
      this.initS3();
    } else {
      console.log("Some parameters didn't found");
    }
  }

  initS3 = async () => {
    try {
      if (!window.AWS) {
        return;
      }
      if (!isConfigUpdate) {
        window.AWS.config.update({ region: this.region });
        isConfigUpdate = true;
      }

      s3 = new window.AWS.S3({
        credentials: new window.AWS.Credentials({
          apiVersion: this.apiVersion,
          accessKeyId: this.accessKeyId,
          secretAccessKey: this.secretAccessKey,
          signatureVersion: this.signatureVersion,
          region: this.region,
          Bucket: this.bucket,
        }),
      });
    } catch (error) {
      console.log(error);
    }
  };

  setEncryptionPolicy = async (EncryptionPolicy) => {
    encryptionPolicy = EncryptionPolicy;
  };

  setKeyGenerationPolicy = async (KeyGenerationPolicy) => {
    keyGenerationPolicy = KeyGenerationPolicy;
  };

  uploadToS3Bucket = async (stream, cd, type, name) => {
    try {
      let uploadItem = await s3
        .upload({
          Bucket: this.bucket,
          Key: name,
          ContentType: type,
          Body: stream,
        })
        .on("httpUploadProgress", function (progress) {
          console.log("progress=>", progress);
          cd(this.getUploadingProgress(progress.loaded, progress.total));
        })
        .promise();
      console.log("uploadItem=>", uploadItem);

      return uploadItem;
    } catch (error) {
      console.log(error);
    }
  };

  downloadImage = async (
    utilCall,
    name,
    DownloadCallBack,
    unlockTextCallBack,
    bayunSessionId
  ) => {
    let data;
    try {
      console.log("Downloading file, please wait");
      data = await s3.getObject({ Bucket: this.bucket, Key: name }).promise();
    } catch (err) {
      console.log("Failed to retrieve an object: ", err);
    }
    console.log("Downloaded Image Data :", data);
    console.log("Array ", data.Body);
    var Base64String = await utilCall(data, name);
    console.log("__Base64String", Base64String);

    try {
      var unlocked_Text = await unlockTextCallBack(
        bayunSessionId,
        Base64String
      );
      console.log("unlockedText", unlocked_Text);
      await DownloadCallBack(unlocked_Text, data.ContentType, name);
    } catch (error) {
      console.log("Error: ", error);
    }
  };

  getUploadingProgress = async (uploadSize, totalSize) => {
    let uploadProgress = (uploadSize / totalSize) * 100;
    return Number(uploadProgress.toFixed(0));
  };

  util = async (data, name) => {
    var base64 = await this.arrayBufferToBase64(data.Body);
    console.log("Base64StringIs ", base64);
    await this.writeFileTextToFile(base64, data.ContentType, "LOCKED_" + name);
    return base64;
  };

  arrayBufferToBase64 = async (buffer) => {
    var binary = "";
    var bytes = new Uint8Array(buffer);
    var len = bytes.byteLength;
    for (var i = 0; i < len; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return window.btoa(binary);
  };

  writeFileTextToFile = async (fileText, fileType, name) => {
    var a = document.createElement("a");
    a.href = "data:" + fileType + ";base64," + fileText;
    var extension = fileType.substring(
      fileType.indexOf("/") + 1,
      fileType.length
    );
    a.download = name + "." + extension; //File name Here
    a.click();
  };

  //to be used when user upload a locked base64 string of a image/text
  base64ToArrayBuffer = async (base64) => {
    var binary_string = window.atob(base64);
    var len = binary_string.length;
    var bytes = new Uint8Array(len);
    for (var i = 0; i < len; i++) {
      bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
  };

  unlockTextForImage = async (sessionId, text) => {
    var unlockedText = await bayunCoreObjectS3
      .unlockFileText(sessionId, text)
      .then((res) => res);
    return unlockedText;
  };

  lockTextForImage = async (
    sessionId,
    text,
    encryptionPolicy,
    keyGenerationPolicy,
    groupId
  ) => {
    console.log("session id for locking", sessionId);
    var lockedText = await bayunCoreObjectS3.lockFileText(
      sessionId,
      text,
      encryptionPolicy,
      keyGenerationPolicy,
      groupId
    );
    console.log("lockedText = ", lockedText);
    return lockedText;
  };

  proccedUpload = async (textToLock, type, name) => {
    let lockedText = await this.lockTextForImage(
      this.bayunSessionId,
      textToLock,
      encryptionPolicy,
      keyGenerationPolicy,
      ""
    );

    console.log("Locking Finished");

    //uploading the item on s3 server
    console.log("Uploading Item On S3");

    var lockedBase64ToArrayBuffer = await this.base64ToArrayBuffer(lockedText);

    await this.uploadToS3Bucket(
      lockedBase64ToArrayBuffer,
      (progress) => {
        console.log(progress);
      },
      type,
      name
    );

    console.log("Uploading Finished");

    //fetching the item from s3 server
    console.log("Downloading from S3");

    await this.downloadImage(
      this.util,
      name,
      this.writeFileTextToFile,
      this.unlockTextForImage,
      this.bayunSessionId
    );
  };

  upload = async (file) => {
    var type = file.type;
    var name = file.name;
    var reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = await function () {
      var inputData = reader.result;
      console.log("inputData = ", inputData);
      var replaceValue = inputData.split(",")[0];
      var metaData = replaceValue;
      var fileText = inputData.replace(replaceValue + ",", "");
      fileInfoObject = {
        fileText: fileText,
        metaData: metaData,
      };
      this.proccedUpload(fileInfoObject.fileText, type, name);
    }.bind(this);
  };

  downloadFile = async (name) => {
    await this.downloadImage(
      this.util,
      name,
      this.writeFileTextToFile,
      this.unlockTextForImage,
      this.bayunSessionId
    );
  };
}

let bayunCoreObjectS3;

function initBayunCoreS3() {
  bayunCoreObjectS3 = BayunCore.init(
    Constants.BAYUN_APP_ID,
    Constants.BAYUN_APP_SECRET,
    Constants.BAYUN_APP_SALT,
    localStorageModeBayun,
    Constants.BASE_URL,
    Constants.BAYUN_SERVER_PUBLIC_KEY,
    Constants.ENABLE_FACE_RECOGNITION
  );
  console.log("Instanciated_BayunCore_Object_S3");
}

var localStorageModeBayun = BayunCore.LocalDataEncryptionMode.SESSION_MODE;
initBayunCoreS3();
