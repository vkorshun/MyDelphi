package vera.pro.DAO;

import lombok.Data;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

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
        url = "jdbc:firebird://localhost:3050/D:/FBDATA/VERA_PRO/ledapravo.fdb";
        username = "SYSDBA";
        password = "masterkey";

    }

    public Connection getConnection() {
        try {
            Properties props = new Properties();

            props.setProperty("user", "SYSDBA");
            props.setProperty("password", "masterkey");
            props.setProperty("encoding", "UTF8");
            return DriverManager.getConnection(url, props);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
