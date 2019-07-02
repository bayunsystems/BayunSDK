package com.bayun.screens.activity;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import androidx.annotation.NonNull;
import android.view.View;
import android.webkit.MimeTypeMap;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.NotificationCenter;
import com.bayun.aws.AWSS3Manager;
import com.bayun.util.Constants;
import com.bayun.util.Utility;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import static java.util.ResourceBundle.clearCache;

public class ViewFileActivity extends AbstractActivity implements NotificationCenter.NotificationCenterDelegate {

    private TextView textView;
    private String fileName = "",savedText = "";
    private EditText fileEditText;
    private RelativeLayout progressbar;

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
        progressbar = (RelativeLayout) findViewById(R.id.progressBar);
        progressbar.setVisibility(View.VISIBLE);
        //fileProgressDialog = Utility.createFileProgressDialog(this, "Downloading...");
        TextView fileNameText = (TextView) findViewById(R.id.activity_view_file_fileName_text);
        textView = (TextView) findViewById(R.id.activity_view_file_edit_text);
        fileEditText = (EditText) findViewById(R.id.activity_view_file_edit_text_view);
        fileEditText.setFocusableInTouchMode(false);
        fileEditText.setFocusable(false);
        Intent intent = getIntent();
        fileName = intent.getExtras().getString(Constants.DOWNLOAD_FILE_NAME, Constants.EMPTY_STRING);
        fileNameText.setText(fileName);
        savedText = fileEditText.getText().toString();
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
        runOnUiThread(() -> progressbar.setVisibility(View.VISIBLE));
        AWSS3Manager.getInstance().downloadFile(fileName);
    }

    /**
     * Handles Edit click Event.
     *
     * @param view as a TextView
     */
    public void editClick(View view) {
        String text = textView.getText().toString();
        if (text.equalsIgnoreCase(getString(R.string.save_file))) {
            saveFile();
            Utility.hideKeyboard(fileEditText);
        }
        else if (text.equalsIgnoreCase(getString(R.string.edit_file))) {
            fileEditText.setFocusableInTouchMode(true);
            fileEditText.setCursorVisible(Boolean.TRUE);
            fileEditText.setEnabled(Boolean.TRUE);
            textView.setText(getString(R.string.save_file));
            Utility.showKeyboard(fileEditText);
        }
    }

    /**
     * Handles User Back Button Click.
     *
     * @param view : Back View as a ImageView.
     */
    public void backButtonImageClick(View view) {
        Utility.hideKeyboard(fileEditText);
        String newText = fileEditText.getText().toString();
        if (savedText.equalsIgnoreCase(newText)) {
            onBackPressed();
        } else {
            showDialog();
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        finish();
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
            dismissDialog();
            try {
                runOnUiThread(() -> {
                    if (isFileImage()) {
                        finish();
                        Intent intent = new Intent();
                        intent.setAction(Intent.ACTION_VIEW);
                        intent.setDataAndType(Uri.fromFile(getFile()), "image");
                        startActivity(intent);
                    }
                    else {
                        String fileText = readFile();
                        //Read data fetched from the file
                        fileEditText.setVisibility(View.VISIBLE);
                        fileEditText.setText(fileText);
                        savedText = fileEditText.getText().toString();
                    }
                });
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
     * Checks if a particular file is an image file
     *
     * @return boolean if the file is an image file
     */
    private boolean isFileImage() {
        MimeTypeMap myMime = MimeTypeMap.getSingleton();
        String file = fileExt(getFile().getAbsolutePath());
        String mimeType = myMime.getMimeTypeFromExtension(file.substring(1));
        //mimeType should be something like "image/png"
        if (mimeType != null && mimeType.split("/")[0].equals("image")) {
            return true;
        }
        return false;
    }

    // read data from file
    public String readFile() {
        StringBuilder out = null;
        String fileData = "";
        try {
            InputStream in = new FileInputStream(getFile());
            BufferedReader reader = new BufferedReader(new InputStreamReader(in));
            out = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                out.append(line);
            }
            fileData = out.toString();
            reader.close();
        }
        catch (IOException e) {
            Utility.displayToast("Error occurred while reading the file.", Toast.LENGTH_SHORT);
        }
        return fileData;
    }

    /**
     * Save existing file
     */
    public void saveFile() {
        String fileText = fileEditText.getText().toString();
        if (fileText.equalsIgnoreCase(Constants.EMPTY_STRING)) {
            Utility.messageAlertForCertainDuration(ViewFileActivity.this, Constants.FILE_EMPTY);
        } else {
            //fileProgressDialog.show();
            AWSS3Manager.getInstance().writeFile(fileEditText.getText().toString(),fileName);

        }
    }

    /**
     * Dismiss progress dialog
     */
    public void dismissDialog() {
        runOnUiThread(() -> progressbar.setVisibility(View.GONE));
    }

    /**
     * Show dialog on press back button.
     */
    public void showDialog() {
        Utility.decisionAlert(ViewFileActivity.this, getString(R.string.dialog_title), "", getString(R.string.yes), getString(R.string.no), (dialog, which) -> {
            dialog.cancel();
            saveFile();
        }, (dialog, which) -> {
            dialog.cancel();
            finish();
        });
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

}
