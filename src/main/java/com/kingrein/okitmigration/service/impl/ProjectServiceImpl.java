package com.kingrein.okitmigration.service.impl;

import com.kingrein.okitmigration.mapperSrc.ProjectSrcMapper;
import com.kingrein.okitmigration.service.ProjectService;
import com.kingrein.okitmigration.util.TreeNode;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.*;

@Service("projectService")
public class ProjectServiceImpl implements ProjectService {

    @Resource
    private ProjectSrcMapper projectSrcMapper;

    @Override
    public Map<Integer, Map<String, Object>>  listSrcProject(){
        return projectSrcMapper.listProject();
    }

    @Override
    public Map<Integer, Map<String, Object>> listSrcProject(List<Integer> ids){
        return projectSrcMapper.listProjectByIds(ids);
    }

    @Override
    public List<TreeNode<Map<String, Object>>> listProjectTree(){
        Map<Integer, Map<String, Object>> projects = listSrcProject();
        List<TreeNode<Map<String, Object>>> roots = new ArrayList<>();
        Map<Integer, TreeNode> hasContained = new HashMap<>();
        while (!projects.isEmpty()){
            Iterator<Map.Entry<Integer, Map<String, Object>>> iterator = projects.entrySet().iterator();
            while (iterator.hasNext()) {
                Map.Entry<Integer, Map<String, Object>> projectEntry = iterator.next();
                Integer projectId = projectEntry.getKey();
                Map<String, Object> project = projectEntry.getValue();
                Integer parent_id = project.get("father_id") == null ? null : (Integer) project.get("father_id");
                TreeNode<Map<String, Object>> node = new TreeNode<>(project);
                if (parent_id == null) {
                    roots.add(node);
                    hasContained.put(projectId, node);
                    iterator.remove();
                } else {
                    if (hasContained.containsKey(parent_id)){
                        hasContained.get(parent_id).addChild(node);
                        hasContained.put(projectId, node);
                        iterator.remove();
                    }
                }
            }
        }
        return roots;
    }

    @Override
    public List<TreeNode<Map<String, Object>>> listProjectSelected(){
        List<TreeNode<Map<String, Object>>> roots = new ArrayList<>();
        return roots;
    }



}
