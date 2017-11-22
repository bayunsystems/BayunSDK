package com.bayun.screens.adapter;

import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.http.model.Contact;
import com.bayun.screens.ConversationViewActivity;
import com.bayun.screens.ListExtensionActivity;
import com.bayun.util.Constants;

public class ExtensionListAdapter extends RecyclerView.Adapter<ExtensionListAdapter.ViewHolder> {

    private static Context context;

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public static class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        // each data item is just a string in this case
        public TextView extension_number, extension_name;

        public ViewHolder(View v) {
            super(v);
            v.setOnClickListener(this);
            extension_number = (TextView) v.findViewById(R.id.extension_number);
            extension_name = (TextView) v.findViewById(R.id.extension_name);
        }

        // list item on click event
        public void onClick(final View view) {

            Intent intent = new Intent(context, ConversationViewActivity.class);
            Contact contact = ListExtensionActivity.extensionInfoArrayList.get(getPosition()).getContact();
            intent.putExtra(Constants.MESSAGE_NAME, contact.getFirstName() + " " + contact.getLastName());
            BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_EXTENSION_NUMBER, ListExtensionActivity.extensionInfoArrayList.get(getPosition()).getExtensionNumber());
            context.startActivity(intent);
        }

    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public ExtensionListAdapter(Context context) {
        ExtensionListAdapter.context = context;
    }

    // Create new views (invoked by the layout manager)
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent,
                                         int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.list_item_extension, parent, false);
        return new ViewHolder(view);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        holder.extension_number.setText(ListExtensionActivity.extensionInfoArrayList.get(position).getExtensionNumber());
        Contact contact = ListExtensionActivity.extensionInfoArrayList.get(position).getContact();
        holder.extension_name.setText(contact.getFirstName() + " " + contact.getLastName());
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        if (null != ListExtensionActivity.extensionInfoArrayList)
            return ListExtensionActivity.extensionInfoArrayList.size();
        else
            return 0;
    }
}