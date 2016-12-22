package com.bayun.screens;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.webkit.MimeTypeMap;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.NotificationCenter;
import com.bayun.aws.AWSS3Manager;
import com.bayun.util.Constants;
import com.bayun.util.Utility;

import java.io.File;


public class ViewFileActivity extends AbstractActivity implements NotificationCenter.NotificationCenterDelegate {

    private TextView fileTextView;
    private String fileName = "", savedText = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_file);
        setUpView();

        // add observer to notify activity
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AWS_DOWNLOAD_COMPLETE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AUTH_KEY_AVAILABLE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AUTH_KEY_NOT_AVAILABLE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AWS_UPLOAD_COMPLETE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.ACCESS_DENIED);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.TRANSFER_FAILED);
        viewFile();
    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        TextView fileNameText = (TextView) findViewById(R.id.activity_view_file_fileName_text);
        // textView = (TextView) findViewById(R.id.activity_view_file_edit_text);
        fileTextView = (TextView) findViewById(R.id.activity_view_file_edit_text_view);
        fileTextView.setMovementMethod(new ScrollingMovementMethod());
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));
        Intent intent = getIntent();
        fileName = intent.getExtras().getString(Constants.DOWNLOAD_FILE_NAME, Constants.EMPTY_STRING);
        fileNameText.setText(fileName);
    }

    /**
     * Remove all observers when activity destroy
     */
    @Override
    protected void onDestroy() {
        super.onDestroy();
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.TRANSFER_FAILED);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AWS_DOWNLOAD_COMPLETE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AUTH_KEY_AVAILABLE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AUTH_KEY_NOT_AVAILABLE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AWS_UPLOAD_COMPLETE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.ACCESS_DENIED);
    }

    /**
     * Get file from External Storage
     *
     * @return File.
     */
    @NonNull
    public File getFile() {
        return new File(getExternalFilesDir(
                Environment.DIRECTORY_PICTURES), fileName);
    }

    /**
     * Downloads a file from S3 to display contents of the file
     */
    public void viewFile() {
        progressDialog.show();
        AWSS3Manager.getInstance().downloadFile(fileName);
    }

    /**
     * Receive notification.
     *
     * @param id   notification id.
     * @param args object arg.
     */
    @Override
    public void didReceivedNotification(int id, Object... args) {
        if (id == NotificationCenter.AWS_DOWNLOAD_COMPLETE) {
            if (progressDialog != null && progressDialog.isShowing()) {
                progressDialog.dismiss();
            }
            try {

                MimeTypeMap myMime = MimeTypeMap.getSingleton();
                Intent intent = new Intent();
                intent.setAction(Intent.ACTION_VIEW);
                String file = fileExt(getFile().getAbsolutePath());
                if (!file.isEmpty()) {
                    if (file.equalsIgnoreCase(".txt")) {
                        String text = Utility.readFile(getFile().getAbsolutePath());
                        fileTextView.setText(text);
                    } else {
                        finish();
                        String mimeType = myMime.getMimeTypeFromExtension(file.substring(1));
                        intent.setDataAndType(Uri.fromFile(getFile()), mimeType);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(intent);
                    }


                }
            } catch (Exception e) {
                Utility.displayToast(e.getMessage(), Toast.LENGTH_SHORT);
            }
        } else if (id == NotificationCenter.AWS_UPLOAD_COMPLETE) {
            dismissDialog();
            NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_ADD_NEW_FILE);
            String file_upload_message = fileName + Constants.FILE_NAME_SPACE + Constants.FILE_SAVED;
            Utility.displayToast(file_upload_message, Toast.LENGTH_SHORT);
            finish();

        } else if (id == NotificationCenter.ACCESS_DENIED) {
            Utility.displayToast("access denied", Toast.LENGTH_SHORT);
            dismissDialog();
            finish();
        } else if (id == NotificationCenter.AUTH_KEY_NOT_AVAILABLE || id == NotificationCenter.TRANSFER_FAILED) {
            dismissDialog();
        }
    }

    /**
     * Save existing file
     */
    public void saveFile() {
        String fileText = fileTextView.getText().toString();
        if (fileText.equalsIgnoreCase(Constants.EMPTY_STRING)) {
            Utility.messageAlertForCertainDuration(ViewFileActivity.this, Constants.FILE_EMPTY);
        } else {
            progressDialog.show();
            AWSS3Manager.getInstance().writeFile(fileTextView.getText().toString(), fileName);

        }
    }

    /**
     * Dismiss progress dialog
     */
    public void dismissDialog() {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
    }

    @NonNull
    private String fileExt(String url) {
        if (url.indexOf("?") > -1) {
            url = url.substring(0, url.indexOf("?"));
        }
        if (url.lastIndexOf(".") == -1) {
            return "";
        } else {
            String ext = url.substring(url.lastIndexOf("."));
            if (ext.indexOf("%") > -1) {
                ext = ext.substring(0, ext.indexOf("%"));
            }
            if (ext.indexOf("/") > -1) {
                ext = ext.substring(0, ext.indexOf("/"));
            }
            return ext.toLowerCase();

        }
    }

    /**
     * Handles User Back Button Click.
     *
     * @param view : Back View as a ImageView.
     */
    public void backButtonImageClick(View view) {
        super.onBackPressed();
    }


}
