package com.bayun.screens.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.S3wrapper.SecureTransferUtility;
import com.bayun.app.BayunApplication;
import com.bayun.aws.model.GroupInfo;
import com.bayun.screens.activity.ViewGroupActivity;
import com.bayun.screens.adapter.GroupsAdapter;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.RecyclerItemClickListener;
import com.bayun.util.Utility;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Fragment to show joined groups for the user.
 *
 * Created by Akriti on 8/18/2017.
 */

public class MyGroupsFragment extends BaseFragment implements RecyclerItemClickListener.OnItemClickListener{

    private View view;
    private ArrayList<GroupInfo> myGroups;
    private RecyclerView recyclerView;
    private ArrayList<HashMap<String, String>> myGroupsArray;
    private RelativeLayout progressBar;

    private Handler.Callback getMyGroupsSuccessCallback = message -> {
        myGroupsArray = (ArrayList<HashMap<String, String>>) message.getData().getSerializable(Constants.MY_GROUPS_ARRAY);
        getActivity().runOnUiThread(() -> progressBar.setVisibility(View.GONE));

        myGroups = new ArrayList<>();
        for (HashMap<String, String> groupMap: myGroupsArray) {
            GroupInfo groupInfo = new GroupInfo();
            groupInfo.setGroupKey(groupMap.get("groupKey"));
            groupInfo.setId(groupMap.get("id"));
            groupInfo.setName(groupMap.get("name"));
            groupInfo.setType(groupMap.get("type"));

            myGroups.add(groupInfo);
        }
        new Handler(Looper.getMainLooper()).post((new Runnable() {
            @Override
            public void run() {
                if (myGroups == null || myGroups.size() == 0) {
                    setUpEmptyView();
                }
                else {
                    setUpListView();
                    GroupsAdapter groupsAdapter = new GroupsAdapter(myGroups);
                    RecyclerView.LayoutManager mLayoutManager = new LinearLayoutManager(getActivity());
                    recyclerView.setLayoutManager(mLayoutManager);
                    recyclerView.setItemAnimator(new DefaultItemAnimator());
                    recyclerView.addItemDecoration(new DividerItemDecoration(getActivity()));
                    groupsAdapter.notifyDataSetChanged();
                    recyclerView.setAdapter(groupsAdapter);
                }
            }
        }));

        return false;
    };

    private Handler.Callback deleteGroupSuccessCallback = message -> {
        getActivity().runOnUiThread(() -> {
            updateRecyclerView();
            Utility.displayToast("Group Deleted Successfully.", Toast.LENGTH_LONG);
        });
        return false;
    };

    public MyGroupsFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        view =  inflater.inflate(R.layout.fragment_tab_layout, container, false);
        progressBar = (RelativeLayout) view.findViewById(R.id.progressBar);
        recyclerView = (RecyclerView) view.findViewById(R.id.fragment_tab_layout_recycler_view);
        recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(getActivity(), this));
        updateRecyclerView();
        return view;
    }

    public void updateRecyclerView() {
        getMyGroups();
    }

    /**
     * get joined groups through BayunCore
     */
    public void getMyGroups() {
        progressBar.setVisibility(View.VISIBLE);
        BayunApplication.bayunCore.getMyGroups(getMyGroupsSuccessCallback,
                Utility.getDefaultFailureCallback(getActivity(), progressBar));
    }

    /**
     * sets empty view
     */
    private void setUpEmptyView() {
        getActivity().runOnUiThread(() -> {
            view.findViewById(R.id.fragment_tab_layout_empty_view).setVisibility(View.VISIBLE);
            view.findViewById(R.id.fragment_tab_layout_recycler_view).setVisibility(View.GONE);
        });
    }

    /**
     * Sets adapter data in recycler view.
     */
    private void setUpListView() {
        getActivity().runOnUiThread(() -> {
            view.findViewById(R.id.fragment_tab_layout_empty_view).setVisibility(View.GONE);
            view.findViewById(R.id.fragment_tab_layout_recycler_view).setVisibility(View.VISIBLE);
        });
    }

    @Override
    public void onItemClick(View childView, int position) {
        String groupId = myGroups.get(position).getId();
        SecureTransferUtility.setGroupId(groupId);
        BayunApplication.tinyDB.putInt(Constants.SHARED_PREFERENCES_OLD_ENCRYPTION_POLICY_ON_DEVICE,
                SecureTransferUtility.getEncryptionPolicyOnDevice());
        SecureTransferUtility.setEncryptionPolicyOnDevice(BayunApplication.bayunCore.ENCRYPTION_POLICY_GROUP);

        Intent intent = new Intent(getActivity(), ViewGroupActivity.class);
        String groupName = myGroups.get(position).getName();
        intent.putExtra(Constants.SHARED_PREFERENCES_GROUP_NAME, groupName);
        startActivity(intent);
    }

    @Override
    public void onItemLongPress(View childView, int position) {
        if (Utility.isNetworkAvailable()) {
            if (BayunApplication.bayunCore.isEmployeeActive())
                deleteListItemDialog(position);
            else {
                Utility.displayToast(Constants.ERROR_USER_INACTIVE, Toast.LENGTH_LONG);
            }
        } else {
            Utility.messageAlertForCertainDuration(getActivity(), Constants.ERROR_INTERNET_OFFLINE);
        }
    }

    /**
     * Delete file from S3 Bucket.
     *
     * @param position file index.
     */
    public void deleteListItemDialog(final int position) {
        String message = "Are you sure you want to delete the Group?";
        Utility.decisionAlert(getActivity(), "Delete Group?",
                message, getString(R.string.yes), getString(R.string.no),
                (dialog, which) -> {
                    getActivity().runOnUiThread(() -> progressBar.setVisibility(View.VISIBLE));
                    BayunApplication.bayunCore.deleteGroup(myGroups.get(position).getId(),
                            deleteGroupSuccessCallback, Utility.getDefaultFailureCallback(getActivity(),
                                    progressBar));
                    dialog.cancel();
                }, (dialog, which) -> dialog.cancel());
    }
}