package com.kingrein.okitmigration.controller;

import com.kingrein.okitmigration.service.ProjectService;
import com.kingrein.okitmigration.service.UserService;
import com.sun.org.apache.xpath.internal.operations.Bool;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.PostConstruct;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;

/**
 * 显示页面相关代码
 */

@Controller
public class ViewController {

    private Integer currentStep = 1;

    @Value("${spring.datasource.src.url}")
    private String srcUrl;
    @Value("${spring.datasource.src.username}")
    private String srcUsername;
    @Value("${spring.datasource.src.password}")
    private String srcPassword;

    @Value("${spring.datasource.dest.url}")
    private String destUrl;
    @Value("${spring.datasource.dest.username}")
    private String destUsername;
    @Value("${spring.datasource.dest.password}")
    private String destPassword;

    @Autowired
    private ProjectService projectService;

    @Autowired
    private UserService userService;

    Map<Integer, String> entityViewMap = new HashMap<>();

    @PostConstruct
    public void init() {
        entityViewMap.put(1, "importSvn");          //相对独立
        entityViewMap.put(2, "importForum");        //相对独立
        entityViewMap.put(3, "importEvents");       //关联任务里程碑
        entityViewMap.put(4, "importRisk");         //
        entityViewMap.put(5, "importQuestion");
        entityViewMap.put(6, "importTest");
        entityViewMap.put(7, "importTicket");       //缺陷中包含测试活动属性
        entityViewMap.put(8, "importFormat");
        entityViewMap.put(9, "importTask");
    }


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
        Map<String, Map<String, String>> datasource = new HashMap<>();
        datasource.put("src", new HashMap<String, String>(){{
            put("url", srcUrl);
            put("username", srcUsername);
            put("password", srcPassword);
        }});
        datasource.put("dest", new HashMap<String, String>(){{
            put("url", destUrl);
            put("username", destUsername);
            put("password", destPassword);
        }});
        modelAndView.addObject("datasource",datasource);
        return modelAndView;
    }

    @RequestMapping(value = "/step3")
    public ModelAndView chooseUnit(ModelAndView modelAndView) {
        modelAndView.setViewName("selectUnit");
        modelAndView.addObject("unitTreeNode",  userService.listSrcUnitTree());
        return modelAndView;
    }

    @RequestMapping(value = "/step4")
    public ModelAndView chooseUser(ModelAndView modelAndView){
        modelAndView.setViewName("selectUser");
        return modelAndView;
    }

    @RequestMapping(value = "/step5")
    public ModelAndView chooseProject(ModelAndView modelAndView) {
        modelAndView.setViewName("selectProject");
        modelAndView.addObject("projectTreeNode", projectService.listSrcProjectTree());
        return modelAndView;
    }

    @RequestMapping(value = "/step6")
    public ModelAndView selectProjectMap(ModelAndView modelAndView){
        modelAndView.setViewName("selectProjectMap");
        return modelAndView;
    }

    @RequestMapping(value = "/step7")
    public ModelAndView selectEntity(ModelAndView modelAndView) {
        modelAndView.setViewName("selectEntity");
        return modelAndView;
    }

    @RequestMapping("/step8")
    public ModelAndView selectWorkflow(ModelAndView modelAndView) {
        modelAndView.setViewName("selectWorkflow");
        return modelAndView;
    }


    @RequestMapping(value = "/next")
    public ModelAndView next(@RequestParam(value = "flag", required = false, defaultValue = "true") Boolean flag, ModelAndView modelAndView) {
        Map<Integer, String> entities = projectService.getEntities();
        if (!flag) {
            modelAndView.setViewName(entityViewMap.get(currentStep));
            return modelAndView;
        }
        for (int step = currentStep; step <=entityViewMap.size(); step++){
            if (entities.get(step) != null) {
                currentStep = step + 1;
                modelAndView.setViewName(entityViewMap.get(step));
                return modelAndView;
            }
        }
        currentStep = 1;
        modelAndView.setViewName("finish");
        return modelAndView;
    }

    @RequestMapping(value = {"svn"})
    public ModelAndView svn(ModelAndView modelAndView){
        modelAndView.setViewName("importSvn");
        return modelAndView;
    }

    @RequestMapping(value = {"/ticket"})
    public ModelAndView chooseStandardData(ModelAndView modelAndView) {
        modelAndView.setViewName("importTicket");
        //modelAndView.addObject("ticket", projectService.dealWithTicketStandard());
        return modelAndView;
    }
    @RequestMapping(value = "/test")
    public ModelAndView test(ModelAndView modelAndView) {
        modelAndView.setViewName("importTest");
        return modelAndView;
    }

    @RequestMapping(value = {"/task"})
    public ModelAndView task(ModelAndView modelAndView) {
        modelAndView.setViewName("importTask");
        return modelAndView;
    }

    @RequestMapping(value = "/events")
    public ModelAndView events(ModelAndView modelAndView) {
        modelAndView.setViewName("importEvents");
        return modelAndView;
    }

    @RequestMapping(value = {"/risk"})
    public ModelAndView risk(ModelAndView modelAndView) {
        modelAndView.setViewName("importRisk");
        return modelAndView;
    }

    @RequestMapping(value = {"/question"})
    public ModelAndView question(ModelAndView modelAndView) {
        modelAndView.setViewName("importQuestion");
        return modelAndView;
    }

    @RequestMapping(value = {"/format"})
    public ModelAndView format(ModelAndView modelAndView) {
        modelAndView.setViewName("importFormat");
        return modelAndView;
    }

    @RequestMapping(value = {"/forum"})
    public ModelAndView forum(ModelAndView modelAndView) {
        modelAndView.setViewName("importForum");
        return modelAndView;
    }

    public Integer getCurrentStep() {
        return currentStep;
    }

    public void setCurrentStep(Integer currentStep) {
        this.currentStep = currentStep;
    }
}
