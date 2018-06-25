package com.kingrein.okitmigration.service;

import com.kingrein.okitmigration.util.TreeNode;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public interface UserService {
    Map<String , Object> getSrcUser(Integer id);

    Map listSrcUser();

    Map listDestUser();

    Map<String, Object> getDestUser(Integer id);

    Map<String, Object> getSrcUnit(Integer id);

    Map<String, Object> getDestUnit(Integer id);

    Map<Integer, Map<String, Object>> listAllSrcUnit();

    List< Map<String , Object>> listSrcUnit(Integer parentId);

    List<TreeNode<Map<String, Object>>> listSrcUnitTree();

    Map<Integer, Map<String, Object>> listAllDestUnit();

    List< Map<String , Object>> listDestUnit(Integer parentId);

    List<TreeNode<Map<String, Object>>> listDestUnitTree();

    List<Map<String, Object>> listUserNotMapped() throws IOException;

    List<Map<String, Object>>  listDestUserByName(String name);

    Boolean addUnitBySrcUnitId(Integer id);
}
