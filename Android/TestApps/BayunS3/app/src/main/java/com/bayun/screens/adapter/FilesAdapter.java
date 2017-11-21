package com.bayun.screens.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bayun.R;
import com.bayun.aws.AWSS3Manager;
import com.bayun.aws.model.FileInfo;
import com.bayun.util.Constants;

import java.util.List;

public class FilesAdapter extends RecyclerView.Adapter<FilesAdapter.ViewHolder> {

    public static List<FileInfo> fileInfoList;

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public static class ViewHolder extends RecyclerView.ViewHolder {
        // each data item is just a string in this case
        public TextView fileNameTextView, fileDateTextView, fileSizeTextView;

        public ViewHolder(View v) {
            super(v);
            fileNameTextView = (TextView) v.findViewById(R.id.file_name_item);
            fileDateTextView = (TextView) v.findViewById(R.id.file_name_date_item);
            fileSizeTextView = (TextView) v.findViewById(R.id.file_name_size_item);
        }
    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public FilesAdapter(Context context, List<FileInfo> fileInfoList) {
        FilesAdapter.fileInfoList = fileInfoList;
    }

    // Create new views (invoked by the layout manager)
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent,
                                         int viewType) {
        // create a new view
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.list_item_view_files, parent, false);
        // set the view's size, margins, padding and layout parameters
        ViewHolder vh = new ViewHolder(v);
        return vh;
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element
        if (AWSS3Manager.getInstance().fileList().size() != 0) {
            String fileName = fileInfoList.get(position).getFileName();
            String fileNameNew = convertStringIntoUppercase(fileName);
            if (fileNameNew.contains(Constants.FILE_EXTENSION)) {
                fileNameNew = fileNameNew.replace(Constants.FILE_EXTENSION, Constants.EMPTY_STRING).trim();
            }
            holder.fileNameTextView.setText(fileNameNew);
            holder.fileDateTextView.setText(Constants.BLANK_SPACE + fileInfoList.get(position).getLastModifiedTime());
            long size = fileInfoList.get(position).getSize();
            if (size > Constants.FILE_SIZE) {
                size = size / 1024;
                holder.fileSizeTextView.setText(Constants.BLANK_SPACE + String.valueOf(size) + Constants.BLANK_SPACE + Constants.FILE_SIZE_KB);

            } else {
                holder.fileSizeTextView.setText(Constants.BLANK_SPACE + String.valueOf(size) + Constants.BLANK_SPACE + Constants.FILE_SIZE_BYTE);
            }
        }

    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        return AWSS3Manager.getInstance().fileList().size();
    }

    //convert string into upper case
    public String convertStringIntoUppercase(String fileName) {
        StringBuffer res = new StringBuffer();
        String[] strArr = fileName.split(Constants.FILE_NAME_SPLIT_CHAR);
        for (String str : strArr) {
            char[] stringArray = str.trim().toCharArray();
            if (stringArray.length != 0)
                stringArray[0] = Character.toUpperCase(stringArray[0]);
            str = new String(stringArray);
            res.append(str).append(Constants.FILE_NAME_SPLIT_CHAR);
        }
        String file = res.toString();
        if (!(file.equalsIgnoreCase(Constants.EMPTY_STRING)))
            file = file.substring(Constants.START_INDEX, file.length() - 1);
        return file;
    }
}