package vera.pro.configuration.UniversalRest;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Scope;
import org.springframework.context.annotation.ScopedProxyMode;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;

import javax.sql.DataSource;

@Service
public class TrManagerConfig {
    //implements TransactionManagementConfigurer
    @Bean(name = "tm1")
    @Scope(value = "request", proxyMode = ScopedProxyMode.INTERFACES)
    public PlatformTransactionManager getTxManager() {
        DataSourceTransactionManager txm = null;
        DataSource ds = getDataSource();
        if (ds != null) {
            txm = new DataSourceTransactionManager(ds);
        }
        return txm;
    }


    public DataSource getDataSource() {
       // return UniversalSessionList.getRequestDataSource();
        return null;
    }

    public static TransactionStatus getTransactionStatus(PlatformTransactionManager txManager) {
        DefaultTransactionDefinition dtd = new DefaultTransactionDefinition();
        dtd.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
        dtd.setIsolationLevel(TransactionDefinition.ISOLATION_READ_COMMITTED);
        dtd.setReadOnly(false);

        return txManager.getTransaction(dtd);
    }

}
