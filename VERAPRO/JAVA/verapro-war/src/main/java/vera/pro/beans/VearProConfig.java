package vera.pro.beans;

import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import vera.pro.model.LocationList;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Component
@Slf4j
public class VearProConfig {
    private LocationList locationList;
    private XmlMapper xmlMapper;
    @Value("${vera.pro.configurationFile}")
    private String configFileName;
    public VearProConfig()  {
        xmlMapper = new XmlMapper();


    }

    @PostConstruct
    public void afteCreate() {
        Path path = Paths.get(configFileName);
        try {
            String s = new String(Files.readAllBytes(path));
            locationList = xmlMapper.readValue(s,LocationList.class);
            log.info(locationList.toString());
        } catch (IOException e) {
            log.error(e.getMessage());
            throw new RuntimeException(e);
        }

    }
}
