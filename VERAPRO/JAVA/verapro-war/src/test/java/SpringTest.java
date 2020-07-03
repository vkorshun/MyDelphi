import lombok.extern.slf4j.Slf4j;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import vera.pro.DAO.FbDataSource;
import vera.pro.DAO.QueryDAO;
import vera.pro.DAO.core.NamedParameterStatement;
import vera.pro.beans.QueryRequest;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = TestConfig.class)
@WebAppConfiguration
@Slf4j
public class SpringTest {

    @Autowired
    FbDataSource fbDataSource;

    @Autowired
    QueryDAO queryDAO;

    @Test
    public void SimpleQuery() {
        final String query = " SELECT * FROM TESTDOC";
//        FbDataSource fbDataSource = new FbDataSource();
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

    @Test
    public void testQuetyDao(){
        QueryRequest qr = new QueryRequest();
        qr.setQuery("SELECT * FROM TESTDOC");
        //qr.setParams(new HashMap<>());

        Map<String, Object> retval =  queryDAO.execute(qr);
        System.out.println(retval.toString());
    }
}
