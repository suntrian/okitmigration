package com.kingrein.okitmigration.service.impl;

import com.kingrein.okitmigration.mapperDest.UserDestMapper;
import com.kingrein.okitmigration.mapperSrc.UserSrcMapper;
import com.kingrein.okitmigration.service.UserService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Service("userService")
public class UserServiceImpl implements UserService {

    @Resource
    private UserSrcMapper userSrcMapper;

    @Resource
    private UserDestMapper userDestMapper;

    @Override
    public Map<String , Object> getSrcUser(Integer id){
        return userSrcMapper.getUser(id);
    }
    @Override
    public Map<String, Object> getDestUser(Integer id) {
        return userDestMapper.getUser(id);
    }
    @Override
    public Map listSrcUser(){
        return userSrcMapper.listAllUser();
    }

    @Override
    public Map listDestUser(){
        return userDestMapper.listAllUser();
    }

    public List checkUnMappedUser(){
        Map srcUsers = listSrcUser();
        Map destUsers = listDestUser();
        List<Map> resultRepeatedPerson = new ArrayList<>();
        Iterator<Map.Entry<Integer, Map<String, Object>>> srcIter = srcUsers.entrySet().iterator();
        Iterator<Map.Entry<Integer, Map<String, Object>>> destIter = destUsers.entrySet().iterator();
        String realname ="";
        String mobile = "";
        int matchCount = 0;
        while (srcIter.hasNext()){
            Map.Entry<Integer, Map<String, Object>> src = srcIter.next();
            realname = src.getValue().get("name").toString();
            mobile = src.getValue().get("mobile").toString();
            while (destIter.hasNext()){
                Map.Entry<Integer, Map<String, Object>> dest = destIter.next();
                if (realname.equals(dest.getValue().get("name"))){
                    matchCount ++;
                }
            }
            if (matchCount == 1){
                resultRepeatedPerson.add(src.getValue());
            } else if (matchCount == 0){

            } else if (matchCount > 1){

            }
        }
        return resultRepeatedPerson;
    }

    @Override
    public List<Map<String , Object>> ListSrcUnit(){
         return (List<Map<String, Object>>) userSrcMapper.listAllUnit().values();

    }

    @Override
    public List<Map<String, Object>> listDestUnit(){
        return (List<Map<String, Object>>) userDestMapper.listAllUnit().values();
    }

}
