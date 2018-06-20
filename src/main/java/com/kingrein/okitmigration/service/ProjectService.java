package com.kingrein.okitmigration.service;

import com.kingrein.okitmigration.util.TreeNode;

import java.util.List;
import java.util.Map;

public interface ProjectService {
    Map<Integer,Map<String, Object>> listProject();

    List<TreeNode<Map<String, Object>>> listProjectTree();

    List<TreeNode<Map<String, Object>>> listProjectSelected();
}
