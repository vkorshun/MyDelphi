package vera.pro.beans;

import lombok.Data;

import java.util.Map;

@Data
public class Response {
    private String result;
    private Map<String,Object> content;
}
