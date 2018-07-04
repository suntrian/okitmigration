package com.kingrein.okitmigration;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
//@MapperScan(value = {"com.kingrein.okitmigration.mapperSrc","com.kingrein.okitmigration.mapperDest"})
public class OkitmigrationApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(OkitmigrationApplication.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        //return super.configure(builder);
        return builder.sources(OkitmigrationApplication.class);
    }
}
