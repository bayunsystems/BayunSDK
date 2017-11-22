package com.bayun.screens.activity;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.S3wrapper.SecureTransferUtility;
import com.bayun.app.BayunApplication;
import com.bayun.screens.adapter.GroupMemberAdapter;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.RecyclerItemClickListener;
import com.bayun.util.Utility;
import com.bayun_module.BayunCore;

import java.util.ArrayList;
import java.util.HashMap;

import static com.bayun.aws.AWSS3Manager.getInstance;

/**
 * Activity shows all group members of the calling activity's group.
 *
 * Created by Akriti on 8/24/2017.
 */

public class GroupMembersActivity extends AppCompatActivity implements RecyclerItemClickListener.OnItemClickListener{

    private ProgressDialog progressDialog;
    private Toolbar toolbar;
    private TextView emptyView;
    private GroupMemberAdapter groupMemberAdapter;
    private RecyclerView recyclerView;
    private ArrayList<HashMap> membersList;
    private String groupId, groupName;

    private Handler.Callback getGroupByIdSuccessCallback = new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            if (progressDialog != null && progressDialog.isShowing()) {
                progressDialog.dismiss();
            }
            HashMap responseMap = (HashMap) message.getData().getSerializable(Constants.GET_GROUP);
            groupName = (String) responseMap.get("name");
            membersList = (ArrayList<HashMap>) responseMap.get("groupMembers");
            new Handler(Looper.getMainLooper()).post(() -> setListView());

            return false;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group_members);
        //get group id of the group in question
        groupId = SecureTransferUtility.getGroupId();

        progressDialog = Utility.createProgressDialog(this, "Please wait...");
        progressDialog.show();
        membersList = new ArrayList();
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("");
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        emptyView = (TextView) findViewById(R.id.empty_view);
        groupMemberAdapter = new GroupMemberAdapter(membersList);
        recyclerView = (RecyclerView) findViewById(R.id.files_recycler_view);
        recyclerView.setHasFixedSize(true);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.addItemDecoration(new DividerItemDecoration(this));
        recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(this, this));
        groupMemberAdapter = new GroupMemberAdapter(membersList);
        recyclerView.setAdapter(groupMemberAdapter);
        setListView();

        BayunApplication.bayunCore.getGroupById(groupId, getGroupByIdSuccessCallback,
                Utility.getDefaultFailureCallback(progressDialog));
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == android.R.id.home) {
            Intent intent = new Intent(GroupMembersActivity.this, ViewGroupActivity.class);
            intent.putExtra(Constants.SHARED_PREFERENCES_GROUP_NAME, groupName);
            startActivity(intent);
        }
        return super.onOptionsItemSelected(menuItem);
    }

    /**
     * Sets adapter data in recycler view.
     */
    public void setListView() {
        recyclerView.setVisibility(View.VISIBLE);
        emptyView.setVisibility(View.GONE);
        new Handler(Looper.getMainLooper()).post(() -> {
            groupMemberAdapter = new GroupMemberAdapter(membersList);
            recyclerView.setAdapter(groupMemberAdapter);
        });
        if (membersList == null || membersList.size() == 0) {
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

    @Override
    public void onItemClick(View childView, int position) {

    }

    @Override
    public void onItemLongPress(View childView, int position) {
        String companyName = (String) membersList.get(position).get("companyName");
        String employeeId = (String) membersList.get(position).get("companyEmployeeId");
        String message = "Do you want to remove " + employeeId + " from the group?";

        Utility.decisionAlert(GroupMembersActivity.this, getString(R.string.dialog_delete_title), message,
                getString(R.string.yes), getString(R.string.no), (dialog, which) -> {
                    //callback for removing a member from group api call
                    Handler.Callback removeMemberSuccessCallback = new Handler.Callback() {
                        @Override
                        public boolean handleMessage(Message message) {
                            if (progressDialog != null && progressDialog.isShowing()) {
                                progressDialog.dismiss();
                            }
                            Utility.displayToast("Member Removed.", Toast.LENGTH_LONG);
                            membersList.remove(position);
                            setListView();

                            return false;
                        }
                    };

                    progressDialog.show();
                    BayunApplication.bayunCore.removeGroupMember(employeeId, companyName, groupId,
                            removeMemberSuccessCallback, Utility.getDefaultFailureCallback(progressDialog));
                    //update recyclerview
                    dialog.cancel();
                },
                (dialog, which) -> dialog.cancel());
    }
}
