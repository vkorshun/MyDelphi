package vera.pro.model;

import com.fasterxml.jackson.annotation.JsonSetter;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import lombok.Data;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;

@Data
//@XmlRootElement(name = "LOCATION")
//@XmlAccessorType(XmlAccessType.FIELD)
public class LocationVO {
//    @XmlAttribute(name = "NAME")
    @JacksonXmlProperty( localName = "name", isAttribute = true)
    private String name;
    //@JacksonXmlProperty( localName = "DB_DRIVERNAME")
    //@JsonSetter("DB_DRIVERNAME")
    private String dbDriverName;
    //@JacksonXmlProperty( localName = "DB_URL")
    private String dbUrl;
    @JacksonXmlProperty( localName = "DB_USERNAME")
    private String userName;
    @JacksonXmlProperty( localName = "DB_PASSWORD")
    private String password;
    @JacksonXmlProperty( localName = "MAXPOOLSIZE")
    private Integer maxPoolSize;
    @JacksonXmlProperty( localName = "MINIDLE")
    private Integer minIdle;
    @JacksonXmlProperty( localName = "ENCODING")
    private String encoding;
}
