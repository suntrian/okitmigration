package com.kingrein.okitmigration.service.impl;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.kingrein.okitmigration.mapperDest.UserDestMapper;
import com.kingrein.okitmigration.mapperSrc.UserSrcMapper;
import com.kingrein.okitmigration.service.RecordService;
import com.kingrein.okitmigration.service.UserService;
import com.kingrein.okitmigration.util.TreeNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service("userService")
public class UserServiceImpl implements UserService {

    private Map<Integer, Integer> unitMap = new HashMap<>();
    private Map<Integer, Integer> userMap = new HashMap<>();

    private final String chineseCharactorRegex = "([\u4e00-\u9fa5]+)";

    @Resource
    private UserSrcMapper userSrcMapper;

    @Resource
    private UserDestMapper userDestMapper;

    @Autowired
    private RecordService recordService;

    @Override
    public Map<String , Object> getSrcUser(Integer id){
        return userSrcMapper.getSimpleUser(id);
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

    @Override
    public Map<Integer, Map<String, Object>> listAllSrcUser() {
        return userSrcMapper.listAllUser();
    }

    @Override
    public Map<Integer, Map<String, Object>> listAllDestUser() {
        return userDestMapper.listAllUser();
    }

    /**
     *  查找在目标系统中无法找到或者找到多个用户的源系统中的人员
     * @return
     */
    @Override
    public List<Map<String, Object>> listUserNotMapped() throws IOException {
        List<Map<String, Object>> srcUsers = userSrcMapper.listAllUserOrderByName();
        List<Map<String, Object>> destUsers = userDestMapper.listAllUserOrderByName();
        List<Map<String, Object>> result = new ArrayList<>();
        if (srcUsers.size() == 0) {
            return result;
        }
        if (destUsers.size() == 0) {
            return srcUsers;
        }
        int checkpoint = 0;
        for (int s = 0 ; s < srcUsers.size(); s++){
            Map<String ,Object> srcUser = srcUsers.get(s);
            srcUser.put("text", srcUser.get("name"));
            Map<String, Object> destUser = null;
            int cursor = checkpoint;
            do {
                destUser = destUsers.get(cursor++);
            } while (!destUser.get("name").equals(srcUser.get("name")) && cursor<destUsers.size());
            if (destUser.get("name").equals(srcUser.get("name"))){
                checkpoint = cursor;
                if (cursor<destUsers.size() && srcUser.get("name").equals(destUsers.get(cursor).get("name"))){
                    //匹配到多个的情况
                    if (userMap.keySet().contains(srcUser.get("id"))) {
                        continue;
                    }
                    srcUser.put("state", "dual");
                    result.add(srcUser);
                } else {
                    //正常匹配到一个的情况
                    userMap.put((Integer) srcUser.get("id"), (Integer) destUser.get("id"));
                }

            }
            if (cursor == destUsers.size()  ){
                //匹配到零个的情况
                if (userMap.keySet().contains(srcUser.get("id"))) {
                    continue;
                }
                srcUser.put("state","single");
                result.add(srcUser);
            }
        }

        return result;
    }

    @Override
    public List<Map<String, Object>>  listDestUserByName(Integer id, String name) {
        name = findChineseCharactor(name);
        List<Map<String, Object>> users = userDestMapper.listUserByName(name);
        for (Map<String, Object> user: users) {
            if (user.get("id").equals(userMap.get(id))) {
                user.put("state", "selected");
            }
        }
        return users;
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

    private String findChineseCharactor(String str){
        String result = "";
        Matcher matcher = Pattern.compile(chineseCharactorRegex).matcher(str);
        while (matcher.find()) {
            result += matcher.group(0);
        }
        return result;
    }

    /**
     * 手动增加单位
     * @param id 源数据表单位ID
     * @return
     */
    @Override
    public Boolean addUnitBySrcUnitId(Integer id){
        Map<String, Object> srcUnit = userSrcMapper.getUnit(id);
        srcUnit.put("parent_id",transformIntergerId((Integer) srcUnit.get("parent_id"), unitMap));
        Integer count = userDestMapper.addUnit(srcUnit);
        unitMap.put(id, (Integer) srcUnit.get("id"));
        return true;
    }

    /**
     * 手动增加人员
     * @param id
     * @return
     * @throws IOException
     */
    @Transactional
    @Override
    public Integer addUserBySrcUserId(Integer id) throws Exception {
        Map<String, Object> srcUser = userSrcMapper.getUser(id);
        Map<String, Object> srcPerson = userSrcMapper.getPerson(id);
        srcPerson.put("unit_id", unitMap.get(srcPerson.get("unit_id")));
        srcPerson.put("id", null);
        Integer count = userDestMapper.addPerson(srcPerson);
        Integer newId = ((Long) srcPerson.get("id")).intValue();
        srcUser.put("id", newId);
        srcUser.put("person_id", newId);

        Integer count2 = userDestMapper.addUser(srcUser);
        if (count2>0) {
            this.userMap.put(id, newId);
        } else {
            throw new Exception("replicate username");
        }
        return count2;
    }

    private Integer transformIntergerId(Integer src, Map<Integer, Integer> map){
        return src == null?null: map.get(src)==null?src: map.get(src);
    }


    @Override
    public Map<Integer, Integer> getUnitMap() {
        return unitMap;
    }

    @Override
    public void setUnitMap(Map<Integer, Integer> unitMap) {
        this.unitMap = unitMap;
    }

    @Override
    public Map<Integer, Integer> getUserMap() {
        return userMap;
    }

    @Override
    public void setUserMap(Map<Integer, Integer> userMap) {
        this.userMap = userMap;
    }
}
