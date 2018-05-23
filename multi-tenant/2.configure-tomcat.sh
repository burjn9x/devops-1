#!/bin/bash
# -------
# This is script to setup eform workplace
# -------

# Configure constants
if [ -f "constants.sh" ]; then
	. constants.sh
fi

# Configure colors
if [ -f "colors.sh" ]; then
	. colors.sh
fi

sudo sed -i '/<\/GlobalNamingResources>/i \
		<Resource name="jdbc\/ProcessEngine"\
				  auth="Container"\
				  type="javax.sql.DataSource"\
				  factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"\
				  uniqueResourceName="process-engine"\
				  driverClassName="@@DB_DRIVER@@"\
				  url="jdbc:@@DB_CONNECTOR@@:\/\/localhost:@@DB_PORT@@\/@@TTV_DB@@@@DB_SUFFIX@@"\
				  username="@@TTV_USER@@"\
				  password="@@TTV_PASSWORD@@"\
				  maxActive="20"\
				  minIdle="5"\/> ' $CATALINA_HOME/conf/server.xml

sudo sed -i '/<\/GlobalNamingResources>/i \
		<Resource name="jdbc\/ProcessEngine"\
				  auth="Container"\
				  type="javax.sql.DataSource"\
				  factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"\
				  uniqueResourceName="process-engine"\
				  driverClassName="@@DB_DRIVER@@"\
				  url="jdbc:@@DB_CONNECTOR@@:\/\/localhost:@@DB_PORT@@\/@@TAPAC_DB@@@@DB_SUFFIX@@"\
				  username="@@TAPAC_USER@@"\
				  password="@@TAPAC_PASSWORD@@"\
				  maxActive="20"\
				  minIdle="5"\/> ' $CATALINA_HOME/conf/server.xml          