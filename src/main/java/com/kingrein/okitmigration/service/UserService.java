package com.kingrein.okitmigration.service;

import com.kingrein.okitmigration.util.TreeNode;

import java.util.List;
import java.util.Map;

public interface UserService {
    Map<String , Object> getSrcUser(Integer id);

    Map listSrcUser();

    Map listDestUser();

    Map<String, Object> getDestUser(Integer id);

    Map<Integer, Map<String, Object>> listAllSrcUnit();

    List< Map<String , Object>> listSrcUnit(Integer parentId);

    List<TreeNode<Map<String, Object>>> listSrcUnitTree();

    Map<Integer, Map<String, Object>> listAllDestUnit();

    List< Map<String , Object>> listDestUnit(Integer parentId);

    List<TreeNode<Map<String, Object>>> listDestUnitTree();
}
