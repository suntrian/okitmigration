package com.kingrein.okitmigration.util;


import com.google.gson.*;

import java.io.*;

public class RecordFile {

    public String readRecordFile(String path) throws IOException {
        File file = new File(path);
        if (!file.exists()) return null;
        FileReader reader = new FileReader(file);
        char[] data = new char[((Long)file.length()).intValue()];
        int n = reader.read(data);
        reader.close();
        if (n > 0) {
            return String.valueOf(data);
        }
        return "";
    }

    public JsonObject readRecordFileAsJsonObject(String path) throws IOException {
        JsonParser parser = new JsonParser();
        JsonObject object = null;
        FileReader reader = null;
        try {
            reader = new FileReader(path);
            object = (JsonObject) parser.parse(reader);
        } catch (FileNotFoundException e) {
            return new JsonObject();
        } catch (JsonSyntaxException e) {
            return new JsonObject();
        } finally {
            if (reader != null) {
                reader.close();
            }
        }
        return object;
    }

    public JsonArray readRecordFileAsJsonArray(String path) throws IOException {
        JsonParser parser = new JsonParser();
        JsonArray array = null;
        FileReader reader = null;
        try {
            reader = new FileReader(path);
            array = (JsonArray) parser.parse(reader);
        } catch (FileNotFoundException e) {
            return new JsonArray();
        } catch (JsonSyntaxException e) {
            return new JsonArray();
        } finally {
            if (reader != null) {
                reader.close();
            }
        }
        return array;
    }

    public void writeRecordFile(String path, Object object) throws IOException {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        this.writeRecordFile(path, gson.toJson(object));
    }

    public void writeRecordFile(String path, String data) throws IOException {
        File file = new File(path);
        if (!file.getParentFile().exists()){
            file.getParentFile().mkdirs();
        }
        FileWriter writer = new FileWriter(path);
        writer.write(data);
        writer.flush();
        writer.close();
    }

}
