package com.kingrein.okitmigration.service;

import com.kingrein.okitmigration.util.RecordFile;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.util.List;

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

    private RecordFile recordFile = new RecordFile();

    public void recordProjectList(List<Integer> projectIds) throws IOException {
        recordFile.writeRecordFile(projectIds.toString(), new File(rootDir, projectListFile).toString());
    }

    public void recordUnitMap(Integer src, Integer dest) throws IOException {
        recordFile.writeRecordFile( new File(rootDir, unitMapFile).toString() ,src+ ":"+dest);
    }

}
