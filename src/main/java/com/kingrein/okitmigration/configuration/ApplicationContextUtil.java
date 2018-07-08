package com.kingrein.okitmigration.configuration;

import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class ApplicationContextUtil implements ApplicationContextAware {

    private static ApplicationContext applicationContext;
    private static BeanDefinitionRegistry beanDefinitionRegistry;


    //获取上下文
    public static ApplicationContext getApplicationContext() {
        return applicationContext;
    }
    //设置上下文
    public void setApplicationContext(ApplicationContext applicationContext) {
        ApplicationContextUtil.applicationContext = applicationContext;
        ApplicationContextUtil.beanDefinitionRegistry = (BeanDefinitionRegistry) ((ConfigurableApplicationContext)applicationContext).getBeanFactory();
    }
    //通过名字获取上下文中的bean
    public static Object getBean(String name){
        return applicationContext.getBean(name);
    }
    //通过类型获取上下文中的bean
    public static <T> T getBean(Class<T> clazz){
        return applicationContext.getBean(clazz);
    }

    //通过类型和名字获取bean
    public static <T> T getBean(String name, Class<T> clazz) {
        return applicationContext.getBean(name, clazz);
    }

    //删除bean
    public static void unregisterBean(String name ) {
        beanDefinitionRegistry.removeBeanDefinition(name);
    }

    /**
     * 注册bean
     * @param name 所注册bean的id
     * @param className bean的className，
     *                     三种获取方式：1、直接书写，如：com.mvc.entity.User
     *                                   2、User.class.getName
     *                                   3.user.getClass().getName()
     */
    public static void registerBean(String name,String className) {
        // get the BeanDefinitionBuilder
        BeanDefinitionBuilder beanDefinitionBuilder =
                BeanDefinitionBuilder.genericBeanDefinition(className);
        // get the BeanDefinition
        BeanDefinition beanDefinition=beanDefinitionBuilder.getBeanDefinition();
        // register the bean
        beanDefinitionRegistry.registerBeanDefinition(name,beanDefinition);
    }

    public static void registerBean(String name, Class<?> clazz) {
        registerBean(name, clazz, new HashMap<>());
    }

    public static void registerBean(String name, Class<?> clazz, Map<String, Object> params) {
        BeanDefinitionBuilder beanDefinitionBuilder = BeanDefinitionBuilder.genericBeanDefinition(clazz);
        for (String key: params.keySet()) {
            beanDefinitionBuilder.addPropertyValue(key, params.get(key));
        }
        beanDefinitionRegistry.registerBeanDefinition(name, beanDefinitionBuilder.getBeanDefinition());
    }
}
