package com.kingrein.okitmigration.controller;

import com.kingrein.okitmigration.service.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {

    @Resource
    private UserService userService;

    @GetMapping("/hello")
    public Map helloWorld(){
        return new HashMap<String, String>(){{
            put("hello","world");
        }};
    }

    @GetMapping("/{id}")
    public Map getUser(@PathVariable Integer id){
        return userService.getSrcUser(id);
    }

    @GetMapping("/dest/{id}")
    public Map getDestUser(@PathVariable Integer id){
        return userService.getDestUser(id);
    }

    @GetMapping("/")
    public Map listAllUser(){
        return userService.listSrcUser();
    }



}
