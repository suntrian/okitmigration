package com.kingrein.okitmigration.controller;

import com.kingrein.okitmigration.model.DataSourceProperties;
import com.kingrein.okitmigration.service.ProjectService;
import com.kingrein.okitmigration.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import java.util.Date;
import java.util.Map;

/**
 * 显示页面相关代码
 */

@Controller
public class ViewController {

    @Autowired
    private ProjectService projectService;

    @Autowired
    private UserService userService;

    @RequestMapping(value = {"/","index","step1"}, method = RequestMethod.GET)
    public ModelAndView index(ModelAndView modelAndView){
        modelAndView.setViewName("index");
        //model.put("time", new Date());
        //model.put("message", "Hello hi");
        return modelAndView;
    }

    @RequestMapping(value = "/step2")
    public ModelAndView setDatasource(ModelAndView modelAndView) {
        modelAndView.setViewName("datasource");
        return modelAndView;
    }

    @RequestMapping(value = "/step3")
    public ModelAndView chooseProject(ModelAndView modelAndView) {
        modelAndView.setViewName("selectProject");
        modelAndView.addObject("projectTreeNode", projectService.listProjectTree());
        return modelAndView;
    }

    @RequestMapping(value = "/step4")
    public ModelAndView chooseUnit(ModelAndView modelAndView) {
        modelAndView.setViewName("selectUnit");
        modelAndView.addObject("unitTreeNode",  userService.listSrcUnitTree());
        return modelAndView;
    }

    @RequestMapping(value = "/step5")
    public ModelAndView chooseUser(ModelAndView modelAndView){
        modelAndView.setViewName("selectUser");
        return modelAndView;
    }

    @RequestMapping(value = "/step6")
    public ModelAndView chooseStandardData(ModelAndView modelAndView) {
        modelAndView.setViewName("selectUnit");
        return modelAndView;
    }

}
