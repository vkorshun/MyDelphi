package vera.pro.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

/**
 * Created by vkorshun on 15.07.2016.
 */
@Controller
//@RequestMapping({"/"})
//@Profile("VK_SWAGGER")
public class SwaggerController {

    @RequestMapping(value = "/documentation", method = RequestMethod.GET)
    public String documentation() {
        return "documentation";
    }


}
