package com.kingrein.okitmigration.controller;


import com.google.gson.Gson;
import com.kingrein.okitmigration.model.ResultVO;
import com.kingrein.okitmigration.service.ProjectService;
import com.kingrein.okitmigration.service.RecordService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.io.IOException;
import java.util.*;

@RestController
@RequestMapping(value = "/project")
public class ProjectController {

    private Map<Integer, Map<String, Object>> projects ;

    private Set<Integer> projectIdSelected;

    @Resource
    private ProjectService projectService;
    @Resource
    private RecordService recordService;

    @GetMapping(value = {"","/"})
    public List listProject(){
        projects = projectService.listProject();
        List<Map<String, Object>> results = new ArrayList<>();
        Map<String, Object> item = new HashMap<>();
        for (Integer projectId: projects.keySet()){
            Map<String, Object> project = projects.get(projectId);
            item.put("id", project.get("id"));
            item.put("name", project.get("name"));
            item.put("project_code", project.get("project_code"));
            item.put("father_id", project.get("father_id"));
            results.add(item);
            item = new HashMap<>();
        }
        return results;
    }

    @PostMapping(value = "/selected")
    public ResultVO selectProjects(@RequestBody ArrayList<Integer> ids) throws IOException {
        projectIdSelected = new HashSet<>();
        projectIdSelected.addAll(ids);
        List<Map<String, Object>> projectList = new ArrayList<>();
        for (Integer id: ids){
            projectList.add(projects.get(id));
        }
        recordService.writeProjectListFile(new Gson().toJson(projectList).toString());
        //recordService.recordProjectList(ids);
        return new ResultVO("successed");
    }

}
