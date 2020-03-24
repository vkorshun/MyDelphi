package vera.pro.DAO.core;


import lombok.extern.slf4j.Slf4j;

import java.io.*;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.stream.Collectors;

import static java.sql.Types.CHAR;

/**
 * Created by vkorshun on 05.02.2017.
 */
@Slf4j
public class NamedParameterStatement implements AutoCloseable {
    /**
     * The statement this object is wrapping.
     */
    private PreparedStatement statement;
    private Integer refCursorIndex = null;
    private Integer refJsonIndex = null;
    private Integer rowAffectedIndex = null;
    //    private List<ReturningPrameterVO> returningParams;
    private String currQuery;
    private Connection connection;
//    private IStatementHelper iStatementHelper;

    /**
     * Maps parameter names to arrays of ints which are the parameter indices.
     */
    private Map indexMap;
    protected List<String> setedList;

    /*public NamedParameterStatement(Connection connection, String query) throws SQLException {
        this(connection, query, null);
    }*/

    protected PreparedStatement createStatement(String query, boolean isCall) throws SQLException {
        if (isCall) {
            return connection.prepareCall(query);
        } else {
            return connection.prepareStatement(query);
        }
    }

    protected boolean isNeedCall() {
        return indexMap.containsKey("refcursor");
        //|| returningParams.size() != 0 ||
        //        currQuery.trim().startsWith("BEGIN") || currQuery.trim().startsWith("{") || currQuery.trim().startsWith("DECLARE");
    }

    public NamedParameterStatement(Connection connection, String query) throws SQLException {
        this.connection = connection;
        /*if (retList != null) {
            returningParams = retList;
            returningParams.forEach(item -> item.setIndex(-1));
        } else {
            returningParams = new ArrayList<>();
        }*/

        indexMap = new HashMap();
        String parsedQuery = parse(query, indexMap);
        currQuery = parsedQuery;
        setedList = new ArrayList();
        statement = createStatement(parsedQuery, isNeedCall());
        // iStatementHelper = createStatementHelper();
    }

    /*protected IStatementHelper createStatementHelper() {
        return new StatementHelper(this);
    }*/


    /**
     * Parses a query with named parameters.  The parameter-index mappings are
     * put into the map, and the
     * parsed query is returned.  DO NOT CALL FROM CLIENT CODE.  This
     * method is non-private so JUnit code can
     * test it.
     *
     * @param query    query to parse
     * @param paramMap map to hold parameter-index mappings
     * @return the parsed query
     */
    public static final String parse(String query, Map paramMap) {
        // I was originally using regular expressions, but they didn't work well for ignoring
        // parameter-like strings inside quotes.
        query = query.replace('\r', '\n');
        int length = query.length();
        StringBuffer parsedQuery = new StringBuffer(length);
        boolean inSingleQuote = false;
        boolean inDoubleQuote = false;
        boolean inComment = false;
        boolean inCommentLine = false;
        int index = 1;

        for (int i = 0; i < length; i++) {
            char c = query.charAt(i);
            if (inSingleQuote) {
                if (c == '\'') {
                    inSingleQuote = false;
                }
            } else if (inDoubleQuote) {
                if (c == '"') {
                    inDoubleQuote = false;
                }
            } else if (inComment) {
                if (c == '*' && query.charAt(i + 1) == '/') {
                    inComment = false;
                }
            } else if (inCommentLine) {
                if (c == '\n') {
                    inCommentLine = false;
                }
            } else {
                if (c == '\'') {
                    inSingleQuote = true;
                } else if (c == '"') {
                    inDoubleQuote = true;
                } else if (c == '/' && i < length - 1 && query.charAt(i + 1) == '*') {
                    inComment = true;
                } else if (!inSingleQuote && ((c == '/' && i < length - 1 && query.charAt(i + 1) == '/') || (c == '-' && query.charAt(i + 1) == '-'))) {
                    inCommentLine = true;
                } else if (c == ':' && i + 1 < length &&
                        Character.isJavaIdentifierStart(query.charAt(i + 1)) && (i > 0 ? query.charAt(i - 1) != ':' : true)) {
                    int j = i + 2;
                    while (j < length && Character.isJavaIdentifierPart(query.charAt(j))) {
                        j++;
                    }
                    String name = query.substring(i + 1, j);
                    c = '?'; // replace the parameter with a question mark
                    i += name.length(); // skip past the end if the parameter

                    List indexList = (List) paramMap.get(name);
                    if (indexList == null) {
                        indexList = new LinkedList();
                        paramMap.put(name, indexList);
                    }
                    indexList.add(Integer.valueOf(index));

                    index++;
                }
            }
            parsedQuery.append(c);
        }

        // replace the lists of Integer objects with arrays of ints
        for (Iterator itr = paramMap.entrySet().iterator(); itr.hasNext(); ) {
            Map.Entry entry = (Map.Entry) itr.next();
            List list = (List) entry.getValue();
            int[] indexes = new int[list.size()];
            int i = 0;
            for (Iterator itr2 = list.iterator(); itr2.hasNext(); ) {
                Integer x = (Integer) itr2.next();
                indexes[i++] = x.intValue();
            }
            entry.setValue(indexes);
        }

        return parsedQuery.toString();
    }


    /**
     * Returns the indexes for a parameter.
     *
     * @param name parameter name
     * @return parameter indexes
     * @throws IllegalArgumentException if the parameter does not exist
     */
    protected int[] getIndexes(String name) {
        int[] indexes = (int[]) indexMap.get(name);
        if (indexes == null) {
            log.error("not param inQ UERY: {}", currQuery);
            throw new IllegalArgumentException("Parameter not found: " + name);
        }
        return indexes;
    }

    public boolean checkParam(String name) {
        int[] indexes = (int[]) indexMap.get(name);
        return indexes != null;
    }


    /**
     * Sets a parameter.
     *
     * @param name  parameter name
     * @param value parameter value
     * @throws SQLException             if an error occurred
     * @throws IllegalArgumentException if the parameter does not exist
     * @see PreparedStatement#setObject(int, java.lang.Object)
     */
    public void setObject(String name, Object value) throws SQLException {
    /*int[] indexes = getIndexes(name);
    for (int i = 0; i < indexes.length; i++) {
      statement.setObject(indexes[i], value);
    }*/
        setParam(name, value);
    }


    /**
     * Sets a parameter.
     *
     * @param name  parameter name
     * @param value parameter value
     * @throws SQLException             if an error occurred
     * @throws IllegalArgumentException if the parameter does not exist
     * @see PreparedStatement#setString(int, java.lang.String)
     */
    public void setString(String name, String value) throws SQLException {
    /*int[] indexes = getIndexes(name);
    int number = -1;
    try {
      for (int i = 0; i < indexes.length; i++) {
        number = i;
        statement.setString(indexes[i], value);
      }
      setedList.add(name);
    } catch (Exception ex) {
      throw new RuntimeException("Basd index "+name+" "+String.valueOf(number));
    }*/
        setParam(name, value);
    }

    public void setClob(String name, String value) throws SQLException, IOException {
        Clob clob = connection.createClob();
        Writer writer = clob.setCharacterStream(0L);
        writer.write(value.toCharArray());
        writer.flush();
        writer.close();
        int[] indexes = getIndexes(name);
        int number = -1;
        try {
            for (int i = 0; i < indexes.length; i++) {
                number = i;
                statement.setClob(indexes[i], clob);
            }
            setedList.add(name);
        } catch (Exception ex) {
            throw new RuntimeException("Basd index " + name + " " + String.valueOf(number));
        }
        //setParam(name,clob);
    }

    protected Object checkIsTimestamp(String parName, Object obj) {
        if (obj instanceof String) {
            String value = checkDateFormat((String) obj);
            if (value.matches("\\d{4}-\\d{2}-\\d{2}")) {
                return Timestamp.valueOf(value + " 00:00:00");
            } else if (value.matches("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}")) {
                return Timestamp.valueOf(value);
            } else if (value.matches("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}")) {
                return Timestamp.valueOf(value + ":00");
            } else if (value.matches("\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}")) {
                return Timestamp.valueOf(value.replace("T", " "));
            }
        }
        return obj;
    }

    protected String checkDateFormat(String s) {
        if (s.matches("\\d{2}\\.\\d{2}\\.\\d{4}") ||
                s.matches("\\d{2}\\.\\d{2}\\.\\d{4} \\d{2}:\\d{2}:\\d{2}") ||
                s.matches("\\d{2}\\.\\d{2}\\.\\d{4} \\d{2}:\\d{2}") ||
                s.matches("\\d{2}\\.\\d{2}\\.\\d{4}T\\d{2}:\\d{2}:\\d{2}")) {
            String dd = s.substring(0, 2);
            String mm = s.substring(3, 5);
            String yy = s.substring(6, 10);
            String other = s.substring(10);
            return yy + "-" + mm + "-" + dd + other;
        } else {
            return s;
        }
    }

    public <T> void setParam(String name, T value) {
        if (statement != null && checkParam(name)) {


            int[] indexes = getIndexes(name);
            int number = -1;
            //        ReturningPrameterVO par = getReturningParam(name);
            try {
                for (int i = 0; i < indexes.length; i++) {
                    number = i;
                    //Если INOUT то надо вначале регистрировать OUT

                    /*if (par != null && par.getIndex() == -1 && Optional.ofNullable(getReturningParam(name)).map(item -> item.isMasked() == false).orElse(true)) {
                        par.setIndex(indexes[i]);
                        ((CallableStatement) statement).registerOutParameter(par.getIndex(), par.getJDBCType());
                    }*/
                    //Для INOUT нельзя присваивать null
                    if (value == null) {
                        statement.setNull(indexes[i], Types.CHAR);
                    } else {
                        Object _obj = checkIsTimestamp(name, value);
                        statement.setObject(indexes[i], _obj);
                    }
                }

                setedList.add(name);
            } catch (Exception ex) {
                log.error(ex.getMessage());
                throw new RuntimeException("Error in setting param - index " + name + " " + String.valueOf(number) + "\n" + ex.getMessage());
            }
        }

    }


    public void setBlob(String name, byte[] bytes) throws SQLException {
        if (checkParam(name)) {
            int[] idx = getIndexes(name);

            for (int i = 0; i < idx.length; ++i) {
                Blob blob = connection.createBlob();
                try (OutputStream in = blob.setBinaryStream(1)) {
                    try {
                        in.write(bytes);
                    } catch (Exception ex) {
                        log.error(ex.getMessage());
                    }
                    statement.setBlob(idx[i], blob);
                } catch (IOException e) {
                    log.error(e.getMessage());

                }
            }
        }
    }

    /**
     * Sets a parameter.
     *
     * @param name  parameter name
     * @param value parameter value
     * @throws SQLException             if an error occurred
     * @throws IllegalArgumentException if the parameter does not exist
     * @see PreparedStatement#setInt(int, int)
     */
    public void setInt(String name, int value) throws SQLException {
/*    int[] indexes = getIndexes(name);
    for (int i = 0; i < indexes.length; i++) {
      statement.setInt(indexes[i], value);
    }*/
        setParam(name, Integer.valueOf(value));
    }


    /**
     * Sets a parameter.
     *
     * @param name  parameter name
     * @param value parameter value
     * @throws SQLException             if an error occurred
     * @throws IllegalArgumentException if the parameter does not exist
     * @see PreparedStatement#setInt(int, int)
     */
    public void setLong(String name, long value) throws SQLException {
    /*int[] indexes = getIndexes(name);
    for (int i = 0; i < indexes.length; i++) {
      statement.setLong(indexes[i], value);
    }*/
        setParam(name, value);
    }


    /**
     * Sets a parameter.
     *
     * @param name  parameter name
     * @param value parameter value
     * @throws SQLException             if an error occurred
     * @throws IllegalArgumentException if the parameter does not exist
     * @see PreparedStatement#setTimestamp(int, java.sql.Timestamp)
     */
    public void setTimestamp(String name, Timestamp value) throws SQLException {
    /*int[] indexes = getIndexes(name);
    for (int i = 0; i < indexes.length; i++) {
      statement.setTimestamp(indexes[i], value);
    }*/
        setParam(name, value);
    }


    /**
     * Returns the underlying statement.
     *
     * @return the statement
     */
    public PreparedStatement getStatement() {
        return statement;
    }


    /**
     * Executes the statement.
     *
     * @return true if the first result is a {@link ResultSet}
     * @throws SQLException if an error occurred
     * @see PreparedStatement#execute()
     */
    public boolean execute() throws SQLException {
        checkSetedParams();
        //checkReturningParameters();
        try {
            return statement.execute();
        } catch (SQLException ex) {
            log.error(currQuery);
            throw ex;
        }
    }


    public boolean execute(boolean bCheck4068) throws SQLException {
        try {
            checkSetedParams();
            //checkReturningParameters();
            return statement.execute();
        } catch (Exception ex) {
            log.error(currQuery);
            throw ex;
        }
    }


    /**
     * Executes the statement, which must be a query.
     *
     * @return the query results
     * @throws SQLException if an error occurred
     * @see PreparedStatement#executeQuery()
     */
    public ResultSet executeQuery() throws SQLException {
        checkSetedParams();
        //checkReturningParameters();
        return statement.executeQuery();
    }


    /**
     * Executes the statement, which must be an SQL INSERT, UPDATE or DELETE
     * statement;
     * or an SQL statement that returns nothing, such as a DDL statement.
     *
     * @return number of rows affected
     * @throws SQLException if an error occurred
     * @see PreparedStatement#executeUpdate()
     */
    public int executeUpdate() throws SQLException {
        checkSetedParams();
        //checkReturningParameters();
        return statement.executeUpdate();
    }


    /**
     * Closes the statement.
     *
     * @throws SQLException if an error occurred
     * @see Statement#close()
     */
    public void close() throws SQLException {
        statement.close();
        setedList.clear();
    }


    /**
     * Adds the current set of parameters as a batch entry.
     *
     * @throws SQLException if something went wrong
     */
    public void addBatch() throws SQLException {
        statement.addBatch();
    }


    /**
     * Executes all of the batched statements.
     * <p>
     * See {@link Statement#executeBatch()} for details.
     *
     * @return update counts for each statement
     * @throws SQLException if something went wrong
     */
    public int[] executeBatch() throws SQLException {
        return statement.executeBatch();
    }

    protected void setAdditionalParameterIndex(String key, boolean isInit) throws SQLException {
    }

    /*private void checkReturningParameters() throws SQLException {
        for (ReturningPrameterVO par : returningParams) {
            String key = par.getNameInQuery();
            int[] indexes = getIndexes(key);
            for (int i = 0; i < indexes.length; i++) {
                switch (key) {
                    case "refcursor": {
                        refCursorIndex = indexes[i];
                        ((CallableStatement) statement).registerOutParameter(refCursorIndex, OracleTypes.CURSOR);
                        break;
                    }
                    case "refJson": {
                        refJsonIndex = indexes[i];
                        ((CallableStatement) statement).registerOutParameter(refJsonIndex, OracleTypes.CLOB);
                        break;
                    }
                    case "row_affected": {
                        rowAffectedIndex = indexes[i];
                        ((CallableStatement) statement).registerOutParameter(rowAffectedIndex, Types.NUMERIC);
                        break;
                    }
                    default: {
                        if (par.getIndex() == -1) {
                            par.setIndex(indexes[i]);
                            ((CallableStatement) statement).registerOutParameter(par.getIndex(), par.getJDBCType());
                        }
                    }
                }
            }
        }
    }*/

    private void checkSetedParams() throws SQLException {
        for (Iterator itr = indexMap.entrySet().iterator(); itr.hasNext(); ) {
            Map.Entry entry = (Map.Entry) itr.next();
            String key = (String) entry.getKey();
            if (setedList.indexOf(key) == -1) {
                int[] indexes = getIndexes(key);
                for (int i = 0; i < indexes.length; i++) {
                    switch (key) {
                        case "refcursor": {
                            refCursorIndex = indexes[i];
                            break;
                        }
                        case "refJson": {
                            refJsonIndex = indexes[i];
                            break;
                        }
                        case "row_affected": {
                            rowAffectedIndex = indexes[i];
                            break;
                        }
                        default: {
                            statement.setNull(indexes[i], CHAR);
                        }
                    }
                }
//        setAdditionalParameterIndex(key, true);
            }
        }
    }

    public ResultSet getResultSet() throws SQLException {
        if (refCursorIndex == null) {
            return statement.getResultSet();
        } else {
            return (ResultSet) ((CallableStatement) statement).getObject(refCursorIndex);
        }
    }

    public boolean isRefCursor() {
        return refCursorIndex != null;
    }

    public boolean isRefJson() {
        return refJsonIndex != null;
    }

    /*public boolean isReturningParameter(String key) {
        for (ReturningPrameterVO par : returningParams) {
//      if (("r_"+par.getName()).equals(key) || par.getName().equals(key)) {
            if (par.getNameInQuery().equals(key)) {
                return true;
            }
        }
        return false;
    }*/

    /*public ReturningPrameterVO getReturningParam(String key) {
        String tmpKey = key.startsWith("r_") ? key.substring(2, key.length()) : key;
        for (ReturningPrameterVO par : returningParams) {
            if (par.getName().equals(tmpKey)) {
                return par;
            }
        }
        return null;
    }*/

    /*public Object getReturningValue(ReturningPrameterVO par) throws SQLException {
        if (par != null) {
            if (par.getIndex() == -1) {
                setAdditionalParameterIndex(par.getName(), false);
            }
            if (par.getJDBCType() == Types.NUMERIC) {
                return ((CallableStatement) statement).getBigDecimal(par.getIndex());
            } else if (par.getJDBCType() == Types.TIMESTAMP) {
                return ((CallableStatement) statement).getTimestamp(par.getIndex());
            } else if (par.getJDBCType() == OracleTypes.CURSOR) {
                return (ResultSet) ((CallableStatement) statement).getObject(par.getIndex());
            } else {
                String s = ((CallableStatement) statement).getString(par.getIndex());
                if (s != null && par.getChar_length() > 0 && s.length() > par.getChar_length()) {
                    return s.substring(0, par.getChar_length());
                } else {
                    return s;
                }
            }
        } else {
            throw new SQLException(String.format("Paramster %s not found", Optional.ofNullable(par).map(item -> item.getName()).orElse("undefined")));
        }
    }


    public Object getReturningValue(String key) throws SQLException {
        ReturningPrameterVO par = getReturningParam(key);
        return getReturningValue(par);
    }

    public void setReturningParams(List<ReturningPrameterVO> returningParams) {
        this.returningParams = returningParams;
    }

    public BigDecimal getReturningBigDecimal(String key) throws SQLException {
        ReturningPrameterVO par = getReturningParam(key);
        if (par != null) {
            return ((CallableStatement) statement).getBigDecimal(par.getIndex());
        } else {
            throw new SQLException(String.format("Paramster %s not found", key));
        }

    }*/

    public Integer getRowAffectedIndex() {
        return rowAffectedIndex != null ? rowAffectedIndex : -1;
    }

    /*public HashMap<String, Object> getReturningValues() throws SQLException {
        HashMap<String, Object> hm = new HashMap<>();
        for (ReturningPrameterVO par : returningParams) {
            hm.put(par.getName(), getReturningValue(par));
        }
        return hm;
    }*/

    //checkUserSessionId(oConnection, params);
    public void setParameters(Map<String, Object> params) {
        if (params != null) {
            for (Map.Entry<String, Object> entry : params.entrySet()) {
                if (checkParam(entry.getKey())) {
                    setParam(entry.getKey(), entry.getValue());
                }
            }
        }
    }

    /*private int getSQLParameterType(ParameterMetaData pmd, String name) throws SQLException {
      for (int i=1;i<=pmd.getParameterCount(); i++) {
        if pmd.
      }

    }*/
    public byte[] readBlob(Blob blob) throws SQLException, IOException {
        try (ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
            if (blob != null) {
                try (InputStream in = blob.getBinaryStream()) {
                    byte[] buffer = new byte[1024];
                    for (int len; (len = in.read(buffer)) != -1; ) {
                        bos.write(buffer, 0, len);
                    }
                }
            }
            return bos.toByteArray();
        }
    }

    /*public Object getObject(String name) throws SQLException {
        return iStatementHelper.getObject(name);
    }

    public byte[] getBytes(String name) throws SQLException {
        return iStatementHelper.getBytes(name);
    }

    public <T> T getValue(String name) throws SQLException {
        return iStatementHelper.getValue(name);
    }*/

    public int getFirstIndex(String name) {
        int[] indexses = getIndexes(name);
        if (indexses.length > 0) {
            return indexses[0];
        } else {
            return -1;
        }
    }

    public Connection getConnection() {
        return connection;
    }

    public static void raiseApplicationError(BigDecimal code, String msg) throws SQLException {
        throw new SQLException(String.format("ORA%d: %s", code.intValue(), msg), "72000", -code.intValue());
    }

    public void setParams(Object obj) {
        Field[] fields = obj.getClass().getDeclaredFields();
        List<String> names = Arrays.stream(fields).filter(item -> checkParam(item.getName())).map(item -> item.getName()).collect(Collectors.toList());
        for (String name : names) {
            try {
                Field field = obj.getClass().getDeclaredField(name);
                field.setAccessible(true);
                setParam(name, field.get(obj));
            } catch (NoSuchFieldException ex) {
                log.error(ex.getMessage());
                throw new RuntimeException(ex);
            } catch (IllegalAccessException ex) {
                log.error(ex.getMessage());
                throw new RuntimeException(ex);
            }
        }
    }

    public String getRefJson() {
        if (refJsonIndex != null) {
            try {
                return ((CallableStatement) statement).getString(refJsonIndex);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        } else {
            return null;
        }

    }

}
