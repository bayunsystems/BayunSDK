package com.bayun.screens.activity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.appcompat.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.RelativeLayout;
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

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Activity shows all group members of the calling activity's group.
 *
 * Created by Akriti on 8/24/2017.
 */

public class GroupMembersActivity extends AppCompatActivity implements RecyclerItemClickListener.OnItemClickListener{

    private Toolbar toolbar;
    private TextView emptyView;
    private GroupMemberAdapter groupMemberAdapter;
    private RecyclerView recyclerView;
    private ArrayList<HashMap> membersList;
    private String groupId, groupName;
    private RelativeLayout progressBar;

    private Handler.Callback getGroupByIdSuccessCallback = new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            runOnUiThread(() -> progressBar.setVisibility(View.GONE));
            HashMap responseMap = (HashMap) message.getData().getSerializable(Constants.GET_GROUP);
            groupName = (String) responseMap.get("name");
            membersList = (ArrayList<HashMap>) responseMap.get("groupMembers");
            setListView();

            return false;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group_members);
        //get group id of the group in question
        groupId = SecureTransferUtility.getGroupId();
        progressBar = (RelativeLayout) findViewById(R.id.progressBar);
        progressBar.setVisibility(View.VISIBLE);
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
                Utility.getDefaultFailureCallback(GroupMembersActivity.this, progressBar));
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
        new Handler(Looper.getMainLooper()).post(() -> {
            recyclerView.setVisibility(View.VISIBLE);
            emptyView.setVisibility(View.GONE);
            groupMemberAdapter = new GroupMemberAdapter(membersList);
            recyclerView.setAdapter(groupMemberAdapter);
            if (membersList == null || membersList.size() == 0) {
                setEmptyView();
            }
        });
    }

    /**
     * Sets empty view.
     */
    public void setEmptyView() {
        runOnUiThread(() -> {
            recyclerView.setVisibility(View.GONE);
            emptyView.setVisibility(View.VISIBLE);
        });
    }

    @Override
    public void onItemClick(View childView, int position) {

    }

    @Override
    public void onItemLongPress(View childView, int position) {
        String companyName = (String) membersList.get(position).get("companyName");
        String employeeId = (String) membersList.get(position).get("companyEmployeeId");
        String message = "Do you want to remove " + employeeId + " from the group?";

        Utility.decisionAlert(GroupMembersActivity.this, "Remove member?", message,
                getString(R.string.yes), getString(R.string.no), (dialog, which) -> {
                    //callback for removing a member from group api call
                    Handler.Callback removeMemberSuccessCallback = new Handler.Callback() {
                        @Override
                        public boolean handleMessage(Message message) {
                            runOnUiThread(() -> {
                                progressBar.setVisibility(View.GONE);
                                Utility.displayToast("Member Removed.", Toast.LENGTH_LONG);
                                membersList.remove(position);
                                setListView();
                            });
                            return false;
                        }
                    };

                    runOnUiThread(() -> progressBar.setVisibility(View.VISIBLE));

                    HashMap<String, String> parameters = new HashMap<>();
                    parameters.put("companyEmployeeId", employeeId);
                    parameters.put("companyName", companyName);
                    parameters.put("groupId", groupId);

                    BayunApplication.bayunCore.removeGroupMember(parameters, removeMemberSuccessCallback,
                            Utility.getDefaultFailureCallback(GroupMembersActivity.this,
                                    progressBar));
                    //update recyclerview
                    dialog.cancel();
                },
                (dialog, which) -> dialog.cancel());
    }
}
