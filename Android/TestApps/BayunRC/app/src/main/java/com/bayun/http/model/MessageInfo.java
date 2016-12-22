package com.bayun.http.model;

import java.util.ArrayList;

/**
 * Created by Gagan on 07/13/2015.
 */

public class MessageInfo {

    private String type;
    private String creationTime;
    private String readStatus;
    private Conversation conversation;
    private String subject;
    private String messageStatus;
    private String direction;
    private String conversationId;
    private Long id;
    private String lastModifiedTime;
    private SenderDetail from;
    private ArrayList<ReceiverDetail> to;

    public Conversation getConversation() {
        return conversation;
    }

    public void setConversation(Conversation conversation) {
        this.conversation = conversation;
    }

    public String getConversationId() {
        return conversationId;
    }

    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }

    public SenderDetail getFrom() {
        return from;
    }

    public void setFrom(SenderDetail from) {
        this.from = from;
    }

    public ArrayList<ReceiverDetail> getTo() {
        return to;
    }

    public void setTo(ArrayList<ReceiverDetail> to) {
        this.to = to;
    }

    public String getLastModifiedTime() {
        return lastModifiedTime;
    }

    public void setLastModifiedTime(String lastModifiedTime) {
        this.lastModifiedTime = lastModifiedTime;
    }

    public String getCreationTime() {
        return creationTime;
    }

    public void setCreationTime(String creationTime) {
        this.creationTime = creationTime;
    }

    public String getReadStatus() {
        return readStatus;
    }

    public void setReadStatus(String readStatus) {
        this.readStatus = readStatus;
    }

    public String getDirection() {
        return direction;
    }

    public void setDirection(String direction) {
        this.direction = direction;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getMessageStatus() {
        return messageStatus;
    }

    public void setMessageStatus(String messageStatus) {
        this.messageStatus = messageStatus;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
}