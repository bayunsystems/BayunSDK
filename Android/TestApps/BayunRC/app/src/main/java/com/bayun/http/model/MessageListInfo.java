package com.bayun.http.model;

import java.util.ArrayList;

/**
 * Created by Gagan on 6/30/2015.
 */
public class MessageListInfo {

    private Paging paging;
    private Navigation navigation;
    private String uri;
	private ArrayList<MessageInfo> records;

    public Paging getPaging() {
        return paging;
    }

    public void setPaging(Paging paging) {
        this.paging = paging;
    }

    public ArrayList<MessageInfo> getRecords() {
        return records;
    }

    public void setRecords(ArrayList<MessageInfo> records) {
        this.records = records;
    }

    public Navigation getNavigation() {
        return navigation;
    }

    public void setNavigation(Navigation navigation) {
        this.navigation = navigation;
    }

    public String getUri() {
        return uri;
    }

    public void setUri(String uri) {
        this.uri = uri;
    }

}
