package com.kingrein.okitmigration.service.impl;

import com.kingrein.okitmigration.mapperDest.ProjectDestMapper;
import com.kingrein.okitmigration.mapperSrc.ProjectSrcMapper;
import com.kingrein.okitmigration.service.ProjectService;
import com.kingrein.okitmigration.service.UserService;
import com.kingrein.okitmigration.util.TreeNode;
import com.sun.org.apache.regexp.internal.RE;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import javax.sql.DataSource;
import java.util.*;

@Service("projectService")
public class ProjectServiceImpl implements ProjectService {

    List<Integer> projectToImport = new ArrayList<>();
    Map<Integer, Integer> projectMap = new HashMap<>();
    Integer svnDestNode = 0;

    Map<Integer, String> entities = new HashMap<>();
    Map<Integer, Integer> entityStatus = new HashMap<>();

    //缺陷对应表
    Map<Integer, Integer> ticketColumnMap = new HashMap<>();
    Map<Integer, Integer> ticketTypeMap = new HashMap<>();
    Map<Integer, Integer> ticketStatusMap = new HashMap<>();
    Map<Integer, Integer> ticketSourceMap = new HashMap<>();
    Map<Integer, Integer> ticketSeverityMap = new HashMap<>();
    Map<Integer, Integer> ticketResolutionMap = new HashMap<>();
    Map<Integer, Integer> ticketPriorityMap = new HashMap<>();
    Map<Integer, Integer> ticketCategoryMap = new HashMap<>();
    Map<Integer, Integer> ticketFrequencyMap = new HashMap<>();
    //测试用例对应表
    Map<Integer, Integer> testActivityLevelMap = new HashMap<>();
    Map<Integer, Integer> testActivityStatusMap = new HashMap<>();
    Map<Integer, Integer> testCasePriorityMap = new HashMap<>();
    Map<Integer, Integer> testCaseStatusMap = new HashMap<>();
    Map<Integer, Integer> testMethodMap = new HashMap<>();
    Map<Integer, Integer> testRuleMap = new HashMap<>();
    Map<Integer, Integer> testStageCategoryMap = new HashMap<>();
    Map<Integer, Integer> testTypeMap = new HashMap<>();

    //需求对应表
    Map<Integer, Integer> formatColumnMap = new HashMap<>();
    Map<Integer, Integer> formatItemTypeMap = new HashMap<>();
    Map<Integer, Integer> formatDocTypeMap = new HashMap<>();
    Map<Integer, Integer> formatItemStatusMap = new HashMap<>();
    Map<Integer, Integer> formatItemChangeMap = new HashMap<>();
    Map<Integer, Integer> formatItemFileTypeMap = new HashMap<>();
    Map<Integer, Integer> formatAlteredStatusMap = new HashMap<>();
    Map<Integer, Integer> formatChangedMannerMap = new HashMap<>();
    Map<Integer, Integer> formatDifficultyMap = new HashMap<>();
    Map<Integer, Integer> formatExpectedLevelMap = new HashMap<>();
    Map<Integer, Integer> formatStabilityMap = new HashMap<>();

    //计划任务对应表
    Map<Integer, Integer> taskColumnMap = new HashMap<>();
    Map<Integer, Integer> taskTypeMap = new HashMap<>();
    Map<Integer, Integer> taskStatusMap = new HashMap<>();
    Map<Integer, Integer> taskLogTypeMap = new HashMap<>();
    Map<Integer, Integer> taskCategoryMap = new HashMap<>();
    Map<Integer, Integer> taskImportantMap = new HashMap<>();
    Map<Integer, Integer> taskSatisfactionMap = new HashMap<>();
    Map<Integer, Integer> taskFileTypeMap = new HashMap<>();

    //项目日志
    Map<Integer, Integer> eventsTypeMap = new HashMap<>();
    Map<Integer, Integer> eventsLevelMap = new HashMap<>();

    //项目论坛
    Map<Integer, Integer> reportQuestionPriorityMap = new HashMap<>();
    Map<Integer, Integer> reportQuestionStatusMap = new HashMap<>();
    Map<Integer, Integer> reportQuestionTypeMap = new HashMap<>();

    //项目问题
    Map<Integer, Integer> questionColumnMap = new HashMap<>();
    Map<Integer, Integer> questionCategoryMap = new HashMap<>();
    Map<Integer, Integer> questionManageStatusMap = new HashMap<>();
    Map<Integer, Integer> questionEvaluationLevelMap = new HashMap<>();

    //项目风险
    Map<Integer, Integer> riskColumnMap = new HashMap<>();
    Map<Integer, Integer> riskDisposeMethodMap = new HashMap<>();
    Map<Integer, Integer> riskDisposeStatusMap = new HashMap<>();
    Map<Integer, Integer> riskCategoryMap = new HashMap<>();
    Map<Integer, Integer> riskStatusMap = new HashMap<>();


    //实体映射表
    Map<Integer, Integer> reportQuestionMap = new HashMap<>();
    Map<Integer, Integer> eventsMap = new HashMap<>();
    Map<Integer, Integer> eventsCriticleMap = new HashMap<>();

    //流程
    Map<String, String> workflowMap = new HashMap<>();
    Map<Integer, Integer> workflowHistoryMap = new HashMap<>();

    @Autowired
    private UserService userService;

    @Autowired
    private ApplicationContext applicationContext;

    @Resource
    private ProjectSrcMapper projectSrcMapper;
    @Resource
    private ProjectDestMapper projectDestMapper;

    @Override
    public Map<Integer, Map<String, Object>>  listSrcProject(){
        return projectSrcMapper.listProject();
    }

    @Override
    public Map<Integer, Map<String, Object>> listDestProject(){
        return projectDestMapper.listProject();
    }

    @Override
    public Map<Integer, Map<String, Object>> listSrcProject(List<Integer> ids){
        return projectSrcMapper.listProjectByIds(ids);
    }

    @Override
    public Map<Integer, Map<String, Object>> listDestProject(List<Integer> ids) {
        return projectDestMapper.listProjectByIds(ids);
    }

    @Override
    public List<TreeNode<Map<String, Object>>> listSrcProjectTree(){
        Map<Integer, Map<String, Object>> projects = listSrcProject();
        return parseMap2Tree(projects);
    }

    @Override
    public Map<Integer, Map<String, Object>> listPageEntityColumnsByEntityColumnIds(List<Integer> columnIds, Integer entityId, String srcOrDest) {
        Map<String, Object> params = new HashMap<>();
        params.put("list", columnIds);
        params.put("entity_id", entityId);
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listPageEntityColumnsByColumnIds(params);
        } else {
            return projectDestMapper.listPageEntityColumnsByColumnIds(params);
        }
    }

    @Override
    public List<TreeNode<Map<String, Object>>> listDestProjectTree(){
        return parseMap2Tree(listDestProject());
    }

    @Override
    public List<Map<String, Object>> listSvnNode() {
        return projectDestMapper.listSvnNode();
    }

    @Override
    public List<Map<String, Object>> listSrcTicketEntityColumn(){
        return projectSrcMapper.listTicketPageEntityColumm();
    }

    @Override
    public List<Map<String, Object>> listDestTicketEntityColumn(){
        return projectDestMapper.listTicketPageEntityColumm();
    }

    @Override
    public List<Map<String, Object>> listTicketType(String srcOrDest) {
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listTicketType();
        } else if ("dest".equals(srcOrDest)) {
            return projectDestMapper.listTicketType();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String , Object>> listTicketStatus(String srcOrDest) {
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listTicketStatus();
        } else if ("dest".equals(srcOrDest)) {
            return projectDestMapper.listTicketStatus();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String, Object>> listTicketSource(String srcOrDest) {
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listTicketSource();
        } else if ("dest".equals(srcOrDest)) {
            return projectDestMapper.listTicketSource();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String, Object>> listTicketSeverity(String srcOrDest) {
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listTicketSeverity();
        } else if ("dest".equals(srcOrDest)) {
            return projectDestMapper.listTicketSeverity();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String, Object>> listTicketPriority(String srcOrDest) {
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listTicketPriority();
        } else if ("dest".equals(srcOrDest)) {
            return projectDestMapper.listTicketPriority();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String , Object>> listTicketCategory(String srcOrDest) {
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listTicketCategory();
        } else if ("dest".equals(srcOrDest)) {
            return projectDestMapper.listTicketCategory();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String , Object>> listTicketResolution(String srcOrDest) {
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listTicketResolution();
        } else if ("dest".equals(srcOrDest)) {
            return projectDestMapper.listTicketResolution();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String, Object>> listTicketFrequency(String srcOrDest) {
        if ("src".equals(srcOrDest)) {
            return projectSrcMapper.listTicketFrequency();
        } else if ("dest".equals(srcOrDest)) {
            return projectDestMapper.listTicketFrequency();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String, Object>> listFormatStandard(String standard, String srcOrDest) {
        switch (standard) {
            case "formatItemStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatItemStatus():projectDestMapper.listFormatItemStatus();
            case "formatItemType":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatItemType():projectDestMapper.listFormatItemType();
            case "formatDifficulty":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatDifficulty():projectDestMapper.listFormatDifficulty();
            case "formatStability":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatStability():projectDestMapper.listFormatStability();
            case "formatExpectedLevel":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatExpectedLevel():projectDestMapper.listFormatExpectedLevel();
            case "formatItemChange":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatItemChange():projectDestMapper.listFormatItemChange();
            case "formatAlteredStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatAlteredStatus():projectDestMapper.listFormatAlteredStatus();
            case "formatDocType":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatDocType():projectDestMapper.listFormatDocType();
            case "formatPrivileges":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatPrivileges():projectDestMapper.listFormatPrivileges();
            case "formatChangedManner":
                return "src".equals(srcOrDest)?projectSrcMapper.listFormatChangedManner():projectDestMapper.listFormatChangedManner();
        }
        return new ArrayList<>();
    }

    @Override
    public List<Map<String, Object>> listTestStandard(String standard, String srcOrDest){
        switch (standard) {
            case "testActivityLevel":
                return "src".equals(srcOrDest)?projectSrcMapper.listTestActivityLevel():projectDestMapper.listTestActivityLevel();
            case "testActivityStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listTestActivityStatus():projectDestMapper.listTestActivityStatus();
            case "testCasePriority":
                return "src".equals(srcOrDest)?projectSrcMapper.listTestCasePriority():projectDestMapper.listTestCasePriority();
            case "testCaseStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listTestCaseStatus():projectDestMapper.listTestCaseStatus();
            case "testMethod":
                return "src".equals(srcOrDest)?projectSrcMapper.listTestMethod():projectDestMapper.listTestMethod();
            case "testRule":
                return "src".equals(srcOrDest)?projectSrcMapper.listTestRule():projectDestMapper.listTestRule();
            case "testStageCategory":
                return "src".equals(srcOrDest)?projectSrcMapper.listTestStageCategory():projectDestMapper.listTestStageCategory();
            case "testType":
                return "src".equals(srcOrDest)?projectSrcMapper.listTestType():projectDestMapper.listTestType();
            default:
                return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> listTaskStandard(String standard, String srcOrDest){
        switch (standard){
            case "taskType":
                return "src".equals(srcOrDest)?projectSrcMapper.listSTaskType():projectDestMapper.listSTaskType();
            case "taskStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listSTaskStatus():projectDestMapper.listSTaskStatus();
            case "taskLogType":
                return "src".equals(srcOrDest)?projectSrcMapper.listSTaskLogType():projectDestMapper.listSTaskLogType();
            case "taskSatisfaction":
                return "src".equals(srcOrDest)?projectSrcMapper.listSTaskSatisfaction():projectDestMapper.listSTaskSatisfaction();
            case "taskImportant":
                return "src".equals(srcOrDest)?projectSrcMapper.listSTaskImportant():projectDestMapper.listSTaskImportant();
            case "taskCategory":
                return "src".equals(srcOrDest)?projectSrcMapper.listSTaskCategory():projectDestMapper.listSTaskCategory();
            default:
                return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> listEventsStandard(String standard, String srcOrDest){
        switch (standard){
            case "memorabiliaType":
                return "src".equals(srcOrDest)?projectSrcMapper.listSMemorabiliaType():projectDestMapper.listSMemorabiliaType();
            case "eventsLevel":
                return "src".equals(srcOrDest)?projectSrcMapper.listSEventsLevel():projectDestMapper.listSEventsLevel();
            default:
                return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> listForumStandard(String standard, String srcOrDest){
        switch (standard) {
            case "questionPriority":
                return "src".equals(srcOrDest)?projectSrcMapper.listSQuestionPriority():projectDestMapper.listSQuestionPriority();
            case "questionStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listSQuestionStatus():projectDestMapper.listSQuestionStatus();
            case "questionType":
                return "src".equals(srcOrDest)?projectSrcMapper.listSQuestionType():projectDestMapper.listSQuestionType();
            default:
                return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> listQuestionStandard(String standard, String srcOrDest){
        switch (standard){
            case "questionCategory":
                return "src".equals(srcOrDest)?projectSrcMapper.listSQuestionCategory():projectDestMapper.listSQuestionCategory();
            case "questionManageStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listSQuestionManageStatus():projectDestMapper.listSQuestionManageStatus();
            case "questionEvaluationLevel":
                return "src".equals(srcOrDest)?projectSrcMapper.listSQuestionEvaluationLevel():projectDestMapper.listSQuestionEvaluationLevel();
            default:
                return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> listRiskStandard(String standard, String srcOrDest) {
        switch (standard) {
            case "riskDisposeMethod":
                return "src".equals(srcOrDest)?projectSrcMapper.listSRiskDisposeMethod():projectDestMapper.listSRiskDisposeMethod();
            case "riskDisposeStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listSRiskDisposeStatus():projectDestMapper.listSRiskDisposeStatus();
            case "riskCategory":
                return "src".equals(srcOrDest)?projectSrcMapper.listSRiskCategory():projectDestMapper.listSRiskCategory();
            case "riskStatus":
                return "src".equals(srcOrDest)?projectSrcMapper.listSRiskStatus():projectDestMapper.listSRiskStatus();
            default:
                return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> listFormatColumns(String srcOrDest) {
        return "src".equals(srcOrDest)?projectSrcMapper.listFormatPageEntityColumn():projectDestMapper.listFormatPageEntityColumn();
    }

    @Override
    public List<Map<String, Object>> listRiskColumns(String srcOrDest) {
        return "src".equals(srcOrDest)?projectSrcMapper.listProjectRiskPageEntityColumn():projectDestMapper.listProjectRiskPageEntityColumn();
    }

    @Override
    public List<Map<String, Object>> listQuestionColumns(String srcOrDest) {
        return "src".equals(srcOrDest)?projectSrcMapper.listQuestionPageEntityColumn():projectDestMapper.listQuestionPageEntityColumn();
    }

    @Override
    public List<Map<String, Object>> listWorkflow(String srcOrDest) {
        return "src".equals(srcOrDest)?projectSrcMapper.listWorkflow():projectDestMapper.listWorkflow();
    }

    private List<TreeNode<Map<String, Object>>> parseMap2Tree(final Map<Integer, Map<String, Object>> itemMap) {
        List<TreeNode<Map<String, Object>>> roots = new ArrayList<>();
        Map<Integer, TreeNode> hasContained = new HashMap<>();
        while (!itemMap.isEmpty()) {
            Iterator<Map.Entry<Integer, Map<String, Object>>> iterator = itemMap.entrySet().iterator();
            while (iterator.hasNext()) {
                Map.Entry<Integer, Map<String, Object>> itemEntry = iterator.next();
                Integer itemId = itemEntry.getKey();
                Map<String, Object> itemData = itemEntry.getValue();
                Integer parentId = itemData.get("father_id") == null?null: (Integer) itemData.get("father_id");
                TreeNode<Map<String, Object>> node = new TreeNode<>(itemData);
                if (parentId == null){
                    roots.add(node);
                    hasContained.put(itemId, node);
                    iterator.remove();
                } else {
                    if (hasContained.containsKey(parentId)){
                        hasContained.get(parentId).addChild(node);
                        hasContained.put(itemId, node);
                        iterator.remove();
                    }
                }
            }
        }
        return roots;
    }

    @Transactional
    @Override
    public void addDestProject(Map<String, Object> project) throws Exception {
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();
        Integer srcProjectId = (Integer) project.get("id");

        project.put("father_id", project.get("father_id")==null?null: projectMap.get((Integer) project.get("father_id")));
        project.put("create_userid", project.get("create_userid")==null?null: userMap.get((Integer) project.get("create_userid")));
        project.put("leader_id", project.get("leader_id")== null?null: userMap.get((Integer) project.get("leader_id")));
        project.put("quality_leader_id", project.get("quality_leader_id")== null?null: userMap.get((Integer) project.get("quality_leader_id")));
        project.put("delete_person_id", project.get("delete_person_id")== null?null: userMap.get((Integer) project.get("delete_person_id")));
        project.put("chief_leader_id", project.get("chief_leader_id")== null?null: userMap.get((Integer) project.get("chief_leader_id")));
        project.put("officer_id", project.get("officer_id")== null?null: userMap.get((Integer) project.get("officer_id")));

        project.put("responsible_unit_id", project.get("responsible_unit_id")== null?null: unitMap.get((Integer) project.get("responsible_unit_id")));
        project.put("order_unit_id", project.get("order_unit_id")== null?null: unitMap.get((Integer) project.get("order_unit_id")));
        Integer count = projectDestMapper.addProject(project);
        if (count == 0) {
            throw new Exception("添加项目失败");
        }
        projectMap.put(srcProjectId, (Integer) project.get("id"));
    }

    @Transactional
    @Override
    public void addDestProject(Integer srcId) throws Exception {
        Map<String, Object> srcProject = projectSrcMapper.getProject(srcId);
        addDestProject(srcProject);
    }
    /**
     * 导入项目成员和项目成员权限，不含角色及角色权限
     * @param projectIds
     */
    @Transactional
    @Override
    public void importProject(List<Integer> projectIds) {
        Map<Integer, Integer> userMap = userService.getUserMap();

        List<Map<String, Object>> projectPersons = projectSrcMapper.listProjectPerson(projectIds);
        for (Map<String, Object> projectPerson: projectPersons) {
            projectPerson.put("project_id", projectMap.get ((Integer) projectPerson.get("project_id")));
            projectPerson.put("user_id", userMap.get((Integer) projectPerson.get("user_id")));
            projectPerson.put("creater_id", projectPerson.get("creater_id")==null?null: userMap.get((Integer) projectPerson.get("creater_id")));
            projectDestMapper.addProjectPerson(projectPerson);
        }

        List<Map<String, Object>> projectPersonAuths = projectSrcMapper.listProjectPersonAuth(projectIds);
        for (Map<String , Object> auth: projectPersonAuths) {
            auth.put("user_id", userMap.get((Integer) auth.get("user_id")));
            auth.put("project_id", projectMap.get((Integer) auth.get("project_id")));
            projectDestMapper.addProjectPersonAuth(auth);
        }
    }

    @Transactional
    @Override
    public void importProduct(List<Integer> projectIds){
        Map<Integer, Integer> userMap = userService.getUserMap();

        List<Map<String, Object>> products = projectSrcMapper.listProductByProjectIds(projectIds);
        for (Map<String, Object> product: products) {
            product.put("pm_person_id", product.get("pm_person_id")==null?null:userMap.get((Integer) product.get("pm_person_id")));
            product.put("creator_id", product.get("creator_id")==null?null:userMap.get((Integer)product.get("creator_id")));
            product.put("delete_person_id", product.get("delete_person_id")==null?null:userMap.get((Integer)product.get("delete_person_id")));
            product.put("rd_person_id", product.get("rd_person_id")==null?null:userMap.get((Integer)product.get("rd_person_id")));
            product.put("qm_person_id", product.get("qm_person_id")==null?null:userMap.get((Integer)product.get("qm_person_id")));
            projectDestMapper.addProduct(product);
        }
        List<Map<String, Object>> productVersions = projectSrcMapper.listProductVersionByProjectIds(projectIds);
        for (Map<String, Object> version: productVersions) {
            version.put("rd_person_id", version.get("rd_person_id")==null?null:userMap.get((Integer)version.get("rd_person_id")));
            version.put("creator_id", version.get("creator_id")==null?null:userMap.get((Integer)version.get("creator_id")));
            version.put("delete_person_id", version.get("delete_person_id")==null?null:userMap.get((Integer)version.get("delete_person_id")));
            version.put("pm_person_id", version.get("pm_person_id")==null?null:userMap.get((Integer)version.get("pm_person_id")));
            version.put("qm_person_id", version.get("qm_person_id")==null?null:userMap.get((Integer)version.get("qm_person_id")));
            projectDestMapper.addProductVersion(version);
        }
        List<Map<String, Object>> productModules = projectSrcMapper.listProductVersionModuleByProjectIds(projectIds);
        for (Map<String, Object> module: productModules){
            module.put("rd_person_id", module.get("rd_person_id")==null?null:userMap.get((Integer)module.get("rd_person_id")));
            module.put("creator_id", module.get("creator_id")==null?null:userMap.get((Integer)module.get("creator_id")));
            module.put("delete_person_id", module.get("delete_person_id")==null?null:userMap.get((Integer)module.get("delete_person_id")));
            projectDestMapper.addProductVersionModule(module);
        }
        List<Map<String, Object>> productProjects = projectSrcMapper.listProductProjectByProjectIds(projectIds);
        for (Map<String, Object> productProject: productProjects) {
            productProject.put("project_id", projectMap.get((Integer)productProject.get("project_id")));
            projectDestMapper.addProductProject(productProject);
        }
        List<Map<String, Object>> productVersionProjects = projectSrcMapper.listProductVersionProjectByProjectIds(projectIds);
        for (Map<String, Object> versionProject: productVersionProjects) {
            versionProject.put("project_id", projectMap.get((Integer)versionProject.get("project_id")));
            projectDestMapper.addProductVersionProject(versionProject);
        }

        List<Map<String, Object>> productVersionModuleProjects = projectSrcMapper.listProductVersionModuleProjectByProjectIds(projectIds);
        for (Map<String, Object> moduleProject: productVersionModuleProjects) {
            moduleProject.put("project_id", projectMap.get((Integer) moduleProject.get("project_id")));
            projectDestMapper.addProductVersionModuleProject(moduleProject);
        }
        List<Map<String, Object>> productAuths = projectSrcMapper.listProductAuthByProjectIds(projectIds);
        for (Map<String, Object> auth: productAuths) {
            auth.put("person_id", userMap.get((Integer) auth.get("person_id")));
            projectDestMapper.addProductAuth(auth);
        }
    }

    @Transactional
    @Override
    public void importSvnDbData(List<Integer> projectIds) throws Exception {
        if (projectIds.size() == 0 ) {
            throw new Exception("no project selected");
        }
        Map<Integer, Integer> userMap = userService.getUserMap();
        List<Map<String, Object>> svnConfigDirectories = projectSrcMapper.listSvnConfigDirectoryByProject(projectIds);
        for (Map<String, Object> svn: svnConfigDirectories) {
            svn.put("project_id", projectMap.get((Integer) svn.get("project_id")));
            svn.put("user_id", userMap.get((Integer) svn.get("user_id")));
            svn.put("delete_person_id", userMap.get(svn.get("delete_person_id")==null?null: (Integer) svn.get("delete_person_id")));
            svn.put("node_config_id", svnDestNode);
            projectDestMapper.addSvnConfigDirectory(svn);
        }
    }

    @Transactional
    @Override
    public void importFileDbData() {
        Map<Integer, Integer> userMap = userService.getUserMap();

        List<Map<String, Object>> files = projectSrcMapper.listAllFile();
        for( Map<String, Object> file: files) {
            file.put("user_id", file.get("user_id") == null?null: userMap.get((Integer) file.get("user_id")));
            projectDestMapper.addFile(file);
        }
    }

    @Transactional
    @Override
    public void importTicket(List<Integer> projectIds) {
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();
        List<Map<String, Object>> products = projectSrcMapper.listProductByProjectIds(projectIds);
        Map<String, Map<String, Object>> productMaps = parseList2Map(products, "product_uid");
        //缺陷

        Map<String, String> ticketEntityMap = new HashMap<>();
        Map<String, Object>  srcTicketValueMap = new HashMap<>();
        if (ticketColumnMap.size()>0) {
            Map<Integer,Map<String, Object>> srcTicketColumns = listPageEntityColumnsByEntityColumnIds(new ArrayList<>(ticketColumnMap.keySet()), 10, "src");
            Map<Integer, Map<String, Object>> destTicketColumns = listPageEntityColumnsByEntityColumnIds(new ArrayList<>(ticketColumnMap.values()), 10, "dest");
            for (Integer srcColumnId: ticketColumnMap.keySet()){
                String srckey = ((String) srcTicketColumns.get(srcColumnId).get("column")).toLowerCase();
                String destKey=  ((String)destTicketColumns.get(ticketColumnMap.get(srcColumnId)).get("column")).toLowerCase();
                ticketEntityMap.put(srckey, destKey);
            }

        }

        List<Map<String, Object>> tickets = projectSrcMapper.listTicketByProjectIds(projectIds);
        for (Map<String, Object> ticket: tickets) {

            //TODO: 需按照 page_entity_column配置转换对应的列
            if (ticketColumnMap.size()>0) {
                for (String srcKey: ticketEntityMap.keySet()) {
                    srcTicketValueMap.put(srcKey, ticket.get(srcKey));
                }
                for (String srcKey: ticketEntityMap.keySet()) {
                    ticket.put(srcKey, null);
                    ticket.put(ticketEntityMap.get(srcKey), srcTicketValueMap.get(srcKey));
                }
            }
            if (ticket.get("product_uid")!=null && !productMaps.keySet().contains((String)ticket.get("product_uid"))){
                ticket.put("product_uid", null);
                ticket.put("product_version_uid", null);
                ticket.put("module_uid", null);
            }

            ticket.put("project_id", transformIntergerId((Integer) ticket.get("project_id"), projectMap));
            ticket.put("project_single_1", transformIntergerId((Integer) ticket.get("project_single_1"), projectMap));
            ticket.put("project_single_2", transformIntergerId((Integer) ticket.get("project_single_2"), projectMap));
            ticket.put("project_single_3", transformIntergerId((Integer) ticket.get("project_single_3"), projectMap));

            ticket.put("modifier_id", transformIntergerId((Integer) ticket.get("modifier_id"), userMap));
            ticket.put("disposer_id", transformIntergerId((Integer) ticket.get("disposer_id"), userMap));
            ticket.put("reporter_id", transformIntergerId((Integer) ticket.get("reporter_id"), userMap));
            ticket.put("person_single_1", transformIntergerId((Integer) ticket.get("person_single_1"), userMap));
            ticket.put("person_single_2", transformIntergerId((Integer) ticket.get("person_single_2"), userMap));
            ticket.put("person_single_3", transformIntergerId((Integer) ticket.get("person_single_3"), userMap));
            ticket.put("person_single_4", transformIntergerId((Integer) ticket.get("person_single_4"), userMap));
            ticket.put("person_single_5", transformIntergerId((Integer) ticket.get("person_single_5"), userMap));
            //TODO: 人员多选和单位多选如果有配置的话，需要进行转换
            //ticket.put("person_multiple_1", ticket.get("person_multiple_1") == null? null:  StringUtils.split(",", (String)ticket.get("person_multiple_1")))

            ticket.put("source_unit_id", transformIntergerId((Integer) ticket.get("source_unit_id"), unitMap));
            ticket.put("unit_single_1", transformIntergerId((Integer) ticket.get("unit_single_1"), unitMap));
            ticket.put("unit_single_2", transformIntergerId((Integer) ticket.get("unit_single_2"), unitMap));
            ticket.put("unit_single_3", transformIntergerId((Integer) ticket.get("unit_single_3"), unitMap));
            ticket.put("unit_single_4", transformIntergerId((Integer) ticket.get("unit_single_4"), unitMap));
            ticket.put("unit_single_4", transformIntergerId((Integer) ticket.get("unit_single_4"), unitMap));

            ticket.put("type_id", transformIntergerId((Integer) ticket.get("type_id"), ticketTypeMap));
            ticket.put("severity_id",  transformIntergerId((Integer) ticket.get("severity_id"), ticketSeverityMap));
            ticket.put("source_id", transformIntergerId((Integer) ticket.get("source_id"), ticketSourceMap));
            ticket.put("priority_id",  transformIntergerId((Integer) ticket.get("priority_id"), ticketPriorityMap));
            ticket.put("status_id", transformIntergerId((Integer) ticket.get("status_id"), ticketStatusMap));
            ticket.put("resolution_id",  transformIntergerId((Integer) ticket.get("resolution_id"), ticketResolutionMap));
            ticket.put("category_id",  transformIntergerId((Integer) ticket.get("category_id"), ticketCategoryMap));
            ticket.put("frequency_id",  transformIntergerId((Integer) ticket.get("frequency_id"), ticketFrequencyMap));

            projectDestMapper.addTicket(ticket);
        }

        //缺陷历史
        List<Map<String, Object>> ticketHistorys = projectSrcMapper.listTicketHistoryByProjectIds(projectIds);
        for (Map<String, Object> history: ticketHistorys) {
            history.put("disposer_id",transformIntergerId((Integer) history.get("disposer_id"), userMap));
            history.put("disposer_from_id", transformIntergerId((Integer) history.get("disposer_from_id"), userMap));
            history.put("status_id",transformIntergerId((Integer) history.get("status_id"), ticketStatusMap));
            history.put("resolution_id", transformIntergerId((Integer) history.get("resolution_id"), ticketResolutionMap));
            projectDestMapper.addTicketHistory(history);
        }

        //缺陷文件
        List<Map<String, Object>> ticketFiles = projectSrcMapper.listTicketFileByProjectIds(projectIds) ;
        for (Map<String, Object> file: ticketFiles) {
            file.put("uploader_id", transformIntergerId((Integer) file.get("uploader_id"), userMap));
            projectDestMapper.addTicketFile(file);
        }

        //缺陷关联的流程实例
        List<Map<String, Object>> workflowTasks = projectSrcMapper.listWorkflowTaskByTicketProjectIds(projectIds);
        for (Map<String, Object> workflowTask: workflowTasks) {
            workflowTask.put("status_id", transformIntergerId((Integer) workflowTask.get("status_id"), ticketStatusMap));
            workflowTask.put("creator_id", transformIntergerId((Integer) workflowTask.get("creator_id"), userMap));
            workflowTask.put("operator_id", transformIntergerId((Integer)workflowTask.get("operator_id"), userMap));
            workflowTask.put("disposer_id", transformIntergerId((Integer) workflowTask.get("disposer_id"), userMap));
            projectDestMapper.addWorkflowTask(workflowTask);
        }

        //缺陷流程
        List<Map<String, Object>> workflowTaskTickets = projectSrcMapper.listWorkflowTaskTicketByProjectIds(projectIds) ;
        for (Map<String, Object> taskTicket: workflowTaskTickets) {
            projectDestMapper.addWorkflowTaskTicket(taskTicket);
        }


        //缺陷流程历史
        List<Map<String, Object>> workflowHistories = projectSrcMapper.listTicketWorkflowHistoryByProjectIds(projectIds);
        for (Map<String, Object> history: workflowHistories) {
            Integer srcHistoryId = (Integer) history.get("id");
            Integer formerDisposerId = (Integer) history.get("former_disposer_id");
            Integer nextDisposerId = (Integer) history.get("next_disposer_id");
            history.put("operator_id", history.get("operator_id")==null?null:userMap.get((Integer) history.get("operator_id")));
            if (formerDisposerId == null){

            } else if (formerDisposerId > 0) {
                history.put("former_disposer_id", userMap.get(formerDisposerId));
            } else if (formerDisposerId < 0) {
                //TODO : 小于0时为指派到角色
                history.put("former_disposer_id", 0);
            }
            if (nextDisposerId == null) {

            } else if (nextDisposerId > 0) {
                history.put("next_disposer_id", userMap.get(nextDisposerId));
            } else if (nextDisposerId< 0) {
                //TODO : 小于0时为指派到角色
                history.put("next_disposer_id", 0);
            }
            history.put("from_status_id", transformIntergerId((Integer) history.get("from_status_id"), ticketStatusMap));
            history.put("to_status_id", transformIntergerId((Integer) history.get("to_status_id"), ticketStatusMap) );
            projectDestMapper.addWorkflowHistory(history);
            Integer newHistoryId = (Integer) history.get("id");
            workflowHistoryMap.put(srcHistoryId, newHistoryId);
        }

        //缺陷流程历史文件
        List<Map<String, Object>> workflowHistoryFiles = projectSrcMapper.listTicketWorkflowHistoryFileByProjectIds(projectIds);
        for (Map<String, Object> file: workflowHistoryFiles) {
            if (!workflowHistoryMap.keySet().contains(file.get("history_id"))) {
                continue;
            }
            file.put("history_id", workflowHistoryMap.get((Integer)file.get("history_id") ));
            projectDestMapper.addWorkflowHistoryFile(file);
        }

        if (entities.values().contains("项目测试用例")) {
            List<Map<String , Object>> testDescStepTickets = projectSrcMapper.listRTestDescStepTicketByProjectIds(projectIds);
            for (Map<String, Object> item: testDescStepTickets) {
                projectDestMapper.addRTestDescStepTicket(item);
            }
        }
    }

    @Transactional
    @Override
    public void importRequirement(List<Integer> ids) {
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();

        //文件夹 format_floder
        List<Map<String, Object>> formatFloders = projectSrcMapper.listFormatDocFloderByProjectIds(ids);
        for (Map<String, Object> item: formatFloders) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("delete_person_id", transformIntergerId((Integer)item.get("delete_person_id"), userMap));
            projectDestMapper.addFormatDocFloder(item);
        }
        //需求文档 format_doc
        List<Map<String, Object>> formatDocs = projectSrcMapper.listFormatDocByProjectIds(ids);
        for (Map<String, Object> item: formatDocs) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("doc_type", transformIntergerId((Integer)item.get("doc_type"), formatDocTypeMap));
            item.put("delete_person_id", transformIntergerId((Integer)item.get("delete_person_id"), userMap));
            item.put("unit_id", transformIntergerId((Integer) item.get("unit_id"), unitMap));
            projectDestMapper.addFormatDoc(item);
        }
        //文档，文件夹关系 r_format_doc_floder
        List<Map<String, Object>> rFormatDocFloders = projectSrcMapper.listRFormatDocFloderByProjectIds(ids);
        for (Map<String, Object> item: rFormatDocFloders) {
            projectDestMapper.addRFormatDocFloder(item);
        }
        //文档版本 format_edition
        List<Map<String, Object>> formatEditions = projectSrcMapper.listFormatEditionByProjectIds(ids);
        for (Map<String, Object> item: formatEditions) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            projectDestMapper.addFormatEdition(item);
        }

        //文档和条目类型关联关系 r_format_doc_item_type
        List<Map<String, Object>> rFormatDocItemTypes = projectSrcMapper.listRFormatDocItemTypeByProjectIds(ids);
        for (Map<String, Object> item: rFormatDocItemTypes) {
            item.put("item_type_id", transformIntergerId((Integer)item.get("item_type_id"), formatItemTypeMap));
            projectDestMapper.addRFormatDocItemType(item);
        }

        List<Map<String, Object>> formatDocWorkflows = projectSrcMapper.listFormatDocWorkflowByProjectIds(ids);
        for (Map<String, Object> item: formatDocWorkflows) {
            item.put("workflow_uid", transformIntergerId((String)item.get("workflow_uid"), workflowMap));
            projectDestMapper.addFormatDocWorkflow(item);
        }

        //文档章节 format_section
        List<Map<String, Object>> formatSections = projectSrcMapper.listFormatSectionByProjectIds(ids);
        for (Map<String, Object> item: formatSections) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            projectDestMapper.addFormatSection(item);
        }

        //文档文件 r_format_docfile
        List<Map<String, Object>> formatDocFiles = projectSrcMapper.listRFormatDocFileByProjectIds(ids);
        for (Map<String, Object> item: formatDocFiles) {
            projectDestMapper.addRFormatDocFile(item);
        }

        //文档依赖关系 r_format_docs
        List<Map<String, Object>> rFormatDocs = projectSrcMapper.listRFormatDocsByProjectIds(ids);
        for (Map<String, Object> item: rFormatDocs) {
            projectDestMapper.addRFormatDocs(item);
        }

        //需求实体 format_item_edition
        List<Map<String , Object>> formatItemEditions = projectSrcMapper.listFormatItemEditionByProjectIds(ids) ;
        for (Map<String , Object> item: formatItemEditions) {
            item.put("project_id", transformIntergerId((Integer) item.get("project_id"), projectMap));
            item.put("operator_id", transformIntergerId((Integer) item.get("operator_id"), userMap ));
            projectDestMapper.addFormatItemEdition(item);
        }

        //需求变更纪录 format_item_changed_record
        List<Map<String, Object>> formatItemChangeRecords = projectSrcMapper.listFormatItemChangedRecordByProjectIds(ids);
        for (Map<String, Object> item: formatItemChangeRecords) {
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            item.put("request_manner", transformIntergerId((Integer)item.get("request_manner"), formatChangedMannerMap));
            projectDestMapper.addFormatItemChangedRecord(item);
        }

        //需求关系 r_format_section_item
        List<Map<String, Object>> rFormatSectionItems = projectSrcMapper.listRFormtSectionItemByProjectIds(ids);
        for (Map<String, Object> item: rFormatSectionItems) {
            item.put("item_type_id", transformIntergerId((Integer)item.get("item_type_id"), formatItemTypeMap));
            item.put("approver", transformIntergerId((Integer)item.get("approver"), userMap));
            item.put("creator", transformIntergerId((Integer)item.get("creator"), userMap));
            item.put("status", transformIntergerId((Integer)item.get("status"), formatItemStatusMap));
            item.put("delete_person_id", transformIntergerId((Integer)item.get("delete_person_id"), userMap));
            item.put("manager", transformIntergerId((Integer)item.get("manager"), userMap));
            item.put("stability_id", transformIntergerId((Integer)item.get("stability_id"), formatStabilityMap));
            item.put("difficulty_id", transformIntergerId((Integer)item.get("difficulty_id"), formatDifficultyMap));
            item.put("expected_level_id", transformIntergerId((Integer)item.get("expected_level_id"), formatExpectedLevelMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            projectDestMapper.addRFormatSectionItem(item);
        }

        //不知道干嘛用的，format_item_comm
        List<Map<String, Object>> formatItemComms = projectSrcMapper.listFormatItemCommByProjectIds(ids) ;
        for (Map<String, Object> comm: formatItemComms) {
            comm.put("creator", transformIntergerId((Integer)comm.get("creator"), userMap));
            projectDestMapper.addFormatItemComm(comm);
        }

        //需求条目处置历史 format_item_dispose_history
        List<Map<String, Object>> formatItemDisposeHistories = projectSrcMapper.listFormatItemDisposeHistoryByProjectids(ids);
        for (Map<String, Object> item: formatItemDisposeHistories) {
            item.put("item_type_id", transformIntergerId((Integer)item.get("item_type_id"), formatItemTypeMap));
            item.put("approver", transformIntergerId((Integer) item.get("approver"), userMap));
            item.put("creator", transformIntergerId((Integer)item.get("creator"), userMap));
            item.put("status", transformIntergerId((Integer)item.get("status"), formatItemStatusMap));
            item.put("alter_operator", transformIntergerId((Integer)item.get("alter_operator"), userMap));
            item.put("delete_person_id", transformIntergerId((Integer)item.get("delete_person_id"), userMap));
            item.put("manager", transformIntergerId((Integer)item.get("manager"), userMap));
            item.put("stability_id", transformIntergerId((Integer) item.get("stability_id") ,formatStabilityMap));
            item.put("difficulty_id", transformIntergerId((Integer) item.get("difficulty_id"), formatDifficultyMap));
            item.put("expected_level_id", transformIntergerId((Integer)item.get("expected_level_id"), formatExpectedLevelMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            projectDestMapper.addFormatItemDisposeHistory(item);
        }

        //不知道干嘛用的 format_item_edition_change
        List<Map<String, Object>> formatItemEditionChanges = projectSrcMapper.listFormatItemEditionChangeByProjectIds(ids);
        for (Map<String, Object> item: formatItemEditionChanges) {
            item.put("creator", transformIntergerId((Integer) item.get("creator"), userMap));
            item.put("status", transformIntergerId((Integer)item.get("status"), formatItemStatusMap));
            item.put("item_type_id", transformIntergerId((Integer)item.get("item_type_id"), formatItemTypeMap));
            item.put("stability_id", transformIntergerId((Integer) item.get("stability_id") ,formatStabilityMap));
            item.put("difficulty_id", transformIntergerId((Integer) item.get("difficulty_id"), formatDifficultyMap));
            item.put("expected_level_id", transformIntergerId((Integer)item.get("expected_level_id"), formatExpectedLevelMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            item.put("approver", transformIntergerId((Integer)item.get("approver"), userMap));
            item.put("manager", transformIntergerId((Integer)item.get("manager"), userMap));
            projectDestMapper.addFormatItemEditionChange(item);
        }

        //需求条目修改历史
        List<Map<String, Object>> formatItemModifyHistories = projectSrcMapper.listFormatItemModifyHistoryByProjectIds(ids);
        for (Map<String, Object> item: formatItemModifyHistories) {
            item.put("project_id", transformIntergerId((Integer) item.get("project_id"), projectMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            projectDestMapper.addFormatItemModifyHistory(item);
        }

        //需求条目产品，一般没数据？
        List<Map<String, Object>> formatItemProducts = projectSrcMapper.listRFormatItemProductByProjectIds(ids);
        for (Map<String, Object> item: formatItemProducts) {
            item.put("manager",transformIntergerId((Integer)item.get("manager"), userMap));
            item.put("product_manager", transformIntergerId((Integer)item.get("product_manager"), userMap));
            item.put("business_manager", transformIntergerId((Integer)item.get("business_manager"), userMap));
            item.put("develop_manager", transformIntergerId((Integer)item.get("develop_manager"), userMap));
            item.put("req_manager", transformIntergerId((Integer)item.get("req_manager"), userMap));
            projectDestMapper.addRFormatItemProduct(item);
        }

        //需求条目文件 r_format_itemfile
        List<Map<String, Object>> formatItemFiles = projectSrcMapper.listRFormatItemFileByProjectIds(ids) ;
        for (Map<String, Object> file: formatItemFiles) {
            file.put("type_id", transformIntergerId((Integer)file.get("type_id"), formatItemFileTypeMap));
            projectDestMapper.addRFormatItemFile(file);
        }

        //需求条目关联关系
        List<Map<String, Object>> formatItems = projectSrcMapper.listRformatItemsByProjectIds(ids) ;
        for (Map<String, Object> item: formatItems){
            projectDestMapper.addRFormatItems(item);
        }

        List<Map<String, Object>> rUserFormatDocs = projectSrcMapper.listRUserFormatDocByProjectIds(ids) ;
        for (Map<String, Object> item: rUserFormatDocs) {
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            projectDestMapper.addRUserFormatDoc(item);
        }
        List<Map<String, Object>> rUserFormatDocStatuss = projectSrcMapper.listRUserFormatDocStatusByProjectIds(ids);
        for (Map<String, Object> item: rUserFormatDocStatuss) {
            item.put("person_id", transformIntergerId((Integer)item.get("person_id"), userMap));
            item.put("concerned_status_id", transformIntergerId((Integer)item.get("concerned_status_id"), formatItemStatusMap));
            projectDestMapper.addRUserFormatDocStatus(item);
        }

        //需求流程任务 workflow_task
        List<Map<String, Object>> workflowTasks = projectSrcMapper.listWorkflowTaskWithinFormatByProjectIds(ids);
        for (Map<String, Object> item: workflowTasks) {
            item.put("status_id", transformIntergerId((Integer)item.get("status_id"), formatItemStatusMap));
            item.put("creator_id", transformIntergerId((Integer)item.get("creator_id"), userMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            item.put("workflow_uid", transformIntergerId((String) item.get("workflow_uid"), workflowMap));
            if (item.get("disposer_id") == null) {

            } else if ((Integer)item.get("disposer_id") > 0) {
                item.put("disposer_id", transformIntergerId((Integer)item.get("disposer_id"), userMap));
            } else if ((Integer)item.get("disposer_id") < 0) {
                //TODO： 指派到角色的情况
                item.put("disposer_id", 0);
            }
            projectDestMapper.addWorkflowTask(item);
        }
        //需求条目和流程任务关联关系 workflow_task_format_item
        List<Map<String, Object>> workflowTaskFormatItems = projectSrcMapper.listWorkflowTaskFormatItemByProjectIds(ids);
        for (Map<String, Object> item: workflowTaskFormatItems) {
            projectDestMapper.addWorkflowTaskFormatFormatItem(item);
        }
        //需求处置历史 workflow_history
        List<Map<String, Object>> workflowHistories = projectSrcMapper.listWorkflowHistoryWithinFormatByProjectIds(ids);
        for (Map<String, Object> item: workflowHistories) {
            Integer srcHistoryId = (Integer) item.get("id");
            item.put("from_status_id", transformIntergerId((Integer)item.get("from_status_id"), formatItemStatusMap));
            item.put("to_status_id", transformIntergerId((Integer)item.get("to_status_id"), formatItemStatusMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), formatItemStatusMap));
            if ((Integer)item.get("former_disposer_id") == null) {

            } else if ((Integer)item.get("former_disposer_id") > 0) {
                item.put("former_disposer_id", transformIntergerId((Integer)item.get("former_disposer_id"), userMap));
            } else if ((Integer) item.get("former_disposer_id") < 0) {
                //TODO 指派到角色的情况
                item.put("former_disposer_id", 0);
            }
            if (item.get("next_disposer_id") == null) {

            } else if ((Integer)item.get("next_disposer_id") > 0){
                item.put("next_disposer_id", transformIntergerId((Integer)item.get("next_disposer_id"), formatItemStatusMap));
            } else if ((Integer)item.get("next_disposer_id") < 0) {
                //TODO: 指派到角色的情况
                item.put("next_disposer_id", 0);
            }
            Integer count =  projectDestMapper.addWorkflowHistory(item);
            if (count == 0) continue;
            Integer newId = (Integer) item.get("id");
            workflowHistoryMap.put(srcHistoryId, newId);
        }
        //需求处置历史 文件 workflow_history_file
        List<Map<String, Object>> rWorkflowHistoryFiles = projectSrcMapper.listRWorkflowHistoryFileWithinFormatByProjectIds(ids);
        for (Map<String, Object> item: rWorkflowHistoryFiles) {
            if (!workflowHistoryMap.keySet().contains(item.get("history_id"))) continue;
            item.put("history_id", transformIntergerId((Integer)item.get("history_id"), workflowHistoryMap));
            projectDestMapper.addWorkflowHistoryFile(item);
        }

        if (entities.values().contains("项目测试用例")) {
            List<Map<String, Object>> testDescFormatDocs = projectSrcMapper.listTestDescFormatDocByProjectIds(ids);
            for (Map<String, Object> item: testDescFormatDocs) {
                projectDestMapper.addTestDescFormatDoc(item);
            }
            List<Map<String,Object>> testDescCaseItemEditions = projectSrcMapper.listRTestDescCaseItemEditionByProjectIds(ids);
            for (Map<String, Object> item: testDescCaseItemEditions) {
                projectDestMapper.addRTestDescCaseItemEdition(item);
            }
        }

    }

    @Transactional
    @Override
    public void importTask(List<Integer> ids) throws DataAccessException {
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();

        List<Map<String, Object>> plans = projectSrcMapper.listPlanByProjectIds(ids);
        for (Map<String, Object> item: plans) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("plan_operator", transformIntergerId((Integer)item.get("plan_operator"), userMap));
            projectDestMapper.addPlan(item);
        }

        Map<Integer, Map<String, Object>> rootTasks = projectDestMapper.listRootTaskByProjectIds(new ArrayList<>(projectMap.values()));
        Map<String, String > rootTaskUidMap = new HashMap<>();
        List<Map<String, Object>> tasks = projectSrcMapper.listTaskByProjectIds(ids);
        LinkedList<Map<String, Object>> taskQueues = new LinkedList<>(tasks);
        Set<String> addedTaskUids = new HashSet<>();
        while (!taskQueues.isEmpty()) {
            Map<String, Object> item = taskQueues.pop();
            if (item.get("parent_uid") == null) {               //处理任务的根任务。根任务非手动创建，为项目名称的任务。
                if (rootTasks.get(projectMap.get((Integer)item.get("project_ID"))) != null ) {
                    rootTaskUidMap.put((String) item.get("UID"), (String) rootTasks.get(projectMap.get((Integer)item.get("project_id"))).get("UID"));
                    continue;
                }
            } else {
                if (!rootTaskUidMap.keySet().contains(item.get("parent_uid")) && !addedTaskUids.contains(item.get("parent_uid"))) {
                    taskQueues.add(item);
                    continue;
                }
            }
            if (item.get("parent_id") != null) {
                item.put("parent_uid", rootTaskUidMap.keySet().contains(item.get("parent_uid")) ? rootTaskUidMap.get(item.get("parent_uid")) : item.get("parent_uid"));
            }
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("update_user_id", transformIntergerId((Integer)item.get("update_user_id"), userMap));
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("category", transformIntergerId((Integer)item.get("category"), taskCategoryMap));
            item.put("Type", transformIntergerId((Integer)item.get("Type"), taskTypeMap));
            item.put("Important", transformIntergerId((Integer)item.get("Important"), taskImportantMap));
            item.put("Status", transformIntergerId((Integer)item.get("Status"), taskStatusMap));
            item.put("update_user_id", transformIntergerId((Integer)item.get("update_user_id"), userMap));
            //TODO: stage_id
            projectDestMapper.addTask(item);
            addedTaskUids.add((String) item.get("UID"));
        }

        List<Map<String, Object>> tasklogs = projectSrcMapper.listTaskLogByProjectIds(ids);
        for (Map<String, Object> log: tasklogs) {
            log.put("user_id", transformIntergerId((Integer)log.get("user_id"), userMap));
            log.put("type", transformIntergerId((Integer)log.get("type"), taskLogTypeMap));
            projectDestMapper.addTaskLog(log);
        }
        List<Map<String, Object>> taskHistories = projectSrcMapper.listTaskHistoryByProjectIds(ids);
        for (Map<String, Object> item: taskHistories) {
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("update_user_id", transformIntergerId((Integer)item.get("update_user_id"), userMap));
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("STATUS", transformIntergerId((Integer)item.get("STATUS"), taskStatusMap));
            //TODO: stage_id
            projectDestMapper.addTaskHistory(item);
        }
        List<Map<String, Object>> rTaskFiles = projectSrcMapper.listRTaskFileByProjectIds(ids);
        for (Map<String, Object> item: rTaskFiles) {
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("task_filetype", transformIntergerId((Integer)item.get("task_filetype"), taskFileTypeMap));
            projectDestMapper.addRTaskFile(item);
        }
        List<Map<String, Object>> taskAssignments = projectSrcMapper.listTaskAssignmentByProjectIds(ids);
        for (Map<String, Object> item: taskAssignments) {
            item.put("ResourceUID", transformIntergerId((Integer)item.get("ResourceUID"), userMap));
            projectDestMapper.addTaskAssignment(item);
        }
        List<Map<String, Object>> taskAcceptances = projectSrcMapper.listTaskAcceptanceByProjectIds(ids);
        for (Map<String, Object> item: taskAcceptances) {
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("satisfaction", transformIntergerId((Integer)item.get("satisfaction"), taskSatisfactionMap));
            projectDestMapper.addTaskAcceptance(item);
        }
        List<Map<String, Object>> taskPredecessorLinks = projectSrcMapper.listTaskPredecessorLinkByProjectIds(ids) ;
        for (Map<String, Object> item: taskPredecessorLinks) {
            projectDestMapper.addTaskPredecessorLink(item);
        }
        List<Map<String, Object>> taskProgressHistories = projectSrcMapper.listTaskProgressHistoryByProjectIds(ids);
        for (Map<String, Object> item: taskProgressHistories) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            projectDestMapper.addTaskProgressHistory(item);
        }

        List<Map<String, Object>> taskReportQuestions = projectSrcMapper.listReportQuestionWithinTaskByProjectIds(ids);
        for (Map<String, Object> item: taskReportQuestions) {
            Integer srcId = (Integer) item.get("id");
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("father_id", transformIntergerId((Integer)item.get("father_id"), reportQuestionMap));
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("last_respondent", transformIntergerId((Integer)item.get("last_respondent"), userMap));
            item.put("type_id", transformIntergerId((Integer)item.get("type_id"), reportQuestionTypeMap));
            item.put("priority_id", transformIntergerId((Integer)item.get("priority_id"), reportQuestionPriorityMap));
            item.put("status_id", transformIntergerId((Integer)item.get("status_id"), reportQuestionStatusMap));
            projectDestMapper.addReportQuestion(item);
            Integer newId = (Integer) item.get("id");
            reportQuestionMap.put(srcId, newId);
        }

        List<Map<String, Object>> taskReportQuestionFiles = projectSrcMapper.listRQuestionFileWithinTaskByProjectIds(ids);
        for (Map<String, Object> item: taskReportQuestionFiles) {
            item.put("question_id", transformIntergerId((Integer)item.get("question_id"), reportQuestionMap));
            projectDestMapper.addRQuestionFile(item);
        }

        if (entities.values().contains("项目需求")) {
            List<Map<String, Object>> rTaskItems = projectSrcMapper.listRTaskItemByProjectIds(ids);
            for (Map<String, Object> item: rTaskItems) {
                projectDestMapper.addRTaskItem(item);
            }
        }
        if (entities.values().contains("项目测试用例")) {
            List<Map<String, Object>> rTaskCases = projectSrcMapper.listRTaskCaseByProjectIds(ids);
            for (Map<String, Object> item: rTaskCases) {
                projectDestMapper.addRTaskCase(item);
            }
        }
        //TODO: report work 计划任务报工，数据结构待分析
    }

    @Transactional
    @Override
    public void importTest(List<Integer> projectIds) {
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();

        List<Map<String, Object>> testActivities = projectSrcMapper.listTestActivityByProjectIds(projectIds);
        for (Map<String, Object> item: testActivities) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("creator_id", transformIntergerId((Integer)item.get("creator_id"), userMap));
            item.put("level_id", transformIntergerId((Integer)item.get("level_id"), testActivityLevelMap));
            item.put("status_id", transformIntergerId((Integer)item.get("status_id"), testActivityStatusMap));
            item.put("unit_id", transformIntergerId((Integer)item.get("unit_id"), unitMap));
            projectDestMapper.addTestActivity(item);
        }
        List<Map<String, Object>> testDescs = projectSrcMapper.listTestDescByProjectIds(projectIds);
        for (Map<String, Object> item: testDescs ){
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            projectDestMapper.addTestDesc(item);
        }
        List<Map<String, Object>> testActivityStages = projectSrcMapper.listTestActivityStageByProjectIds(projectIds);
        for (Map<String, Object> item: testActivityStages) {
            item.put("creator_id", transformIntergerId((Integer)item.get("creator_id"), userMap));
            item.put("stage_status_id", transformIntergerId((Integer)item.get("stage_status_id"), testActivityStatusMap));
            item.put("unit_id", transformIntergerId((Integer)item.get("unit_id"), unitMap));
            item.put("level_id", transformIntergerId((Integer)item.get("level_id"), testActivityLevelMap));
            item.put("rule_id", transformIntergerId((Integer)item.get("rule_id"), testRuleMap));
            item.put("method_id", transformIntergerId((Integer)item.get("method_id"), testMethodMap));
            item.put("category_id", transformIntergerId((Integer)item.get("category_id"), testStageCategoryMap));
            projectDestMapper.addTestActivityStage(item);
        }

        List<Map<String, Object>> testDescSections = projectSrcMapper.listTestDescSectionByProjectIds(projectIds);
        for (Map<String, Object> item: testDescSections) {
            projectDestMapper.addTestDescSection(item);
        }
        List<Map<String, Object>> testDescriptionCaseResults = projectSrcMapper.listTestDescriptionCaseResultByProjectIds(projectIds);
        for (Map<String, Object> item: testDescriptionCaseResults) {
            item.put("status_id", transformIntergerId((Integer)item.get("status_id"), testCaseStatusMap));
            item.put("priority_id", transformIntergerId((Integer)item.get("priority_id"), testCasePriorityMap));
            item.put("type_id", transformIntergerId((Integer)item.get("type_id"), testTypeMap));
            item.put("designer_id", transformIntergerId((Integer)item.get("designer_id"), userMap));
            item.put("monitor_person_id", transformIntergerId((Integer)item.get("monitor_person_id"), userMap));
            item.put("test_person_id", transformIntergerId((Integer)item.get("test_person_id"), userMap));
            item.put("executor", transformIntergerId((Integer)item.get("executor"), userMap));
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            projectDestMapper.addTestDescriptionCaseResult(item);
        }
        List<Map<String, Object>> testDescStepResults = projectSrcMapper.listTestDescStepResultByProjectIds(projectIds);
        for (Map<String, Object> item: testDescStepResults) {
            projectDestMapper.addTestDescStepResult(item);
        }
        List<Map<String, Object>> rTestDescCaseFiles = projectSrcMapper.listRTestDestCaseFileByProjectIds(projectIds);
        for (Map<String, Object> item: rTestDescCaseFiles) {
            projectDestMapper.addRTestDescCaseFile(item);
        }


    }

    @Transactional
    @Override
    public void importEvents(List<Integer> projectIds) {
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();

        List<Map<String, Object>> memorabilias = projectSrcMapper.listMemorabiliaByProjectIds(projectIds);
        for(Map<String, Object> item: memorabilias) {
            Integer srcId = (Integer) item.get("id");
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("type_id", transformIntergerId((Integer)item.get("type_id"), eventsTypeMap));
            item.put("level_id", transformIntergerId((Integer)item.get("level_id"), eventsLevelMap));
            //todo: 项目日志关联里程碑，现在为直接置空
            item.put("relevance_milestone_uid", null);

            Integer count = projectDestMapper.addMemorabilia(item);
            if (count == 0) continue;
            Integer newId = (Integer) item.get("id");
            eventsMap.put(srcId, newId);
        }
        List<Map<String, Object>> rMemorabiliaFiles = projectSrcMapper.listRMemorabiliaFileByProjectIds(projectIds);
        for (Map<String, Object> item: rMemorabiliaFiles) {
            //日志已经删除，但日志文件还在的情况处理
            if (!eventsMap.keySet().contains((Integer)item.get("memorabilia_id"))) continue;
            item.put("memorabilia_id", transformIntergerId((Integer)item.get("memorabilia_id"), eventsMap));
            projectDestMapper.addRMemorabiliaFile(item);
        }
        List<Map<String, Object>> rMemoUserProjects = projectSrcMapper.listRMemorabiliaUserProject(projectIds);
        for (Map<String, Object> item: rMemoUserProjects) {
            if (!eventsMap.keySet().contains(item.get("events_id"))) continue;
            item.put("events_id", transformIntergerId((Integer)item.get("events_id"), eventsMap));
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            projectDestMapper.addRMemorabiliaUserProject(item);
        }
        List<Map<String, Object>> eventsCriticles = projectSrcMapper.listEventsCriticleByProjectIds(projectIds);
        for (Map<String, Object>item: eventsCriticles) {
            Integer srcId = (Integer) item.get("id");
            item.put("events_id", transformIntergerId((Integer)item.get("events_id"), eventsMap));
            item.put("creator", transformIntergerId((Integer)item.get("creator"), userMap));
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"), userMap));
            item.put("last_critics", transformIntergerId((Integer)item.get("last_critics"), userMap));
            Integer count = projectDestMapper.addEventsCriticle(item);
            if (count == 0) continue;
            Integer newId = (Integer) item.get("id");
            eventsCriticleMap.put(srcId, newId);
        }
        List<Map<String, Object>> eventsCriticleFiles = projectSrcMapper.listEventsCriticleFileByProjectIds(projectIds);
        for (Map<String, Object> item: eventsCriticleFiles) {
            if (!eventsCriticleMap.keySet().contains(item.get("criticle_id"))) continue;
            item.put("criticle_id", transformIntergerId((Integer)item.get("criticle_id"), eventsCriticleMap));
            projectDestMapper.addEventsCriticleFile(item);
        }

    }

    @Transactional
    @Override
    public void importForum(List<Integer> projectIds){
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();

        List<Map<String, Object>> reportQuestions = projectSrcMapper.listReportQuestionByProjectIds(projectIds);
        for (Map<String, Object> item: reportQuestions) {
            Integer srcId = (Integer) item.get("id");
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("father_id", transformIntergerId((Integer)item.get("father_id"), reportQuestionMap));
            item.put("user_id", transformIntergerId((Integer)item.get("user_id"),userMap ));
            item.put("last_respondent", transformIntergerId((Integer)item.get("last_respondent"), userMap));
            item.put("type_id", transformIntergerId((Integer)item.get("type_id"), reportQuestionTypeMap));
            item.put("priority_id", transformIntergerId((Integer)item.get("priority_id"), reportQuestionPriorityMap));
            item.put("status_id", transformIntergerId((Integer)item.get("status_id"), reportQuestionStatusMap));
            Integer count = projectDestMapper.addReportQuestion(item);
            if (count == 0) continue;
            Integer newId = (Integer) item.get("id");
            reportQuestionMap.put(srcId, newId);
        }
        List<Map<String, Object>> reportQuestionFiles = projectSrcMapper.listRQuestionFileByProjectIds(projectIds);
        for (Map<String, Object>item: reportQuestionFiles) {
            if (!reportQuestionMap.keySet().contains(item.get("question_id"))) continue;
            item.put("question_id", transformIntergerId((Integer)item.get("question_id"), reportQuestionMap));
            projectDestMapper.addRQuestionFile(item);
        }
    }

    @Transactional
    @Override
    public void importQuestion(List<Integer> projectIds) {
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();

        List<Map<String, Object>> questions = projectSrcMapper.listQuestionByProjectIds(projectIds);
        for (Map<String, Object> item: questions) {
            item.put("creator_id", transformIntergerId((Integer)item.get("creator_id"), userMap));
            item.put("create_unit_id", transformIntergerId((Integer)item.get("create_unit_id"), unitMap));
            item.put("disposer", transformIntergerId((Integer)item.get("disposer"), userMap));
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("category_id", transformIntergerId((Integer)item.get("category_id"), questionCategoryMap));
            item.put("status_id", transformIntergerId((Integer)item.get("status_id"), questionManageStatusMap));
            item.put("evaluation_level",transformIntergerId((Integer)item.get("evaluation_level"), questionEvaluationLevelMap));
            projectDestMapper.addQuestion(item);
        }
        List<Map<String, Object>> rQuestionManageFiles = projectSrcMapper.listRQuestionManagFileByProjectIds(projectIds);
        for (Map<String, Object> item: rQuestionManageFiles) {
            projectDestMapper.addRQuestionManageFile(item);
        }

        List<Map<String, Object>> workflowTasks = projectSrcMapper.listWorkflowTaskWithinQuestionByProjectIds(projectIds);
        for (Map<String, Object> item: workflowTasks) {
            item.put("status_id", transformIntergerId((Integer) item.get("status_id"), questionManageStatusMap));
            item.put("creator_id", transformIntergerId((Integer)item.get("creator_id"), userMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            item.put("workflow_uid", transformIntergerId((String)item.get("workflow_uid"), workflowMap));
            if (item.get("disposer_id") == null) {

            } else if ((Integer)item.get("disposer_id")>0) {
                item.put("disposer_id", transformIntergerId((Integer)item.get("disposer_id"), userMap));
            } else if ((Integer)item.get("disposer_id")<0) {
                //todo: 指派到角色的情况
                item.put("disposer_id", 0);
            }
            projectDestMapper.addWorkflowTask(item);
        }
        List<Map<String, Object>> workflowTaskQuestions = projectSrcMapper.listWorkflowTaskQuestionByProjectIds(projectIds);
        for (Map<String, Object> item: workflowTaskQuestions) {
            projectDestMapper.addWorkflowTaskQuestion(item);
        }

        List<Map<String, Object>> workflowHistories = projectSrcMapper.listWorkflowHistoryWithinQuestionByProjectIds(projectIds);
        for (Map<String, Object> item: workflowHistories) {
            Integer srcId = (Integer)item.get("id");
            item.put("from_status_id", transformIntergerId((Integer)item.get("from_status_id"), questionManageStatusMap));
            item.put("to_status_id", transformIntergerId((Integer)item.get("to_status_id"), questionManageStatusMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            if (item.get("former_disposer_id") == null) {

            } else if ((Integer)item.get("former_disposer_id")>0) {
                item.put("former_disposer_id", transformIntergerId((Integer)item.get("former_disposer_id"), userMap));
            } else if ((Integer)item.get("former_disposer_id")<0) {
                //TODO：指派到角色
                item.put("former_disposer_id", 0);
            }
            if (item.get("") == null) {

            } else if ((Integer)item.get("next_disposer_id")>0) {
                item.put("next_disposer_id", transformIntergerId((Integer)item.get("next_disposer_id"), userMap));
            } else if ((Integer)item.get("next_disposer_id")<0) {
                //TODO：指派到角色
                item.put("next_disposer_id", 0);
            }
            Integer count = projectDestMapper.addWorkflowHistory(item);
            if (count == 0) {
                continue;
            }
            workflowHistoryMap.put(srcId, (Integer) item.get("id"));
        }
        List<Map<String, Object>> workflowHistoryFiles = projectSrcMapper.listWorkflowHistoryFileWithinQuestionByProjectIds(projectIds);
        for (Map<String, Object> item: workflowHistoryFiles) {
            if (!workflowHistoryMap.keySet().contains(item.get("history_id"))){
                continue;
            }
            item.put("history_id", transformIntergerId((Integer)item.get("history_id"), workflowHistoryMap));
        }
    }

    @Transactional
    @Override
    public void importRisk(List<Integer> projectIds) {
        Map<Integer, Integer> userMap = userService.getUserMap();
        Map<Integer, Integer> unitMap = userService.getUnitMap();

        List<Map<String, Object>> projectRisks = projectSrcMapper.listProjectRiskByProjectIds(projectIds);
        for (Map<String, Object> item: projectRisks) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            item.put("category_id", transformIntergerId((Integer)item.get("category_id"), riskCategoryMap));
            //TODO: s_influence_degree, s_influence_type
            //TODO: milestone_type_id
            item.put("risk_status_id", transformIntergerId((Integer)item.get("risk_status_id"), riskStatusMap));
            item.put("risk_dispose_status_id", transformIntergerId((Integer)item.get("risk_dispose_status_id"), riskDisposeStatusMap));
            item.put("manager", transformIntergerId((Integer)item.get("manager"), userMap));
            item.put("introducer", transformIntergerId((Integer)item.get("introducer"), userMap));  //提出人
            item.put("disposer", transformIntergerId((Integer)item.get("disposer"), userMap));
            item.put("risk_dispose_method", transformIntergerId((Integer)item.get("risk_dispose_method"), riskDisposeMethodMap));
            projectDestMapper.addProjectRisk(item);
        }
        List<Map<String, Object>> rProjectRiskFiles = projectSrcMapper.listRProjectRiskFileByProjectIds(projectIds);
        for (Map<String, Object> item: rProjectRiskFiles) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            projectDestMapper.addRProjectRiskFile(item);
        }

        List<Map<String, Object>> workflowTasks = projectSrcMapper.listWorkflowWithinProjectRiskByProjectIds(projectIds);
        for (Map<String, Object> item: workflowTasks) {
            item.put("status_id", transformIntergerId((Integer) item.get("status_id"), riskDisposeStatusMap));
            item.put("creator_id", transformIntergerId((Integer)item.get("creator_id"), userMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            item.put("workflow_uid", transformIntergerId((String)item.get("workflow_uid"), workflowMap));
            if (item.get("disposer_id") == null) {

            }else if ((Integer)item.get("disposer_id")>0) {
                item.put("disposer_id", transformIntergerId((Integer)item.get("disposer_id"), userMap));
            } else if ((Integer)item.get("disposer_id")<0) {
                //todo: 指派到角色的情况
                item.put("disposer_id", 0);
            }
            projectDestMapper.addWorkflowTask(item);
        }
        List<Map<String, Object>> workflowTaskRisks = projectSrcMapper.listWorkflowTaskProjectRiskByProjectIds(projectIds);
        for (Map<String, Object> item: workflowTaskRisks) {
            item.put("project_id", transformIntergerId((Integer)item.get("project_id"), projectMap));
            projectDestMapper.addWorkflowTaskRisk(item);
        }
        List<Map<String, Object>> workflowHistories = projectSrcMapper.listWorkflowHistoryWithinProjectRiskByProjectIds(projectIds);
        for (Map<String, Object> item: workflowHistories) {
            Integer srcId = (Integer)item.get("id");
            item.put("from_status_id", transformIntergerId((Integer)item.get("from_status_id"), riskDisposeStatusMap));
            item.put("to_status_id", transformIntergerId((Integer)item.get("to_status_id"), riskDisposeStatusMap));
            item.put("operator_id", transformIntergerId((Integer)item.get("operator_id"), userMap));
            if (item.get("former_disposer_id") == null) {

            } else if ((Integer)item.get("former_disposer_id")>0) {
                item.put("former_disposer_id", transformIntergerId((Integer)item.get("former_disposer_id"), userMap));
            } else if ((Integer)item.get("former_disposer_id")<0) {
                //TODO：指派到角色
                item.put("former_disposer_id", 0);
            }
            if (item.get("next_disposer_id") == null) {

            } else if ((Integer)item.get("next_disposer_id")>0) {
                item.put("next_disposer_id", transformIntergerId((Integer)item.get("next_disposer_id"), userMap));
            } else if ((Integer)item.get("next_disposer_id")<0) {
                //TODO：指派到角色
                item.put("next_disposer_id", 0);
            }
            Integer count = projectDestMapper.addWorkflowHistory(item);
            if (count == 0) {
                continue;
            }
            workflowHistoryMap.put(srcId, (Integer) item.get("id"));
        }
        List<Map<String, Object>> workflowHistoryFiles = projectSrcMapper.listWorkflowHistoryFileWithInProjectRiskByProjectIds(projectIds);
        for (Map<String, Object> item: workflowHistoryFiles) {
            if (!workflowHistoryMap.keySet().contains(item.get("history_id"))) {
                continue;
            }
            item.put("history_id", transformIntergerId((Integer)item.get("history_id"), workflowHistoryMap));
        }

    }

    /**
     * 根据map获取srcid的映射关系
     * @param src
     * @param map
     * @param <T>
     * @return
     */
    private <T> T transformIntergerId(T src, Map<T, T> map){
        return src == null?null: map.get(src)==null?src: map.get(src);
    }

    private <T> Map<T, Map<String, Object>> parseList2Map(List<Map<String, Object>> list, T idKey){
        Map<T, Map<String, Object>> result = new HashMap<T, Map<String, Object>>();
        for (Map<String, Object> item: list) {
            result.put((T) item.get(idKey), item);
        }
        return result;
    }

    @Override
    public List<Integer> getProjectToImport() {
        return projectToImport;
    }

    @Override
    public void setProjectToImport(List<Integer> projectToImport) {
        this.projectToImport = projectToImport;
    }
    @Override
    public Map<Integer, Integer> getProjectMap() {
        return projectMap;
    }
    @Override
    public void setProjectMap(Map<Integer, Integer> projectMap) {
        this.projectMap = projectMap;
    }

    @Override
    public Map<String, String> getWorkflowMap() {
        return workflowMap;
    }

    @Override
    public void setWorkflowMap(Map<String, String> workflowMap) {
        this.workflowMap = workflowMap;
    }

    @Override
    public Integer getSvnDestNode() {
        return svnDestNode;
    }
    @Override
    public void setSvnDestNode(Integer svnDestNode) {
        this.svnDestNode = svnDestNode;
    }
    @Override
    public Map<Integer, Integer> getTicketTypeMap() {
        return ticketTypeMap;
    }
    @Override
    public void setTicketTypeMap(Map<Integer, Integer> ticketTypeMap) {
        this.ticketTypeMap = ticketTypeMap;
    }
    @Override
    public Map<Integer, Integer> getTicketStatusMap() {
        return ticketStatusMap;
    }
    @Override
    public void setTicketStatusMap(Map<Integer, Integer> ticketStatusMap) {
        this.ticketStatusMap = ticketStatusMap;
    }
    @Override
    public Map<Integer, Integer> getTicketSourceMap() {
        return ticketSourceMap;
    }
    @Override
    public void setTicketSourceMap(Map<Integer, Integer> ticketSourceMap) {
        this.ticketSourceMap = ticketSourceMap;
    }
    @Override
    public Map<Integer, Integer> getTicketSeverityMap() {
        return ticketSeverityMap;
    }
    @Override
    public void setTicketSeverityMap(Map<Integer, Integer> ticketSeverityMap) {
        this.ticketSeverityMap = ticketSeverityMap;
    }
    @Override
    public Map<Integer, Integer> getTicketResolutionMap() {
        return ticketResolutionMap;
    }
    @Override
    public void setTicketResolutionMap(Map<Integer, Integer> ticketResolutionMap) {
        this.ticketResolutionMap = ticketResolutionMap;
    }
    @Override
    public Map<Integer, Integer> getTicketPriorityMap() {
        return ticketPriorityMap;
    }
    @Override
    public void setTicketPriorityMap(Map<Integer, Integer> ticketPriorityMap) {
        this.ticketPriorityMap = ticketPriorityMap;
    }
    @Override
    public Map<Integer, Integer> getTicketCategoryMap() {
        return ticketCategoryMap;
    }
    @Override
    public void setTicketCategoryMap(Map<Integer, Integer> ticketCategoryMap) {
        this.ticketCategoryMap = ticketCategoryMap;
    }
    @Override
    public Map<Integer, Integer> getTicketFrequencyMap() {
        return ticketFrequencyMap;
    }
    @Override
    public void setTicketFrequencyMap(Map<Integer, Integer> ticketFrequencyMap) {
        this.ticketFrequencyMap = ticketFrequencyMap;
    }
    @Override
    public Map<Integer, Integer> getWorkflowHistoryMap() {
        return workflowHistoryMap;
    }
    @Override
    public void setWorkflowHistoryMap(Map<Integer, Integer> workflowHistoryMap) {
        this.workflowHistoryMap = workflowHistoryMap;
    }

    @Override
    public Map<Integer, Integer> getTicketColumnMap() {
        return ticketColumnMap;
    }

    @Override
    public void setTicketColumnMap(Map<Integer, Integer> ticketColumnMap) {
        this.ticketColumnMap = ticketColumnMap;
    }
    @Override
    public Map<Integer, Integer> getFormatItemTypeMap() {
        return formatItemTypeMap;
    }
    @Override
    public void setFormatItemTypeMap(Map<Integer, Integer> formatItemTypeMap) {
        this.formatItemTypeMap = formatItemTypeMap;
    }
    @Override
    public Map<Integer, Integer> getFormatDocTypeMap() {
        return formatDocTypeMap;
    }
    @Override
    public void setFormatDocTypeMap(Map<Integer, Integer> formatDocTypeMap) {
        this.formatDocTypeMap = formatDocTypeMap;
    }
    @Override
    public Map<Integer, Integer> getFormatItemStatusMap() {
        return formatItemStatusMap;
    }
    @Override
    public void setFormatItemStatusMap(Map<Integer, Integer> formatItemStatusMap) {
        this.formatItemStatusMap = formatItemStatusMap;
    }
    @Override
    public Map<Integer, Integer> getFormatItemChangeMap() {
        return formatItemChangeMap;
    }
    @Override
    public void setFormatItemChangeMap(Map<Integer, Integer> formatItemChangeMap) {
        this.formatItemChangeMap = formatItemChangeMap;
    }
    @Override
    public Map<Integer, Integer> getFormatItemFileTypeMap() {
        return formatItemFileTypeMap;
    }
    @Override
    public void setFormatItemFileTypeMap(Map<Integer, Integer> formatItemFileTypeMap) {
        this.formatItemFileTypeMap = formatItemFileTypeMap;
    }
    @Override
    public Map<Integer, Integer> getFormatAlteredStatusMap() {
        return formatAlteredStatusMap;
    }
    @Override
    public void setFormatAlteredStatusMap(Map<Integer, Integer> formatAlteredStatusMap) {
        this.formatAlteredStatusMap = formatAlteredStatusMap;
    }
    @Override
    public Map<Integer, Integer> getFormatChangedMannerMap() {
        return formatChangedMannerMap;
    }
    @Override
    public void setFormatChangedMannerMap(Map<Integer, Integer> formatChangedMannerMap) {
        this.formatChangedMannerMap = formatChangedMannerMap;
    }
    @Override
    public Map<Integer, Integer> getFormatDifficultyMap() {
        return formatDifficultyMap;
    }
    @Override
    public void setFormatDifficultyMap(Map<Integer, Integer> formatDifficultyMap) {
        this.formatDifficultyMap = formatDifficultyMap;
    }
    @Override
    public Map<Integer, Integer> getFormatExpectedLevelMap() {
        return formatExpectedLevelMap;
    }
    @Override
    public void setFormatExpectedLevelMap(Map<Integer, Integer> formatExpectedLevelMap) {
        this.formatExpectedLevelMap = formatExpectedLevelMap;
    }
    @Override
    public Map<Integer, Integer> getFormatStabilityMap() {
        return formatStabilityMap;
    }
    @Override
    public void setFormatStabilityMap(Map<Integer, Integer> formatStabilityMap) {
        this.formatStabilityMap = formatStabilityMap;
    }
    @Override
    public Map<Integer, Integer> getTaskTypeMap() {
        return taskTypeMap;
    }
    @Override
    public void setTaskTypeMap(Map<Integer, Integer> taskTypeMap) {
        this.taskTypeMap = taskTypeMap;
    }
    @Override
    public Map<Integer, Integer> getTaskStatusMap() {
        return taskStatusMap;
    }
    @Override
    public void setTaskStatusMap(Map<Integer, Integer> taskStatusMap) {
        this.taskStatusMap = taskStatusMap;
    }
    @Override
    public Map<Integer, Integer> getTaskLogTypeMap() {
        return taskLogTypeMap;
    }
    @Override
    public void setTaskLogTypeMap(Map<Integer, Integer> taskLogTypeMap) {
        this.taskLogTypeMap = taskLogTypeMap;
    }
    @Override
    public Map<Integer, Integer> getTaskCategoryMap() {
        return taskCategoryMap;
    }
    @Override
    public void setTaskCategoryMap(Map<Integer, Integer> taskCategoryMap) {
        this.taskCategoryMap = taskCategoryMap;
    }
    @Override
    public Map<Integer, Integer> getTaskImportantMap() {
        return taskImportantMap;
    }
    @Override
    public void setTaskImportantMap(Map<Integer, Integer> taskImportantMap) {
        this.taskImportantMap = taskImportantMap;
    }
    @Override
    public Map<Integer, Integer> getTaskSatisfactionMap() {
        return taskSatisfactionMap;
    }
    @Override
    public void setTaskSatisfactionMap(Map<Integer, Integer> taskSatisfactionMap) {
        this.taskSatisfactionMap = taskSatisfactionMap;
    }

    @Override
    public Map<Integer, String> getEntities() {
        return entities;
    }
    @Override
    public void setEntities(Map<Integer, String> entities) {
        this.entities = entities;
    }
    @Override
    public Map<Integer, Integer> getEntityStatus() {
        return entityStatus;
    }
    @Override
    public void setEntityStatus(Map<Integer, Integer> entityStatus) {
        this.entityStatus = entityStatus;
    }

    @Override
    public Map<Integer, Integer> getTaskFileTypeMap() {
        return taskFileTypeMap;
    }
    @Override
    public void setTaskFileTypeMap(Map<Integer, Integer> taskFileTypeMap) {
        this.taskFileTypeMap = taskFileTypeMap;
    }
    @Override
    public Map<Integer, Integer> getReportQuestionMap() {
        return reportQuestionMap;
    }
    @Override
    public void setReportQuestionMap(Map<Integer, Integer> reportQuestionMap) {
        this.reportQuestionMap = reportQuestionMap;
    }
    @Override
    public Map<Integer, Integer> getTestActivityLevelMap() {
        return testActivityLevelMap;
    }
    @Override
    public void setTestActivityLevelMap(Map<Integer, Integer> testActivityLevelMap) {
        this.testActivityLevelMap = testActivityLevelMap;
    }
    @Override
    public Map<Integer, Integer> getTestActivityStatusMap() {
        return testActivityStatusMap;
    }
    @Override
    public void setTestActivityStatusMap(Map<Integer, Integer> testActivityStatusMap) {
        this.testActivityStatusMap = testActivityStatusMap;
    }
    @Override
    public Map<Integer, Integer> getTestCasePriorityMap() {
        return testCasePriorityMap;
    }
    @Override
    public void setTestCasePriorityMap(Map<Integer, Integer> testCasePriorityMap) {
        this.testCasePriorityMap = testCasePriorityMap;
    }
    @Override
    public Map<Integer, Integer> getTestCaseStatusMap() {
        return testCaseStatusMap;
    }
    @Override
    public void setTestCaseStatusMap(Map<Integer, Integer> testCaseStatusMap) {
        this.testCaseStatusMap = testCaseStatusMap;
    }
    @Override
    public Map<Integer, Integer> getTestMethodMap() {
        return testMethodMap;
    }
    @Override
    public void setTestMethodMap(Map<Integer, Integer> testMethodMap) {
        this.testMethodMap = testMethodMap;
    }
    @Override
    public Map<Integer, Integer> getTestRuleMap() {
        return testRuleMap;
    }
    @Override
    public void setTestRuleMap(Map<Integer, Integer> testRuleMap) {
        this.testRuleMap = testRuleMap;
    }
    @Override
    public Map<Integer, Integer> getTestStageCategoryMap() {
        return testStageCategoryMap;
    }
    @Override
    public void setTestStageCategoryMap(Map<Integer, Integer> testStageCategoryMap) {
        this.testStageCategoryMap = testStageCategoryMap;
    }
    @Override
    public Map<Integer, Integer> getTestTypeMap() {
        return testTypeMap;
    }
    @Override
    public void setTestTypeMap(Map<Integer, Integer> testTypeMap) {
        this.testTypeMap = testTypeMap;
    }
    @Override
    public Map<Integer, Integer> getEventsTypeMap() {
        return eventsTypeMap;
    }
    @Override
    public void setEventsTypeMap(Map<Integer, Integer> eventsTypeMap) {
        this.eventsTypeMap = eventsTypeMap;
    }
    @Override
    public Map<Integer, Integer> getEventsLevelMap() {
        return eventsLevelMap;
    }
    @Override
    public void setEventsLevelMap(Map<Integer, Integer> eventsLevelMap) {
        this.eventsLevelMap = eventsLevelMap;
    }
    @Override
    public Map<Integer, Integer> getReportQuestionPriorityMap() {
        return reportQuestionPriorityMap;
    }
    @Override
    public void setReportQuestionPriorityMap(Map<Integer, Integer> reportQuestionPriorityMap) {
        this.reportQuestionPriorityMap = reportQuestionPriorityMap;
    }
    @Override
    public Map<Integer, Integer> getReportQuestionStatusMap() {
        return reportQuestionStatusMap;
    }
    @Override
    public void setReportQuestionStatusMap(Map<Integer, Integer> reportQuestionStatusMap) {
        this.reportQuestionStatusMap = reportQuestionStatusMap;
    }
    @Override
    public Map<Integer, Integer> getReportQuestionTypeMap() {
        return reportQuestionTypeMap;
    }
    @Override
    public void setReportQuestionTypeMap(Map<Integer, Integer> reportQuestionTypeMap) {
        this.reportQuestionTypeMap = reportQuestionTypeMap;
    }
    @Override
    public Map<Integer, Integer> getQuestionCategoryMap() {
        return questionCategoryMap;
    }
    @Override
    public void setQuestionCategoryMap(Map<Integer, Integer> questionCategoryMap) {
        this.questionCategoryMap = questionCategoryMap;
    }
    @Override
    public Map<Integer, Integer> getQuestionManageStatusMap() {
        return questionManageStatusMap;
    }
    @Override
    public void setQuestionManageStatusMap(Map<Integer, Integer> questionManageStatusMap) {
        this.questionManageStatusMap = questionManageStatusMap;
    }
    @Override
    public Map<Integer, Integer> getQuestionEvaluationLevelMap() {
        return questionEvaluationLevelMap;
    }
    @Override
    public void setQuestionEvaluationLevelMap(Map<Integer, Integer> questionEvaluationLevelMap) {
        this.questionEvaluationLevelMap = questionEvaluationLevelMap;
    }
    @Override
    public Map<Integer, Integer> getRiskDisposeMethodMap() {
        return riskDisposeMethodMap;
    }
    @Override
    public void setRiskDisposeMethodMap(Map<Integer, Integer> riskDisposeMethodMap) {
        this.riskDisposeMethodMap = riskDisposeMethodMap;
    }
    @Override
    public Map<Integer, Integer> getRiskDisposeStatusMap() {
        return riskDisposeStatusMap;
    }
    @Override
    public void setRiskDisposeStatusMap(Map<Integer, Integer> riskDisposeStatusMap) {
        this.riskDisposeStatusMap = riskDisposeStatusMap;
    }
    @Override
    public Map<Integer, Integer> getRiskCategoryMap() {
        return riskCategoryMap;
    }
    @Override
    public void setRiskCategoryMap(Map<Integer, Integer> riskCategoryMap) {
        this.riskCategoryMap = riskCategoryMap;
    }
    @Override
    public Map<Integer, Integer> getRiskStatusMap() {
        return riskStatusMap;
    }
    @Override
    public void setRiskStatusMap(Map<Integer, Integer> riskStatusMap) {
        this.riskStatusMap = riskStatusMap;
    }
    @Override
    public Map<Integer, Integer> getEventsMap() {
        return eventsMap;
    }
    @Override
    public void setEventsMap(Map<Integer, Integer> eventsMap) {
        this.eventsMap = eventsMap;
    }
    @Override
    public Map<Integer, Integer> getEventsCriticleMap() {
        return eventsCriticleMap;
    }
    @Override
    public void setEventsCriticleMap(Map<Integer, Integer> eventsCriticleMap) {
        this.eventsCriticleMap = eventsCriticleMap;
    }
    @Override
    public Map<Integer, Integer> getFormatColumnMap() {
        return formatColumnMap;
    }
    @Override
    public void setFormatColumnMap(Map<Integer, Integer> formatColumnMap) {
        this.formatColumnMap = formatColumnMap;
    }
    @Override
    public Map<Integer, Integer> getTaskColumnMap() {
        return taskColumnMap;
    }
    @Override
    public void setTaskColumnMap(Map<Integer, Integer> taskColumnMap) {
        this.taskColumnMap = taskColumnMap;
    }
    @Override
    public Map<Integer, Integer> getQuestionColumnMap() {
        return questionColumnMap;
    }
    @Override
    public void setQuestionColumnMap(Map<Integer, Integer> questionColumnMap) {
        this.questionColumnMap = questionColumnMap;
    }
    @Override
    public Map<Integer, Integer> getRiskColumnMap() {
        return riskColumnMap;
    }
    @Override
    public void setRiskColumnMap(Map<Integer, Integer> riskColumnMap) {
        this.riskColumnMap = riskColumnMap;
    }
}
