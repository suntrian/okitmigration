package com.kingrein.okitmigration.controller;


import com.kingrein.okitmigration.service.ProjectService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(value = "/project")
public class ProjectController {

    @Resource
    private ProjectService projectService;

    @GetMapping(value = {"","/"})
    public List listProject(){
        List<Map<String, Object>> projects = projectService.listProject();
        List<Map<String, Object>> results = new ArrayList<>();
        Map<String, Object> item = new HashMap<>();
        for (Map project: projects){
            item.put("id", project.get("id"));
            item.put("name", project.get("name"));
            item.put("project_code", project.get("project_code"));
            item.put("father_id", project.get("father_id"));
            results.add(item);
            item = new HashMap<>();
        }
        return results;
    }

}
