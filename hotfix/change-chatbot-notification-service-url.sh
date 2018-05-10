#!/bin/bash
# -------
# This is standalone script which change notification service url
# -------

# Configure constants
if [ -f "constants.sh" ]; then
	. constants.sh
else
	. ../constants.sh
fi

# Configure colors
if [ -f "colors.sh" ]; then
	. colors.sh
else
	. ../colors.sh
fi

export NOTICATION_SERVICE_URL=https://scaucwnkwa.execute-api.ap-southeast-1.amazonaws.com/v1/notify/workchat

sudo sed -i "s/\(^endpoint=\).*/\1$NOTICATION_SERVICE_URL/" 	$CATALINA_HOME/webapps/eform/WEB-INF/classes/application.properties

sudo $DEVOPS_HOME/devops-service.sh restart