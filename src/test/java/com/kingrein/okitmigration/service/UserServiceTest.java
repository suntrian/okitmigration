package com.kingrein.okitmigration.service;

import com.kingrein.okitmigration.OkitmigrationApplicationTests;
import com.kingrein.okitmigration.util.TreeNode;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Map;

public class UserServiceTest extends OkitmigrationApplicationTests {

    @Autowired
    private UserService userService;

    @Test
    public void testListUnitTree(){
        List<TreeNode<Map<String, Object>>> units = userService.listSrcUnitTree();
        System.out.println(units);
    }

}
