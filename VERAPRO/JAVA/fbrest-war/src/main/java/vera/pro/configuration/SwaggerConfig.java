package vera.pro.configuration;

/**
 * Created by vkorshun on 15.07.2016.
 */

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

import static springfox.documentation.builders.PathSelectors.regex;

@Configuration
//@EnableWebMvc
@EnableSwagger2
//@Profile("SP_SWAGGER")
public class SwaggerConfig {
    @Bean
    public Docket api() {
        return new Docket(DocumentationType.SWAGGER_2)
                .select()
                .apis(RequestHandlerSelectors.any())
                .paths(regex("/.*"))
                .build()
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo() {
        return new ApiInfo(
                "REST API - universal",
                "Сервисы для UNIVERSAL",
                "1.0",
                "http://wgsoftpro.com.ua",
                "http://wgsoftpro.com.ua",
                "API License",
                "http://wgsoftpro.com.ua"
        );
    }
}
