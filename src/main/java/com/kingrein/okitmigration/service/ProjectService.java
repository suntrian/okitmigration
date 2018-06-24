package com.kingrein.okitmigration.service;

import com.kingrein.okitmigration.util.TreeNode;

import java.util.List;
import java.util.Map;

public interface ProjectService {
    Map<Integer,Map<String, Object>> listSrcProject();

    Map<Integer, Map<String, Object>> listSrcProject(List<Integer> ids);

    List<TreeNode<Map<String, Object>>> listProjectTree();

    List<TreeNode<Map<String, Object>>> listProjectSelected();
}
