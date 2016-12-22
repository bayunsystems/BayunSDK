package com.bayun.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.bayun.app.BayunApplication;
import com.bayun.util.Constants;


/**
 * Created by Gagan on 01/07/2015.
 */

public class ActivityDBHelper extends SQLiteOpenHelper {

    private static ActivityDBHelper mInstance = null;

    public synchronized static ActivityDBHelper getInstance() {
        ActivityDBHelper localInstance = mInstance;
        if (localInstance == null) {
            synchronized (ActivityDBHelper.class) {
                localInstance = mInstance;
                if (localInstance == null) {
                    mInstance = localInstance = new ActivityDBHelper(BayunApplication.appContext);
                }
            }
        }
        return mInstance;
    }

    public ActivityDBHelper(Context context) {
        super(context, Constants.DATABASE_NAME, null, Constants.DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(Constants.DATABASE_CREATE_TABLE_CONVERSATION);
        db.execSQL(Constants.DATABASE_CREATE_TABLE_MESSAGE);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + Constants.DATABASE_CREATE_TABLE_CONVERSATION);
        db.execSQL("DROP TABLE IF EXISTS " + Constants.DATABASE_CREATE_TABLE_MESSAGE);
        onCreate(db);
    }
}
