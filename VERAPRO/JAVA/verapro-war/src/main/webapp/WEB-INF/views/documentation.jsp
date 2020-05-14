<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>UNIVERSAL9 RESTFull Documentation</title>
    <link rel="icon" type="image/png" href="<c:url value='/resources/swagger-ui/lib/images/favicon-32x32.png'/>"
          sizes="32x32"/>
    <link rel="icon" type="image/png" href="<c:url value='/resources/swagger-ui/lib/images/favicon-32x32.png'/>"
          sizes="16x16"/>
    <link href="<c:url value='/resources/swagger-ui/lib/css/typography.css'/>" rel="stylesheet"/>
    <link href='<c:url value='/resources/swagger-ui/lib/css/reset.css'/>' media='screen' rel='stylesheet'
          type='text/css'/>
    <link href='<c:url value='/resources/swagger-ui/lib/css/screen.css'/>' media='screen' rel='stylesheet'
          type='text/css'/>
    <link href='<c:url value='/resources/swagger-ui/lib/css/reset.css'/>' media='print' rel='stylesheet'
          type='text/css'/>
    <link href='<c:url value='/resources/swagger-ui/lib/css/print.css'/>' media='print' rel='stylesheet'
          type='text/css'/>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/jquery-1.8.0.min.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/jquery.slideto.min.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/jquery.wiggle.min.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/jquery.ba-bbq.min.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/handlebars-2.0.0.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/underscore-min.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/backbone-min.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/swagger-ui.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/highlight.7.3.pack.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/marked.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lib/swagger-oauth.js'/>' type='text/javascript'></script>

    <!-- Some basic translations -->
    <script src='<c:url value='/resources/swagger-ui/lib/lang/translator.js'/>' type='text/javascript'></script>
    <script src='<c:url value='/resources/swagger-ui/lib/lang/ru.js'/>' type='text/javascript'></script>

    <script type="text/javascript">
        $(function () {
            // Pre load translate...
            if (window.SwaggerTranslator) {
                window.SwaggerTranslator.translate();
            }
            window.swaggerUi = new SwaggerUi({
                url: '<c:url value="/v2/api-docs"/>',
                <%--url: '<c:url value="http://petstore.swagger.io/v2/swagger.json"/>',--%>
                dom_id: "swagger-ui-container",
                supportedSubmitMethods: ['get', 'post', 'put', 'delete', 'patch'],
                onComplete: function (swaggerApi, swaggerUi) {
                    /*if (typeof initOAuth == "function") {
                        initOAuth({
                            clientId: "eRoom",
                            clientSecret: "eroomsecret",
                            realm: "your-realms",
                            appName: "eRoom",
                            scopeSeparator: ","
                        });
                    }*/

                    if (window.SwaggerTranslator) {
                        window.SwaggerTranslator.translate();
                    }

                    $('pre code').each(function (i, e) {
                        hljs.highlightBlock(e)
                    });

//                    addApiKeyAuthorization();
                },
                onFailure: function (data) {
                    log("Unable to Load SwaggerUI");
                },
                docExpansion: "none",
                apisSorter: "alpha",
                showRequestHeaders: false
            });

            /*function addApiKeyAuthorization() {
                var key = encodeURIComponent($('#input_apiKey')[0].value);
                if (key && key.trim() != "") {
                    var apiKeyAuth = new SwaggerClient.ApiKeyAuthorization("api_key", key, "query");
                    window.swaggerUi.api.clientAuthorizations.add("api_key", apiKeyAuth);
                    log("added key " + key);
                }
            }*/

//            $('#input_apiKey').change(addApiKeyAuthorization);

            // if you have an apiKey you would like to pre-populate on the page for demonstration purposes...
            /*
             var apiKey = "myApiKeyXXXX123456789";
             $('#input_apiKey').val(apiKey);
             */

            window.swaggerUi.load();

            function log() {
                if ('console' in window) {
                    console.log.apply(console, arguments);
                }
            }
        });
    </script>
</head>

<body class="swagger-section">
<div id='header'>
    <div class="swagger-ui-wrap">
        <a id="logo" href="http://swagger.io">swagger</a>

        <form id='api_selector' style="display: none">
            <div class='input'><input id="input_baseUrl" name="baseUrl" type="text"/></div>
            <div class='input'><input value="eroom" id="input_apiKey" name="apiKey" type="text"/></div>
            <div class='input'><a id="explore" href="#" data-sw-translate>Explore</a></div>
        </form>
    </div>
</div>

<div id="message-bar" class="swagger-ui-wrap" data-sw-translate>&nbsp;</div>
<div id="swagger-ui-container" class="swagger-ui-wrap"></div>
</body>
</html>
