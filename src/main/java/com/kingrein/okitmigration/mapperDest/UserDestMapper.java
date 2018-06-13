package com.kingrein.okitmigration.mapperDest;


import org.apache.ibatis.annotations.MapKey;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public interface UserDestMapper {

    Map<String, Object> getUser(Integer id);

    @MapKey("id")
    Map<Integer, Map<String, Object>>  listAllUser();

    @MapKey("id")
    Map<Integer, Map<String , Object>> listAllUnit();
}
