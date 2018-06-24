package com.kingrein.okitmigration.mapperSrc;

import org.apache.ibatis.annotations.MapKey;

import java.util.List;
import java.util.Map;

public interface ProjectSrcMapper {

    @MapKey("id")
    Map<Integer,Map<String, Object>> listProject();

    @MapKey("id")
    Map<Integer, Map<String, Object>> listProjectByIds(List<Integer> ids);
}
