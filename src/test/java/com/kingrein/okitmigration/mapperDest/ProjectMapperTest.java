package com.kingrein.okitmigration.mapperDest;

import com.kingrein.okitmigration.OkitmigrationApplicationTests;
import com.kingrein.okitmigration.mapperSrc.ProjectSrcMapper;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ProjectMapperTest  extends OkitmigrationApplicationTests {

    @Autowired
    private ProjectDestMapper projectDestMapper;
    @Autowired
    private ProjectSrcMapper projectSrcMapper;

    @Test
    @Transactional
    public void testImportFormat() {
        List<Integer> ids = new ArrayList<Integer>(){{
            add(6);
        }};
        List<Map<String, Object>> items = projectSrcMapper.listFormatItemModifyHistoryByProjectIds(ids);
        int count = 0;
        for (int i = 0; i < Math.min(items.size(), 10); i++) {
            Map<String, Object> item = items.get(i);
            item.put("project_id", 18);
            item.put("operator_id", 216);
            int c = projectDestMapper.addFormatItemModifyHistory(item);
            count += c;
        }
        System.out.println(count);

    }
}
