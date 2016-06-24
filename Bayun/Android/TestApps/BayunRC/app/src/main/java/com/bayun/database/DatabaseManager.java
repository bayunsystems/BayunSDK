package com.bayun.database;

import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.util.concurrent.atomic.AtomicInteger;

public class DatabaseManager {

    private AtomicInteger mOpenCounter = new AtomicInteger();
    private static DatabaseManager mInstance;
    private SQLiteOpenHelper mDatabaseHelper;
    private SQLiteDatabase mDatabase;

    private DatabaseManager(SQLiteOpenHelper helper) {
        mDatabaseHelper = helper;
    }

    public static synchronized void initializeInstance(SQLiteOpenHelper helper) {
        DatabaseManager localInstance = mInstance;
        if (localInstance == null) {
            synchronized (DatabaseManager.class) {
                localInstance = mInstance;
                if (localInstance == null) {
                    mInstance = localInstance = new DatabaseManager(helper);
                }
            }
        }
    }

    public static synchronized DatabaseManager getInstance() {
        if (mInstance == null) {
            throw new IllegalStateException(DatabaseManager.class.getSimpleName() +
                    " is not initialized, call initializeInstance(..) method first.");
        }
        return mInstance;
    }

    public synchronized SQLiteDatabase openDatabase() {
        if (mOpenCounter.incrementAndGet() == 1) {
            // Opening new database connection
            mDatabase = mDatabaseHelper.getWritableDatabase();
        }
        return mDatabase;
    }

    public synchronized void closeDatabase() {
        if (mOpenCounter.decrementAndGet() == 0) {
            // Closing database connection
            mDatabase.close();
        }
    }
}
