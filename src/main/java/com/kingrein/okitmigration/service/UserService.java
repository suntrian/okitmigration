package com.kingrein.okitmigration.service;

import java.util.List;
import java.util.Map;

public interface UserService {
    Map<String , Object> getSrcUser(Integer id);

    Map listSrcUser();

    Map listDestUser();

    Map<String, Object> getDestUser(Integer id);

    List<Map<String , Object>> ListSrcUnit();

    List<Map<String, Object>> listDestUnit();
}
