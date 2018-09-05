package com.kingrein.okitmigration;

import com.kingrein.okitmigration.configuration.ApplicationContextUtil;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.ApplicationContext;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
//@MapperScan(value = {"com.kingrein.okitmigration.mapperSrc","com.kingrein.okitmigration.mapperDest"})
public class OkitmigrationApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        ApplicationContext context = SpringApplication.run(OkitmigrationApplication.class, args);
        //ApplicationContextUtil.setApplicationContext(context);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        //return super.configure(builder);
        return builder.sources(OkitmigrationApplication.class);
    }
}
