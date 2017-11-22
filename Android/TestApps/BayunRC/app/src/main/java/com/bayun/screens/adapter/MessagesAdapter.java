package com.bayun.screens.adapter;

import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.screens.ConversationViewActivity;
import com.bayun.screens.ListMessagesActivity;
import com.bayun.util.Constants;

import java.util.Calendar;
import java.util.Date;

public class MessagesAdapter extends RecyclerView.Adapter<MessagesAdapter.ViewHolder> {

    private static Context context;

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public static class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        // each data item is just a string in this case
        public TextView messageSubject, messageSenderOrReceiver, messageCreationTime;
        public ImageView messageIcon;

        public ViewHolder(View v) {
            super(v);
            v.setOnClickListener(this);
            messageSubject = (TextView) v.findViewById(R.id.message_subject_text);
            messageSenderOrReceiver = (TextView) v.findViewById(R.id.extension_name);
            messageCreationTime = (TextView) v.findViewById(R.id.message_creation_time);
            messageIcon = (ImageView) v.findViewById(R.id.file_icon);
        }

        // list item on click event
        public void onClick(final View view) {
            ((ListMessagesActivity) context).onClickCalled(getPosition());
        }

    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public MessagesAdapter(Context context) {
        MessagesAdapter.context = context;
    }

    // Create new views (invoked by the layout manager)
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent,
                                         int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.list_item_view_files, parent, false);
        return new ViewHolder(v);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        String messageSenderOrReceiver;
        if (ListMessagesActivity.conversationInfoArrayList.get(position).getDirection().equalsIgnoreCase(Constants.INBOUND)) {
            holder.messageIcon.setImageResource(R.drawable.ico_received);
        } else {
            holder.messageIcon.setImageResource(R.drawable.ico_sent);
        }
        messageSenderOrReceiver = ListMessagesActivity.conversationInfoArrayList.get(position).getName();
        messageSenderOrReceiver = messageSenderOrReceiver.toUpperCase();
        String messageSubject = ListMessagesActivity.conversationInfoArrayList.get(position).getSubject();
        String lastModifiedTime = getLastModifiedTime(ListMessagesActivity.conversationInfoArrayList.get(position).getCreationTime());
        String decryptedText = BayunApplication.rcCryptManager.decryptText(messageSubject);
        holder.messageSubject.setText(decryptedText);
        holder.messageCreationTime.setText(lastModifiedTime);
        holder.messageSenderOrReceiver.setText(messageSenderOrReceiver);
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        if (null != ListMessagesActivity.conversationInfoArrayList)
            return ListMessagesActivity.conversationInfoArrayList.size();
        else
            return 0;
    }

    // Convert last modified date into time format.
    private String getLastModifiedTime(Date startDate) {
        String time = "";
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.MILLISECOND, -calendar.getTimeZone().getOffset(calendar.getTimeInMillis()));
        Date date = calendar.getTime();
        //milliseconds
        long timeElapsed = date.getTime() - startDate.getTime();
        long secondsInMilli = 1000;
        long minutesInMilli = secondsInMilli * 60;
        long hoursInMilli = minutesInMilli * 60;
        long daysInMilli = hoursInMilli * 24;
        long elapsedDays = timeElapsed / daysInMilli;
        timeElapsed = timeElapsed % daysInMilli;
        long elapsedHours = timeElapsed / hoursInMilli;
        timeElapsed = timeElapsed % hoursInMilli;
        long elapsedMinutes = timeElapsed / minutesInMilli;
        if (elapsedDays > 0) {
            time = elapsedDays + Constants.BLANK_SPACE + Constants.LAST_MODIFIED_TIME_DAY;
        } else if (elapsedHours > 0) {
            time = elapsedHours + Constants.BLANK_SPACE + Constants.LAST_MODIFIED_TIME_HOUR;
        } else if (elapsedMinutes > 0) {
            time = elapsedMinutes + Constants.BLANK_SPACE + Constants.LAST_MODIFIED_TIME_MINUTE;
        } else {
            time = Constants.LAST_MODIFIED_TIME_SECOND;
        }
        return time;
    }

}