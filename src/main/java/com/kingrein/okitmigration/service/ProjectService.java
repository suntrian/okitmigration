package com.kingrein.okitmigration.service;

import com.kingrein.okitmigration.util.TreeNode;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Set;

public interface ProjectService {
    Map<Integer,Map<String, Object>> listSrcProject();

    Map<Integer, Map<String, Object>> listDestProject();

    Map<Integer, Map<String, Object>> listSrcProject(List<Integer> ids);

    Map<Integer, Map<String, Object>> listDestProject(List<Integer> ids);

    List<TreeNode<Map<String, Object>>> listSrcProjectTree();

    Map<Integer,Map<String, Object>> listPageEntityColumnsByEntityColumnIds(List<Integer> columnIds, Integer entityId, String srcOrDest);

    List<TreeNode<Map<String, Object>>> listDestProjectTree();

    List<Map<String, Object>> listSvnNode();

    List<Map<String, Object>> listSrcTicketEntityColumn();

    List<Map<String, Object>> listDestTicketEntityColumn();

    List<Map<String, Object>> listTicketType(String srcOrDest);

    List<Map<String , Object>> listTicketStatus(String srcOrDest);

    List<Map<String, Object>> listTicketSource(String srcOrDest);

    List<Map<String, Object>> listTicketSeverity(String srcOrDest);

    List<Map<String, Object>> listTicketPriority(String srcOrDest);

    List<Map<String , Object>> listTicketCategory(String srcOrDest);

    List<Map<String , Object>> listTicketResolution(String srcOrDest);

    List<Map<String, Object>> listTicketFrequency(String srcOrDest);

    List<Map<String, Object>> listFormatStandard(String standard, String srcOrDest);

    List<Map<String, Object>> listTestStandard(String standard, String srcOrDest);

    List<Map<String, Object>> listTaskStandard(String standard, String srcOrDest);

    List<Map<String, Object>> listEventsStandard(String standard, String srcOrDest);

    List<Map<String, Object>> listForumStandard(String standard, String srcOrDest);

    List<Map<String, Object>> listQuestionStandard(String standard, String srcOrDest);

    List<Map<String, Object>> listRiskStandard(String standard, String srcOrDest);

    List<Map<String, Object>> listFormatColumns(String srcOrDest);

    List<Map<String, Object>> listRiskColumns(String srcOrDest);

    List<Map<String, Object>> listQuestionColumns(String srcOrDest);

    List<Map<String, Object>> listWorkflow(String srcOrDest);

    void addDestProject(Map<String, Object> project) throws Exception;
    void addDestProject(Integer srcProjectId) throws Exception;

    @Transactional
    void importProject(List<Integer> projectIds);

    @Transactional
    void importProduct(List<Integer> projectIds);

    @Transactional
    void importSvnDbData(List<Integer> projectIds) throws Exception;

    @Transactional
    void importFileDbData();

    @Transactional
    void importTicket(List<Integer> projectIds);

    @Transactional
    void importRequirement(List<Integer> ids);

    void importTask(List<Integer> ids);

    @Transactional
    void importTest(List<Integer> projectIds);

    @Transactional
    void importEvents(List<Integer> projectIds);

    @Transactional
    void importForum(List<Integer> projectIds);

    @Transactional
    void importQuestion(List<Integer> projectIds);

    @Transactional
    void importRisk(List<Integer> projectIds);

    List<Integer> getProjectToImport();

    void setProjectToImport(List<Integer> projectToImport);

    Map<Integer, Integer> getProjectMap();

    void setProjectMap(Map<Integer, Integer> projectMap);

    Map<String, String> getWorkflowMap();

    void setWorkflowMap(Map<String, String> workflowMap);

    Integer getSvnDestNode();

    void setSvnDestNode(Integer svnDestNode);

    Map<Integer, Integer> getTicketTypeMap();

    void setTicketTypeMap(Map<Integer, Integer> ticketTypeMap);

    Map<Integer, Integer> getTicketStatusMap();

    void setTicketStatusMap(Map<Integer, Integer> ticketStatusMap);

    Map<Integer, Integer> getTicketSourceMap();

    void setTicketSourceMap(Map<Integer, Integer> ticketSourceMap);

    Map<Integer, Integer> getTicketSeverityMap();

    void setTicketSeverityMap(Map<Integer, Integer> ticketSeverityMap);

    Map<Integer, Integer> getTicketResolutionMap();

    void setTicketResolutionMap(Map<Integer, Integer> ticketResolutionMap);

    Map<Integer, Integer> getTicketPriorityMap();

    void setTicketPriorityMap(Map<Integer, Integer> ticketPriorityMap);

    Map<Integer, Integer> getTicketCategoryMap();

    void setTicketCategoryMap(Map<Integer, Integer> ticketCategoryMap);

    Map<Integer, Integer> getTicketFrequencyMap();

    void setTicketFrequencyMap(Map<Integer, Integer> ticketFrequencyMap);

    Map<Integer, Integer> getWorkflowHistoryMap();

    void setWorkflowHistoryMap(Map<Integer, Integer> workflowHistoryMap);

    Map<Integer, Integer> getTicketColumnMap();

    void setTicketColumnMap(Map<Integer, Integer> ticketColumnMap);

    Map<Integer, Integer> getFormatItemTypeMap();

    void setFormatItemTypeMap(Map<Integer, Integer> formatItemTypeMap);

    Map<Integer, Integer> getFormatDocTypeMap();

    void setFormatDocTypeMap(Map<Integer, Integer> formatDocTypeMap);

    Map<Integer, Integer> getFormatItemStatusMap();

    void setFormatItemStatusMap(Map<Integer, Integer> formatItemStatusMap);

    Map<Integer, Integer> getFormatItemChangeMap();

    void setFormatItemChangeMap(Map<Integer, Integer> formatItemChangeMap);

    Map<Integer, Integer> getFormatItemFileTypeMap();

    void setFormatItemFileTypeMap(Map<Integer, Integer> formatItemFileTypeMap);

    Map<Integer, Integer> getFormatAlteredStatusMap();

    void setFormatAlteredStatusMap(Map<Integer, Integer> formatAlteredStatusMap);

    Map<Integer, Integer> getFormatChangedMannerMap();

    void setFormatChangedMannerMap(Map<Integer, Integer> formatChangedMannerMap);

    Map<Integer, Integer> getFormatDifficultyMap();

    void setFormatDifficultyMap(Map<Integer, Integer> formatDifficultyMap);

    Map<Integer, Integer> getFormatExpectedLevelMap();

    void setFormatExpectedLevelMap(Map<Integer, Integer> formatExpectedLevelMap);

    Map<Integer, Integer> getFormatStabilityMap();

    void setFormatStabilityMap(Map<Integer, Integer> formatStabilityMap);

    Map<Integer, Integer> getTaskTypeMap();

    void setTaskTypeMap(Map<Integer, Integer> taskTypeMap);

    Map<Integer, Integer> getTaskStatusMap();

    void setTaskStatusMap(Map<Integer, Integer> taskStatusMap);

    Map<Integer, Integer> getTaskLogTypeMap();

    void setTaskLogTypeMap(Map<Integer, Integer> taskLogTypeMap);

    Map<Integer, Integer> getTaskCategoryMap();

    void setTaskCategoryMap(Map<Integer, Integer> taskCategoryMap);

    Map<Integer, Integer> getTaskImportantMap();

    void setTaskImportantMap(Map<Integer, Integer> taskImportantMap);

    Map<Integer, Integer> getTaskSatisfactionMap();

    void setTaskSatisfactionMap(Map<Integer, Integer> taskSatisfactionMap);

    Map<Integer, String> getEntities();

    void setEntities(Map<Integer, String> entities);

    Map<Integer, Integer> getTaskFileTypeMap();

    void setTaskFileTypeMap(Map<Integer, Integer> taskFileTypeMap);

    Map<Integer, Integer> getReportQuestionMap();

    void setReportQuestionMap(Map<Integer, Integer> reportQuestionMap);

    Map<Integer, Integer> getTestActivityLevelMap();

    void setTestActivityLevelMap(Map<Integer, Integer> testActivityLevelMap);

    Map<Integer, Integer> getTestActivityStatusMap();

    void setTestActivityStatusMap(Map<Integer, Integer> testActivityStatusMap);

    Map<Integer, Integer> getTestCasePriorityMap();

    void setTestCasePriorityMap(Map<Integer, Integer> testCasePriorityMap);

    Map<Integer, Integer> getTestCaseStatusMap();

    void setTestCaseStatusMap(Map<Integer, Integer> testCaseStatusMap);

    Map<Integer, Integer> getTestMethodMap();

    void setTestMethodMap(Map<Integer, Integer> testMethodMap);

    Map<Integer, Integer> getTestRuleMap();

    void setTestRuleMap(Map<Integer, Integer> testRuleMap);

    Map<Integer, Integer> getTestStageCategoryMap();

    void setTestStageCategoryMap(Map<Integer, Integer> testStageCategoryMap);

    Map<Integer, Integer> getTestTypeMap();

    void setTestTypeMap(Map<Integer, Integer> testTypeMap);

    Map<Integer, Integer> getEventsTypeMap();

    void setEventsTypeMap(Map<Integer, Integer> eventsTypeMap);

    Map<Integer, Integer> getEventsLevelMap();

    void setEventsLevelMap(Map<Integer, Integer> eventsLevelMap);

    Map<Integer, Integer> getReportQuestionPriorityMap();

    void setReportQuestionPriorityMap(Map<Integer, Integer> reportQuestionPriorityMap);

    Map<Integer, Integer> getReportQuestionStatusMap();

    void setReportQuestionStatusMap(Map<Integer, Integer> reportQuestionStatusMap);

    Map<Integer, Integer> getReportQuestionTypeMap();

    void setReportQuestionTypeMap(Map<Integer, Integer> reportQuestionTypeMap);

    Map<Integer, Integer> getQuestionCategoryMap();

    void setQuestionCategoryMap(Map<Integer, Integer> questionCategoryMap);

    Map<Integer, Integer> getQuestionManageStatusMap();

    void setQuestionManageStatusMap(Map<Integer, Integer> questionManageStatusMap);

    Map<Integer, Integer> getQuestionEvaluationLevelMap();

    void setQuestionEvaluationLevelMap(Map<Integer, Integer> questionEvaluationLevelMap);

    Map<Integer, Integer> getRiskDisposeMethodMap();

    void setRiskDisposeMethodMap(Map<Integer, Integer> riskDisposeMethodMap);

    Map<Integer, Integer> getRiskDisposeStatusMap();

    void setRiskDisposeStatusMap(Map<Integer, Integer> riskDisposeStatusMap);

    Map<Integer, Integer> getRiskCategoryMap();

    void setRiskCategoryMap(Map<Integer, Integer> riskCategoryMap);

    Map<Integer, Integer> getRiskStatusMap();

    void setRiskStatusMap(Map<Integer, Integer> riskStatusMap);

    Map<Integer, Integer> getEventsMap();

    void setEventsMap(Map<Integer, Integer> eventsMap);

    Map<Integer, Integer> getEventsCriticleMap();

    void setEventsCriticleMap(Map<Integer, Integer> eventsCriticleMap);

    Map<Integer, Integer> getFormatColumnMap();

    void setFormatColumnMap(Map<Integer, Integer> formatColumnMap);

    Map<Integer, Integer> getTaskColumnMap();

    void setTaskColumnMap(Map<Integer, Integer> taskColumnMap);

    Map<Integer, Integer> getQuestionColumnMap();

    void setQuestionColumnMap(Map<Integer, Integer> questionColumnMap);

    Map<Integer, Integer> getRiskColumnMap();

    void setRiskColumnMap(Map<Integer, Integer> riskColumnMap);
}
