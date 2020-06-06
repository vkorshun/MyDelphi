package vera.pro.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import vera.pro.beans.QueryRequest;
import vera.pro.beans.Response;
import vera.pro.model.UserAuth;
import vera.pro.services.AuthSerrvice;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping(value="/users")
public class UsersController {
    @Autowired
    private AuthSerrvice authSerrvice;

    @RequestMapping(value="/auth",method = RequestMethod.POST, produces = {"application/json"})
    public @ResponseBody Response auth(@RequestBody UserAuth userRequest) {
        Response response = new Response();
        try {
            Map<String,Object> result = new LinkedHashMap<>();
            result.put("result", authSerrvice.checkUser(userRequest.getUsername(), userRequest.getPassword()));

            response.setContent( result);
            response.setResult("OK");
        } catch (Exception ex) {
            Map<String,Object> error = new HashMap<>();
            error.put("errorMessage",ex.getMessage());
            response.setResult("ERROR");
            response.setContent(error);
        }
        return response;
    }

    //@Data
    /*private class UserRequest {
        private String userName;
        private String password;

        public UserRequest(String userName, String password) {
            this.userName = userName;
            this.password = password;
        }
    }*/

}
