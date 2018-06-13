package com.kingrein.okitmigration.mapperSrc;


import org.apache.ibatis.annotations.MapKey;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public interface UserSrcMapper {

    Map<String, Object> getUser(Integer id);

    @MapKey("id")
    Map<Integer, Map<String, Object>>  listAllUser();

    @MapKey("id")
    Map<Integer, Map<String , Object>> listAllUnit();

}
