package com.kingrein.okitmigration.controller;

import com.kingrein.okitmigration.model.DataSourceProperties;
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

    @RequestMapping(value = {"/","index","step1"}, method = RequestMethod.GET)
    public String index(Map<String, Object> model){
        //model.put("time", new Date());
        //model.put("message", "Hello hi");
        return "/index";
    }

    @RequestMapping(value = "/step2")
    public String setDatasource(DataSourceProperties properties) {
        if (properties == null) {
            return "datasource";
        } else {
            return "datasource";
        }
    }

    @RequestMapping(value = "/step3")
    public String chooseProject(ModelAndView modelAndView) {
        return "selectProject";
    }

    @RequestMapping(value = "/step4")
    public String chooseStandardData() {
        return "selectStandardData";
    }

}
