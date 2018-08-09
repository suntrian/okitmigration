package com.kingrein.okitmigration.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.kingrein.okitmigration.mapperSrc.UserSrcMapper;
import com.kingrein.okitmigration.util.RecordFile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
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

    @Value("${spring.record.entityFile}")
    private String entityFile;

    @Value("${spring.record.svnFile}")
    private String svnFile;

    @Value("${spring.record.ticketMapFile}")
    private String ticketMapFile;

    @Value("${spring.record.requirementMapFile}")
    private String requirementMapFile;

    @Value("${spring.record.taskMapFile}")
    private String taskMapFile;

    @Value("${spring.record.memoryMapFile}")
    private String memoryMapFile;

    @Value("${spring.record.testcaseMapFile}")
    private String testcaseMapFIle;

    @Value("${spring.record.forumMapFile}")
    private String forumMapFile;

    @Value("${spring.record.riskMapFile}")
    private String riskMapFile;

    @Value("${spring.record.questionMapFile}")
    private String questionMapFile;

    @Value("${spring.record.workflowMapFile}")
    private String workflowMapFile;

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

    /**
     * 记录用户选择的人员对应关系，采用JSON格式存储，结构为
     *  [
     *      {
     *          src:{
     *              id: ***,
     *              name: ***,
     *              code: ***,
     *              unitid: ***,
     *              unitname: ***
     *          },
     *          dest:{
     *              id: ***,
     *              name: ***,
     *              code: ***,
     *              unitid: ***,
     *              unitname: ***
     *          }
     *      },
     *      {
     *
     *      }
     *  ]
     *
     * @param src
     * @param dest
     * @throws IOException
     */
    public void recordUserMap(Integer src, Integer dest) throws IOException {
        String filePath = new File(rootDir, userMapFile).toString();
        JsonArray json = recordFile.readRecordFileAsJsonArray(filePath);
        Map<String, Object> srcUser = userService.getSrcUser(src);
        Map<String, Object> destUser = userService.getDestUser(dest);
        JsonObject srcObj =  new JsonObject();
        JsonObject destObj = new JsonObject();
        srcObj.addProperty("id", (Number) srcUser.get("id"));
        srcObj.addProperty("name", (String) srcUser.get("name"));
        srcObj.addProperty("code", (String) srcUser.get("mobile"));
        srcObj.addProperty("unit_id", (Number) srcUser.get("unit_id"));
        srcObj.addProperty("unit_name", (String) srcUser.get("unitname"));
        destObj.addProperty("id", (Number) destUser.get("id"));
        destObj.addProperty("name", (String) destUser.get("name"));
        destObj.addProperty("code", (String) destUser.get("mobile"));
        destObj.addProperty("unit_id", (Number) destUser.get("unit_id"));
        destObj.addProperty("unit_name", (String) destUser.get("unitname"));
        JsonObject thisMap = new JsonObject();
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        //thisMap.addProperty("src", gson.toJson(srcObj));
        //thisMap.addProperty("dest", gson.toJson(srcObj));
        thisMap.add("src", srcObj);
        thisMap.add("dest", destObj);
        json.add(thisMap);
        recordFile.writeRecordFile( filePath ,json);
    }

    public void recordUserMap() throws IOException {
        String filePath = new File(rootDir, userMapFile).toString();
        Map<Integer, Integer> userMap = userService.getUserMap();
        JsonArray json = new JsonArray();
        Map<Integer, Map<String, Object>> srcUserMap = userService.listAllSrcUser();
        Map<Integer, Map<String, Object>> destUserMap= userService.listAllDestUser();
        JsonObject srcObj = new JsonObject();
        JsonObject destObj = new JsonObject();
        JsonObject item = new JsonObject();
        for (Integer srcId: userMap.keySet()){
            Map<String, Object> srcUser = srcUserMap.get(srcId);
            Map<String, Object> destUser = destUserMap.get(userMap.get(srcId));
            srcObj.addProperty("id", (Number) srcUser.get("id"));
            srcObj.addProperty("name", (String) srcUser.get("name"));
            srcObj.addProperty("code", (String) srcUser.get("mobile"));
            srcObj.addProperty("unit", (String) srcUser.get("unitname"));
            destObj.addProperty("id", (Number)destUser.get("id"));
            destObj.addProperty("name", (String) destUser.get("name"));
            destObj.addProperty("code", (String) destUser.get("mobile"));
            destObj.addProperty("unit", (String) destUser.get("unitname"));
            item.add("src", srcObj);
            item.add("dest", destObj);
            json.add(item);
            srcObj = new JsonObject();
            destObj = new JsonObject();
            item = new JsonObject();
        }
        recordFile.writeRecordFile(filePath, json);
    }

    public void recordUserMap(Object obj) throws IOException {
        recordFile.writeRecordFile( new File(rootDir, userMapFile).toString(), new GsonBuilder().setPrettyPrinting().create().toJson(obj) );
    }

    public JsonArray readUserMap() throws IOException {
        String filePath = new File(rootDir, userMapFile).toString();
        JsonArray json = recordFile.readRecordFileAsJsonArray(filePath);
        return json;
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
            obj.addProperty("parent", (Integer)project.get("father_id"));
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

    public void recordProjectMap() throws IOException {
        String projectMapFilePath = new File(rootDir, projectMapFile).toString();
        Map<Integer, Integer> projectMap = projectService.getProjectMap();

        Map<Integer, Map<String, Object>> srcProjectMap = projectService.listSrcProject(new ArrayList<>(projectMap.keySet()));
        Map<Integer, Map<String, Object>> destProjectMap = projectService.listDestProject(new ArrayList<>(projectMap.values()));
        JsonArray json = new JsonArray();
        JsonObject src = new JsonObject();
        JsonObject dest = new JsonObject();
        JsonObject item = new JsonObject();
        for (Integer srcId: projectMap.keySet()){
            Map<String, Object> srcProject = srcProjectMap.get(srcId);
            Map<String, Object> destProject = destProjectMap.get(projectMap.get(srcId));
            src.addProperty("id", (Number) srcProject.get("id"));
            src.addProperty("name", (String) srcProject.get("name"));
            src.addProperty("code", (String) srcProject.get("code"));
            dest.addProperty("id", (Number) destProject.get("id"));
            dest.addProperty("name", (String) destProject.get("name"));
            dest.addProperty("code", (String) destProject.get("code"));
            item.add("src", src);
            item.add("dest", dest);
            json.add(item);
            src = new JsonObject();
            dest = new JsonObject();
            item = new JsonObject();
        }
        recordFile.writeRecordFile(projectMapFilePath, json);
    }

    public JsonArray readProjectMap() throws IOException {
        String projectMapFilePath = new File(rootDir, projectMapFile).toString();
        return recordFile.readRecordFileAsJsonArray(projectMapFilePath);
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

    public void recordUnitMap() throws IOException {
        String filePath = new File(rootDir, unitMapFile).toString();
        Map<Integer, Integer> unitMap = userService.getUnitMap();
        Map<Integer, Map<String, Object>> srcUnitMap = userService.listAllSrcUnit();
        Map<Integer, Map<String, Object>> destUnitMap = userService.listAllDestUnit();
        JsonArray json = new JsonArray();
        JsonObject srcObj = new JsonObject();
        JsonObject destObj = new JsonObject();
        JsonObject item = new JsonObject();
        for (Integer srcId:  unitMap.keySet()) {
            Map<String, Object> srcUnit = srcUnitMap.get(srcId);
            Map<String, Object> destUnit = destUnitMap.get(unitMap.get(srcId));
            srcObj.addProperty("id", (Number) srcUnit.get("id"));
            srcObj.addProperty("name", (String) srcUnit.get("name"));
            destObj.addProperty("id", (Number) destUnit.get("id"));
            destObj.addProperty("name", (String) destUnit.get("name"));
            item.add("src", srcObj);
            item.add("dest", destObj);
            json.add(item);
            srcObj = new JsonObject();
            destObj = new JsonObject();
            item = new JsonObject();
        }
        recordFile.writeRecordFile(filePath, json);
    }

    public JsonArray readUnitMap() throws IOException {
        String filePath = new File(rootDir, unitMapFile).toString();
        JsonArray json = recordFile.readRecordFileAsJsonArray(filePath);
        return json;
    }

    public void recordSvnNode(Integer nodeId) throws IOException {
        String svnFilePath = new File(rootDir, svnFile).toString();
        recordFile.writeRecordFile(svnFilePath, nodeId.toString());
    }

    public Integer readSvnNode() throws IOException {
        String svnFilePath = new File(rootDir, svnFile).toString();
        String content =recordFile.readRecordFile(svnFilePath);
        if (content == null || "".equals(content.trim())) return null;
        return Integer.valueOf(content);
    }

    public void recordEntity(Object obj) throws IOException {
        String path = new File(rootDir, entityFile).toString();
        if (obj instanceof Map){
            recordFile.writeRecordFile(path, obj);
        }
    }

    /**
     * 记录缺陷的对应关系 格式如：
     *  {
     *      column:{
     *          src: {
     *              column_id: ***,
     *              column_name: ***,
     *              column_zh_name: ***
     *          },
     *          dest: {
     *              column_id: ***,
     *              column_name: ***,
     *              column_zh_name: ***
     *          }
     *      },
     *      type: {
     *
     *      },
     *      status: {
     *
     *      },
     *      category:{
     *
     *      }
     *  }
     *
     * @param obj
     * @throws IOException
     */
    public void recordTicketMap(Object obj) throws IOException {
        String ticketFilePath = new File(rootDir, ticketMapFile).toString();
        recordFile.writeRecordFile(ticketFilePath, obj);
    }

    public JsonObject readTicketMap() throws IOException {
        String ticketFilePath = new File(rootDir, ticketMapFile).toString();
        JsonObject object = recordFile.readRecordFileAsJsonObject(ticketFilePath);
        return object;
    }

    public void recordFormatMap(JsonObject formatMap) throws IOException {
        String formatFilePath = new File(rootDir, requirementMapFile).toString();
        recordFile.writeRecordFile(formatFilePath, formatMap);
    }

    public JsonObject readFormatMap() throws IOException {
        String formatFilePath = new File(rootDir, requirementMapFile).toString();
        JsonObject object = recordFile.readRecordFileAsJsonObject(formatFilePath);
        return object;
    }


    public void recordTestMap(JsonObject testMap) throws IOException {
        String testFilePath = new File(rootDir, testcaseMapFIle).toString();
        recordFile.writeRecordFile(testFilePath, testMap);
    }

    public JsonObject readTestMap() throws IOException {
        String testFilePath = new File(rootDir, testcaseMapFIle).toString();
        JsonObject object = recordFile.readRecordFileAsJsonObject(testFilePath);
        return object;
    }


    public void recordTaskMap(JsonObject taskMap) throws IOException {
        String taskFilePath = new File(rootDir, taskMapFile).toString();
        recordFile.writeRecordFile(taskFilePath, taskMap);
    }

    public JsonObject readTaskMap() throws IOException {
        String taskFilePath = new File(rootDir, taskMapFile).toString();
        JsonObject object = recordFile.readRecordFileAsJsonObject(taskFilePath);
        return object;
    }

    public void recordEventsMap(JsonObject eventsMap) throws IOException {
        String eventsFilePath = new File(rootDir, memoryMapFile).toString();
        recordFile.writeRecordFile(eventsFilePath, eventsMap);
    }

    public JsonObject readEventsMap() throws IOException {
        String eventsFilePath = new File(rootDir, memoryMapFile).toString();
        return recordFile.readRecordFileAsJsonObject(eventsFilePath );
    }

    public void recordForumMap(JsonObject forumMap) throws IOException {
        String forumFilePath = new File(rootDir, forumMapFile).toString();
        recordFile.writeRecordFile(forumFilePath, forumMap);
    }

    public JsonObject readForumMap() throws IOException {
        String forumFilePath = new File(rootDir, forumMapFile).toString();
        return recordFile.readRecordFileAsJsonObject(forumFilePath);
    }

    public void recordRiskMap(JsonObject riskMap) throws IOException {
        String riskFilePath = new File(rootDir, riskMapFile).toString();
        recordFile.writeRecordFile(riskFilePath, riskMap);
    }

    public JsonObject readRiskMap() throws IOException {
        String riskFilePath = new File(rootDir, riskMapFile).toString();
        return recordFile.readRecordFileAsJsonObject(riskFilePath);
    }

    public void recordQuestionMap(JsonObject questionMap) throws IOException {
        String questionFilePath = new File(rootDir, questionMapFile).toString();
        recordFile.writeRecordFile(questionFilePath, questionMap);
    }

    public JsonObject readQuestionMap() throws IOException {
        String questionFilePath = new File(rootDir, questionMapFile).toString();
        return recordFile.readRecordFileAsJsonObject(questionFilePath);
    }

    public void recordWorkflowMap(Map<String,String> workflowMap) throws IOException {
        String workflowFilePath = new File(rootDir, workflowMapFile).toString();
        recordFile.writeRecordFile(workflowFilePath, workflowMap);
    }

    public JsonObject readWorkflowMap() throws IOException {
        String workflowFilePath = new File(rootDir, workflowMapFile).toString();
        return readAsJsonObject(workflowFilePath);
    }

    public JsonArray readAsJsonArray(String path) throws IOException {
        return recordFile.readRecordFileAsJsonArray(path);
    }

    public JsonObject readAsJsonObject(String path) throws IOException {
        return recordFile.readRecordFileAsJsonObject(path);
    }

    public void writeObject(String path, Object object) throws IOException {
        recordFile.writeRecordFile(path, object);
    }

    public void clearRecord() {
        File fileDir = new File(rootDir);
        File[] subFiles =  fileDir.listFiles();
        for (File file: subFiles) {
            file.delete();
        }

    }
}
