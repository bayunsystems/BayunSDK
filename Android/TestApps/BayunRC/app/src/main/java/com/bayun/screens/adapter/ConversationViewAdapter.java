package com.bayun.screens.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.screens.ConversationViewActivity;
import com.bayun.util.Constants;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

public class ConversationViewAdapter extends RecyclerView.Adapter<ConversationViewAdapter.ViewHolder> {

    private static Context context;
    private String extensionNumber = "";


    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public static class ViewHolder extends RecyclerView.ViewHolder {
        public TextView messageSubject, messageCreationTime;

        public ViewHolder(View v) {
            super(v);
            messageSubject = (TextView) v.findViewById(R.id.chat_layout_conversation_text);
            messageCreationTime = (TextView) v.findViewById(R.id.chat_layout_text_view_date_text);
        }
    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public ConversationViewAdapter(Context context) {
        ConversationViewAdapter.context = context;
        extensionNumber = BayunApplication.tinyDB.getString(Constants.SHARED_PREFERENCES_EXTENSION_NUMBER);
    }

    // Create new views (invoked by the layout manager)
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent,
                                         int viewType) {
        if (viewType == 1) {
            return new ViewHolder(LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.list_row_left, parent, false));
        }
        return new ViewHolder(LayoutInflater.from(parent.getContext())
                .inflate(R.layout.list_row_right, parent, false));
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        String messageSubject = ConversationViewActivity.messageInfoArrayList.get(position).getSubject();
        String lastModifiedTime = convertDate(ConversationViewActivity.messageInfoArrayList.get(position).getCreationTime());
        String decryptedText = BayunApplication.rcCryptManager.decryptText(messageSubject);
        holder.messageSubject.setText(decryptedText);
        holder.messageCreationTime.setText(lastModifiedTime);
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        if (null != ConversationViewActivity.messageInfoArrayList)
            return ConversationViewActivity.messageInfoArrayList.size();
        else
            return 0;
    }

    @Override
    public int getItemViewType(int position) {
        // Just as an example, return 0 or 2 depending on position
        // Note that unlike in ListView adapters, types don't have to be contiguous
        if (ConversationViewActivity.messageInfoArrayList.get(position).getDirection().equalsIgnoreCase(Constants.INBOUND)) {
            return 1;
        }
        return 2;
    }

    //Change date format.

    private static String convertDate(Date date) {
        long ts = System.currentTimeMillis();
        Date localTime = new Date(ts);
        Date fromGmt = new Date(date.getTime() + TimeZone.getDefault().getOffset(localTime.getTime()));
        DateFormat time = new SimpleDateFormat("EEE HH:mm a");
        return time.format(fromGmt);

    }
}