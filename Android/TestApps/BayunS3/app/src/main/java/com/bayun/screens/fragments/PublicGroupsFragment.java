package com.bayun.screens.fragments;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.Toast;

import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.aws.model.GroupInfo;
import com.bayun.screens.adapter.GroupsAdapter;
import com.bayun.screens.helper.DividerItemDecoration;
import com.bayun.util.Constants;
import com.bayun.util.RecyclerItemClickListener;
import com.bayun.util.Utility;
import com.bayun_module.Group;

import java.util.ArrayList;

/**
 * Fragment to show available public groups for user.
 * <p>
 * Created by Akriti on 8/18/2017.
 */

public class PublicGroupsFragment extends BaseFragment {

    private View view;
    private RecyclerView recyclerView;
    private ArrayList<GroupInfo> unJoinedPublicGroups;
    private ArrayList<Group> unJoinedPublicGroupsArray;
    private RelativeLayout progressBar;

    public Handler.Callback getUnjoinedPublicGroupsSuccessCallback = message -> {
        unJoinedPublicGroupsArray = (ArrayList<Group>) message.getData().
                getSerializable(Constants.UNJOINED_GROUPS_ARRAY);
        getActivity().runOnUiThread(() -> progressBar.setVisibility(View.GONE));

        unJoinedPublicGroups = new ArrayList<>();
        for (Group groupMap : unJoinedPublicGroupsArray) {
            GroupInfo groupInfo = new GroupInfo();
            groupInfo.setGroupKey(groupMap.groupKey);
            groupInfo.setId(groupMap.groupId);
            groupInfo.setName(groupMap.groupName);
            groupInfo.setType(groupMap.groupType);
            groupInfo.setCreatorCompanyName(groupMap.creatorCompanyName);
            groupInfo.setCreatorCompanyEmployeeId(groupMap.creatorCompanyEmployeeId);

            unJoinedPublicGroups.add(groupInfo);
        }
        new Handler(Looper.getMainLooper()).post((new Runnable() {
            @Override
            public void run() {
                if (unJoinedPublicGroups == null || unJoinedPublicGroups.size() == 0) {
                    setUpEmptyView();
                } else {
                    setUpListView();
                    GroupsAdapter groupsAdapter = new GroupsAdapter(unJoinedPublicGroups);
                    RecyclerView.LayoutManager mLayoutManager =
                            new LinearLayoutManager(getActivity());
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
        getActivity().runOnUiThread(() -> progressBar.setVisibility(View.GONE));
        Utility.displayToast("Group Joined.", Toast.LENGTH_LONG);
        updateRecyclerView();

        return false;
    };

    public PublicGroupsFragment() {
        // Required empty public constructor
    }

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

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        view = inflater.inflate(R.layout.fragment_tab_layout, container, false);
        progressBar = (RelativeLayout) view.findViewById(R.id.progressBar);
        recyclerView = (RecyclerView) view.findViewById(R.id.fragment_tab_layout_recycler_view);
        recyclerView
                .addOnItemTouchListener(
                        new RecyclerItemClickListener(getActivity(), recyclerView,
                                                      new RecyclerItemClickListener.ClickListener() {
                                                          @Override
                                                          public void onItemClick(View view,
                                                                                  int position) {
                                                              Utility.decisionAlert(getActivity(),
                                                                                    "Join group",
                                                                                    "Do you want " +
                                                                                            "to join this group?",
                                                                                    getString(
                                                                                            R.string.yes),
                                                                                    getString(
                                                                                            R.string.no),
                                                                                    (dialog,
                                                                                     which) -> {
                                                                                        getActivity()
                                                                                                .runOnUiThread(
                                                                                                        () -> progressBar
                                                                                                                .setVisibility(
                                                                                                                        View.VISIBLE));
                                                                                        String
                                                                                                groupId =
                                                                                                unJoinedPublicGroups
                                                                                                        .get(position)
                                                                                                        .getId();
                                                                                        String
                                                                                                creatorCompanyName =
                                                                                                unJoinedPublicGroups.get(position).getCreatorCompanyName();
                                                                                        String creatorCompanyEmployeeId = unJoinedPublicGroups.get(position).getCreatorCompanyEmployeeId();

                                                                                      /*  BayunApplication.bayunCore
                                                                                                .joinPublicGroup(
                                                                                                        groupId,
                                                                                                        creatorCompanyName,
                                                                                                        creatorCompanyEmployeeId,
                                                                                                        joinPublicGroupSuccessCallback,
                                                                                                        Utility.getDefaultFailureCallback(
                                                                                                                getActivity(),
                                                                                                                progressBar)); */

                                                                                        BayunApplication.bayunCore
                                                                                                .joinPublicGroup(
                                                                                                        groupId,
                                                                                                        creatorCompanyName,
                                                                                                        creatorCompanyEmployeeId,
                                                                                                        joinPublicGroupSuccessCallback,
                                                                                                        Utility.getDefaultFailureCallback(
                                                                                                                getActivity(),
                                                                                                                progressBar));
                                                                                        dialog.cancel();
                                                                                    },
                                                                                    (dialog,
                                                                                     which) -> dialog
                                                                                            .cancel());
                                                          }

                                                          @Override
                                                          public void onLongItemClick(View view,
                                                                                      int position) {

                                                          }
                                                      }));
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
        getActivity().runOnUiThread(() -> progressBar.setVisibility(View.VISIBLE));
        BayunApplication.bayunCore.getUnjoinedPublicGroups(getUnjoinedPublicGroupsSuccessCallback,
                                                           Utility.getDefaultFailureCallback(
                                                                   getActivity(), progressBar));
    }

    /*@Override
    public void onItemClick(View childView, int position) {
        Utility.decisionAlert(getActivity(), "Join group", "Do you want to join this group?",
                getString(R.string.yes), getString(R.string.no),
        (dialog, which) -> {
            getActivity().runOnUiThread(() -> progressBar.setVisibility(View.VISIBLE));
            String groupId = unJoinedPublicGroups.get(position).getId();
            BayunApplication.bayunCore.joinPublicGroup(groupId, joinPublicGroupSuccessCallback,
                    Utility.getDefaultFailureCallback(getActivity(), progressBar));
            dialog.cancel();
        }, (dialog, which) -> dialog.cancel());
    }

    @Override
    public void onItemLongPress(View childView, int position) {

    }*/
}