package vera.pro.configuration;

import org.springframework.web.filter.CommonsRequestLoggingFilter;

import javax.servlet.*;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Created by vkorshun on 18.02.2017.
 */
public class CORSFilter extends CommonsRequestLoggingFilter {
  /*public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
    System.out.println("Filtering on...........................................................");
    HttpServletResponse response = (HttpServletResponse) res;
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, OPTIONS, DELETE");
    response.setHeader("Access-Control-Max-Age", "3600");
    response.setHeader("Access-Control-Allow-Headers", "x-requested-with");
    chain.doFilter(req, res);
  }

  public void init(FilterConfig filterConfig) {
  }*/

    public CORSFilter() {
        setIncludeClientInfo(true);
        setIncludeQueryString(true);
        setIncludePayload(true);
        setIncludeHeaders(true);
    }

    public void destroy() {
    }
}
