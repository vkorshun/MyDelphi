package vera.pro.configuration;

import lombok.extern.slf4j.Slf4j;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

@Slf4j

public class VeraProServletContextListener implements ServletContextListener {

    static {
        try {
            Class.forName("org.firebirdsql.jdbc.FBDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    //FBPool fbPool;
    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        //super.contextInitialized(servletContextEvent);
        //universalSessionList = MyApplicationContext.getApplicationContext().getBean(UniversalSessionListInterface.class);
        log.info("Starting up FbRest!");
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {
        try {

            Enumeration<Driver> drivers = DriverManager.getDrivers();
            while (drivers.hasMoreElements()) {
                Driver driver = drivers.nextElement();
                try {
                    DriverManager.deregisterDriver(driver);
                    log.info(String.format("Deregistering jdbc driver: %s", driver));
                } catch (SQLException e) {
                    log.error(String.format("Error deregistering driver %s", driver), e);
                }

            }
        } catch (Exception ex) {
            log.error("Shutdown error: "+ex.getMessage());
        }

    }
}
