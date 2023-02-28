package com.bayun.aws.model;

/**
 * Created by Akriti on 8/18/2017.
 */

public class GroupInfo {

    private String groupKey;
    private String id;
    private String name;
    private String type;
    private String creatorCompanyName;
    private String creatorCompanyEmployeeId;

    public GroupInfo() {}

    public GroupInfo (String groupKey, String id, String name, String type, String creatorCompanyName, String creatorCompanyEmployeeId) {
        this.groupKey = groupKey;
        this.id = id;
        this.name = name;
        this.type = type;
        this.creatorCompanyName = creatorCompanyName;
        this.creatorCompanyEmployeeId = creatorCompanyEmployeeId;
    }

    public String getGroupKey() {
        return groupKey;
    }

    public void setGroupKey(String groupKey) {
        this.groupKey = groupKey;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCreatorCompanyName() {
        return creatorCompanyName;
    }

    public void setCreatorCompanyName(String creatorCompanyName) {
        this.creatorCompanyName = creatorCompanyName;
    }

    public String getCreatorCompanyEmployeeId() {
        return creatorCompanyEmployeeId;
    }

    public void setCreatorCompanyEmployeeId(String creatorCompanyEmployeeId) {
        this.creatorCompanyEmployeeId = creatorCompanyEmployeeId;
    }
}
