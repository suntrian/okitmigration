package com.kingrein.okitmigration.util;

import org.junit.Test;
import org.yaml.snakeyaml.DumperOptions;
import org.yaml.snakeyaml.Yaml;

import java.io.*;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

public class YamlTest {

    private String yamlFile = "D:\\Projects\\okitmigration\\src\\main\\resources\\application.yml";
    private String writeYamlFile = "D:\\Projects\\okitmigration\\src\\main\\resources\\test.yml";

    @Test
    public void testYamlLoad() throws FileNotFoundException {
        File file = new File(yamlFile);
        FileInputStream inputStream = new FileInputStream(file);
        Yaml yaml = new Yaml();
        Object obj = yaml.load(inputStream);
        System.out.println(obj);
    }

    @Test
    public void testYamlWrite() throws IOException {
        Map<String, Object> root = new HashMap<>();
        root.put("abc", new HashMap<String, String>(){{
            put("aaa", "aaa");
            put("bbb", "bbb");
        }});
        Yaml yaml = new Yaml();
        yaml.dump(root, new FileWriter(new File(writeYamlFile)));
    }

    @Test
    public void testReadWriteYamlFile() throws IOException {
        FileInputStream in = new FileInputStream(new File(yamlFile));
        DumperOptions options = new DumperOptions();
        options.setAllowReadOnlyProperties(true);
        options.setDefaultFlowStyle(DumperOptions.FlowStyle.BLOCK);
        //options.setCanonical(true);
        //options.setPrettyFlow(true);
        Yaml yaml = new Yaml(options);
        Object obj = yaml.load(in);
        LinkedHashMap spring = (LinkedHashMap) ((LinkedHashMap)obj).get("spring");
        LinkedHashMap datasource = (LinkedHashMap) spring.get("datasource");
        LinkedHashMap src = (LinkedHashMap)datasource.get("src");
        String srcUrl = (String) src.get("url");
        String srcUsername = (String) src.get("username");
        String srcPassworc = (String) src.get("password");
        System.out.println(srcUrl + srcUsername + srcPassworc);
        src.put("url", "aaaaa");
        src.put("username", "username");
        src.put("password", "passssssss");
        yaml.dump(obj, new FileWriter(new File(writeYamlFile)));
    }
}
