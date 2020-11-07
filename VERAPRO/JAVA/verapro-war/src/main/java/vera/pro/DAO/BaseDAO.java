package vera.pro.DAO;

import org.springframework.beans.factory.annotation.Autowired;

import java.text.SimpleDateFormat;

public class BaseDAO {
    @Autowired
    protected FbDataSource fbDataSource;
    protected SimpleDateFormat simpleDateFormat;
    protected SimpleDateFormat simpleDateTimeFormat;

    public BaseDAO() {
        simpleDateTimeFormat = new SimpleDateFormat("dd.MM.yyyy hh:mm:ss");
        simpleDateFormat = new SimpleDateFormat("dd.MM.yyyy");
    }

}
