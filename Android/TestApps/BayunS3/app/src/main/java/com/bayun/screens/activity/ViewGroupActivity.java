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
import android.os.Message;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.appcompat.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.S3wrapper.SecureTransferUtility;
import com.bayun.app.BayunApplication;
import com.bayun.app.NotificationCenter;
import com.bayun.screens.adapter.FilesAdapter;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.FileUtils;
import com.bayun.util.RecyclerItemClickListener;
import com.bayun.util.Utility;
import com.bayun_module.BayunCore;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.HashMap;

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;
import static com.bayun.aws.AWSS3Manager.getInstance;

/**
 * Activity to show a group's files, and provide with group options.
 *
 * Created by Akriti on 8/22/2017.
 */

public class ViewGroupActivity extends AppCompatActivity implements SwipeRefreshLayout.OnRefreshListener,
        NotificationCenter.NotificationCenterDelegate, RecyclerItemClickListener.OnItemClickListener{

    private Toolbar toolbar;
    private String groupId;
    private RecyclerView recyclerView;
    private TextView emptyView;
    private RelativeLayout progressBar;
    private int refreshFlag = 0;
    private FilesAdapter filesAdapter;
    private SwipeRefreshLayout swipeRefreshLayout;
    private static final int PERMISSION_REQUEST_CODE = 200;
    private static final int PICK_FILE_RESULT_CODE = 1;
    private File file;

    //callback for add member to group api call
    private Handler.Callback addGroupMemberSuccessCallback = new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            runOnUiThread(() -> progressBar.setVisibility(View.GONE));
            Utility.displayToast("Member Added.", Toast.LENGTH_LONG);

            return false;
        }
    };

    //callback for removing a member from group api call
    private Handler.Callback removeMemberSuccessCallback = new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            runOnUiThread(() -> progressBar.setVisibility(View.GONE));
            Utility.displayToast("Member Removed.", Toast.LENGTH_LONG);

            return false;
        }
    };

    //callback for leaving a group api call
    private Handler.Callback leaveGroupSuccessCallback = new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            runOnUiThread(() -> progressBar.setVisibility(View.GONE));
            Utility.displayToast("Group Left.", Toast.LENGTH_LONG);
            startActivity(new Intent(ViewGroupActivity.this, GroupsListActivity.class));

            return false;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group);
        groupId = SecureTransferUtility.getGroupId();
        String bucketName = "bayun-group-" + groupId;
        bucketName = bucketName.toLowerCase();
        BayunApplication.tinyDB.putString(Constants.S3_BUCKET_NAME, bucketName);

        setUpViews();

        // add observer to notify activity
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AWS_UPLOAD_COMPLETE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_ADD_NEW_FILE);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.AWS_DOWNLOAD_LIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.TRANSFER_FAILED);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_EXIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_FILE_EXIST);
        NotificationCenter.getInstance().addObserver(this, NotificationCenter.S3_BUCKET_FILE_NOT_EXIST);

        if (Utility.isNetworkAvailable()) {
            getInstance().createBucketOnS3(bucketName);
        } else {
            Utility.messageAlertForCertainDuration(ViewGroupActivity.this, Constants.ERROR_INTERNET_OFFLINE);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!checkPermission()) {
                ActivityCompat.requestPermissions(this, new String[]{READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE},
                        PERMISSION_REQUEST_CODE);
            }
        }
    }

    /**
     * checks required permissions
     *
     * @return boolean if permissions are granted
     */
    private boolean checkPermission() {
        int result = ContextCompat.checkSelfPermission(getApplicationContext(), READ_EXTERNAL_STORAGE);
        int result1 = ContextCompat.checkSelfPermission(getApplicationContext(), WRITE_EXTERNAL_STORAGE);
        return result == PackageManager.PERMISSION_GRANTED && result1 == PackageManager.PERMISSION_GRANTED;
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
     * sets up views for the activity
     */
    private void setUpViews() {
        progressBar = (RelativeLayout) findViewById(R.id.progressBar);
        progressBar.setVisibility(View.VISIBLE);
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("");
        String groupName = getIntent().getStringExtra(Constants.SHARED_PREFERENCES_GROUP_NAME);
        if (groupName == null || groupName.isEmpty()) {
            groupName = "Untitled";
        }
        ((TextView)toolbar.findViewById(R.id.group_name)).setText(groupName);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipeRefreshLayout);
        swipeRefreshLayout.setOnRefreshListener(this);
        emptyView = (TextView) findViewById(R.id.empty_view);
        filesAdapter = new FilesAdapter(ViewGroupActivity.this, getInstance().fileList());
        recyclerView = (RecyclerView) findViewById(R.id.files_recycler_view);
        recyclerView.setHasFixedSize(true);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.addItemDecoration(new DividerItemDecoration(this));
        recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(this, this));
        recyclerView.setAdapter(filesAdapter);
        setListView();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        menu.findItem(R.id.menu_create_group).setVisible(false);
        menu.findItem(R.id.menu_group_manage).setVisible(true);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == android.R.id.home) {
            onBackPressed();
        }
        else if (menuItem.getItemId() == R.id.menu_group_manage) {
            showGroupOptionsDialog();
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        SecureTransferUtility.setEncryptionPolicyOnDevice(BayunApplication.tinyDB.getInt(
                Constants.SHARED_PREFERENCES_OLD_ENCRYPTION_POLICY_ON_DEVICE, 1));
        Intent intent = new Intent(ViewGroupActivity.this, GroupsListActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
    }

    /**
     * shows dialog for available group options
     */
    private void showGroupOptionsDialog() {
        final CharSequence sequences[] = new CharSequence[]{"Upload", "Group Members", "Add Member",
                "Remove Member", "Leave Group"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT);
        builder.setTitle("Options");
        builder.setItems(sequences, (dialog, which) -> {
            if (sequences[which].equals("Upload")) {
                showUploadFileDialog();
            }
            else if (sequences[which].equals("Group Members")) {
                Intent intent = new Intent(ViewGroupActivity.this, GroupMembersActivity.class);;
                startActivity(intent);
            }
            else if (sequences[which].equals("Add Member")) {
                showAddMemberDialog();
            }
            else if (sequences[which].equals("Remove Member")) {
                showRemoveMemberDialog();
            }
            else if (sequences[which].equals("Leave Group")) {
                DialogInterface.OnClickListener positiveCallBack = (dialog1, which1) -> {
                    BayunApplication.bayunCore.leaveGroup(groupId, leaveGroupSuccessCallback,
                            Utility.getDefaultFailureCallback(ViewGroupActivity.this, progressBar));
                };
                Utility.decisionAlert(this, null, "Are you sure you want to leave the group?", "Yes",
                        "Cancel", positiveCallBack, null);
            }
        });
        builder.show();
    }

    /**
     * shows dialog to add a member to group
     */
    private void showAddMemberDialog() {
        Dialog dialog = new Dialog(this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.spinner_dialog_layout);

        ((TextView)dialog.findViewById(R.id.dialog_title)).setText("Add Member");
        ((EditText)dialog.findViewById(R.id.dialog_group_name))
                .setText(BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_COMPANY_NAME));
        dialog.findViewById(R.id.dialog_group_name).requestFocus();
        ((EditText)dialog.findViewById(R.id.dialog_employee_id)).setHint("Member EmployeeId");
        dialog.findViewById(R.id.dialog_spinner).setVisibility(View.GONE);

        dialog.findViewById(R.id.cancel_action).setOnClickListener(v -> dialog.dismiss());
        dialog.findViewById(R.id.ok_action).setOnClickListener(v -> {
            String companyEmployeeId = ((EditText) dialog.findViewById(R.id.dialog_employee_id))
                    .getText().toString();
            String companyName = ((EditText)dialog.findViewById(R.id.dialog_group_name)).getText()
                    .toString();
            progressBar.setVisibility(View.VISIBLE);

            HashMap<String, String> parameters = new HashMap<>();
            parameters.put("companyEmployeeId", companyEmployeeId);
            parameters.put("companyName", companyName);
            parameters.put("groupId", groupId);

            BayunApplication.bayunCore.addGroupMember(parameters, addGroupMemberSuccessCallback,
                    Utility.getDefaultFailureCallback(ViewGroupActivity.this, progressBar));
            dialog.dismiss();
        });
        dialog.show();
    }


    /**
     * shows dialog to remove a member from the group
     */
    private void showRemoveMemberDialog() {
        Dialog dialog = new Dialog(this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.spinner_dialog_layout);

        ((TextView)dialog.findViewById(R.id.dialog_title)).setText("Remove Member");
        ((EditText)dialog.findViewById(R.id.dialog_group_name))
                .setText(BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_COMPANY_NAME));
        dialog.findViewById(R.id.dialog_group_name).requestFocus();
        ((EditText)dialog.findViewById(R.id.dialog_employee_id)).setHint("Member EmployeeId");
        dialog.findViewById(R.id.dialog_spinner).setVisibility(View.GONE);

        dialog.findViewById(R.id.cancel_action).setOnClickListener(v -> dialog.dismiss());
        dialog.findViewById(R.id.ok_action).setOnClickListener(v -> {
            String companyEmployeeId = ((EditText) dialog.findViewById(R.id.dialog_employee_id))
                    .getText().toString();
            String companyName = ((EditText)dialog.findViewById(R.id.dialog_group_name)).getText()
                    .toString();
            progressBar.setVisibility(View.VISIBLE);

            HashMap<String, String> parameters = new HashMap<>();
            parameters.put("companyEmployeeId", companyEmployeeId);
            parameters.put("companyName", companyName);
            parameters.put("groupId", groupId);

            BayunApplication.bayunCore.removeGroupMember(parameters, removeMemberSuccessCallback,
                    Utility.getDefaultFailureCallback(ViewGroupActivity.this, progressBar));
            dialog.dismiss();

        });
        dialog.show();
    }

    /**
     * Shows dialog for upload file options - upload or create a new file
     */
    private void showUploadFileDialog() {
        final CharSequence sequences[] = new CharSequence[] {"Create a New File", "Choose From Library"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT);
        builder.setTitle("Upload a File");
        builder.setItems(sequences, (dialog, which) -> {
            if (sequences[which].equals("Create a New File")) {
                if (Utility.isNetworkAvailable()) {
                    Intent intent = new Intent(ViewGroupActivity.this, CreateNewFileActivity.class);
                    startActivity(intent);
                } else {
                    Utility.messageAlertForCertainDuration(ViewGroupActivity.this, Constants.ERROR_INTERNET_OFFLINE);
                }
            }
            else {
                openFileManager();
            }
        });
        builder.show();
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
                    startActivityForResult(intent, PICK_FILE_RESULT_CODE);
                }
            } else {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType("file/*");
                startActivityForResult(intent, PICK_FILE_RESULT_CODE);
            }
        } else {
            Utility.messageAlertForCertainDuration(ViewGroupActivity.this, Constants.ERROR_INTERNET_OFFLINE);
        }
    }

    @Override
    public void onRefresh() {
        refreshFlag = 1;
        getListFromS3Bucket();
        swipeRefreshLayout.setRefreshing(false);
    }

    /**
     * Gets list of files from s3 bucket server.
     */
    public void getListFromS3Bucket() {
        runOnUiThread(() -> {
            if (Utility.isNetworkAvailable()) {
                progressBar.setVisibility(View.VISIBLE);
                getInstance().getListOfObjects();
            } else {
                Utility.messageAlertForCertainDuration(ViewGroupActivity.this, Constants.ERROR_INTERNET_OFFLINE);
            }

        });
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
            dismissDialog();
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
            if (file != null) {
                getInstance().uploadFile(file);
            }
        }
    }

    /**
     * Dismiss dialog.
     */
    public void dismissDialog() {
        runOnUiThread(() -> progressBar.setVisibility(View.GONE));
    }

    /**
     * Click listeners for the recyclerview items.
     *
     * @param childView View of the item that was clicked.
     * @param position  Position of the item that was clicked.
     */
    @Override
    public void onItemClick(View childView, int position) {
        if (Utility.isNetworkAvailable()) {
            if (getInstance().fileList().size() != 0) {
                String fileName = getInstance().fileList().get(position).getFileName();
                Intent intent = new Intent(ViewGroupActivity.this, ViewFileActivity.class);
                intent.putExtra(Constants.DOWNLOAD_FILE_NAME, fileName);
                startActivity(intent);
            }
        } else {
            Utility.messageAlertForCertainDuration(ViewGroupActivity.this, Constants.ERROR_INTERNET_OFFLINE);
        }
    }

    @Override
    public void onItemLongPress(View childView, int position) {
        if (Utility.isNetworkAvailable()) {
            if (BayunCore.isEmployeeActive())
                deleteListItemDialog(position);
            else {
                Utility.displayToast(Constants.ERROR_USER_INACTIVE, Toast.LENGTH_LONG);
            }
        } else {
            Utility.messageAlertForCertainDuration(ViewGroupActivity.this, Constants.ERROR_INTERNET_OFFLINE);
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
        Utility.decisionAlert(ViewGroupActivity.this, getString(R.string.dialog_delete_title), message,
            getString(R.string.yes), getString(R.string.no), (dialog, which) -> {
                getInstance().deleteFileFromS3(getInstance().fileList().get(position).getFileName());
                getInstance().fileList().remove(position);
                filesAdapter.notifyItemRemoved(position);
                dialog.cancel();
            }, (dialog, which) -> dialog.cancel());
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case PICK_FILE_RESULT_CODE:
                if (resultCode == RESULT_OK) {
                    if (data != null) {
                        // Get the URI of the selected file
                        final Uri uri = data.getData();
                        try {
                            // Get the file path from the URI
                            final String path = FileUtils.getPath(this, uri);
                            runOnUiThread(() -> progressBar.setVisibility(View.VISIBLE));
                            if (!path.isEmpty()) {
                                File file = new File(path);
                                copyFile(path, file.getName());
                            }
                        } catch (Exception e) {
                            Log.d("msg", "file upload - failed");
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
            Log.e("tag", e.getMessage());
        }

    }
}
