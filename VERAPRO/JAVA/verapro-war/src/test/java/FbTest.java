import lombok.extern.slf4j.Slf4j;
import org.junit.Test;
import vera.pro.DAO.FbDataSource;
import vera.pro.DAO.core.NamedParameterStatement;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@Slf4j
public class FbTest {
    @Test
    public void SimpleQuery() {
        final String query = " SELECT * FROM TESTDOC";
        FbDataSource fbDataSource = new FbDataSource();
        try (Connection connection = fbDataSource.getConnection();
             NamedParameterStatement stm = new NamedParameterStatement(connection, query)) {
            if (stm.execute()) {
                ResultSet rs = stm.getResultSet();
                while (rs.next()) {
                    System.out.println(rs.getString("commentary"));
                }
            }

        } catch (SQLException e) {
            log.error(e.getMessage());
        }

    }
}
