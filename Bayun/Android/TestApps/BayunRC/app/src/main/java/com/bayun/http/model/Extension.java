package com.bayun.http.model;

import java.util.ArrayList;

/**
 * Created by Gagan on 6/30/2015.
 */
public class Extension {

    private String text;
    private CallerInfo from;
    private ArrayList<CallerInfo> to;

    public ArrayList<CallerInfo> getTo() {
        return to;
    }

    public void setTo(ArrayList<CallerInfo> to) {
        this.to = to;
    }

    public CallerInfo getFrom() {
        return from;
    }

    public void setFrom(CallerInfo from) {
        this.from = from;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

}






