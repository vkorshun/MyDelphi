package vera.pro.beans;

import lombok.Data;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Data
public class QueryRequest {
    private String query;
    private List<Map<String,Object>> params;

    public Map<String,Object> getParams(){
        Map<String,Object> map = new HashMap<>();
        params.forEach(item->map.putAll(item));
        return map;
    }
}
