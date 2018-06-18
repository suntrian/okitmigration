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
            recordService.recordUnitMap(src, dest);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return new ResultVO(src + "" + dest);
    }
}
