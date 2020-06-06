package vera.pro.model;

import lombok.Data;

@Data
public class TFieldDef {
    private String name;
    private String type;
    private Integer scale;
    private Integer precision;
}
