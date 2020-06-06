package vera.pro.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import vera.pro.DAO.FbDataSource;
import vera.pro.DAO.UsersDAO;
import vera.pro.model.UserVO;

@Service
public class AuthSerrvice {
    @Autowired
    private FbDataSource fbDataSource;

    @Autowired
    private UsersDAO usersDAO;

    public boolean checkUser(String userName, String password){
        UserVO userVO =usersDAO.getUser(fbDataSource.getDatasource(), userName);
        if (userVO == null) {
            throw new RuntimeException(String.format("User %s not found", userName));
        }
        try {
            return password.equals(userVO.getUserpassword());
        } catch (Exception ex) {
            throw new RuntimeException(String.format("Error in check password of User %s ", userName));
        }
    }

}
