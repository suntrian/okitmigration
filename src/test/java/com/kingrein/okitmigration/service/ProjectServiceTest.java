package com.kingrein.okitmigration.service;

import com.kingrein.okitmigration.OkitmigrationApplicationTests;
import com.kingrein.okitmigration.util.TreeNode;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

public class ProjectServiceTest extends OkitmigrationApplicationTests {

    @Autowired
    private ProjectService projectService;

    @Test
    public void testListProjectTree(){
        Map<Integer, Map<String, Object>> projectsMap = projectService.listSrcProject();
        List<TreeNode<Map<String, Object>>> projectTree = projectService.listSrcProjectTree();
        System.out.println(projectTree);
    }

    @Transactional
    @Test
    public void testImportFormat() {

    }

}
