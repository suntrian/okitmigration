package com.kingrein.okitmigration;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
//@MapperScan(value = {"com.kingrein.okitmigration.mapperSrc","com.kingrein.okitmigration.mapperDest"})
public class OkitmigrationApplication {

    public static void main(String[] args) {
        SpringApplication.run(OkitmigrationApplication.class, args);
    }
}
