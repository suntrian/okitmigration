package com.kingrein.okitmigration.mapperDest;

import org.apache.ibatis.annotations.MapKey;
import org.apache.ibatis.annotations.Param;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface ProjectDestMapper {

    @MapKey("id")
    Map<Integer, Map<String, Object>> listProject();

    @MapKey("id")
    Map<Integer, Map<String, Object>> listProjectByIds(List<Integer> ids);

    List<Map<String, Object>> listWorkflow();
    Integer addWorkflowTask(Map<String, Object> workflowTask);
    Integer addWorkflowHistory(Map<String, Object> workflowHistory);
    Integer addWorkflowHistoryFile(Map<String, Object> workflowHistoryFile);

    List<Map<String, Object>> listProjectType();
    List<Map<String, Object>> listProjectStatus();
    List<Map<String, Object>> listProjectLevel();
    List<Map<String, Object>> listProjectImportance();
    List<Map<String, Object>> listProjectStage();
    @MapKey("column_id")
    Map<Integer, Map<String, Object>> listPageEntityColumnsByColumnIds(Map<String, Object> params);

    Integer addProject(Map<String, Object> project);
    Integer addProjectPerson(Map<String, Object> projectPerson);
    Integer addProjectPersonAuth(Map<String, Object> projectPersonAuth);

    List<Map<String, Object>> listSvnNode();

    //SVN导入
    Integer addProduct(Map<String, Object> product);
    Integer addProductVersion(Map<String, Object> productVersion);
    Integer addProductVersionModule(Map<String, Object> productVersionModule);
    Integer addProductProject(Map<String, Object> productProject);
    Integer addProductVersionProject(Map<String, Object> productVersionProject);
    Integer addProductVersionModuleProject(Map<String, Object> productVersionModuleProject);
    Integer addProductAuth(Map<String, Object> productAuth);
    Integer addSvnConfigDirectory(Map<String, Object> svnConfigDirectory);

    //缺陷导入
    List<Map<String, Object>> listTicketPageEntityColumm();
    List<Map<String, Object>> listTicketType();
    List<Map<String, Object>> listTicketStatus();
    List<Map<String, Object>> listTicketSource();
    List<Map<String, Object>> listTicketSeverity();
    List<Map<String, Object>> listTicketResolution();
    List<Map<String, Object>> listTicketPriority();
    List<Map<String, Object>> listTicketFrequency();
    List<Map<String, Object>> listTicketCategory();
    Integer addTicket(Map<String, Object> ticket);
    Integer addFile(Map<String, Object> file);
    Integer addTicketFile(Map<String, Object> ticketFille);
    Integer addTicketHistory(Map<String, Object> ticketHistory);
    Integer addWorkflowTaskTicket(Map<String, Object> workflowTaskTicket);
    Integer addTicketFormatItem(Map<String,Object> item);
    Integer updateTicketMilestone(@Param("ticket") String Ticketuid, @Param("milestone") String milestoneUid);

    //需求导入开始
    List<Map<String, Object>> listFormatPageEntityColumn();
    List<Map<String, Object>> listFormatItemStatus();
    List<Map<String, Object>> listFormatItemType();
    List<Map<String, Object>> listFormatDifficulty();
    List<Map<String, Object>> listFormatStability();
    List<Map<String, Object>> listFormatExpectedLevel();
    List<Map<String, Object>> listFormatItemChange();
    List<Map<String, Object>> listFormatAlteredStatus();
    List<Map<String, Object>> listFormatDocType();
    List<Map<String, Object>> listFormatPrivileges();
    List<Map<String, Object>> listFormatChangedManner();
    Integer addFormatDoc(Map<String, Object> formatDoc);
    Integer addFormatDocFloder(Map<String, Object> item);
    Integer addFormatDocWorkflow(Map<String, Object> item);
    Integer addFormatEdition(Map<String, Object> item);
    Integer addFormatSection(Map<String, Object> item);
    Integer addFormatItemEdition(Map<String, Object> item);
    Integer addFormatItemChangedRecord(Map<String, Object> item);
    Integer addFormatItemComm(Map<String, Object> item);
    Integer addFormatItemDisposeHistory(Map<String, Object> item);
    Integer addFormatItemEditionChange(Map<String, Object> item);
    Integer addFormatItemModifyHistory(Map<String, Object> item);
    Integer addRFormatDocFloder(Map<String, Object> item);
    Integer addRFormatDocItemType(Map<String, Object> item);
    Integer addRFormatDocFile(Map<String, Object> item);
    Integer addRFormatDocs(Map<String, Object> item);
    Integer addRFormatItemProduct(Map<String, Object> item);
    Integer addRFormatItemFile(Map<String, Object> item);
    Integer addRFormatItems(Map<String, Object> item);
    Integer addRFormatSectionItem(Map<String, Object> item);
    Integer addRUserFormatDoc(Map<String, Object> item);
    Integer addRUserFormatDocStatus(Map<String, Object> item);
    Integer addWorkflowTaskFormatFormatItem(Map<String, Object> item);

    //测试用例
    List<Map<String, Object>> listTestActivityLevel();
    List<Map<String, Object>> listTestActivityStatus();
    List<Map<String, Object>> listTestCasePriority();
    List<Map<String, Object>> listTestCaseStatus();
    List<Map<String, Object>> listTestMethod();
    List<Map<String, Object>> listTestRule();
    List<Map<String, Object>> listTestStageCategory();
    List<Map<String, Object>> listTestType();
    Integer addTestActivity(Map<String, Object> item);
    Integer addTestActivityStage(Map<String, Object> item);
    Integer addTestDesc(Map<String, Object> item);
    Integer addTestDescSection(Map<String, Object> item);
    Integer addTestDescStepResult(Map<String, Object> item);
    Integer addTestDescriptionCaseResult(Map<String, Object> item);
    Integer addTestDescFormatDoc(Map<String, Object> item);
    Integer addRTestDescStepTicket(Map<String, Object> item);
    Integer addRTestDescCaseFile(Map<String, Object> item);
    Integer addRTestDescCaseItemEdition(Map<String, Object> item);

    //计划任务
    List<Map<String, Object>> listSTaskType();
    List<Map<String, Object>> listSTaskStatus();
    List<Map<String, Object>> listSTaskLogType();
    List<Map<String, Object>> listSTaskSatisfaction();
    List<Map<String, Object>> listSTaskImportant();
    List<Map<String, Object>> listSTaskCategory();
    @MapKey("project_id")
    Map<Integer, Map<String, Object>> listRootTaskByProjectIds(List<Integer> ids);
    Integer addPlan(Map<String, Object> item);
    Integer addTask(Map<String, Object> item) throws DataAccessException;
    Integer addTaskLog(Map<String, Object> item);
    Integer addTaskHistory(Map<String, Object> item);
    Integer addTaskAssignment(Map<String, Object> item);
    Integer addTaskAcceptance(Map<String, Object> item);
    Integer addRTaskFile(Map<String, Object> item);
    Integer addTaskPredecessorLink(Map<String, Object> item);
    Integer addTaskProgressHistory(Map<String, Object> item);
    Integer addRTaskItem(Map<String, Object> item);
    Integer addRTaskCase(Map<String, Object> item);
    Integer addReportQuestion(Map<String, Object> item);
    Integer addRQuestionFile(Map<String, Object> item);

    //项目日志
    List<Map<String, Object>> listSMemorabiliaType();
    List<Map<String, Object>> listSEventsLevel();
    Integer addMemorabilia(Map<String, Object> item);
    Integer addRMemorabiliaFile(Map<String, Object> item);
    Integer addRMemorabiliaUserProject(Map<String, Object> item);
    Integer addEventsCriticle(Map<String, Object> item);
    Integer addEventsCriticleFile(Map<String, Object> item);

    //项目论坛
    List<Map<String, Object>> listSQuestionPriority();
    List<Map<String, Object>> listSQuestionStatus();
    List<Map<String, Object>> listSQuestionType();

    //项目问题
    List<Map<String, Object>> listQuestionPageEntityColumn();
    List<Map<String, Object>> listSQuestionCategory();
    List<Map<String, Object>> listSQuestionManageStatus();
    List<Map<String, Object>> listSQuestionEvaluationLevel();
    Integer addQuestion(Map<String, Object> item);
    Integer addRQuestionManageFile(Map<String, Object> item);
    Integer addWorkflowTaskQuestion(Map<String, Object> item);

    //项目风险
    List<Map<String, Object>> listProjectRiskPageEntityColumn();
    List<Map<String, Object>> listSRiskDisposeMethod();
    List<Map<String, Object>> listSRiskDisposeStatus();
    List<Map<String, Object>> listSRiskCategory();
    List<Map<String, Object>> listSRiskStatus();
    Integer addProjectRisk(Map<String, Object> item);
    Integer addRProjectRiskFile(Map<String, Object> item);
    Integer addWorkflowTaskRisk(Map<String, Object> item);


}
