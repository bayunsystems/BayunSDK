package com.bayun.aws.model;

import android.support.annotation.NonNull;

import java.util.Date;

/**
 * Created by Gagan on 08/06/15.
 */

public class FileInfo implements Comparable<FileInfo> {

    private String fileName;
    public String lastModifiedTime;
    private Date date;
    private long size;

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Date getDate() {
        return date;
    }

    public String getLastModifiedTime() {
        return lastModifiedTime;
    }

    public void setLastModifiedTime(String lastModifiedTime) {
        this.lastModifiedTime = lastModifiedTime;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public long getSize() {
        return size;
    }

    public void setSize(long size) {
        this.size = size;
    }

    @Override
    @NonNull
    public int compareTo(FileInfo o) {
        return getDate().compareTo(o.getDate());
    }
}


