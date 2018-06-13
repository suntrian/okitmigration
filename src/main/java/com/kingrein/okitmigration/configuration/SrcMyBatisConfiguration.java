package com.kingrein.okitmigration.configuration;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;

import javax.sql.DataSource;

@Configuration
@MapperScan(basePackages = "com.kingrein.okitmigration.mapperSrc", sqlSessionTemplateRef = "srcSqlSessionTemplate" )
public class SrcMyBatisConfiguration {

    @Value("${spring.datasource.src.mapperLocation}")
    private String srcMapperLocation;

    @Bean(name = "srcDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.src")
    public DataSource srcDataSource(){
        return DataSourceBuilder.create().build();
    }


    @Bean(name = "srcSqlSessionFactory")
    public SqlSessionFactory srcSqlSessionFactory(@Qualifier("srcDataSource")DataSource dataSource) throws Exception {
        SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
        bean.setDataSource(dataSource);
        bean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources(srcMapperLocation));
        return bean.getObject();
    }

    @Bean(name = "srcTransactionManager")
    public DataSourceTransactionManager srcTransactionManager(@Qualifier("srcDataSource") DataSource dataSource){
        return new DataSourceTransactionManager(dataSource);
    }

    @Bean(name = "srcSqlSessionTemplate")
    public SqlSessionTemplate srcSqlSessionTemplate(@Qualifier("srcSqlSessionFactory") SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }

}
