package vera.pro.configuration.UniversalRest.Async;

import lombok.extern.slf4j.Slf4j;
import org.springframework.aop.interceptor.AsyncUncaughtExceptionHandler;

import java.lang.reflect.Method;

@Slf4j
public class AsyncExceptionHandler implements AsyncUncaughtExceptionHandler {
    @Override
    public void handleUncaughtException(Throwable throwable, Method method, Object... obj) {

        log.error("Async Exception Cause - {}", throwable.getMessage());
        log.error("Async Err Method name - {}",  method.getName());
        for (Object param : obj) {
            log.error("Async Parameter value - {}", param);
        }
    }
}
