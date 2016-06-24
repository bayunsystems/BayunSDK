package com.bayun.screens.adapter;

import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bayun.R;
import com.bayun.app.BayunApplication;
import com.bayun.screens.ConversationViewActivity;
import com.bayun.screens.ListMessagesActivity;
import com.bayun.util.Constants;
import com.bayun.util.Utility;
import com.bayun_module.constants.BayunError;
import com.bayun_module.util.BayunException;

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
            Intent intent = new Intent(context, ConversationViewActivity.class);
            BayunApplication.tinyDB.putString(Constants.SHARED_PREFERENCES_EXTENSION_NUMBER, ListMessagesActivity.conversationInfos.get(getPosition()).getExtensionNumber());
            intent.putExtra(Constants.MESSAGE_NAME, ListMessagesActivity.conversationInfos.get(getPosition()).getName());
            context.startActivity(intent);

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
        if (ListMessagesActivity.conversationInfos.get(position).getDirection().equalsIgnoreCase(Constants.INBOUND)) {
            holder.messageIcon.setImageResource(R.drawable.ico_received);
        } else {
            holder.messageIcon.setImageResource(R.drawable.ico_sent);
        }
        messageSenderOrReceiver = ListMessagesActivity.conversationInfos.get(position).getName();
        messageSenderOrReceiver = messageSenderOrReceiver.toUpperCase();
        String messageSubject = ListMessagesActivity.conversationInfos.get(position).getSubject();
        String lastModifiedTime = getLastModifiedTime(ListMessagesActivity.conversationInfos.get(position).getCreationTime());

        if (BayunApplication.bayunCore.employeeStatus() != BayunApplication.bayunCore.BayunEmployeeStatusRegistered &&
                BayunApplication.bayunCore.employeeStatus() != BayunApplication.bayunCore.BayunEmployeeStatusCancelled) {
            try {
                String messageValue = BayunApplication.bayunCore.decryptText(messageSubject);
                holder.messageSubject.setText(messageValue);
            } catch (BayunException exception) {
                holder.messageSubject.setText(messageSubject);
                if (exception.getMessage().equalsIgnoreCase(BayunError.ERROR_ACCESS_DENIED))
                    Utility.displayToast(Constants.ACCESS_DENIED_ERROR, Toast.LENGTH_SHORT);
                else if (exception.getMessage().equalsIgnoreCase(BayunError.ERROR_USER_NOT_ACTIVE)) {
                    Utility.displayToast(Constants.ERROR_USER_INACTIVE, Toast.LENGTH_SHORT);
                } else {
                    Utility.displayToast(Constants.ERROR_SOME_THING_WENT_WRONG, Toast.LENGTH_SHORT);
                }
            }
        } else {
            holder.messageSubject.setText(messageSubject);
        }
        holder.messageCreationTime.setText(lastModifiedTime);
        holder.messageSenderOrReceiver.setText(messageSenderOrReceiver);
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        if (null != ListMessagesActivity.conversationInfos)
            return ListMessagesActivity.conversationInfos.size();
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