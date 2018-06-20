package com.kingrein.okitmigration.util;


import com.google.gson.Gson;
import com.google.gson.JsonArray;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.*;

public class RecordFile {

    public JsonArray readRecordFile(String path) throws IOException {
        File file = new File(path);
        FileReader reader = new FileReader(file);
        char[] data = new char[((Long)file.length()).intValue()];
        int n = reader.read(data);
        if (n>0){
            return new Gson().fromJson(String.valueOf(data), JsonArray.class);
        }
        return new JsonArray();
    }

    public void writeRecordFile(String path, Object object) throws IOException {
        FileWriter writer = new FileWriter(path);
        writer.write(new Gson().toJson(object));
        writer.flush();
        writer.close();
    }

    public void writeRecordFile(String path, String data) throws IOException {
        FileWriter writer = new FileWriter(path);
        writer.write(data);
        writer.flush();
        writer.close();
    }

}
