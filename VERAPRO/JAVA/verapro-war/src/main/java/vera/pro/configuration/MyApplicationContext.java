package vera.pro.configuration;

import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;
import org.springframework.web.context.ContextLoader;
import org.springframework.web.context.WebApplicationContext;

/**
 * Created by vkorshun on 03.04.2017.
 */
@Component
public class MyApplicationContext implements ApplicationContextAware {
    static public ApplicationContext context;

    public void setApplicationContext(ApplicationContext context) {
        this.context = context;
    }

    public static ApplicationContext getApplicationContext() {
        return context;
    }

    public static WebApplicationContext getWebApplicationContext() {
        return ContextLoader.getCurrentWebApplicationContext();
    }
}

