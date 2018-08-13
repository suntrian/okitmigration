package com.kingrein.okitmigration.controller;


import com.google.gson.*;
import com.kingrein.okitmigration.model.ResultVO;
import com.kingrein.okitmigration.service.ProjectService;
import com.kingrein.okitmigration.service.RecordService;
import com.kingrein.okitmigration.service.UserService;
import com.kingrein.okitmigration.util.TreeNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.web.bind.annotation.*;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.io.IOException;
import java.util.*;

@RestController
@RequestMapping(value = "/project")
public class ProjectController {
    Logger logger = LoggerFactory.getLogger(ProjectController.class);

    private Map<Integer , String> entities = new HashMap<>();
    private Set<Integer> projectIdSelected;

    Gson gson = new GsonBuilder().create();

    @Resource
    private ProjectService projectService;
    @Resource
    private RecordService recordService;
    @Resource
    private UserService userService;

    @PostConstruct
    public void readMapFile() throws IOException {
        JsonArray projectSelected = recordService.readProjectList();
        for (JsonElement element: projectSelected) {
            Integer projectId = element.getAsJsonObject().get("id").getAsInt();
            if (!projectService.getProjectToImport().contains(projectId)) {
                projectService.getProjectToImport().add(projectId);
            }
        }
        JsonArray projectMap = recordService.readProjectMap();
        for (JsonElement element: projectMap){
            Integer srcProjectId = element.getAsJsonObject().get("src").getAsJsonObject().get("id").getAsInt();
            Integer destProjectId = element.getAsJsonObject().get("dest").getAsJsonObject().get("id").getAsInt();
            projectService.getProjectMap().put(srcProjectId, destProjectId);
        }

        JsonObject workflowMap = recordService.readWorkflowMap();
        for (String key: workflowMap.keySet()) {
            projectService.getWorkflowMap().put(key, workflowMap.get(key).getAsString());
        }

        entities = projectService.getEntities();
        entities.put(1, "项目配置管理");
        entities.put(2, "项目论坛");
        entities.put(3, "项目日志");
        entities.put(4, "项目风险");
        entities.put(5, "项目问题");
        entities.put(6, "项目测试用例");
        entities.put(7, "项目缺陷");
        entities.put(8, "项目需求");
        entities.put(9, "项目计划任务");
    }

    @RequestMapping(value = "/clear")
    public ResultVO clearRecord() {
        recordService.clearRecord();
        userService.setUserMap(new HashMap<>());
        userService.setUnitMap(new HashMap<>());
        projectService.setWorkflowMap(new HashMap<>());
        projectService.setProjectToImport(new ArrayList<>());
        projectService.setProjectMap(new HashMap<>());
        return new ResultVO("succeed");
    }

    @GetMapping(value = {"","/"})
    public List listSrcProject(){
        Map<Integer, Map<String, Object>> projects = projectService.listSrcProject();
        List<Map<String, Object>> results = new ArrayList<>();
        Map<String, Object> item = new HashMap<>();
        for (Integer projectId: projects.keySet()){
            Map<String, Object> project = projects.get(projectId);
            item.put("id", project.get("id"));
            item.put("name", project.get("name"));
            item.put("text", project.get("name"));
            item.put("project_code", project.get("project_code"));
            item.put("father_id", project.get("father_id"));
            results.add(item);
            item = new HashMap<>();
        }
        return results;
    }

    @GetMapping(value = "/dest")
    public List listDestProject(){
        Map<Integer, Map<String, Object>> projects = projectService.listDestProject();
        List<Map<String, Object>> results = new ArrayList<Map<String, Object>>(projects.values());
        for (Map<String, Object> r: results) {
            r.put("text", r.get("name"));
            r.put("parent", r.get("father_id")==null?"#":r.get("father_id"));
            r.put("state", new HashMap<String, Object>(){{
                put("opened", true);
            }});
        };
        return results;
    }

    @PostMapping(value = "/selected")
    public ResultVO selectProjects(@RequestBody ArrayList<Integer> ids) throws IOException {
        projectIdSelected = new HashSet<>();
        projectIdSelected.addAll(ids);
        projectService.setProjectToImport(ids);
        recordService.recordProjectList(ids);
        //recordService.recordProjectList(ids);
        return new ResultVO("succeed");
    }

    @PostMapping(value = "/")
    public ResultVO addProject(@RequestParam Integer id) throws Exception {
        projectService.addDestProject(id);
        return new ResultVO("succeed");
    }

    @GetMapping(value = "/selected")
    public List<Map<String , Object>> listProjectSelected() throws IOException {
        JsonArray json = recordService.readProjectList();
        List<Map<String, Object>> result = new ArrayList<>();
        Map<String, Object> item = new HashMap<>();
        for (JsonElement obj: json){
            item.put("id", obj.getAsJsonObject().get("id").getAsInt());
            item.put("text", obj.getAsJsonObject().get("name").getAsString());
            item.put("parent", obj.getAsJsonObject().get("parent")==null?"#":obj.getAsJsonObject().get("parent").getAsInt());
            item.put("state", new HashMap<String, Boolean>(){{
                put("opened", true);
            }});
            result.add(item);
            item = new HashMap<>();
        }
        return result;
    }

    public List<TreeNode<Map<String, Object>>> listProjectTree(){
        List<TreeNode<Map<String, Object>>> result = projectService.listSrcProjectTree();
        return result;
    }


    @PostMapping(value = "/map")
    public ResultVO setProjectMap(@RequestParam("src") Integer src,@RequestParam("dest") Integer dest) {
        projectService.getProjectMap().put(src, dest);
        return new ResultVO("succeed");
    }

    @GetMapping(value = "/map")
    public ResultVO getProjectMap(@RequestParam("src") Integer src) {
        return new ResultVO(projectService.getProjectMap().get(src));
    }

    @RequestMapping(value = "/map/save")
    public ResultVO saveProjectMap() throws IOException {
        //记录项目映射关系
        recordService.recordProjectMap();
        //导入产品表
        projectService.importProduct(projectService.getProjectToImport());
        //导入项目成员
        projectService.importProject(projectService.getProjectToImport());
        //导入所有附件文件
        projectService.importFileDbData();;
        return new ResultVO("succeed");
    }

    @GetMapping(value = "/entity")
    public Map<Integer, String> listEntities() {
        return entities;
    }

    @PostMapping(value = "/entity")
    public ResultVO selectEntities(@RequestBody ArrayList<Integer> ids) throws IOException {
        //Iterator<Map.Entry<Integer, String>> itor = entities.entrySet().iterator();
        Map<Integer, Integer> entityStatus = projectService.getEntityStatus();
        Map<Integer, String> selectedEntities = new HashMap<>();
        for (Integer id: ids) {
            entityStatus.put(id, 1);        //实体1,代表选择导入
            selectedEntities.put(id, entities.get(id));
        }
        recordService.recordEntity(selectedEntities);
        return new ResultVO("succeed");
    }

    @GetMapping(value = "/svn/node")
    public List<Map<String, Object>> listSvnNode(){
        List<Map<String, Object>> svnNodes = projectService.listSvnNode();
        try {
            Integer svnId = recordService.readSvnNode();
            if (svnId != null) {
                for (Map<String, Object> svn: svnNodes) {
                    if (svnId.equals(svn.get("id"))) {
                        svn.put("state", "selected");
                    }
                }
            }
        } catch (IOException e) {

        }
        return svnNodes;
    }

    @PostMapping(value = "/svn/node")
    public ResultVO setSvnNode(@RequestParam("id") Integer id) throws IOException {
        projectService.setSvnDestNode(id);
        recordService.recordSvnNode(id);
        return new ResultVO("succeed");
    }

    @GetMapping(value = "/ticket/column/{source}")
    public List<Map<String, Object>> listTicketEntityColumn(@PathVariable("source") String source) {
        if ("src".equals(source)) {
            return projectService.listSrcTicketEntityColumn();
        } else if ("dest".equalsIgnoreCase(source)) {
            return projectService.listDestTicketEntityColumn();
        }
        return new ArrayList<>();
    }

    @GetMapping(value = "/ticket/{standard}/{source}")
    public List<Map<String, Object>> listTicketStandard(@PathVariable String standard, @PathVariable String source) {
        switch (standard) {
            case "type":
                return projectService.listTicketType(source);
            case "status":
                return projectService.listTicketStatus(source);
            case "category":
                return projectService.listTicketCategory(source);
            case "source":
                return projectService.listTicketSource(source);
            case "severity":
                return projectService.listTicketSeverity(source);
            case "priority":
                return projectService.listTicketPriority(source);
            case "resolution":
                return projectService.listTicketResolution(source);
            case "frequency":
                return projectService.listTicketFrequency(source);
        }
        return new ArrayList<>();
    }

    @PostMapping("/ticket/{standard}")
    public ResultVO setStandardMap(@PathVariable String standard, @RequestParam("src") Integer src, @RequestParam("dest") Integer dest ){
        switch (standard) {
            case "column":
                projectService.getTicketColumnMap().put(src, dest);
                break;
            case "type":
                projectService.getTicketTypeMap().put(src, dest);
                break;
            case "status":
                projectService.getTicketStatusMap().put(src, dest);
                break;
            case "resolution":
                projectService.getTicketResolutionMap().put(src, dest);
                break;
            case "category":
                projectService.getTicketCategoryMap().put(src, dest);
                break;
            case "severity":
                projectService.getTicketSeverityMap().put(src, dest);
                break;
            case "priority":
                projectService.getTicketPriorityMap().put(src, dest);
                break;
            case "source":
                projectService.getTicketSourceMap().put(src,dest);
                break;
            case "frequency":
                projectService.getTicketFrequencyMap().put(src, dest);
                break;
        }
        return new ResultVO("succeed");
    }

    @GetMapping(value = "/{entity}/{source}")
    public List<Map<String, Object>> listEntityColumns(@PathVariable String entity, @PathVariable String source) {
        switch (entity) {
            case "format":
                return projectService.listFormatColumns(source);
            case "risk":
                return projectService.listRiskColumns(source);
            case "question":
                return projectService.listQuestionColumns(source);
            default:
                return new ArrayList<>();
        }
    }

    @GetMapping(value = "/{entity}/{standard}/{source}")
    public List<Map<String , Object>> listEntityStandard(@PathVariable String entity, @PathVariable String standard, @PathVariable String source) {
        List<Map<String, Object>> results = new ArrayList<>();
        try {
            switch (entity) {
                case "format":
                    results = projectService.listFormatStandard(standard, source);
                    break;
                case "test":
                    results  = projectService.listTestStandard(standard, source);
                    break;
                case "task":
                    results = projectService.listTaskStandard(standard, source);
                    break;
                case "events":
                    results = projectService.listEventsStandard(standard, source);
                    break;
                case "forum":
                    results = projectService.listForumStandard(standard, source);
                    break;
                case "question":
                    results = projectService.listQuestionStandard(standard, source);
                    break;
                case "risk":
                    results = projectService.listRiskStandard(standard, source);
                    break;
            }
        } catch (Exception e) {
            logger.error(e.getMessage());
        }
        return results;
    }

    @PostMapping(value = "/{entity}/{standard}")
    public ResultVO setEntityStandardMap(@PathVariable String entity, @PathVariable String standard, @RequestParam("src") Integer src, @RequestParam("dest") Integer dest) {
        switch (entity) {
            case "format":
                switch (standard) {
                    case "formatItemStatus":
                        projectService.getFormatItemStatusMap().put(src, dest);
                        break;
                    case "formatItemType":
                        projectService.getFormatItemTypeMap().put(src,dest);
                        break;
                    case "formatDifficulty":
                        projectService.getFormatDifficultyMap().put(src, dest);
                        break;
                    case "formatStability":
                        projectService.getFormatStabilityMap().put(src, dest);
                        break;
                    case "formatExpectedLevel":
                        projectService.getFormatExpectedLevelMap().put(src, dest);
                        break;
                    case "formatItemChange":
                        projectService.getFormatItemChangeMap().put(src, dest);
                        break;
                    case "formatAlteredStatus":
                        projectService.getFormatAlteredStatusMap().put(src, dest);
                        break;
                    case "formatDocType":
                        projectService.getFormatDocTypeMap().put(src, dest);
                        break;
                    case "formatPrivileges":
                        break;
                    case "formatChangeManner":
                        projectService.getFormatChangedMannerMap().put(src, dest);
                        break;
                }
                break;
            case "test":
                switch (standard) {
                    case "testActivityLevel":
                        projectService.getTestActivityLevelMap().put(src, dest);
                        break;
                    case "testActivityStatus":
                        projectService.getTestActivityStatusMap().put(src, dest);
                        break;
                    case "testCasePriority":
                        projectService.getTestCasePriorityMap().put(src,dest);
                        break;
                    case "testCaseStatus":
                        projectService.getTestCaseStatusMap().put(src, dest);
                        break;
                    case "testMethod":
                        projectService.getTestMethodMap().put(src, dest);
                        break;
                    case "testRule":
                        projectService.getTestRuleMap().put(src, dest);
                        break;
                    case "testStageCategory":
                        projectService.getTestStageCategoryMap().put(src, dest);
                        break;
                    case "testType":
                        projectService.getTestTypeMap().put(src, dest);
                        break;
                }
                break;
            case "task":
                switch (standard) {
                    case "taskType":
                        projectService.getTaskTypeMap().put(src, dest);
                        break;
                    case "taskStatus":
                        projectService.getTaskStatusMap().put(src, dest);
                        break;
                    case "taskLogType":
                        projectService.getTaskLogTypeMap().put(src, dest);
                        break;
                    case "taskSatisfaction":
                        projectService.getTaskSatisfactionMap().put(src, dest);
                        break;
                    case "taskImportant":
                        projectService.getTaskImportantMap().put(src, dest);
                        break;
                    case "taskCategory":
                        projectService.getTaskCategoryMap().put(src, dest);
                        break;
                }
                break;
            case "events":
                switch (standard){
                    case "memorabiliaType":
                        projectService.getEventsTypeMap().put(src, dest);
                        break;
                    case "eventsLevel":
                        projectService.getEventsLevelMap().put(src, dest);
                        break;
                }
                break;
            case "forum":
                switch (standard) {
                    case "questionPriority":
                        projectService.getReportQuestionPriorityMap().put(src, dest);
                        break;
                    case "questionStatus":
                        projectService.getReportQuestionStatusMap().put(src, dest);
                        break;
                    case "questionType":
                        projectService.getReportQuestionTypeMap().put(src, dest);
                        break;
                }
                break;
            case "question":
                switch (standard) {
                    case "questionCategory":
                        projectService.getQuestionCategoryMap().put(src, dest);
                        break;
                    case "questionManageStatus":
                        projectService.getQuestionManageStatusMap().put(src, dest);
                        break;
                    case "questionEvaluationLevel":
                        projectService.getQuestionEvaluationLevelMap().put(src, dest);
                        break;
                }
                break;
            case "risk":
                switch (standard) {
                    case "riskDisposeMethod":
                        projectService.getRiskDisposeMethodMap().put(src, dest);
                        break;
                    case "riskDisposeStatus":
                        projectService.getRiskDisposeStatusMap().put(src, dest);
                        break;
                    case "riskCategory":
                        projectService.getRiskStatusMap().put(src, dest);
                        break;
                    case "riskStatus":
                        projectService.getRiskStatusMap().put(src, dest);
                        break;
                }
                break;
        }
        return new ResultVO("succeed");
    }

    @GetMapping("/workflow/{source}")
    public List<Map<String, Object>> listWorkflow(@PathVariable String source) {
        return projectService.listWorkflow(source);
    }

    @PostMapping("/workflow")
    public ResultVO setWorkflowMap(@RequestParam String src, @RequestParam String dest) {
        projectService.getWorkflowMap().put(src, dest);
        return new ResultVO("succeed");
    }
    @GetMapping("/workflow")
    public ResultVO getWorkflowMap(@RequestParam String src) {
        return new ResultVO(projectService.getWorkflowMap().get(src));
    }

    @RequestMapping("/workflow/save")
    public ResultVO saveWorkflowMap() throws IOException {
        List<Map<String, Object>> srcWorkflows = projectService.listWorkflow("src");
        if (projectService.getWorkflowMap().size() != srcWorkflows.size()) {
            return new ResultVO("failed", false);
        }
        recordService.recordWorkflowMap(projectService.getWorkflowMap());
        return new ResultVO("succeed");
    }

    @RequestMapping("/ticket/doimport")
    public ResultVO doTicketImport() throws IOException {
        List<Integer> projectIds = projectService.getProjectToImport();
        JsonObject ticketMap = new JsonObject();
        ticketMap.add("column",gson.toJsonTree(projectService.getTicketColumnMap()));
        ticketMap.add("type", gson.toJsonTree(projectService.getTicketTypeMap()));
        ticketMap.add("status", gson.toJsonTree(projectService.getTicketStatusMap()));
        ticketMap.add("category", gson.toJsonTree(projectService.getTicketCategoryMap()));
        ticketMap.add("priority", gson.toJsonTree(projectService.getTicketPriorityMap()));
        ticketMap.add("resolution", gson.toJsonTree(projectService.getTicketResolutionMap()));
        ticketMap.add("severity",gson.toJsonTree(projectService.getTicketSeverityMap()));
        ticketMap.add("source", gson.toJsonTree(projectService.getTicketSourceMap()));
        ticketMap.add("frequency", gson.toJsonTree(projectService.getTicketFrequencyMap()));
        recordService.recordTicketMap(ticketMap);
        projectService.importTicket(projectIds);
        projectService.getEntityStatus().put(7, 2);         //2 for has imported successfully
        return new ResultVO("succeed");
    }


    @RequestMapping("/file/doimport")
    public ResultVO doFileImport() {
        projectService.importFileDbData();
        return new ResultVO("succeed");
    }

    @RequestMapping("/svn/doimport")
    public ResultVO doSvnImport() throws Exception {
        List<Integer> projectIds = projectService.getProjectToImport();
        projectService.importSvnDbData(projectIds);
        projectService.getEntityStatus().put(1, 2);
        return new ResultVO("succeed");
    }


    @RequestMapping("/format/doimport")
    public ResultVO doRequirementImport() throws IOException {
        List<Integer> projectIds = projectService.getProjectToImport();
        JsonObject formatMap = new JsonObject();
        formatMap.add("column", gson.toJsonTree(projectService.getFormatColumnMap()));
        formatMap.add("doctype", gson.toJsonTree(projectService.getFormatDocTypeMap()));
        formatMap.add("itemstatus", gson.toJsonTree(projectService.getFormatItemStatusMap()));
        formatMap.add("itemtype", gson.toJsonTree(projectService.getFormatItemTypeMap()));
        formatMap.add("difficulty", gson.toJsonTree(projectService.getFormatDifficultyMap()));
        formatMap.add("stability", gson.toJsonTree(projectService.getFormatStabilityMap()));
        formatMap.add("expectedlevel", gson.toJsonTree(projectService.getFormatExpectedLevelMap()));
        formatMap.add("itemchange", gson.toJsonTree(projectService.getFormatItemChangeMap()));
        formatMap.add("alteredstatus", gson.toJsonTree(projectService.getFormatAlteredStatusMap()));
        formatMap.add("changedmanner", gson.toJsonTree(projectService.getFormatChangedMannerMap()));
        recordService.recordFormatMap(formatMap);
        projectService.importRequirement(projectIds);
        projectService.getEntityStatus().put(8, 2);
        return new ResultVO("succeed");
    }

    @RequestMapping("/test/doimport")
    public ResultVO doTestcaseImport() throws IOException {
        List<Integer> projectIds = projectService.getProjectToImport();
        JsonObject testMap = new JsonObject();
        Gson gson = new GsonBuilder().create();
        testMap.add("activitylevel", gson.toJsonTree(projectService.getTestActivityLevelMap()));
        testMap.add("activitystatus", gson.toJsonTree(projectService.getTestActivityStatusMap()));
        testMap.add("casepriority", gson.toJsonTree(projectService.getTestCasePriorityMap()));
        testMap.add("casestatus", gson.toJsonTree(projectService.getTestCaseStatusMap()));
        testMap.add("method", gson.toJsonTree(projectService.getTestMethodMap()));
        testMap.add("testrule", gson.toJsonTree(projectService.getTestRuleMap()));
        testMap.add("stagecategory", gson.toJsonTree(projectService.getTestStageCategoryMap()));
        testMap.add("testype", gson.toJsonTree(projectService.getTestTypeMap()));
        recordService.recordTestMap(testMap);
        projectService.importTest(projectIds);
        projectService.getEntityStatus().put(6, 2);
        return new ResultVO("succeed");
    }

    @RequestMapping("/task/doimport")
    public ResultVO doTaskImport() throws IOException {
        List<Integer> projectIds = projectService.getProjectToImport();
        JsonObject taskMap = new JsonObject();

        taskMap.add("type", gson.toJsonTree(projectService.getTaskTypeMap()));
        taskMap.add("status", gson.toJsonTree(projectService.getTaskStatusMap()));
        taskMap.add("important", gson.toJsonTree(projectService.getTaskImportantMap()));
        taskMap.add("category", gson.toJsonTree(projectService.getTaskCategoryMap()));
        taskMap.add("satisfaction", gson.toJsonTree(projectService.getTaskSatisfactionMap()));
        taskMap.add(    "logtype", gson.toJsonTree(projectService.getTaskLogTypeMap()));
        recordService.recordTaskMap(taskMap);

        try {
            projectService.importTask(projectIds);
        } catch (DataAccessException e){
            Throwable cause = e.getCause();
            logger.error(e.getMessage());
            return new ResultVO(e.getMessage(), false);
        }
        projectService.getEntityStatus().put(9, 2);
        return new ResultVO("succeed");
    }

    @RequestMapping("/events/doimport")
    public ResultVO doEventsImport() throws IOException {
        List<Integer> projectIds = projectService.getProjectToImport();
        JsonObject eventsMap = new JsonObject();
        eventsMap.add("memorabiliatype", gson.toJsonTree(projectService.getEventsTypeMap()));
        eventsMap.add("eventslevel", gson.toJsonTree(projectService.getEventsLevelMap()));
        recordService.recordEventsMap(eventsMap);
        projectService.importEvents(projectIds);
        projectService.getEntityStatus().put(3, 2);
        return new ResultVO("succeed");
    }

    @RequestMapping("/forum/doimport")
    public ResultVO doForumImport() throws IOException {
        List<Integer> projectIds = projectService.getProjectToImport();
        JsonObject forumMap = new JsonObject();
        forumMap.add("priority", gson.toJsonTree(projectService.getReportQuestionPriorityMap()));
        forumMap.add("status", gson.toJsonTree(projectService.getReportQuestionStatusMap()));
        forumMap.add("type", gson.toJsonTree(projectService.getReportQuestionTypeMap()));
        recordService.recordForumMap(forumMap);
        projectService.importForum(projectIds);
        projectService.getEntityStatus().put(2, 2);
        return new ResultVO("succeed");
    }

    @RequestMapping("/question/doimport")
    public ResultVO doQuestionImort() throws IOException {
        List<Integer> projectIds = projectService.getProjectToImport();
        JsonObject questionMap = new JsonObject();
        questionMap.add("column", gson.toJsonTree(projectService.getQuestionColumnMap()));
        questionMap.add("category", gson.toJsonTree(projectService.getQuestionCategoryMap()));
        questionMap.add("status", gson.toJsonTree(projectService.getQuestionManageStatusMap()));
        questionMap.add("evaluationlevel", gson.toJsonTree(projectService.getQuestionEvaluationLevelMap()));
        recordService.recordQuestionMap(questionMap);
        projectService.importQuestion(projectIds);
        projectService.getEntityStatus().put(5, 2);
        return new ResultVO("succeed");
    }

    @RequestMapping("/risk/doimport")
    public ResultVO doRiskImort() throws IOException {
        List<Integer> projectIds = projectService.getProjectToImport();
        JsonObject riskMap = new JsonObject();
        riskMap.add("column", gson.toJsonTree(projectService.getRiskColumnMap()));
        riskMap.add("status", gson.toJsonTree(projectService.getRiskStatusMap()));
        riskMap.add("category", gson.toJsonTree(projectService.getRiskCategoryMap()));
        riskMap.add("disposemethod", gson.toJsonTree(projectService.getRiskDisposeMethodMap()));
        riskMap.add("disposestatus", gson.toJsonTree(projectService.getRiskDisposeStatusMap()));
        recordService.recordRiskMap(riskMap);
        projectService.importRisk(projectIds);
        projectService.getEntityStatus().put(4, 2);
        return new ResultVO("succeed");
    }


}
