package com.kingrein.okitmigration.mapperDest;


import org.apache.ibatis.annotations.MapKey;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface UserDestMapper {

    Map<String, Object> getUser(Integer id);

    @MapKey("id")
    Map<Integer, Map<String, Object>>  listAllUser();

    @MapKey("id")
    Map<Integer, Map<String, Object>> listUserByIds(Integer[] ids);

    List<Map<String , Object>> listUnitByParent(@Param("id") Integer parentId);

    @MapKey("id")
    Map<Integer, Map<String, Object>> listAllUnit();

    Map<String, Object> getUnit(Integer id);

    List<Map<String, Object>> listAllUserOrderByName();

    List<Map<String, Object>> listUserByName(String name);

    Integer addUnit(Map<String, Object> unit);

    Integer addPerson(Map<String, Object> person);

    Integer addUser(Map<String, Object> user);
}
