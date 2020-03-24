package vera.pro.DAO.core;

import lombok.Getter;
import lombok.Setter;

import java.sql.*;

@Getter
@Setter
public class NamedCallableStatement extends NamedParameterStatement {

    //private List<PkgProcParam> procParamList;


    public NamedCallableStatement(Connection connection, String query) throws SQLException {
        super(connection, query);
    }

    @Override
    protected boolean isNeedCall(){
        return true;
    }

    protected Object checkIsTimestamp(String name, Object obj) {
        if (obj instanceof String) {
            String value = checkDateFormat((String) obj);
            if (value.matches("\\d{4}-\\d{2}-\\d{2}") ) {
                    return Timestamp.valueOf(value + " 00:00:00");
            } else if (value.matches("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}")) {
                return Timestamp.valueOf(value);
            } else if (value.matches("\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}")) {
                return Timestamp.valueOf(value);
            }
        }
        return obj;
    }

    public void registerOutParameter(String name, int type) throws SQLException {
        int[] indexes = getIndexes(name);
        for (int i = 0; i < indexes.length; ++i) {
            ((CallableStatement) getStatement()).registerOutParameter(indexes[i], type);
        }
        setedList.add(name);
    }


}
