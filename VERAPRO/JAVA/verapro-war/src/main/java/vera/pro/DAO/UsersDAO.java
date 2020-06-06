package vera.pro.DAO;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import vera.pro.model.UserVO;

import javax.sql.DataSource;
import java.math.BigDecimal;

@Component
public class UsersDAO {

    public UserVO getUser(DataSource ds, String userName) {
        JdbcTemplate jdbcTempalte = new JdbcTemplate(ds);
        try {
            return jdbcTempalte.queryForObject("SELECT * FROM userslist WHERE username=?", new Object[]{userName}, new BeanPropertyRowMapper<>(UserVO.class));
        } catch (EmptyResultDataAccessException ex) {
            return null;
        }

    }

}
