package com.bayun.screens.adapter;

import androidx.recyclerview.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bayun.R;
import com.bayun_module.GroupMember;

import java.util.HashMap;
import java.util.List;

/**
 * Created by Akriti on 8/24/2017.
 */

public class GroupMemberAdapter extends RecyclerView.Adapter<GroupMemberAdapter.ViewHolder>{
    public static List<GroupMember> list;

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView employeeId;
        TextView companyName;

        ViewHolder(View v) {
            super(v);
            employeeId = (TextView) v.findViewById(R.id.employee_id_text);
            companyName = (TextView) v.findViewById(R.id.company_name_text);
        }
    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public GroupMemberAdapter(List<GroupMember> list) {
        GroupMemberAdapter.list = list;
    }

    // Create new views (invoked by the layout manager)
    @Override
    public GroupMemberAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        // create a new view
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.group_member_row_layout, parent, false);
        // set the view's size, margins, padding and layout parameters
        return new ViewHolder(v);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(GroupMemberAdapter.ViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element
        String companyName = list.get(position).companyName;
        String employeeId =  list.get(position).companyEmployeeId;
        holder.companyName.setText(companyName);
        holder.employeeId.setText(employeeId);
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        return list.size();
    }
}
