#!/bin/bash
# -------
# Script to check and initialize all necessary stuffs before installing devops
# -------

CAMUNDA_VERSION=7.8
export DEVOPS_HOME=/home/devops
# export BASE_INSTALL=/home/ubuntu/devops
# export TIME_ZONE="Asia/Ho_Chi_Minh"
# export NGINX_CONF=$BASE_INSTALL/_ubuntu/etc/nginx
export TMP_INSTALL=/tmp/devops-install

export CATALINA_HOME=$DEVOPS_HOME/tomcat
export DEVOPS_DATA_HOME=$DEVOPS_HOME/devops_data

export CAMUNDAURL=https://camunda.org/release/camunda-bpm/tomcat/$CAMUNDA_VERSION/camunda-bpm-tomcat-$CAMUNDA_VERSION.0.zip

export APTVERBOSITY="-qq -y"
export DEFAULTYESNO="y"

## Database info, mysql is used by default
## these variables will be changed if different database is picked up
## with mariadb, database info connector is quite the same with mysql
export DB_USERNAME=devops
export DB_PASSWORD=devops
export DB_NAME=devops
export DB_PORT=3306
export DB_DRIVER=com.mysql.jdbc.Driver
export DB_CONNECTOR=mysql
export DB_SUFFIX="\?useSSL=false\&amp;autoReconnect=true\&amp;useUnicode=yes\&amp;characterEncoding=utf8"

DEVOPS_DATA_HOME_PATH="${DEVOPS_DATA_HOME//\//\\/}"


# size of swapfile in megabytes
# default is 8192MB (8GBx1024)
swapsize=8192

# Color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echoblue () {
  echo "${bldblu}$1${txtrst}"
}
echored () {
  echo "${bldred}$1${txtrst}"
}
echogreen () {
  echo "${bldgre}$1${txtrst}"
}

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Begin running...."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Camunda BPM."
echo "Download war files and other configuration"
echo "If you have already downloaded your war files you can skip this step and add "
echo "them manually."
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add Camunda war file and configuration${ques} [y/n] " -i "$DEFAULTYESNO" installcamundawar
if [ "$installcamundawar" = "y" ]; then
  if [ ! -d "$TMP_INSTALL" ]; then 
    mkdir "$TMP_INSTALL" 
  fi

  echo "Downloading Camunda..."
  curl -# -o $TMP_INSTALL/camunda-bpm-tomcat-$CAMUNDA_VERSION.0.zip $CAMUNDAURL
  echo

  unzip -q $TMP_INSTALL/camunda-bpm-tomcat-*.zip -d $TMP_INSTALL/camunda-bpm-tomcat
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/conf/bpm-platform.xml $CATALINA_HOME/conf
  
  sed -i "s/@@DEVOPS_DATA_HOME@@/$DEVOPS_DATA_HOME_PATH/g" $CATALINA_HOME/conf/server.xml
  
  # Insert Camunda configuration into server.xml
  #sudo sed -i $'/<\/GlobalNamingResources>/{e cat     tomcat/camunda-server.conf\n}' $CATALINA_HOME/conf/server.xml
  sed -i '/<Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" \/>/s/.*/&\n<Listener className="org.camunda.bpm.container.impl.tomcat.TomcatBpmPlatformBootstrap" \/>/' $CATALINA_HOME/conf/server.xml
  sed -i '/<\/GlobalNamingResources>/i \
    <Resource name="jdbc\/ProcessEngine"\
			  auth="Container"\
			  type="javax.sql.DataSource"\
			  factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"\
			  uniqueResourceName="process-engine"\
			  driverClassName="@@DB_DRIVER@@"\
			  url="jdbc:@@DB_CONNECTOR@@:\/\/localhost:@@DB_PORT@@\/camunda@@DB_SUFFIX@@"\
			  username="@@DB_USERNAME@@"\
			  password="@@DB_PASSWORD@@"\
			  maxActive="20"\
			  minIdle="5"\/> ' $CATALINA_HOME/conf/server.xml

  sed -i '/<\/GlobalNamingResources>/i \
    <Resource name="global\/camunda-bpm-platform\/process-engine\/ProcessEngineService\!org.camunda.bpm.ProcessEngineService"\
              auth="Container"\
              type="org.camunda.bpm.ProcessEngineService"\
              description="camunda BPM platform Process Engine Service"\
              factory="org.camunda.bpm.container.impl.jndi.ProcessEngineServiceObjectFactory" \/> ' $CATALINA_HOME/conf/server.xml				  
  sed -i '/<\/GlobalNamingResources>/i \
    <Resource name="global/camunda-bpm-platform/process-engine/ProcessApplicationService!org.camunda.bpm.ProcessApplicationService"\
              auth="Container"\
              type="org.camunda.bpm.ProcessApplicationService"\
              description="camunda BPM platform Process Application Service"\
              factory="org.camunda.bpm.container.impl.jndi.ProcessApplicationServiceObjectFactory"\/> ' $CATALINA_HOME/conf/server.xml				  


  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/camunda*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/freemarker-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/groovy-all-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/h2-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/java-uuid-generator-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/javax.security.auth.message-api-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/joda-time-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/mail-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/mybatis-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/slf4j-api-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/lib/slf4j-jdk14-*.jar $CATALINA_HOME/lib
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/webapps/camunda 	$CATALINA_HOME/webapps
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/webapps/camunda-welcome 	$CATALINA_HOME/webapps
  rsync -avz $TMP_INSTALL/camunda-bpm-tomcat/server/*/webapps/engine-rest* 	$CATALINA_HOME/webapps
  
  sed -i "s/@@DB_USERNAME@@/$DB_USERNAME/g" $CATALINA_HOME/conf/server.xml  
  sed -i "s/@@DB_PASSWORD@@/$DB_PASSWORD/g" $CATALINA_HOME/conf/server.xml
  sed -i "s/@@DB_DRIVER@@/$DB_DRIVER/g" $CATALINA_HOME/conf/server.xml
  sed -i "s/@@DB_PORT@@/$DB_PORT/g" $CATALINA_HOME/conf/server.xml
  sed -i "s/@@DB_CONNECTOR@@/$DB_CONNECTOR/g" $CATALINA_HOME/conf/server.xml
  sed -i "s/@@DB_SUFFIX@@/$DB_SUFFIX/g" $CATALINA_HOME/conf/server.xml
	
  echogreen "Finished installing Camunda BPM"
  echo
else
  echo
  echo "Skipping installing Camunda BPM"
  echo
fi