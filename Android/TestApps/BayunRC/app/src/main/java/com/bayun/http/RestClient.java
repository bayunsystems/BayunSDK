package com.bayun.http;

import com.bayun.http.model.Extension;
import com.bayun.http.model.ExtensionListInfo;
import com.bayun.http.model.LoginInfo;
import com.bayun.http.model.MessageInfo;
import com.bayun.http.model.MessageListInfo;

import retrofit.Callback;
import retrofit.http.Body;
import retrofit.http.Field;
import retrofit.http.FormUrlEncoded;
import retrofit.http.GET;
import retrofit.http.POST;
import retrofit.http.Path;
import retrofit.http.Query;

/**
 * Created by Gagan on 04/06/15.
 */
 interface RestClient {

    @FormUrlEncoded
    @POST("/restapi/oauth/token")
    void authenticate(@Field("username") Long username,
                      @Field("extension") Long extension,
                      @Field("password") String password,
                      @Field("grant_type") String grant_type,
                      Callback<LoginInfo> callback);
    @FormUrlEncoded
    @POST("/restapi/oauth/token")
    LoginInfo getAccessToken(@Field("grant_type") String grant_type,
                             @Field("refresh_token") String refresh_token);


    @GET("/restapi/v1.0/account/~/extension/~/message-store?messageType=Pager")
   // void getMessageList( Callback<MessageListInfo> callback);
    void getMessageList(@Query("dateFrom") String date, Callback<MessageListInfo> callback);

    @GET("/restapi/v1.0/account/~/extension")
    void getExtensionList(Callback<ExtensionListInfo> callback);

    @POST("/restapi/v1.0/account/~/extension/~/company-pager")
    void sendMessage(@Body Extension extension, Callback<MessageInfo> callback);


    @GET("/restapi/v1.0/account/~/extension/~/message-store/{messageId}")
    void getMessageById(@Path("messageId") Long messageId,
                        Callback<MessageInfo> callback);

}

