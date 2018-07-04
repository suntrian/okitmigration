package com.kingrein.okitmigration.mapperSrc;

import com.kingrein.okitmigration.OkitmigrationApplicationTests;
import org.junit.Assert;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Map;

public class UserMapperTest  extends OkitmigrationApplicationTests {

    Logger logger = LoggerFactory.getLogger(UserMapperTest.class);

    @Autowired
    private UserSrcMapper userMapper;

    @Test
    public void testGetUser(){
        Map<String, Object> user = userMapper.getSimpleUser(1);
        Assert.assertNotNull(user);
        logger.debug(user.get("username").toString());
        System.out.println(user.get("username"));
    }

    @Test
    public void testListUser(){
        Map<Integer, Map<String ,Object>> users = userMapper.listAllUser();
        Assert.assertTrue(users.size()>0);
        System.out.println(users.get(2).get("name"));
    }

    @Test
    public void testListUnit(){
        List< Map<String ,Object>> units = userMapper.listUnitByParent(null);
        Assert.assertTrue(units.size()>0);
        System.out.println(units.get(1).get("name"));
    }
}
