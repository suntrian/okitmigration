package com.kingrein.okitmigration.service.impl;

import com.kingrein.okitmigration.mapperSrc.ProjectSrcMapper;
import com.kingrein.okitmigration.service.ProjectService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Service("projectService")
public class ProjectServiceImpl implements ProjectService {

    @Resource
    private ProjectSrcMapper projectSrcMapper;

    @Override
    public List<Map<String, Object>>  listProject(){
        return projectSrcMapper.listProject();
    }

}
