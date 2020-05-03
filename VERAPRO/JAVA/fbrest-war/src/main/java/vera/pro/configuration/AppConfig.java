package vera.pro.configuration;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.spi.LocationAwareLogger;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.filter.CommonsRequestLoggingFilter;

import java.lang.reflect.Field;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

@Configuration
@EnableScheduling
@EnableTransactionManagement
@Slf4j
@ComponentScan(basePackages = {"vera.pro"})

public class AppConfig implements SchedulingConfigurer {

    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        taskRegistrar.setScheduler(taskExecutor());
    }

    @Bean
            //(destroyMethod = "shutdown")
    public Executor taskExecutor() {
        //setLogger();
        return Executors.newScheduledThreadPool(30);
    }

    /*@Bean(name="tm1")
    @Scope(value="request")
    PlatformTransactionManager tm1() {
        DataSourceTransactionManager txm  = new DataSourceTransactionManager(getDataSource());
        return txm;
    }

    public DataSource getDataSource() {
        try {
            UniversalRequestInfoInterface universalRequestInfo = MyApplicationContext.context.getBean(UniversalRequestInfo.class);
            return UniversalSessionList.getRequestDataSource();
        } catch (Exception ex) {
            return null;
        }
    }*/


    //@Bean
    public CommonsRequestLoggingFilter requestLoggingFilter() {
        CommonsRequestLoggingFilter loggingFilter = new CommonsRequestLoggingFilter();
        loggingFilter.setIncludeClientInfo(true);
        loggingFilter.setIncludeQueryString(true);
        loggingFilter.setIncludePayload(true);
        loggingFilter.setIncludeHeaders(false);
        return loggingFilter;
    }

    private void setLogger() {
        try {
            Logger l = LoggerFactory.getLogger("full.classname.of.noisy.logger");  //This is actually a MavenSimpleLogger, but due to various classloader issues, can't work with the directly.
            Field f = l.getClass().getSuperclass().getDeclaredField("currentLogLevel");
            f.setAccessible(true);
            f.set(l, LocationAwareLogger.TRACE_INT);
        } catch (Exception e) {
            log.warn("Failed to reset the log level of " + "'aa'" + ", it will continue being noisy.", e);
        }
    }

    /*@Bean
    @Scope(value = "prototype")
    public AsyncRequestLogDAOInterface getAsyncRequestLogDAO(UniversalSessionVO universalSessionVO) {
        return AsyncRequestLogDAO.getAsyncRequestLogDAO(universalSessionVO);
    }*/

}
