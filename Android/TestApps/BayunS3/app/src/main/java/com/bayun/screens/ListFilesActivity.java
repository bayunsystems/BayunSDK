package com.bayun.screens;

import android.app.AlertDialog;
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
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.app.NotificationCenter;
import com.bayun.aws.AWSS3Manager;
import com.bayun.screens.adapter.FilesAdapter;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.FileUtils;
import com.bayun.util.RecyclerItemClickListener;
import com.bayun.util.Utility;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;


public class ListFilesActivity extends AbstractActivity implements NotificationCenter.NotificationCenterDelegate, SwipeRefreshLayout.OnRefreshListener, RecyclerItemClickListener.OnItemClickListener {

    private RecyclerView recyclerView;
    private RecyclerView.Adapter filesAdapter;
    private RecyclerView.LayoutManager layoutManager;
    private SwipeRefreshLayout swipeRefreshLayout;
    private TextView emptyView;
    private static final int PICKFILE_RESULT_CODE = 1;
    private int refreshFlag = 0;
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
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_EXCEPTION);

        String companyName = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_COMPANY_NAME);
        String bucketName = Constants.S3_BUCKET_NAME_PREFIX + companyName;
        bucketName = bucketName.toLowerCase();
        BayunApplication.tinyDB.putString(Constants.S3_BUCKET_NAME, bucketName);
        if (Utility.isNetworkAvailable()) {
            AWSS3Manager.getInstance().createBucketOnS3(bucketName);
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
        fileProgressDialog = Utility.createFileProgressDialog(this, "uploading");
        recyclerView = (RecyclerView) findViewById(R.id.list_files_recycler_view);
        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipeRefreshLayout);
        emptyView = (TextView) findViewById(R.id.empty_view);
        recyclerView.setHasFixedSize(true);
        layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.addItemDecoration(new DividerItemDecoration(this));
        swipeRefreshLayout.setOnRefreshListener(this);
        filesAdapter = new FilesAdapter(ListFilesActivity.this, AWSS3Manager.getInstance().fileList());
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
        NotificationCenter.getInstance().removeObserver(this, NotificationCenter.S3_EXCEPTION);
    }

    /**
     * Handles Create new file Button Click.
     *
     * @param view : View as a TextView.
     */
    public void createNewFileClick(View view) {
        showDialogMoreOptions();
    }

    /**
     * Show Dialog for file picker.
     */
    public void showDialogMoreOptions() {
        final CharSequence sequences[] = new CharSequence[]{"Upload", "Logout"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT);
        builder.setItems(sequences, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (sequences[which].equals("Upload")) {
                    dialog.dismiss();
                    showDialogFilePicker();
                } else if (sequences[which].equals("Logout")) {
                    Intent intent = new Intent(ListFilesActivity.this, RegisterActivity.class);
                    startActivity(intent);
                    BayunApplication.tinyDB.clear();
                    BayunApplication.bayunCore.deauthenticate();
                    if (AWSS3Manager.getInstance().fileList() != null && AWSS3Manager.getInstance().fileList().size() != 0)
                        AWSS3Manager.getInstance().fileList().clear();

                }

            }
        });
        builder.show();
    }

    /**
     * Show Dialog for file picker.
     */
    public void showDialogFilePicker() {
        final CharSequence sequences[] = new CharSequence[]{"Create a New File", "Choose From Library"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT);
        builder.setTitle("Upload a File !");
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

                } else {
                    openFileManager();
                }

            }
        });
        builder.show();
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
                AWSS3Manager.getInstance().uploadFile(file);
        } else if (id == NotificationCenter.S3_EXCEPTION) {
            dismissDialog();
            Utility.displayToast("Amazon S3 Exception!!", Toast.LENGTH_SHORT);
        }
    }

    /**
     * Gets list of files from s3 bucket server.
     */
    public void getListFromS3Bucket() {

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (Utility.isNetworkAvailable()) {
                    if (refreshFlag == 0) {
                        progressDialog.show();
                    }
                    AWSS3Manager.getInstance().getListOfObjects();
                    Log.v("here", "new");
                } else {
                    Utility.messageAlertForCertainDuration(ListFilesActivity.this, Constants.ERROR_INTERNET_OFFLINE);
                }

            }
        });
    }

    /**
     * Refresh List view on pull down.
     */
    @Override
    public void onRefresh() {
        refreshFlag = 1;
        getListFromS3Bucket();
        swipeRefreshLayout.setRefreshing(false);
    }

    /**
     * Sets adapter data in recycler view.
     */
    public void setListView() {
        recyclerView.setVisibility(View.VISIBLE);
        emptyView.setVisibility(View.GONE);
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                filesAdapter.notifyDataSetChanged();
            }
        });
        if (AWSS3Manager.getInstance().fileList().size() == Constants.LIST_SIZE_EMPTY) {
            setEmptyView();
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
                            Log.v("file upload", "failed");
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
            AWSS3Manager.getInstance().Exists(file.getName());

        } catch (Exception e) {
            Log.e("tag", e.getMessage());
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
            if (AWSS3Manager.getInstance().fileList().size() != 0) {
                String fileName = AWSS3Manager.getInstance().fileList().get(position).getFileName();
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

        String fileName = AWSS3Manager.getInstance().fileList().get(position).getFileName();
        String message = "Delete" + " " + fileName + " " + "permanently?";
        Utility.decisionAlert(ListFilesActivity.this, getString(R.string.dialog_delete_title), message, getString(R.string.yes), getString(R.string.no), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                AWSS3Manager.getInstance().deleteFileFromS3(AWSS3Manager.getInstance().fileList().get(position).getFileName());
                AWSS3Manager.getInstance().fileList().remove(position);
                filesAdapter.notifyItemRemoved(position);
                dialog.cancel();

            }
        }, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {

                dialog.cancel();
            }
        });

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case PERMISSION_REQUEST_CODE:
                if (grantResults.length > 0) {
                    boolean permissionAccepted = grantResults[0] == PackageManager.PERMISSION_GRANTED;

                    if (permissionAccepted) {
                    } else {
                        Utility.displayToast("Permission Denied, You cannot access the fies .", Toast.LENGTH_SHORT);
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (shouldShowRequestPermissionRationale(READ_EXTERNAL_STORAGE)) {
                                showMessageOKCancel("You need this permissions to access the File Storage.",
                                        new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                                    requestPermissions(new String[]{READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE},
                                                            PERMISSION_REQUEST_CODE);
                                                }
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

    private void showMessageOKCancel(String message, DialogInterface.OnClickListener okListener) {
        new AlertDialog.Builder(ListFilesActivity.this)
                .setMessage(message)
                .setPositiveButton("OK", okListener)
                .setNegativeButton("Cancel", null)
                .create()
                .show();
    }

    private boolean checkPermission() {
        int result = ContextCompat.checkSelfPermission(getApplicationContext(), READ_EXTERNAL_STORAGE);
        int result1 = ContextCompat.checkSelfPermission(getApplicationContext(), WRITE_EXTERNAL_STORAGE);
        return result == PackageManager.PERMISSION_GRANTED && result1 == PackageManager.PERMISSION_GRANTED;
    }

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
