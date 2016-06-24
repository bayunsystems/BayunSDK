package com.bayun.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.sqlite.SQLiteStatement;

import com.bayun.database.entity.ConversationInfo;
import com.bayun.database.entity.MessageInfo;
import com.bayun.http.model.Conversation;
import com.bayun.http.model.MessageListInfo;
import com.bayun.http.model.ReceiverDetail;
import com.bayun.http.model.SenderDetail;
import com.bayun.util.Constants;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Created by Gagan on 01/07/2015.
 */
public class ActivityDBOperations {

    final private SQLiteOpenHelper dbHelper;

    public ActivityDBOperations(Context context) {
        dbHelper = new ActivityDBHelper(context);
    }

    // Method to insert message details in database
    public void insertMessageDetails(MessageListInfo messageListInfo) {
        ArrayList<com.bayun.http.model.MessageInfo> records = messageListInfo.getRecords();
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        try {
            database.beginTransaction();
            String sql = "INSERT INTO " + Constants.TABLE_MESSAGE_DETAIL + " VALUES (?,?,?,?,?,?,?,?,?,?,?);";
            SQLiteStatement insert = database.compileStatement(sql);
            for (int i = 0; i < records.size(); i++) {
                com.bayun.http.model.MessageInfo item = records.get(i);
                SenderDetail from = item.getFrom();
                ArrayList<ReceiverDetail> to = item.getTo();
                Conversation conversation = item.getConversation();
                insert.bindString(1, item.getId().toString());
                insert.bindString(2, item.getType());
                insert.bindString(3, item.getDirection());
                insert.bindString(4, from.getExtensionNumber());
                insert.bindString(5, from.getName());
                insert.bindString(6, to.get(0).getExtensionNumber());
                insert.bindString(7, to.get(0).getName());
                insert.bindString(8, item.getSubject());
                insert.bindString(9, item.getReadStatus());
                insert.bindString(10, item.getCreationTime());
                insert.bindString(11, conversation.getId());
                insert.execute();
            }
            database.setTransactionSuccessful();
        } catch (Exception e) {
		    e.printStackTrace();
        } finally {
            database.endTransaction();
            DatabaseManager.getInstance().closeDatabase();
        }
    }

    // Method to insert conversation details in database
    public void insertConversationDetails(MessageListInfo messageListInfo) {
        ArrayList<com.bayun.http.model.MessageInfo> records = messageListInfo.getRecords();
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        try {
            database.beginTransaction();
            for (int i = records.size() - 1; i >= 0; i--) {
                com.bayun.http.model.MessageInfo item = records.get(i);
                Conversation conversation = item.getConversation();
                String id = conversation.getId();
                Cursor cursor = database.query(Constants.TABLE_CONVERSATION_DETAIL, new String[]{Constants.CONVERSATION_ID, Constants.LAST_MESSAGE_SUBJECT, Constants.LAST_MESSAGE_NAME, Constants.MESSAGE_UPDATE_TIME, Constants.MESSAGE_DIRECTION, Constants.EXTENSION_NUMBER
                        }, Constants.CONVERSATION_ID + "=?",
                        new String[]{id}, null, null, null, null);
                if ((cursor != null) && (cursor.getCount() > 0)) {
                    updateConversation(item);
                } else {
                    insertConversation(item);
                }
                if (cursor != null) {
                    cursor.close();
                }
            }
            database.setTransactionSuccessful();
        } catch (Exception e) {
            e.printStackTrace();   
        } finally {
            database.endTransaction();
            DatabaseManager.getInstance().closeDatabase();
        }
    }

    // Method to insert single conversation details in database
    private void insertConversation(com.bayun.http.model.MessageInfo item) {
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        try {
            String sql = "INSERT INTO " + Constants.TABLE_CONVERSATION_DETAIL + " VALUES (?,?,?,?,?,?);";
            SQLiteStatement insert = database.compileStatement(sql);
            SenderDetail from = item.getFrom();
            ArrayList<ReceiverDetail> to = item.getTo();
            Conversation conversation = item.getConversation();
            insert.bindString(1, conversation.getId());
            insert.bindString(2, item.getSubject());
            if (item.getDirection().equalsIgnoreCase("Inbound")) {
                insert.bindString(3, from.getName());
                insert.bindString(6, from.getExtensionNumber());
            } else {
                insert.bindString(3, to.get(0).getName());
                insert.bindString(6, to.get(0).getExtensionNumber());
            }
            insert.bindString(4, item.getCreationTime());
            insert.bindString(5, item.getDirection());
            insert.execute();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DatabaseManager.getInstance().closeDatabase();
        }
    }

    // Method to update single conversation details in database
    private void updateConversation(com.bayun.http.model.MessageInfo item) {
        SenderDetail from = item.getFrom();
        ArrayList<ReceiverDetail> to = item.getTo();
        Conversation conversation = item.getConversation();
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put(Constants.LAST_MESSAGE_SUBJECT, item.getSubject());
        if (item.getDirection().equalsIgnoreCase("Inbound")) {
            contentValues.put(Constants.LAST_MESSAGE_NAME, from.getName());
            contentValues.put(Constants.EXTENSION_NUMBER, from.getExtensionNumber());
        } else {
            contentValues.put(Constants.LAST_MESSAGE_NAME, to.get(0).getName());
            contentValues.put(Constants.EXTENSION_NUMBER, to.get(0).getExtensionNumber());
        }
        contentValues.put(Constants.MESSAGE_UPDATE_TIME, item.getCreationTime());
        contentValues.put(Constants.MESSAGE_DIRECTION, item.getDirection());
        database.update(Constants.TABLE_CONVERSATION_DETAIL, contentValues, Constants.CONVERSATION_ID + " = ? ", new String[]{conversation.getId()});
        DatabaseManager.getInstance().closeDatabase();
    }

    // Get all messages by conversation id
    public ArrayList<MessageInfo> getAllMessagesById(String id) {
        ArrayList<MessageInfo> messageInfoList = new ArrayList<>();
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        Cursor cursor = database.rawQuery("SELECT * FROM " + Constants.TABLE_MESSAGE_DETAIL + " WHERE " + Constants.CONVERSATION_MESSAGE_ID + "='" + id + "'", null);
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        Date date = null;
        try {
            if (cursor != null && cursor.moveToFirst()) {
                do {
                    MessageInfo messageInfo = new MessageInfo();
                    messageInfo.setId(cursor.getLong(0));
                    messageInfo.setType(cursor.getString(1));
                    messageInfo.setDirection(cursor.getString(2));
                    messageInfo.setSenderNumber(cursor.getString(3));
                    messageInfo.setSenderName(cursor.getString(4));
                    messageInfo.setReceiverNumber(cursor.getString(5));
                    messageInfo.setReceiverName(cursor.getString(6));
                    messageInfo.setSubject(cursor.getString(7));
                    messageInfo.setReadStatus(cursor.getString(8));
                    try {
                        date = dateFormat.parse(cursor.getString(9));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    messageInfo.setCreationTime(date);
                    messageInfoList.add(messageInfo);
                } while (cursor.moveToNext());
            }
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        DatabaseManager.getInstance().closeDatabase();
        return messageInfoList;
    }

    // Get all messages from message table
    public ArrayList<MessageInfo> getAllMessages() {
        ArrayList<MessageInfo> messageInfoList = new ArrayList();
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        Cursor cursor = database.rawQuery("SELECT * FROM " + Constants.TABLE_MESSAGE_DETAIL, null);
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        Date date = null;
        try {
            if (cursor != null && cursor.moveToFirst()) {
                do {
                    MessageInfo messageInfo = new MessageInfo();
                    messageInfo.setId(cursor.getLong(0));
                    messageInfo.setType(cursor.getString(1));
                    messageInfo.setDirection(cursor.getString(2));
                    messageInfo.setSenderNumber(cursor.getString(3));
                    messageInfo.setSenderName(cursor.getString(4));
                    messageInfo.setReceiverNumber(cursor.getString(5));
                    messageInfo.setReceiverName(cursor.getString(6));
                    messageInfo.setSubject(cursor.getString(7));
                    messageInfo.setReadStatus(cursor.getString(8));
                    try {
                        date = dateFormat.parse(cursor.getString(9));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    messageInfo.setCreationTime(date);
                    messageInfoList.add(messageInfo);
                } while (cursor.moveToNext());
            }
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        DatabaseManager.getInstance().closeDatabase();
        return messageInfoList;
    }

    // Get all conversation status
    public ArrayList<ConversationInfo> getAllConversations() {
        ArrayList<ConversationInfo> conversationInfos = new ArrayList();
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        Cursor cursor = database.rawQuery("SELECT * FROM " + Constants.TABLE_CONVERSATION_DETAIL, null);
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        Date date = null;
        try {
            if (cursor != null && cursor.moveToFirst()) {
                do {
                    ConversationInfo conversationInfo = new ConversationInfo();
                    conversationInfo.setConversation_id(cursor.getString(0));
                    conversationInfo.setSubject(cursor.getString(1));
                    conversationInfo.setName(cursor.getString(2));
                    try {
                        date = dateFormat.parse(cursor.getString(3));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    conversationInfo.setCreationTime(date);
                    conversationInfo.setDirection(cursor.getString(4));
                    conversationInfo.setExtensionNumber(cursor.getString(5));
                    conversationInfos.add(conversationInfo);
                } while (cursor.moveToNext());
            }
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        DatabaseManager.getInstance().closeDatabase();
        return conversationInfos;
    }

    // Get conversation id using extension
    public String getConversationId(String extension) {
        String conversationId = "";
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        Cursor cursor = database.rawQuery("SELECT * FROM " + Constants.TABLE_CONVERSATION_DETAIL + " WHERE " + Constants.EXTENSION_NUMBER + "='" + extension + "'", null);
        try {
            if (cursor != null && cursor.moveToFirst()) {
                do {
                    conversationId = cursor.getString(0);
                } while (cursor.moveToNext());
            }
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        DatabaseManager.getInstance().closeDatabase();
        return conversationId;
    }

    // Delete the data from both conversation and message tables.
    public void deleteAll() {
        SQLiteDatabase database = DatabaseManager.getInstance().openDatabase();
        database.delete(Constants.TABLE_CONVERSATION_DETAIL, null, null);
        database.delete(Constants.TABLE_MESSAGE_DETAIL, null, null);
        DatabaseManager.getInstance().closeDatabase();
    }
}
