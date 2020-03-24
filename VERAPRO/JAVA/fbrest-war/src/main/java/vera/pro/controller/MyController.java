package vera.pro.controller;

import vera.pro.DAO.QueryDAO;
import vera.pro.beans.QueryRequest;
import vera.pro.beans.Response;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@RestController
public class MyController {
    @Autowired
    private QueryDAO queryDAO;

    @RequestMapping(value="/test",method = RequestMethod.GET, produces = {"application/json"})
    public Map<String,Object> index() {
        Map<String,Object> hm = new HashMap();
        hm.put("RESULT","OK");
//        Link link = ControllerLinkBuilder.linkTo(MyController.class)
//                .withSelfRel();

        List<Map<String,Object>> list = new ArrayList();
        list.add(hm);
        //Resource<Map<String, Object>> res = Resource.wrap(list);
  //      Resource<Map<String,Object>> result = new Resource<Map<String,Object>>(hm, link);
        //res.add(link);
        return hm;
    }

    @RequestMapping(value="/query",method = RequestMethod.POST, produces = {"application/json"})
    public Response query(@RequestBody QueryRequest request) {
        Response response = new Response();
        try {
            response.setContent( queryDAO.execute(request));
            response.setResult("OK");
        } catch (Exception ex) {
            Map<String,Object> error = new HashMap<>();
            error.put("errorMessage",ex.getMessage());
            response.setResult("ERROR");
            response.setContent(error);
        }
        return response;
    }
}

