package com.bayun.screens.adapter;

import androidx.recyclerview.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bayun.R;
import com.bayun.aws.model.GroupInfo;

import java.util.List;

/**
 * Created by Akriti on 8/18/2017.
 */

public class GroupsAdapter extends RecyclerView.Adapter<GroupsAdapter.ViewHolder> {
    private static List<GroupInfo> groupList;

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView groupName;

        ViewHolder(View v) {
            super(v);
            groupName = (TextView) v.findViewById(R.id.group_row_layout_name);
        }
    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public GroupsAdapter(List<GroupInfo> groupList) {
        GroupsAdapter.groupList = groupList;
    }

    // Create new views (invoked by the layout manager)
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        // create a new view
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.group_row_layout, parent, false);
        // set the view's size, margins, padding and layout parameters
        return new ViewHolder(v);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element
        String name = groupList.get(position).getName();
        if (name == null || name.isEmpty()) {
            name = "Untitled";
        }
        holder.groupName.setText(name);
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        return groupList.size();
    }

}
