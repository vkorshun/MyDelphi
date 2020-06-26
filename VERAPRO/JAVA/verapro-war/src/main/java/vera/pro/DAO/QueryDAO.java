package vera.pro.DAO;

import com.google.common.base.Strings;
import lombok.extern.slf4j.Slf4j;
import vera.pro.DAO.core.NamedParameterStatement;
import vera.pro.beans.QueryRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import vera.pro.model.TFieldDef;

import java.sql.*;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
@Slf4j
public class QueryDAO {

    @Autowired
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

    private List<TFieldDef> getFieldDefs(ResultSetMetaData rsm) {
        try {
            List<TFieldDef> fieldDefs = new LinkedList<>();
            for (int i = 1; i <= rsm.getColumnCount(); ++i) {
                String name = rsm.getColumnName(i);
                TFieldDef fieldDefine = new TFieldDef();
                if (Strings.isNullOrEmpty(name)) {
                    name = rsm.getColumnLabel(i);
                }
                System.out.println(String.format("---- %s %s", name, rsm.getColumnLabel(i)));
                fieldDefine.setName(name);
                fieldDefine.setPrecision(rsm.getPrecision(i));
                fieldDefine.setScale(rsm.getScale(i));
                fieldDefine.setFieldType(rsm.getColumnType(i));
                /*switch (rsm.getColumnType(i)) {
                    case Types.DATE: {
                        fieldDefine.setType("D");
                        break;
                    }
                    case Types.TIMESTAMP:
                    case Types.TIMESTAMP_WITH_TIMEZONE: {
                        fieldDefine.setType("TS");
                        break;
                    }
                    case Types.TIME:
                    case Types.TIME_WITH_TIMEZONE: {
                        fieldDefine.setType("T");
                        break;
                    }
                    case Types.LONGVARBINARY:
                    case Types.VARBINARY:
                    case Types.BINARY:
                        fieldDefine.setType("BINARY");
                        break;
                    case Types.BIGINT:
                        fieldDefine.setType("BIGINT");
                        break;
                    case Types.BIT:
                    case Types.BOOLEAN:
                        fieldDefine.setType("L");
//                        fieldDefine.setPrecision(16);
                        break;
                    case Types.BLOB:
                        fieldDefine.setType("BLOB");
                        break;
                    case Types.CLOB:
                        fieldDefine.setType("CLOB");
                        break;
                    case Types.DECIMAL:
                    case Types.FLOAT:
                    case Types.NUMERIC:
                        fieldDefine.setType("N");
                        break;
                    case Types.INTEGER:
                    case Types.SMALLINT:
                        fieldDefine.setType("I");
                        break;
                    default: {
                        fieldDefine.setType("C");
                        fieldDefine.setPrecision(rsm.getPrecision(i));
                    }
                }*/
                fieldDefs.add(fieldDefine);
            }
            return fieldDefs;
        } catch (SQLException throwables) {
            log.error(throwables.getMessage());
            throw new RuntimeException(throwables);
        }

    }

    private Map<String, Object> fillContent(NamedParameterStatement stm, Map<String, Object> result) throws SQLException {
        ResultSet rs = stm.getResultSet();
        List<Map<String, Object>> list = new ArrayList();
        ResultSetMetaData rsm = rs.getMetaData();
        List<TFieldDef> fieldDefs = getFieldDefs(rsm);
        result.put("fieldDefs", fieldDefs);
        while (rs.next()) {
            Map<String, Object> map = new LinkedHashMap<>();
            for (int i = 1; i <= rsm.getColumnCount(); i++) {
                String name = rsm.getColumnName(i);
                if (Strings.isNullOrEmpty(name)) {
                    name = rsm.getColumnLabel(i);
                }
                switch (rsm.getColumnType(i)) {
                    case Types.DATE: {
                        Date val = rs.getDate(i);
                        map.put(name, rs.wasNull() ? null : simpleDateFormat.format(val));
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
        result.put("rows", list);
        return result;
    }
}
