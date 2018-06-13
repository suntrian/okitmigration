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
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;

@EnableTransactionManagement
@Configuration
@MapperScan(basePackages = "com.kingrein.okitmigration.mapperdest", sqlSessionTemplateRef = "destSqlSessionTemplate" )
public class DestMyBatisConfiguration {

    @Value("${spring.datasource.dest.mapperLocation}")
    private String destMapperLocation;

    @Bean(name = "destDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.dest")
    @Primary
    public DataSource destDataSource(){
        return DataSourceBuilder.create().build();
    }


    @Bean(name = "destSqlSessionFactory")
    @Primary
    public SqlSessionFactory destSqlSessionFactory(@Qualifier("destDataSource")DataSource dataSource) throws Exception {
        SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
        bean.setDataSource(dataSource);
        bean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources(destMapperLocation));
        return bean.getObject();
    }

    @Bean(name = "destTransactionManager")
    @Primary
    public DataSourceTransactionManager destTransactionManager(@Qualifier("destDataSource") DataSource dataSource){
        return new DataSourceTransactionManager(dataSource);
    }

    @Bean(name = "destSqlSessionTemplate")
    @Primary
    public SqlSessionTemplate destSqlSessionTemplate(@Qualifier("destSqlSessionFactory") SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }

}
