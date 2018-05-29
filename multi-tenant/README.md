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

- Run script multitenant-installation.sh (setup environment)

- Create tenant: run script 4.create-tenant.sh

- Delete tenant: run script 6.delete-tenant.sh

- Create user: run script 5.create-user.sh

## User account:

- Link login SSO: http://camunda.local.tctav.com/camunda/login

- Password of default users: Abcd@1234

## Scenario:

- Use script to create user in TTV tenant, or use default user to submit form.
- In TTV tenant, we can log as account: eform.tbd@tctav.com to approve this task.

- Use script to create user in TAPAC tenant (adminTAPAC, Lee.Kwangho@trans-cosmos.co.jp, Sohara.Kotaro@trans-cosmos.co.jp)
- Login account in different browser
- In SSO login, we redirect to TTV tenant, we also see this task and can approve this task (if this task was assigned to this logged user)

* FLow approver (Business-Trip): eform.tbd@tctav.com => eform.op@tctav.com => oai.vq@tctav.com, tramanh@tctav.com => onishi.tomohiro@tctav.com, onishi.tomohiro@tctav.com => End

* FLow approver (Entertainment): 
    eform.tbd@tctav.com => eform.op@tctav.com => oai.vq@tctav.com => eform.ceo@tctav.com => End (<18000000)
    eform.tbd@tctav.com => eform.op@tctav.com => oai.vq@tctav.com => Lee.Kwangho@trans-cosmos.co.jp, Sohara.Kotaro@trans-cosmos.co.jp => End (>=18000000)


