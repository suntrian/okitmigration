package com.kingrein.okitmigration.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.kingrein.okitmigration.util.RecordFile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service
public class RecordService {

    @Value("${spring.record.rootDir}")
    private String rootDir;

    @Value("${spring.record.projectListFile}")
    private String projectListFile;

    @Value("${spring.record.projectMapFile}")
    private String projectMapFile;

    @Value("${spring.record.unitMapFile}")
    private String unitMapFile;

    @Value("${spring.record.userMapFile}")
    private String userMapFile;

    @Value("${spring.record.ticketMapFile")
    private String ticketMapFile;

    @Value("${spring.record.requirementMapFile")
    private String requirementMapFile;

    @Value("${spring.record.taskMapFile")
    private String taskMapFile;

    @Value("${spring.record.memoryMapFile")
    private String memoryMapFile;

    @Value("${spring.record.testcaseMapFile")
    private String testcaseMapFIle;

    @Autowired
    private UserService userService;
    @Autowired
    private ProjectService projectService;


    private RecordFile recordFile = new RecordFile();

    public void writeProjectListFile(String data) throws IOException {
        recordFile.writeRecordFile(new File(rootDir, projectListFile).toString(), data);
    }

    public void writeUnitMapFile(String data) throws IOException {
        recordFile.writeRecordFile( new File(rootDir, unitMapFile).toString(), data);
    }

    public void recordUserMap(Object obj) throws IOException {
        recordFile.writeRecordFile( new File(rootDir, userMapFile).toString(), new GsonBuilder().setPrettyPrinting().create().toJson(obj) );
    }


    /**
     * 记录用户选择的项目，采用JSON格式存储，结构为
     *  [
     *      {
     *          id:***,
     *          name:***
     *      },
     *      {
     *          id:***,
     *          name:***
     *      }
     *  ]
     * @param projectIds
     * @throws IOException
     */
    public void recordProjectList(List<Integer> projectIds) throws IOException {
        Map<Integer, Map<String , Object>> projects = projectService.listSrcProject(projectIds);
        JsonArray json = new JsonArray();
        JsonObject obj = new JsonObject();
        for (Integer id: projectIds){
            Map<String, Object> project = projects.get(id);
            obj.addProperty("id", id);
            obj.addProperty("name", (String) project.get("name"));
            obj.addProperty("state", "NOT IMPORTED");
            json.add(obj);
            obj = new JsonObject();
        }
        recordFile.writeRecordFile( new File(rootDir, projectListFile).toString(),json);
    }

    public JsonArray readProjectList() throws IOException {
        String projectListFilePath = new File(rootDir, projectListFile).toString();
        return recordFile.readRecordFileAsJsonArray(projectListFilePath);
    }

    public void recordProjectMap(Object obj) throws IOException {
        String projectMapFilePath = new File(rootDir, projectMapFile).toString();
        recordFile.writeRecordFile(projectMapFilePath, obj );
        return;
    }

    /**
     * 记录源数据库与目标数据库的单位映射关系，采用JSON格式存储，结构为
     * [
     *      {
     *          src:{
     *              id:***,
     *              name:***
     *          },
     *          dest:{
     *              id:***,
     *              name:***
     *          }
     *      },
     *      {
     *          src:{
     *
     *          },
     *          dest:{
     *
     *          }
     *      }
     * ]
     * @param src
     * @param dest
     * @return
     */
    public void recordUnitMap(Integer src, Integer dest) throws IOException {
        String filePath = new File(rootDir, unitMapFile).toString();
        JsonArray json = recordFile.readRecordFileAsJsonArray(filePath);
        Map<String, Object> srcUnit = userService.getSrcUnit(src);
        Map<String, Object> destUnit = userService.getDestUnit(dest);
        JsonObject srcObj =  new JsonObject();
        JsonObject destObj = new JsonObject();
        srcObj.addProperty("id", (Number) srcUnit.get("id"));
        srcObj.addProperty("name", (String) srcUnit.get("name"));
        destObj.addProperty("id", (Number) destUnit.get("id"));
        destObj.addProperty("name", (String) destUnit.get("name"));
        JsonObject thisMap = new JsonObject();
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        //thisMap.addProperty("src", gson.toJson(srcObj));
        //thisMap.addProperty("dest", gson.toJson(srcObj));
        thisMap.add("src", srcObj);
        thisMap.add("dest", destObj);
        json.add(thisMap);
        recordFile.writeRecordFile( filePath ,json);
    }

    public JsonArray readUnitMap() throws IOException {
        String filePath = new File(rootDir, unitMapFile).toString();
        JsonArray json = recordFile.readRecordFileAsJsonArray(filePath);
        return json;
    }

}
