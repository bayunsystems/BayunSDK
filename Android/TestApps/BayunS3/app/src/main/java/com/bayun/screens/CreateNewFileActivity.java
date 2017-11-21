package com.bayun.screens;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.app.NotificationCenter;
import com.bayun.aws.AWSS3Manager;
import com.bayun.util.Constants;
import com.bayun.util.Utility;


public class CreateNewFileActivity extends AbstractActivity implements NotificationCenter.NotificationCenterDelegate {

    private String fileName = "";
    private TextView saveTextView;
    private EditText fileEditText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_file);
        setUpView();

        // add observer to notify activity
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AWS_UPLOAD_COMPLETE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AUTH_KEY_AVAILABLE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AUTH_KEY_NOT_AVAILABLE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_FILE_EXIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.ACCESS_DENIED);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.TRANSFER_FAILED);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_EXCEPTION);
    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));
        fileEditText = (EditText) findViewById(R.id.activity_create_new_file_editText);
        fileEditText.requestFocus();
        saveTextView = (TextView) findViewById(R.id.activity_create_new_file_save_text_view);
    }

    /**
     * Remove all observers when activity destroy
     */
    @Override
    protected void onDestroy() {
        super.onDestroy();
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AWS_UPLOAD_COMPLETE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AUTH_KEY_AVAILABLE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AUTH_KEY_NOT_AVAILABLE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_BUCKET_FILE_EXIST);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.ACCESS_DENIED);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.TRANSFER_FAILED);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_EXCEPTION);
    }

    /**
     * Handles User Back Button Click.
     *
     * @param view : Back View as a ImageView.
     */
    public void backButtonImageClick(View view) {
        backButtonClick();
    }

    /**
     * Handles User Back Button Click.
     */
    @Override
    public void onBackPressed() {
        backButtonClick();
    }

    /**
     * Handles User Save Button Click .
     *
     * @param view save View as a TextView.
     */
    public void saveClick(View view) {
        String fileText = fileEditText.getText().toString();
        if (fileText.equalsIgnoreCase(Constants.EMPTY_STRING)) {
            if (!isFinishing())
                Utility.messageAlertForCertainDuration(CreateNewFileActivity.this, Constants.FILE_EMPTY);
            Utility.hideKeyboard(fileEditText);
        } else {
            if (Utility.isNetworkAvailable()) {
                showDialog();
            } else {
                Utility.messageAlertForCertainDuration(CreateNewFileActivity.this, Constants.ERROR_INTERNET_OFFLINE);
            }
        }
    }

    /**
     * Receive notification.
     *
     * @param id   notification id.
     * @param args object arg.
     */
    @Override
    public void didReceivedNotification(int id, Object... args) {
        if (id == NotificationCenter.AWS_UPLOAD_COMPLETE) {
            dismissDialog();
            String file_upload_message = fileName + Constants.FILE_NAME_SPACE + Constants.FILE_SAVED;
            Utility.displayToast(file_upload_message, Toast.LENGTH_SHORT);
            NotificationCenter.getInstance().postNotificationName(NotificationCenter.S3_BUCKET_ADD_NEW_FILE);
            finish();
        } else if (id == NotificationCenter.S3_BUCKET_FILE_EXIST) {
            dismissDialog();
            Utility.displayToast(Constants.FILE_ALREADY_EXIST, Toast.LENGTH_SHORT);
        } else if (id == NotificationCenter.S3_BUCKET_FILE_NOT_EXIST) {
            saveFile();
        } else if (id == NotificationCenter.ACCESS_DENIED | (id == NotificationCenter.TRANSFER_FAILED)) {
            dismissDialog();
            finish();
        } else if (id == NotificationCenter.S3_EXCEPTION) {
            dismissDialog();
            Utility.displayToast("Amazon S3 Exception!!", Toast.LENGTH_SHORT);
        }
    }

    /**
     * Show alert dialog to ask user file name.
     */
    public void showDialog() {
        LayoutInflater li = LayoutInflater.from(BayunApplication.appContext);
        View dialogView = li.inflate(R.layout.custom_dialog, null);
        final EditText userFileNameEditText = (EditText) dialogView
                .findViewById(R.id.editTextDialogUserInput);
        final EditText companyNameEditText = (EditText) dialogView.findViewById(R.id.editTextCompanyName);
        Utility.showAlertDialog(CreateNewFileActivity.this, getString(R.string.enter_file_name), getString(R.string.ok), dialogView, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                String fileName = userFileNameEditText.getText().toString();
                if (fileName.length() > 0) {
                    CreateNewFileActivity.this.fileName = companyNameEditText.getText().toString() + fileName;
                    CreateNewFileActivity.this.fileName = CreateNewFileActivity.this.fileName + Constants.FILE_EXTENSION;
                    AWSS3Manager.getInstance().Exists(CreateNewFileActivity.this.fileName);
                    InputMethodManager im = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                    im.hideSoftInputFromWindow(userFileNameEditText.getWindowToken(), 0);
                    dialog.dismiss();
                    progressDialog.show();
                } else {
                    Utility.displayToast(Constants.FILE_NAME_ERROR, Toast.LENGTH_SHORT);

                }
            }
        });
    }

    /**
     * Save a new file on Amazon S3
     */
    public void saveFile() {
        saveTextView.setEnabled(false);
        AWSS3Manager.getInstance().writeFile(fileEditText.getText().toString(), fileName);
    }

    /**
     * Dismiss progress dialog.
     */
    public void dismissDialog() {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
    }

    /**
     * Show dialog on press back button.
     */
    public void showDialogOnBack() {
        Utility.decisionAlert(CreateNewFileActivity.this, "", getString(R.string.dialog_title), getString(R.string.yes), getString(R.string.no), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                showDialog();
            }
        }, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {

                dialog.cancel();
                finish();
            }
        });
    }

    private void backButtonClick() {
        Utility.hideKeyboard(fileEditText);
        if (fileEditText.getText().toString().equals(Constants.EMPTY_STRING)) {
            finish();
        } else {
            showDialogOnBack();
        }
    }
}