package com.bayun.screens.activity;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
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
    private ProgressDialog progressDialog;
    private Dialog dialog;
    private int selectedTabIndex;

    //create group callback
    private Handler.Callback createGroupSuccessCallback = message -> {
        if (progressDialog != null && progressDialog.isShowing()) {
            progressDialog.dismiss();
            if (selectedTabIndex == 0) {
                myGroupsFragment.updateRecyclerView();
            }
            else if (selectedTabIndex == 1) {
                publicGroupsFragment.updateRecyclerView();
            }
        }
        dialog.dismiss();

        Utility.displayToast("Group created successfully.", Toast.LENGTH_LONG);

        return false;
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_groups_list);
        myGroupsFragment = new MyGroupsFragment();
        publicGroupsFragment = new PublicGroupsFragment();

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
        startActivity(new Intent(GroupsListActivity.this, ListFilesActivity.class));
        super.onBackPressed();
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
            String selectedGroupType = spinner.getSelectedItem().toString();
            String groupName = ((EditText)dialog.findViewById(R.id.dialog_group_name)).getText().toString();
            progressDialog = Utility.createProgressDialog(this, "Please wait...");
            progressDialog.show();
            if (selectedGroupType.equalsIgnoreCase(GroupType.PUBLIC.toString())) {
                BayunApplication.bayunCore.createGroupWithName(groupName, GroupType.PUBLIC,
                        createGroupSuccessCallback, Utility.getDefaultFailureCallback(progressDialog));
            }
            else {
                BayunApplication.bayunCore.createGroupWithName(groupName, GroupType.PRIVATE,
                        createGroupSuccessCallback, Utility.getDefaultFailureCallback(progressDialog));
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
