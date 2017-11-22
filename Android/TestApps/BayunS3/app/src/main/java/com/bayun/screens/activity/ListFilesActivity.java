package com.bayun.screens.activity;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.app.NotificationCenter;
import com.bayun.aws.AWSS3Manager;
import com.bayun.screens.adapter.FilesAdapter;
import com.bayun.util.CognitoHelper;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.FileUtils;
import com.bayun.util.RecyclerItemClickListener;
import com.bayun.util.Utility;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;
import static com.bayun.aws.AWSS3Manager.getInstance;


public class ListFilesActivity extends AbstractActivity implements NotificationCenter.NotificationCenterDelegate,
        SwipeRefreshLayout.OnRefreshListener, RecyclerItemClickListener.OnItemClickListener {

    private RecyclerView recyclerView;
    private FilesAdapter filesAdapter;
    private SwipeRefreshLayout swipeRefreshLayout;
    private TextView emptyView;
    private static final int PICKFILE_RESULT_CODE = 1;
    private static final int PERMISSION_REQUEST_CODE = 200;
    File file;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_file);
        setUpView();

        // add observer to notify activity
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AWS_UPLOAD_COMPLETE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_ADD_NEW_FILE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AWS_DOWNLOAD_LIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.TRANSFER_FAILED);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_EXIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_FILE_EXIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);
        String companyName = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_COMPANY_NAME);
        String bucketName = "bayun-test-" + companyName;
        bucketName = bucketName.toLowerCase();
        BayunApplication.tinyDB.putString(Constants.S3_BUCKET_NAME, bucketName);
        if (Utility.isNetworkAvailable()) {
            getInstance().createBucketOnS3(bucketName);
        } else {
            Utility.messageAlertForCertainDuration(ListFilesActivity.this, Constants.ERROR_INTERNET_OFFLINE);
        }
        recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(this, this));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!checkPermission()) {
                ActivityCompat.requestPermissions(this, new String[]{READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE}, PERMISSION_REQUEST_CODE);
            }
        }
    }

    /**
     * Sets up Views.
     */
    private void setUpView() {
        progressDialog = Utility.createProgressDialog(this, getString(R.string.please_wait));
        progressDialog.show();
        fileProgressDialog = Utility.createFileProgressDialog(this, "uploading");
        recyclerView = (RecyclerView) findViewById(R.id.list_files_recycler_view);
        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipeRefreshLayout);
        emptyView = (TextView) findViewById(R.id.empty_view);
        recyclerView.setHasFixedSize(true);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.addItemDecoration(new DividerItemDecoration(this));
        swipeRefreshLayout.setOnRefreshListener(this);
        filesAdapter = new FilesAdapter(ListFilesActivity.this, getInstance().fileList());
        recyclerView.setAdapter(filesAdapter);
    }

    /**
     * Remove all observers when activity destroy
     */
    @Override
    protected void onDestroy() {
        super.onDestroy();
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_BUCKET_EXIST);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.TRANSFER_FAILED);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AWS_UPLOAD_COMPLETE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_BUCKET_ADD_NEW_FILE);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.AWS_DOWNLOAD_LIST);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_BUCKET_FILE_EXIST);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);
    }

    /**
     * Handles Create new file Button Click.
     *
     * @param view : View as a TextView.
     */
    public void createNewFileClick(View view) {
        showDialogFilePicker();
    }

    /**
     * Show Dialog for file picker.
     */
    public void showDialogFilePicker() {
        final CharSequence sequences[] = new CharSequence[]{"Upload", "Groups", "Encryption Policy",
                "Logout"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT);
        builder.setTitle("Options");
        builder.setItems(sequences, (dialog, which) -> {
            if (sequences[which].equals("Upload")) {
                showDialogUploadFile();
            }
            else if (sequences[which].equals("Groups")) {
                Intent intent = new Intent(ListFilesActivity.this, GroupsListActivity.class);
                startActivity(intent);
            }
            else if (sequences[which].equals("Logout")) {
                Intent intent = new Intent(ListFilesActivity.this, RegisterActivity.class);
                startActivity(intent);
                BayunApplication.tinyDB.clear();
                AWSS3Manager.getInstance().resetEncryptionPolicyOnDevice();
                // Logout from Cognito and Bayun
                BayunApplication.secureAuthentication.signOut
                        (CognitoHelper.getPool().getUser(CognitoHelper.getUserId()));

                if (getInstance().fileList() != null && getInstance().fileList().size() != 0)
                    getInstance().fileList().clear();
            }
            else if (sequences[which].equals("Encryption Policy")){
                showDialogEncryptionPolicy();
            }
        });
        builder.show();
    }

    /**
     * Shows dialog for upload file options - upload or create a new file
     */
    private void showDialogUploadFile() {
        final CharSequence sequences[] = new CharSequence[] {"Create a New File", "Choose From Library"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT);
        builder.setTitle("Upload a File");
        builder.setItems(sequences, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (sequences[which].equals("Create a New File")) {
                    if (Utility.isNetworkAvailable()) {
                        Intent intent = new Intent(ListFilesActivity.this, CreateNewFileActivity.class);
                        startActivity(intent);
                    } else {
                        Utility.messageAlertForCertainDuration(ListFilesActivity.this, Constants.ERROR_INTERNET_OFFLINE);
                    }
                }
                else {
                    openFileManager();
                }
            }
        });
        builder.show();
    }

    /**
     * Show dialog box for selecting encryption policy
     */
    private void showDialogEncryptionPolicy() {
        Dialog dialog = new Dialog(this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.spinner_dialog_layout);
        ((TextView)dialog.findViewById(R.id.dialog_title)).setText("Set Encryption Policy");
        dialog.findViewById(R.id.dialog_group_name).setVisibility(View.GONE);
        dialog.findViewById(R.id.dialog_employee_id).setVisibility(View.GONE);
        Spinner spinner = (Spinner) dialog.findViewById(R.id.dialog_spinner);
        final ArrayList<String> encryptionPolicies = getPolicies();
        ArrayAdapter<String> dataAdapter = new ArrayAdapter<>(this,
                android.R.layout.simple_spinner_item, encryptionPolicies);
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(dataAdapter);

        // get stored value to show it selected
        int position = AWSS3Manager.getInstance().getEncryptionPolicyOnDevice();
        spinner.setSelection(position);

        // setting click listeners
        dialog.findViewById(R.id.cancel_action).setOnClickListener(v -> dialog.dismiss());
        dialog.findViewById(R.id.ok_action).setOnClickListener(v -> {
            String selectedValue = spinner.getSelectedItem().toString();
            int selectedValueIndex = encryptionPolicies.indexOf(selectedValue);
            AWSS3Manager.getInstance().setEncryptionPolicyOnDevice(selectedValueIndex);
            dialog.dismiss();
        });
        dialog.show();
    }

    /**
     * Sets empty view.
     */
    public void setEmptyView() {
        recyclerView.setVisibility(View.GONE);
        emptyView.setVisibility(View.VISIBLE);
    }

    /**
     * Receive notification.
     *
     * @param id   notification id.
     * @param args object arg.
     */
    @Override
    public void didReceivedNotification(int id, Object... args) {
        if (id == NotificationCenter.S3_BUCKET_ADD_NEW_FILE) {
            getListFromS3Bucket();
        } else if (id == NotificationCenter.AWS_DOWNLOAD_LIST) {
            if (progressDialog != null && progressDialog.isShowing()) {
                progressDialog.dismiss();
            }
            setListView();
            swipeRefreshLayout.setEnabled(true);
        } else if (id == NotificationCenter.AWS_UPLOAD_COMPLETE) {
            dismissDialog();
            getListFromS3Bucket();
        } else if (id == NotificationCenter.TRANSFER_FAILED) {
            dismissDialog();
        } else if (id == NotificationCenter.S3_BUCKET_EXIST) {
            getListFromS3Bucket();
        } else if (id == NotificationCenter.S3_BUCKET_FILE_EXIST) {
            dismissDialog();
            Utility.displayToast(Constants.FILE_ALREADY_EXIST, Toast.LENGTH_SHORT);
        } else if (id == NotificationCenter.S3_BUCKET_FILE_NOT_EXIST) {
            if (file != null)
                getInstance().uploadFile(file);
        }
    }

    /**
     * Gets list of files from s3 bucket server.
     */
    public void getListFromS3Bucket() {

        runOnUiThread(() -> {
            if (Utility.isNetworkAvailable()) {
                progressDialog.show();
                getInstance().getListOfObjects();
            } else {
                Utility.messageAlertForCertainDuration(ListFilesActivity.this, Constants.ERROR_INTERNET_OFFLINE);
            }

        });
    }

    /**
     * Refresh List view on pull down.
     */
    @Override
    public void onRefresh() {
        getListFromS3Bucket();
        swipeRefreshLayout.setRefreshing(false);
    }

    /**
     * Sets adapter data in recycler view.
     */
    public void setListView() {
        recyclerView.setVisibility(View.VISIBLE);
        emptyView.setVisibility(View.GONE);
        new Handler(Looper.getMainLooper()).post(() -> filesAdapter.notifyDataSetChanged());
        if (getInstance().fileList().size() == Constants.LIST_SIZE_EMPTY) {
            setEmptyView();
        }
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
    }

    /**
     * open file manager.
     */
    public void openFileManager() {
        if (Utility.isNetworkAvailable()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!checkPermission()) {
                    ActivityCompat.requestPermissions(this, new String[]{READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE}, PERMISSION_REQUEST_CODE);
                } else {
                    Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                    intent.setType("file/*");
                    startActivityForResult(intent, PICKFILE_RESULT_CODE);
                }
            } else {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType("file/*");
                startActivityForResult(intent, PICKFILE_RESULT_CODE);
            }
        } else {
            Utility.messageAlertForCertainDuration(ListFilesActivity.this, Constants.ERROR_INTERNET_OFFLINE);
        }
    }

    /**
     * Show file progress.
     *
     * @param progress file progress.
     */
    public static void showProgress(int progress) {
        fileProgressDialog.setProgress(progress);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case PICKFILE_RESULT_CODE:
                if (resultCode == RESULT_OK) {
                    if (data != null) {
                        // Get the URI of the selected file
                        final Uri uri = data.getData();
                        try {
                            // Get the file path from the URI
                            final String path = FileUtils.getPath(this, uri);
                            progressDialog.show();
                            if (!path.isEmpty()) {
                                File file = new File(path);
                                copyFile(path, file.getName());
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
                break;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    /**
     * Copy file into bayun directory.
     *
     * @param inputPath file path.
     * @param fileName  file name.
     */
    private void copyFile(String inputPath, String fileName) {

        InputStream in = null;
        try {
            file = new File(getExternalFilesDir(
                    Environment.DIRECTORY_PICTURES), fileName);
            FileOutputStream outputStream = null;
            try {
                in = new FileInputStream(inputPath);
                outputStream = new FileOutputStream(file.getAbsolutePath());
                byte[] buffer = new byte[1024];
                int read;
                while ((read = in.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, read);
                }
                outputStream.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            getInstance().Exists(file.getName());

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    /**
     * Dismiss dialog.
     */
    public void dismissDialog() {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
        if (fileProgressDialog != null && fileProgressDialog.isShowing()) {
            fileProgressDialog.dismiss();
        }
    }

    @Override
    public void onItemClick(View childView, int position) {
        if (Utility.isNetworkAvailable()) {
            if (getInstance().fileList().size() != 0) {
                String fileName = getInstance().fileList().get(position).getFileName();
                Intent intent = new Intent(ListFilesActivity.this, ViewFileActivity.class);
                intent.putExtra(Constants.DOWNLOAD_FILE_NAME, fileName);
                startActivity(intent);
            }
        } else {
            Utility.messageAlertForCertainDuration(ListFilesActivity.this, Constants.ERROR_INTERNET_OFFLINE);
        }
    }

    @Override
    public void onItemLongPress(View childView, int position) {
        // TODO: Check this status active.
        if (Utility.isNetworkAvailable()) {
            if (BayunApplication.bayunCore.isEmployeeActive())
                deleteListItemDialog(position);
            else {
                Utility.displayToast(Constants.ERROR_USER_INACTIVE, Toast.LENGTH_LONG);
            }
        } else {
            Utility.messageAlertForCertainDuration(ListFilesActivity.this, Constants.ERROR_INTERNET_OFFLINE);
        }
    }

    /**
     * Delete file from S3 Bucket.
     *
     * @param position file index.
     */
    public void deleteListItemDialog(final int position) {
        String fileName = getInstance().fileList().get(position).getFileName();
        String message = "Delete" + " " + fileName + " " + "permanently?";
        Utility.decisionAlert(ListFilesActivity.this, getString(R.string.dialog_delete_title), message,
                getString(R.string.yes), getString(R.string.no), (dialog, which) -> {
            getInstance().deleteFileFromS3(getInstance().fileList().get(position).getFileName());
            getInstance().fileList().remove(position);
            filesAdapter.notifyItemRemoved(position);
            dialog.cancel();

        }, (dialog, which) -> dialog.cancel());
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case PERMISSION_REQUEST_CODE: {
                if (grantResults.length > 0) {
                    boolean permissionAccepted = grantResults[0] == PackageManager.PERMISSION_GRANTED;

                    if (permissionAccepted) {
                    } else {
                        Utility.displayToast("Permission Denied, You cannot access the fies .", Toast.LENGTH_SHORT);
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (shouldShowRequestPermissionRationale(READ_EXTERNAL_STORAGE)) {
                                showMessageOKCancel("You need this permissions to access the File Storage.",
                                        (dialog, which) -> {
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                                requestPermissions(new String[]{READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE},
                                                        PERMISSION_REQUEST_CODE);
                                            }
                                        });
                                return;
                            }
                        }
                    }
                }
                break;
            }
        }
    }

    /**
     * Show dialog with Ok button.
     *
     * @param message       Message for dialog box.
     * @param okListener    Listener for the ok button.
     */
    private void showMessageOKCancel(String message, DialogInterface.OnClickListener okListener) {
        new AlertDialog.Builder(ListFilesActivity.this)
                .setMessage(message)
                .setPositiveButton("OK", okListener)
                .setNegativeButton("Cancel", null)
                .create()
                .show();
    }

    /**
     * Check if required permissions are granted.
     *
     * @return  boolean for permissions granted.
     */
    private boolean checkPermission() {
        int result = ContextCompat.checkSelfPermission(getApplicationContext(), READ_EXTERNAL_STORAGE);
        int result1 = ContextCompat.checkSelfPermission(getApplicationContext(), WRITE_EXTERNAL_STORAGE);
        return result == PackageManager.PERMISSION_GRANTED && result1 == PackageManager.PERMISSION_GRANTED;
    }

    /**
     * creates an arraylist of the encryption policies to be shown in "choose encryption policy" dialog
     *
     * @return encryption policies arraylist
     */
    public ArrayList<String> getPolicies() {
        final ArrayList<String> encryptionPolicies = new ArrayList<>();
        // policies index in list is the same as their int value
        encryptionPolicies.add("None");
        encryptionPolicies.add("Default");
        encryptionPolicies.add("Company");
        encryptionPolicies.add("Employee");
        encryptionPolicies.add("Conversation");
        return encryptionPolicies;
    }

    // Remove/Add observers when activity changes state.
    @Override
    protected void onResume() {
        super.onResume();
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_FILE_EXIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);
    }

    @Override
    protected void onStop() {
        super.onStop();
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_BUCKET_FILE_EXIST);
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);
    }
}
