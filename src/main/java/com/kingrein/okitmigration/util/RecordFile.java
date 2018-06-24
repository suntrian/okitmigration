package com.kingrein.okitmigration.util;


import com.google.gson.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.*;

public class RecordFile {

    public String readRecordFile(String path) throws IOException {
        File file = new File(path);
        if (!file.exists()) return null;
        FileReader reader = new FileReader(file);
        char[] data = new char[((Long)file.length()).intValue()];
        int n = reader.read(data);
        if (n > 0) {
            return String.valueOf(data);
        }
        return "";
    }

    public JsonObject readRecordFileAsJsonObject(String path) throws IOException {
        JsonParser parser = new JsonParser();
        JsonObject object = null;
        try {
            object = (JsonObject) parser.parse(new FileReader(path));
        } catch (JsonSyntaxException e) {
            return new JsonObject();
        }
        return object;
    }

    public JsonArray readRecordFileAsJsonArray(String path) throws IOException {
        JsonParser parser = new JsonParser();
        JsonArray array = null;
        try {
            array = (JsonArray) parser.parse(new FileReader(path));
        } catch (FileNotFoundException e){
            return new JsonArray();
        } catch (JsonSyntaxException e) {
            return new JsonArray();
        }
        return array;
    }

    public void writeRecordFile(String path, Object object) throws IOException {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        this.writeRecordFile(path, gson.toJson(object));
    }

    public void writeRecordFile(String path, String data) throws IOException {
        FileWriter writer = new FileWriter(path);
        writer.write(data);
        writer.flush();
        writer.close();
    }

}
