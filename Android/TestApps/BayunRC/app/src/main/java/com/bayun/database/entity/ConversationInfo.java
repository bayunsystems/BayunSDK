package com.bayun.database.entity;

import java.util.Date;

/**
 * Created by Gagan on 14/07/15.
 */
public class ConversationInfo implements Comparable<ConversationInfo> {
    private Date creationTime;
    private String direction;
    private String extensionNumber;
    private String subject;
    private String conversation_id;
    private String name;

    public String getExtensionNumber() {
        return extensionNumber;
    }

    public void setExtensionNumber(String extensionNumber) {
        this.extensionNumber = extensionNumber;
    }

    public String getDirection() {
        return direction;
    }

    public void setDirection(String direction) {
        this.direction = direction;
    }

    public String getConversation_id() {
        return conversation_id;
    }

    public void setConversation_id(String conversation_id) {
        this.conversation_id = conversation_id;
    }

    public Date getCreationTime() {
        return creationTime;
    }

    public void setCreationTime(Date creationTime) {
        this.creationTime = creationTime;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public int compareTo(ConversationInfo o) {
        return -(getCreationTime().compareTo(o.getCreationTime()));
    }
}


