package com.kingrein.okitmigration.mapperSrc;


import org.apache.ibatis.annotations.MapKey;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface UserSrcMapper {

    Map<String, Object> getUser(Integer id);

    @MapKey("id")
    Map<Integer, Map<String, Object>>  listAllUser();

    List<Map<String , Object>> listUnitByParent(@Param("id") Integer parentId);

    @MapKey("id")
    Map<Integer, Map<String, Object>> listAllUnit();

    Map<String, Object> getUnit(Integer id);

    List<Map<String, Object>> listAllUserOrderByName();
}
