package com.kingrein.okitmigration.controller;

import com.alibaba.druid.pool.DruidDataSource;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.kingrein.okitmigration.configuration.ApplicationContextUtil;
import com.kingrein.okitmigration.model.ResultVO;
import com.kingrein.okitmigration.service.RecordService;
import com.kingrein.okitmigration.service.UserService;
import com.kingrein.okitmigration.util.TreeNode;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.SqlSessionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.web.bind.annotation.*;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.sql.DataSource;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
//@RequestMapping("/user")
@SessionAttributes(value = {"users","unitMap"})
public class UserController {

    Logger logger = LoggerFactory.getLogger(UserController.class);
    //private Map<Integer, Integer> unitMap = new HashMap<>();
    //private Map<Integer, Integer> userMap = new HashMap<>();


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

    @RequestMapping("/datasource/{source}")
    public void setDataSource(@PathVariable String source, String url, String username, String password) throws SQLException {
        String datasource = "destDataSource";
        if ("src".equals(source)) {
            datasource = "srcDataSource";
        }
        DruidDataSource dataSource = ApplicationContextUtil.getBean(datasource, DruidDataSource.class);
        dataSource.restart();
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        try{
            dataSource.setConnectionErrorRetryAttempts(3);      //druid bug, can't stop while exceed retryAttemptsTimes;
            dataSource.setTimeBetweenConnectErrorMillis(60000);
            Connection conn = dataSource.getConnection();
            dataSource.validateConnection(conn);
            dataSource.discardConnection(conn);

        } catch (SQLException e) {
            throw e;
        }
    }

    @RequestMapping("/clearcache")
    public void clearCache() {
        SqlSessionFactory src = ApplicationContextUtil.getBean("srcSqlSessionFactory", SqlSessionFactory.class);
        SqlSessionFactory dest = ApplicationContextUtil.getBean("destSqlSessionFactory", SqlSessionFactory.class);
        SqlSessionUtils.getSqlSession(src).clearCache();
        SqlSessionUtils.getSqlSession(dest).clearCache();
    }

    @PostConstruct
    public void readMapFile() throws IOException {
        JsonArray unitMapArray = recordService.readUnitMap();
        for (int i = 0; i < unitMapArray.size(); i++){
            JsonElement unitMapObject = unitMapArray.get(i);
            Integer unitSrcId = unitMapObject.getAsJsonObject().get("src").getAsJsonObject().get("id").getAsInt();
            Integer unitDestId = unitMapObject.getAsJsonObject().get("dest").getAsJsonObject().get("id").getAsInt();
            userService.getUnitMap().put(unitSrcId,unitDestId);
        }
        //userService.setUnitMap(unitMap);
        JsonArray userMapArray = recordService.readUserMap();
        for (int i = 0; i< userMapArray.size(); i++){
            JsonElement userMapObject = userMapArray.get(i);
            Integer userSrcId = userMapObject.getAsJsonObject().get("src").getAsJsonObject().get("id").getAsInt();
            Integer userDestId = userMapObject.getAsJsonObject().get("dest").getAsJsonObject().get("id").getAsInt();
            userService.getUserMap().put(userSrcId, userDestId);
        }
        //userService.setUserMap(userMap);
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
    public List<Map<String, Object>> listDestUnitMapped(@RequestParam(name = "id", required = false) Integer parentId, @RequestParam(name = "selfid") Integer selfid ){
        Integer destUnitParentId = userService.getUnitMap().get(parentId);
        List<Map<String, Object>> unitList = userService.listDestUnit(destUnitParentId);
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


    /**
     * 设定源单位和目标单位对应关系
     * @param src
     * @param dest
     * @return
     */
    @RequestMapping(value = "/unit/map")
    public ResultVO setUnitMap(@RequestParam("src") Integer src, @RequestParam("dest") Integer dest){
        userService.getUnitMap().put(src, dest);
        //recordService.recordUnitMap(src, dest);
        return new ResultVO(src + "" + dest);
    }

    /**
     * 点下一步时保存选择的单位对应关系
     * @return
     * @throws IOException
     */
    @RequestMapping("/unit/map/save")
    public ResultVO saveUnitMap() throws IOException {
        //recordService.recordUnitMap();
        recordService.recordUnitMap();
        return new ResultVO("succeed");
    }

    @RequestMapping(value = "/user/notmapped")
    public List<Map<String, Object>> listSrcUserNotMapped() throws IOException {
        return userService.listUserNotMapped();
    }

    /**
     * 设定源人和目标人的对应关系
     * @param src
     * @param dest
     * @return
     * @throws IOException
     */
    @RequestMapping(value = "/user/map", method = RequestMethod.POST)
    public ResultVO setUserMap(@RequestParam("src") Integer src, @RequestParam("dest") Integer dest) throws IOException {
        userService.getUserMap().put(src, dest);
        //recordService.recordUserMap(src, dest);
        return new ResultVO("succeed");
    }

    @RequestMapping("/user/map/save")
    public ResultVO saveUserMap() throws IOException {
        recordService.recordUserMap();
        return new ResultVO("succeed");
    }

    /**
     * 获取目标库中同名的人员
     * @param name
     * @param unit_id
     * @return
     */
    @RequestMapping(value = "/user/dest", method = RequestMethod.GET)
    public List<Map<String, Object>> listDestUserByName(@RequestParam("name") String name, @RequestParam(value = "unit_id", required = false) Integer unit_id) {
        return userService.listDestUserByName(name);
    }

    @PostMapping(value = "/unit")
    public ResultVO addUnit(@RequestParam("id") Integer id){
        userService.addUnitBySrcUnitId(id);
        return new ResultVO("succeed");
    }

    @PostMapping(value = "/user")
    public ResultVO addUser(@RequestParam("id") Integer id) throws Exception {
        userService.addUserBySrcUserId(id);
        return new ResultVO("succeed");
    }

    @RequestMapping(value = "/user/map/check")
    public ResultVO checkUserMap() {
        Map<Integer,Map<String, Object>> srcUserList = userService.listAllSrcUser();
        if (srcUserList.size() == userService.getUserMap().size()){
            return new ResultVO("success");
        }
        return new ResultVO("failed", false);
    }
    @RequestMapping("/unit/map/check")
    public ResultVO checkUnitMap () {
        Map<Integer,Map<String, Object>> srcUnitMap = userService.listAllSrcUnit();
        if (srcUnitMap.size() == userService.getUnitMap().size()) {
            return new ResultVO("succeed");
        }
        return new ResultVO("failed", false);
    }
}
