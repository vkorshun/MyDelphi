package vera.pro.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import lombok.Data;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;
import java.util.List;

@Data
//@XmlRootElement(name = "LOCATIONS")
//@XmlAccessorType(XmlAccessType.FIELD)
public class LocationList {
    //@JacksonXmlElement(localName = "LOCATION")
    @JacksonXmlProperty( localName = "LOCATION")
    @JacksonXmlElementWrapper(useWrapping = false)
    private List<LocationVO> locations;
}
