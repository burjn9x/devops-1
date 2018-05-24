## Manual:

- Download camunda tomcat: https://camunda.com/download/

- Configure files: server.xml, bpm-platform.xml (process engine)

- Add mysql-connector library to apache-tomcat-8.0.47/lib

- Build workflow-plugin-sso and copy target/workflow-plugin-sso-7.6.1-SNAPSHOT.jar to apache-tomcat-8.0.47/webapps/camunda/WEB-INF/lib

- Configure file: apache-tomcat-8.0.47/webapps/camunda/WEB-INF/web.xml

- Copy file login.html to apache-tomcat-8.0.47/webapps/camunda/app/welcome

- Run script create-schema.sql

- Build eform and copy eForm/gateway/target/eform.war to apache-tomcat-8.0.47/webapps

- Run startup.sh in apache-tomcat-8.0.47/bin

- Run script create-user.sql

## Auto:

- Run script install-db-multitenant.sh (create TTV, TAPAC Db)



## User account:

Password of users: Abcd@1234

Link login SSO: http://localhost:8080/camunda/app/welcome/login
Link create tenant: http://localhost:8080/eform/tenant/{tenantName}
Link delete tenant: http://localhost:8080/eform/tenant/delete/{tenantName}

## Scenario:

- Login account: thanh.tn@tctav.com (SSO login link)
- Submit form Business-Trip
- In TTV tenant, we can log as account: eform.tbd@tctav.com to approve this task.
- Login account: approver@tapac.com (different browser)
- In SSO login, we redirect to TTV tenant, we also see this task and can approve this task.

* FLow approver (Business-Trip): eform.tbd@tctav.com => eform.op@tctav.com => oai.vq@tctav.com, tramanh@tctav.com => onishi.tomohiro@tctav.com, onishi.tomohiro@tctav.com => End

* FLow approver (Entertainment): 
    eform.tbd@tctav.com => eform.op@tctav.com => oai.vq@tctav.com => eform.ceo@tctav.com => End (<18000000)
    eform.tbd@tctav.com => eform.op@tctav.com => oai.vq@tctav.com => Lee.Kwangho@trans-cosmos.co.jp, Sohara.Kotaro@trans-cosmos.co.jp => End (>=18000000)


