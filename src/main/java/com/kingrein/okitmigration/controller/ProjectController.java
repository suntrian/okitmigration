package com.kingrein.okitmigration.controller;


import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.kingrein.okitmigration.model.ResultVO;
import com.kingrein.okitmigration.service.ProjectService;
import com.kingrein.okitmigration.service.RecordService;
import com.kingrein.okitmigration.util.TreeNode;
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
        projects = projectService.listSrcProject();
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

    @PostMapping(value = "/selected")
    public ResultVO selectProjects(@RequestBody ArrayList<Integer> ids) throws IOException {
        projectIdSelected = new HashSet<>();
        projectIdSelected.addAll(ids);
        recordService.recordProjectList(ids);
        //recordService.recordProjectList(ids);
        return new ResultVO("successed");
    }

    @GetMapping(value = "/selected")
    public List<Map<String , Object>> listProjectSelected() throws IOException {
        JsonArray json = recordService.readProjectList();
        List<Map<String, Object>> result = new ArrayList<>();
        Map<String, Object> item = new HashMap<>();
        for (JsonElement obj: json){
            item.put("id", obj.getAsJsonObject().get("id").getAsInt());
            item.put("text", obj.getAsJsonObject().get("name").getAsString());
            result.add(item);
            item = new HashMap<>();
        }
        return result;
    }

    public List<TreeNode<Map<String, Object>>> listProjectTree(){
        List<TreeNode<Map<String, Object>>> result = projectService.listProjectTree();
        return result;
    }


    @PostMapping(value = "/map")
    public ResultVO setProjectMap(@RequestParam("src") Integer src,@RequestParam("dest") Integer dest) {
        
        return new ResultVO("succeed");
    }

}
