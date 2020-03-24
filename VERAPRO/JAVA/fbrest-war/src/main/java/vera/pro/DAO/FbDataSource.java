package vera.pro.DAO;

import lombok.Data;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

@Component
@Data
public class FbDataSource {

    private String url;
    private String username;
    private String password;

    public FbDataSource() {
     /*   HikariConfig jdbcConfig = new HikariConfig();
        jdbcConfig.setPoolName("FB_TENDER");
        jdbcConfig.setMaximumPoolSize(10);
        jdbcConfig.setMinimumIdle(60000);
        jdbcConfig.setJdbcUrl(System.getProperty("tender.url","jdbc:firebirdsql://tender.globino.ua:3050/C:/tender/data/120-globino.fdb"));
        jdbcConfig.setDriverClassName("org.firebirdsql.jdbc.FBDriver");
        jdbcConfig.setUsername(System.getProperty("tender.username","SYSDBA"));
        jdbcConfig.setPassword(System.getProperty("tender.password","masterkey"));
      */
       // dataSource = ;
        url = "jdbc:firebirdsql://testtender.globino.ua:3050/C:/tender/data/120-globino.fdb";
        username = System.getProperty("tender.username","SYSDBA");
        password = System.getProperty("tender.password","masterkey");

    }

    public Connection getConnection() {
        try {
            return DriverManager.getConnection(url, username, password);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
