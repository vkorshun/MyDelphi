package vera.pro.DAO;

import com.google.common.base.Strings;
import vera.pro.DAO.core.NamedParameterStatement;
import vera.pro.beans.QueryRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import vera.pro.model.TFieldType;

import java.sql.*;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
public class QueryDAO {

    //@Autowired
    private FbDataSource fbDataSource;
    protected SimpleDateFormat simpleDateFormat;
    protected SimpleDateFormat simpleDateTimeFormat;
    //private String query;
    //private Map<String,Object> params;


    public QueryDAO() {
        simpleDateTimeFormat = new SimpleDateFormat("dd.MM.yyyy hh:mm:ss");
        simpleDateFormat = new SimpleDateFormat("dd.MM.yyyy");
    }

    public Map<String, Object> execute(QueryRequest request) {
        Map<String, Object> result = new HashMap();
        try (Connection oConnection = fbDataSource.getConnection();
             NamedParameterStatement stm = new NamedParameterStatement(oConnection, request.getQuery())) {
            if (request.getParams() != null) {
                stm.setParameters(request.getParams());
            }
            if (stm.execute()) {
                result = fillContent(stm, result);
            } else {
                result.put("query", request.getQuery());
            }
            return result;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }

    }

    //private Map<String, TFieldType>

    private Map<String, Object> fillContent(NamedParameterStatement stm, Map<String, Object> result) throws SQLException {
        ResultSet rs = stm.getResultSet();
        List<Map<String, Object>> list = new ArrayList();
        ResultSetMetaData rsm = rs.getMetaData();
        while (rs.next()) {
            Map<String,Object> map = new LinkedHashMap<>();
            List<TFieldType> fieldTypes = new LinkedList<>();
            for (int i = 1; i <= rsm.getColumnCount(); i++) {
                String name = rsm.getColumnName(i);
                TFieldType fieldType = new TFieldType();
                if (Strings.isNullOrEmpty(name)) {
                    name = rsm.getColumnLabel(i);
                }
                fieldType.setName(name);
                switch (rsm.getColumnType(i)) {
                    case Types.DATE: {
                        Date val = rs.getDate(i);
                        map.put(name, rs.wasNull() ? null : simpleDateFormat.format(val));
                        fieldType.setType("D");
                        break;
                    }
                    case Types.TIMESTAMP:
                    case Types.TIMESTAMP_WITH_TIMEZONE: {
                        Timestamp val = rs.getTimestamp(i);
                        map.put(name, rs.wasNull() ? null : simpleDateTimeFormat.format(val));
                        break;
                    }
                    case Types.TIME:
                    case Types.TIME_WITH_TIMEZONE: {
                        Time tval = rs.getTime(i);
                        map.put(name, rs.wasNull() ? null : tval);
                        break;
                    }
                    case Types.LONGVARBINARY:
                    case Types.VARBINARY:
                    case Types.BINARY:
                        byte[] b = rs.getBytes(i);
                        map.put(name, rs.wasNull() ? null : Base64.getEncoder().encode(b));
                        break;
                    default: {
                        map.put(name, rs.getObject(i));
                    }
                }
            }
            list.add(map);
        }
        result.put("records",list);
        return result;
    }
}
