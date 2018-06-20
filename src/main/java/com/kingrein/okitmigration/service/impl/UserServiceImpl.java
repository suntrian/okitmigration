package com.kingrein.okitmigration.service.impl;

import com.kingrein.okitmigration.mapperDest.UserDestMapper;
import com.kingrein.okitmigration.mapperSrc.UserSrcMapper;
import com.kingrein.okitmigration.service.UserService;
import com.kingrein.okitmigration.util.TreeNode;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.*;

@Service("userService")
public class UserServiceImpl implements UserService {

    private Map<Integer, Integer> unitMap = new HashMap<>();

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
    public Map<String, Object> getSrcUnit(Integer id){
        return userSrcMapper.getUnit(id);
    }

    @Override
    public Map<String, Object> getDestUnit(Integer id){
        return userDestMapper.getUnit(id);
    }

    @Override
    public Map<Integer, Map<String, Object>> listAllSrcUnit(){
        return userSrcMapper.listAllUnit();
    }

    @Override
    public List< Map<String , Object>> listSrcUnit(Integer parentId){
        return userSrcMapper.listUnitByParent(parentId);
    }

    @Override
    public List<TreeNode<Map<String, Object>>> listSrcUnitTree(){
        Map<Integer, Map<String, Object>> units = listAllSrcUnit();
        return parseMap2Tree(units);
    }

    @Override
    public Map<Integer, Map<String, Object>> listAllDestUnit(){
        return userDestMapper.listAllUnit();
    }

    @Override
    public  List< Map<String , Object>> listDestUnit(Integer parentId){
        List<Map<String, Object>> unitList = userDestMapper.listUnitByParent(parentId);
        return  unitList;
    }

    @Override
    public List<TreeNode<Map<String, Object>>> listDestUnitTree(){
        Map<Integer, Map<String, Object>> units = listAllDestUnit();
        return parseMap2Tree(units);
    }

    private List<TreeNode<Map<String, Object>>> parseMap2Tree(Map<Integer, Map<String, Object>> map){
        List<TreeNode<Map<String, Object>>> roots = new ArrayList<>();
        Map<Integer, TreeNode> hasContained = new HashMap<>();
        while (!map.isEmpty()){
            Iterator<Map.Entry<Integer, Map<String, Object>>> iterator = map.entrySet().iterator();
            while (iterator.hasNext()) {
                Map.Entry<Integer, Map<String, Object>> unitEntry = iterator.next();
                Integer unitId = unitEntry.getKey();
                Map<String, Object> unit = unitEntry.getValue();
                Integer parent_id = unit.get("parent_id") == null ? null : (Integer) unit.get("parent_id");
                TreeNode<Map<String, Object>> node = new TreeNode<>(unit);
                if (parent_id == null) {
                    roots.add(node);
                    hasContained.put(unitId, node);
                    iterator.remove();
                } else {
                    if (hasContained.containsKey(parent_id)){
                        hasContained.get(parent_id).addChild(node);
                        hasContained.put(unitId, node);
                        iterator.remove();
                    }
                }
            }
        }
        return roots;
    }

}
