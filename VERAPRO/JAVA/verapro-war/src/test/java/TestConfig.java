import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.*;
import vera.pro.configuration.MyApplicationContext;

import java.io.IOException;
import java.io.InputStream;

@Configuration
@ComponentScan(basePackages = {"vera.pro"})
@PropertySource("classpath:test/test.conf")
public class TestConfig {

    //@Autowired
    ApplicationContext applicationContext;

    public TestConfig() {
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "debug");
        System.setProperty("org.slf4j.simpleLogger.showDateTime", "true");
        /*try (InputStream is = getClass().getResourceAsStream("test.conf")) {
            System.getProperties().load(is);
        } catch (IOException e) {
            e.printStackTrace();
        }*/

    }

    public void setApplicationContext(ApplicationContext context) {
        this.applicationContext = context;
        MyApplicationContext.context = applicationContext;
    }


    @Bean("ConnPath")
    @Profile("vktest")
    public String getConPath() {
        return "jdbc:oracle:thin:@cdb2:1521/cdb2";
    }
}
