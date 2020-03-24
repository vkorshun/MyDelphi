package vera.pro.beans;

import lombok.Data;

import java.util.Map;

@Data
public class QueryRequest {
    private String query;
    private Map<String,Object> params;
}
