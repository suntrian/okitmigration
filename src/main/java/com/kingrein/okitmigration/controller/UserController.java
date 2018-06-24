package com.kingrein.okitmigration.controller;

import com.kingrein.okitmigration.model.ResultVO;
import com.kingrein.okitmigration.service.RecordService;
import com.kingrein.okitmigration.service.UserService;
import com.kingrein.okitmigration.util.TreeNode;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
//@RequestMapping("/user")
public class UserController {

    private Map<Integer, Integer> unitMap = new HashMap<>();

    @Resource
    private UserService userService;
    @Resource
    private RecordService recordService;

    @GetMapping("/hello")
    public Map helloWorld(){
        return new HashMap<String, String>(){{
            put("hello","world");
        }};
    }

    @GetMapping("/user/src/{id}")
    public Map getUser(@PathVariable Integer id){
        return userService.getSrcUser(id);
    }

    @GetMapping("/user/dest/{id}")
    public Map getDestUser(@PathVariable Integer id){
        return userService.getDestUser(id);
    }

    @GetMapping("/user")
    public Map listAllUser(){
        return userService.listSrcUser();
    }

    @GetMapping(value = {"/unit/dest","/unit/dest/"})
    public List< Map<String,Object>> listDestUnit(@RequestParam(name = "id", required = false) Integer id) {
        return userService.listDestUnit(id);
    }

    @RequestMapping(value = "/unit/dest/mapped")
    public List<Map<String, Object>> listDestUnitMapped(@RequestParam(name = "id", required = false) Integer id, @RequestParam(name = "selfid") Integer selfid ){
        List<Map<String, Object>> unitList = userService.listDestUnit(id);
        Map<String, Object> srcUnit = userService.getSrcUnit(selfid);
        for (Map<String, Object> dest : unitList){
            if (dest.get("name")!=null && dest.get("name")!=null && dest.get("name").equals(srcUnit.get("name"))){
                dest.put("selected", true);
            }
        }
        return unitList;
    }

    @GetMapping(value = {"/unit/src","/unit/src/"})
    public List< Map<String,Object>> listSrcUnit(@RequestParam(name = "id", required = false) Integer id) {
        return userService.listSrcUnit(id);
    }

    @GetMapping(value = "/unit/src/tree")
    public List<TreeNode<Map<String, Object>>> listSrcUnitTree(){
        return userService.listSrcUnitTree();
    }


    @RequestMapping(value = "/unit/map")
    public ResultVO setUnitMap(@RequestParam("src") Integer src, @RequestParam("dest") Integer dest){
        try {
            unitMap.put(src, dest);
            recordService.recordUnitMap(src, dest);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return new ResultVO(src + "" + dest);
    }

    @RequestMapping(value = "/user/notmapped")
    public List<Map<String, Object>> listSrcUserNotMapped() throws IOException {
        return userService.listUserNotMapped();
    }

}
