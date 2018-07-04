package com.kingrein.okitmigration.mapperSrc;

import org.apache.ibatis.annotations.MapKey;

import java.util.List;
import java.util.Map;

public interface ProjectSrcMapper {

    @MapKey("id")
    Map<Integer,Map<String, Object>> listProject();

    @MapKey("id")
    Map<Integer, Map<String, Object>> listProjectByIds(List<Integer> ids);

    List<Map<String, Object>> listAllFile();

    List<Map<String, Object>> listProjectPerson(List<Integer> ids);
    List<Map<String, Object>> listProjectPersonAuth(List<Integer> ids);

    List<Map<String, Object>> listWorkflow();
    List<Map<String, Object>> listAllWorkflowTask();

    List<Map<String, Object>> listProjectType();
    List<Map<String, Object>> listProjectStatus();
    List<Map<String, Object>> listProjectLevel();
    List<Map<String, Object>> listProjectImportance();
    List<Map<String, Object>> listProjectStage();

    /**
     * 产品IDKey
     * @param ids
     * @return
     */
    List<Map<String, Object>> listProductByProjectIds(List<Integer> ids);
    List<Map<String , Object>> listProductVersionByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listProductVersionModuleByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listProductProjectByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listProductVersionProjectByProjectIds(List<Integer> ids) ;
    List<Map<String, Object>> listProductVersionModuleProjectByProjectIds(List<Integer> ids);
    List<Map<String , Object>> listProductAuthByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listSvnNode();
    List<Map<String, Object>> listSvnConfigDirectoryByProject(List<Integer> projectIds);

    //缺陷导入导入开始
    List<Map<String, Object>> listTicketByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTicketPageEntityColumm();
    List<Map<String, Object>> listFileByTicketProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTicketFileByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTicketHistoryByProjectIds(List<Integer> ids);

    /**
     * 获取workflow_task
     * @param ids
     * @return
     */
    List<Map<String, Object>> listWorkflowTaskByTicketProjectIds(List<Integer> ids);

    /**
     * 获取workflow_taskticket
     * @param ids
     * @return
     */
    List<Map<String, Object>> listWorkflowTaskTicketByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTicketWorkflowHistoryByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTicketWorkflowHistoryFileByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTicketType();
    List<Map<String, Object>> listTicketStatus();
    List<Map<String, Object>> listTicketSource();
    List<Map<String, Object>> listTicketSeverity();
    List<Map<String, Object>> listTicketResolution();
    List<Map<String, Object>> listTicketPriority();
    List<Map<String, Object>> listTicketFrequency();
    List<Map<String, Object>> listTicketCategory();
    List<Map<String, Object>> listTicketTestcaseStepByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTicketFormatItemByProjectIds(List<Integer> ids) ;

    //需求
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

    List<Map<String, Object>> listFormatDocByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listFormatDocFloderByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listFormatEditionByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listFormatSectionByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listFormatItemEditionByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listFormatItemChangedRecordByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listFormatItemCommByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listFormatItemDisposeHistoryByProjectids(List<Integer> ids);
    List<Map<String, Object>> listFormatItemEditionChangeByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listFormatItemModifyHistoryByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRFormatDocFloderByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRFormatDocItemTypeByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRFormatDocFileByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRFormatDocsByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRFormatItemProductByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRFormatItemFileByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRformatItemsByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRFormtSectionItemByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRUserFormatDocByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRUserFormatDocStatusByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowTaskFormatItemByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowTaskWithinFormatByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowHistoryWithinFormatByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRWorkflowHistoryFileWithinFormatByProjectIds(List<Integer> ids);

    //测试用例
    List<Map<String, Object>> listTestActivityLevel();
    List<Map<String, Object>> listTestActivityStatus();
    List<Map<String, Object>> listTestCasePriority();
    List<Map<String, Object>> listTestCaseStatus();
    List<Map<String, Object>> listTestMethod();
    List<Map<String, Object>> listTestRule();
    List<Map<String, Object>> listTestStageCategory();
    List<Map<String, Object>> listTestType();
    List<Map<String, Object>> listTestActivityByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listTestActivityStageByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listTestDescByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listTestDescSectionByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listTestDescStepResultByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listTestDescriptionCaseResultByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listTestDescFormatDocByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listRTestDescStepTicketByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listRTestDestCaseFileByProjectIds(List<Integer> projectIds);
    List<Map<String, Object>> listRTestDescCaseItemEditionByProjectIds(List<Integer> projectIds);


    //计划任务
    List<Map<String, Object>> listSTaskType();
    List<Map<String, Object>> listSTaskStatus();
    List<Map<String, Object>> listSTaskLogType();
    List<Map<String, Object>> listSTaskSatisfaction();
    List<Map<String, Object>> listSTaskImportant();
    List<Map<String, Object>> listSTaskCategory();
    List<Map<String, Object>> listPlanByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTaskByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRTaskFileByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTaskLogByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTaskPredecessorLinkByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTaskProgressHistoryByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTaskHistoryByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTaskAssignmentByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listTaskAcceptanceByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRTaskItemByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRTaskCaseByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listReportQuestionWithinTaskByProjectIds(List<Integer> ids);      //报告及反馈，和项目论坛为同一个表
    List<Map<String, Object>> listRQuestionFileWithinTaskByProjectIds(List<Integer> ids);

    //项目日志
    List<Map<String, Object>> listSMemorabiliaType();
    List<Map<String, Object>> listSEventsLevel();
    List<Map<String, Object>> listMemorabiliaByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRMemorabiliaFileByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRMemorabiliaUserProject(List<Integer> ids);
    List<Map<String, Object>> listEventsCriticleByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listEventsCriticleFileByProjectIds(List<Integer> ids);

    //项目论坛
    List<Map<String, Object>> listReportQuestionByProjectIds(List<Integer> ids);            //项目论坛，和计划任务报告反馈为同一表
    List<Map<String, Object>> listSQuestionPriority();
    List<Map<String, Object>> listSQuestionStatus();
    List<Map<String, Object>> listSQuestionType();
    List<Map<String, Object>> listRQuestionFileByProjectIds(List<Integer> ids);

    //项目问题
    List<Map<String, Object>> listQuestionPageEntityColumn();
    List<Map<String, Object>> listSQuestionCategory();
    List<Map<String, Object>> listSQuestionManageStatus();
    List<Map<String, Object>> listSQuestionEvaluationLevel();
    List<Map<String, Object>> listQuestionByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRQuestionManagFileByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowTaskQuestionByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowTaskWithinQuestionByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowHistoryWithinQuestionByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowHistoryFileWithinQuestionByProjectIds(List<Integer> ids);

    //项目风险
    List<Map<String, Object>> listProjectRiskPageEntityColumn();
    List<Map<String, Object>> listSRiskDisposeMethod();
    List<Map<String, Object>> listSRiskDisposeStatus();
    List<Map<String, Object>> listSRiskCategory();
    List<Map<String, Object>> listSRiskStatus();
    List<Map<String, Object>> listProjectRiskByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listRProjectRiskFileByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowTaskProjectRiskByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowWithinProjectRiskByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowHistoryWithinProjectRiskByProjectIds(List<Integer> ids);
    List<Map<String, Object>> listWorkflowHistoryFileWithInProjectRiskByProjectIds(List<Integer> ids);


}
