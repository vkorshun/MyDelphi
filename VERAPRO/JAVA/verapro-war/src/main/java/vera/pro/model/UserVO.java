package vera.pro.model;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class UserVO {
    private BigDecimal idGroup;
    private BigDecimal idUser;
    private String name;
    private String description;
    private BigDecimal idObject;
    private BigDecimal idEnterprize;
    private String userpassword;
    private boolean requiredpasword;

}
