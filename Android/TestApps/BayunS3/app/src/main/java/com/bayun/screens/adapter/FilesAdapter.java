package com.bayun.screens.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bayun.aws.AWSS3Manager;
import com.bayun.aws.model.FileInfo;
import com.bayun.util.Constants;
import com.bayun.R;

import java.util.List;

public class FilesAdapter extends RecyclerView.Adapter<FilesAdapter.ViewHolder> {
    private static List<FileInfo> fileInfoList;

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    static class ViewHolder extends RecyclerView.ViewHolder {
        // each data item is just a string in this case
        TextView fileNameTextView, fileDateTextView, fileSizeTextView;

        ViewHolder(View v) {
            super(v);
            fileNameTextView = v.findViewById(R.id.file_name_item);
            fileDateTextView = v.findViewById(R.id.file_name_date_item);
            fileSizeTextView = v.findViewById(R.id.file_name_size_item);
        }
    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public FilesAdapter(List<FileInfo> fileInfoList) {
        FilesAdapter.fileInfoList = fileInfoList;
    }

    // Create new views (invoked by the layout manager)
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent,
                                         int viewType) {
        // create a new view
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.list_item_view_files, parent, false);
        // set the view's size, margins, padding and layout parameters
        return new ViewHolder(v);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element
        if(AWSS3Manager.getInstance().fileList().size()!=0)
        {
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
                holder.fileSizeTextView.setText(Constants.BLANK_SPACE + size + Constants.BLANK_SPACE + Constants.FILE_SIZE_KB);

            } else {
                holder.fileSizeTextView.setText(Constants.BLANK_SPACE + size + Constants.BLANK_SPACE + Constants.FILE_SIZE_BYTE);
            }
        }

    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        return AWSS3Manager.getInstance().fileList().size();
    }

    //convert string into upper case
     private String convertStringIntoUppercase(String fileName) {
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