package com.bayun.screens.activity;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;

import com.bayun.R;
import com.google.android.material.tabs.TabLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.viewpager.widget.ViewPager;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.app.BayunApplication;
import com.bayun.screens.fragments.MyGroupsFragment;
import com.bayun.screens.fragments.PublicGroupsFragment;
import com.bayun.util.Utility;
import com.bayun_module.BayunCore.GroupType;

import java.util.ArrayList;
import java.util.List;

/**
 * Activity to show list of joined groups and available public groups to join
 *
 * Created by Akriti on 8/23/2017.
 */
public class GroupsListActivity extends AppCompatActivity {

    private MyGroupsFragment myGroupsFragment;
    private PublicGroupsFragment publicGroupsFragment;
    private RelativeLayout progressBar;
    private Dialog dialog;
    private int selectedTabIndex;

    //create group callback
    private Handler.Callback createGroupSuccessCallback = message -> {
        runOnUiThread(() -> {
            progressBar.setVisibility(View.GONE);

            if (selectedTabIndex == 0) {
                myGroupsFragment.updateRecyclerView();
            }
            else if (selectedTabIndex == 1) {
                publicGroupsFragment.updateRecyclerView();
            }
            dialog.dismiss();

            Utility.displayToast("Group created successfully.", Toast.LENGTH_LONG);
        });

        return false;
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_groups_list);
        myGroupsFragment = new MyGroupsFragment();
        publicGroupsFragment = new PublicGroupsFragment();
        progressBar = (RelativeLayout) findViewById(R.id.progressBar);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("");
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        ViewPager viewPager = (ViewPager) findViewById(R.id.viewpager);
        setupViewPager(viewPager);
        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            }

            @Override
            public void onPageSelected(int position) {
                selectedTabIndex = position;
                if (position == 0) {
                    myGroupsFragment.updateRecyclerView();
                }
                else if (position == 1) {
                    publicGroupsFragment.updateRecyclerView();
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {
            }
        });

        TabLayout tabLayout = (TabLayout) findViewById(R.id.tabs);
        if (tabLayout != null) {
            tabLayout.setupWithViewPager(viewPager);
        }
    }

    //sets view pager adapter and adds fragments for tabs
    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());
        adapter.addFragment(myGroupsFragment, "My Groups");
        adapter.addFragment(publicGroupsFragment, "Join Public Groups");
        viewPager.setAdapter(adapter);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        menu.findItem(R.id.menu_group_manage).setVisible(false);
        menu.findItem(R.id.menu_create_group).setVisible(true);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == android.R.id.home) {
            onBackPressed();
        }
        else if (menuItem.getItemId() == R.id.menu_create_group) {
            showCreateGroupDialog();
        }
        return super.onOptionsItemSelected(menuItem);
    }

    @Override
    public void onBackPressed() {
        Intent intent = new Intent(GroupsListActivity.this, ListFilesActivity.class);
        super.onBackPressed();
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
    }

    /**
     * shows create group dialog
     */
    private void showCreateGroupDialog() {
        dialog = new Dialog(this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.spinner_dialog_layout);

        ((TextView)dialog.findViewById(R.id.dialog_title)).setText("New Group");
        ((EditText)dialog.findViewById(R.id.dialog_group_name)).setHint("Group Name");
        dialog.findViewById(R.id.dialog_employee_id).setVisibility(View.GONE);
        dialog.findViewById(R.id.dialog_group_name).requestFocus();
        Spinner spinner = (Spinner) dialog.findViewById(R.id.dialog_spinner);
        final ArrayList<String> groupType = new ArrayList<>();
        groupType.add("Public");
        groupType.add("Private");
        ArrayAdapter<String> dataAdapter = new ArrayAdapter<>(this,
                android.R.layout.simple_spinner_item, groupType);
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(dataAdapter);

        // setting click listeners
        dialog.findViewById(R.id.cancel_action).setOnClickListener(view -> dialog.dismiss());
        dialog.findViewById(R.id.ok_action).setOnClickListener(view -> {
            progressBar.bringToFront();
            progressBar.setVisibility(View.VISIBLE);
            Utility.hideKeyboard(dialog.findViewById(R.id.dialog_group_name));
            dialog.dismiss();

            String selectedGroupType = spinner.getSelectedItem().toString();
            String groupName = ((EditText)dialog.findViewById(R.id.dialog_group_name)).getText().toString();

            if (selectedGroupType.equalsIgnoreCase(GroupType.PUBLIC.toString())) {
                BayunApplication.bayunCore.createGroup(groupName, GroupType.PUBLIC,
                        createGroupSuccessCallback, Utility.getDefaultFailureCallback(GroupsListActivity.this,
                                progressBar));
            }
            else {
                BayunApplication.bayunCore.createGroup(groupName, GroupType.PRIVATE,
                        createGroupSuccessCallback, Utility.getDefaultFailureCallback(GroupsListActivity.this,
                                progressBar));
            }
        });

        dialog.show();
    }

    /**
     * adapter class for viewpager
     */
    private class ViewPagerAdapter extends FragmentPagerAdapter {
        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {
            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFragment(Fragment fragment, String title) {
            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mFragmentTitleList.get(position);
        }
    }
}
