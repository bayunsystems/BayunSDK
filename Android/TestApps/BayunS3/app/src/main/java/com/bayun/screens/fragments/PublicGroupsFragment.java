package com.bayun.screens.fragments;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.aws.model.GroupInfo;
import com.bayun.screens.adapter.GroupsAdapter;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.RecyclerItemClickListener;
import com.bayun.util.Utility;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Fragment to show available public groups for user.
 *
 * Created by Akriti on 8/18/2017.
 */

public class PublicGroupsFragment extends BaseFragment implements RecyclerItemClickListener.OnItemClickListener {

    private View view;
    private RecyclerView recyclerView;
    private ArrayList<GroupInfo> unJoinedPublicGroups;
    private ArrayList<HashMap<String, String>> unJoinedPublicGroupsArray;

    public Handler.Callback getUnjoinedPublicGroupsSuccessCallback = message -> {
        unJoinedPublicGroupsArray = (ArrayList<HashMap<String, String>>) message.getData().
                getSerializable(Constants.UNJOINED_GROUPS_ARRAY);
        dismissProgressDialog();

        unJoinedPublicGroups = new ArrayList<>();
        for (HashMap<String, String> groupMap: unJoinedPublicGroupsArray) {
            GroupInfo groupInfo = new GroupInfo();
            groupInfo.setGroupKey(groupMap.get("groupKey"));
            groupInfo.setId(groupMap.get("id"));
            groupInfo.setName(groupMap.get("name"));
            groupInfo.setType(groupMap.get("type"));

            unJoinedPublicGroups.add(groupInfo);
        }
        new Handler(Looper.getMainLooper()).post((new Runnable() {
            @Override
            public void run() {
                if (unJoinedPublicGroups == null || unJoinedPublicGroups.size() == 0) {
                    setUpEmptyView();
                }
                else {
                    setUpListView();
                    GroupsAdapter groupsAdapter = new GroupsAdapter(unJoinedPublicGroups);
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

    private Handler.Callback joinPublicGroupSuccessCallback = message -> {
        dismissProgressDialog();
        Utility.displayToast("Group Joined.", Toast.LENGTH_LONG);
        updateRecyclerView();

        return false;
    };

    /**
     * Sets empty view.
     */
    private void setUpEmptyView() {
        view.findViewById(R.id.fragment_tab_layout_empty_view).setVisibility(View.VISIBLE);
        view.findViewById(R.id.fragment_tab_layout_recycler_view).setVisibility(View.GONE);
    }

    /**
     * Sets adapter data in recycler view.
     */
    private void setUpListView() {
        view.findViewById(R.id.fragment_tab_layout_empty_view).setVisibility(View.GONE);
        view.findViewById(R.id.fragment_tab_layout_recycler_view).setVisibility(View.VISIBLE);
    }

    public PublicGroupsFragment() {
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
        recyclerView = (RecyclerView) view.findViewById(R.id.fragment_tab_layout_recycler_view);
        recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(getActivity(), this));
        updateRecyclerView();
        return view;
    }

    /**
     * Updates recyclerView
     */
    public void updateRecyclerView() {
        getUnjoinedPublicGroups();
    }

    /**
     * gets unjoined public groups through BayunCore
     */
    public void getUnjoinedPublicGroups() {
        showProgressDialog();
        BayunApplication.bayunCore.getUnjoinedPublicGroups(getUnjoinedPublicGroupsSuccessCallback,
                Utility.getDefaultFailureCallback(progressDialog));
    }

    @Override
    public void onItemClick(View childView, int position) {
        Utility.decisionAlert(getActivity(), "Join group", "Do you want to join this group?",
                getString(R.string.yes), getString(R.string.no),
        (dialog, which) -> {
            showProgressDialog();
            String groupId = unJoinedPublicGroups.get(position).getId();
            BayunApplication.bayunCore.joinPublicGroup(groupId, joinPublicGroupSuccessCallback,
                    Utility.getDefaultFailureCallback(progressDialog));
            dialog.cancel();
        }, (dialog, which) -> dialog.cancel());
    }

    @Override
    public void onItemLongPress(View childView, int position) {

    }
}