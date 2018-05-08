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

echogreen "Setting up Eforms Camunda..........."

if [ "`which git`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echored "Please run ubuntu-upgrade.sh firstly to install git before running this script."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
fi

sudo chmod 775 -R $DEVOPS_HOME
sudo chown -R $USER:$USER ~/.local

if [ -d "$TMP_INSTALL/workplacebpm" ]; then
	sudo rm -rf $TMP_INSTALL/workplacebpm
fi

if [ -d "$TMP_INSTALL/eformcamundaui" ]; then
	sudo rm -rf $TMP_INSTALL//eformcamundaui
fi

if [ -d "$DEVOPS_HOME/eformsrenderer" ]; then
	sudo rm -rf $DEVOPS_HOME/eformsrenderer
fi

if [ -d "$DEVOPS_HOME/eformsbuilder" ]; then
	sudo rm -rf $DEVOPS_HOME/eformsbuilder
fi

git clone https://bitbucket.org/workplace101/workplacebpm.git $TMP_INSTALL/workplacebpm
cd $TMP_INSTALL/workplacebpm/src/eForm
source /etc/profile.d/maven.sh
mvn clean install

if [ -d "$CATALINA_HOME/webapps/eform" ]; then
	sudo rm -rf $CATALINA_HOME/webapps/eform*
fi
sudo rsync -avz $TMP_INSTALL/workplacebpm/src/eForm/gateway/target/eform.war $CATALINA_HOME/webapps

read -e -p "Please enter the public host name for your server (only domain name, not subdomain)${ques} [`hostname`] " -i "`hostname`" DOMAIN_NAME
sudo sed -i "s/MYCOMPANY.COM/$DOMAIN_NAME/g" $BASE_INSTALL/domain.txt

#read -e -p "Please enter the public host name for Camunda server (fully qualified domain name)${ques} [`hostname`] " -i "`hostname`" CAMUNDA_HOSTNAME
#read -e -p "Please enter the public host name for Alfresco server (fully qualified domain name)${ques} [`hostname`] " -i "`hostname`" ALFRESCO_HOSTNAME
camunda_line=$(grep "camunda" $BASE_INSTALL/domain.txt)
IFS='|' read -ra arr <<<"$camunda_line"
camunda_hostname="$(echo -e "${arr[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
camunda_port="$(echo -e "${arr[3]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

if sudo test -f /etc/nginx/sites-available/$camunda_hostname.conf; then	
	
	if [ -n "$camunda_port" ]; then
		TOMCAT_HTTP_PORT=$camunda_port
	fi

	# Check if eform config does exist
	eform_found=$(sudo grep -o "eform" /etc/nginx/sites-available/$camunda_hostname.conf | wc -l)
	
	if [ $eform_found = 0 ]; then
		#sudo sed -i "0,/server/s/server/upstream eform {	    \n\tserver localhost:$TOMCAT_HTTP_PORT;	\n}\n\n&/" /etc/nginx/sites-available/$CAMUNDA_HOSTNAME.conf
		sudo sed -i "1 i\upstream eform {	    \n\tserver localhost:$TOMCAT_HTTP_PORT;	\n}\n\n" /etc/nginx/sites-available/$camunda_hostname.conf
		 
		 # Insert camunda configuration content before the last line in domain.conf in nginx
		 #sudo sed -i "$e cat $NGINX_CONF/sites-available/camunda.conf" /etc/nginx/sites-available/$hostname.conf
		 sudo mkdir temp
		 sudo cp $NGINX_CONF/sites-available/eform.snippet	temp/
		 sudo sed -e '/##EFORM##/ {' -e 'r temp/eform.snippet' -e 'd' -e '}' -i /etc/nginx/sites-available/$camunda_hostname.conf
		 sudo rm -rf temp
	fi
fi

echo "We are waiting for eform being deployed...."

sleep 20

alfresco_line=$(grep "alfresco" $BASE_INSTALL/domain.txt)
IFS='|' read -ra arr <<<"$alfresco_line"
alfresco_hostname="$(echo -e "${arr[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

alfresco_protocol=https
ssl_found=$(grep -o "443" /etc/nginx/sites-available/$alfresco_hostname.conf | wc -l)
if [ $ssl_found = 0 ]; then
	alfresco_protocol=http
fi

sudo sed -i "s/\(^endpoint=\).*/\1https\:\/\/scaucwnkwa.execute-api.ap-southeast-1.amazonaws.com\/v1\/notify\/workchat/"  $CATALINA_HOME/webapps/eform/WEB-INF/classes/application.properties
sudo sed -i "s/\(^CmisBrowserUrl=\).*/\1$alfresco_protocol:\/\/$alfresco_hostname\/alfresco\/api\/-default-\/public\/cmis\/versions\/1.1\/browser/"  $CATALINA_HOME/webapps/eform/WEB-INF/classes/application.properties
sudo sed -i "s/\(^CmisRepoId=\).*/\1-default-/" 	$CATALINA_HOME/webapps/eform/WEB-INF/classes/application.properties
sudo sed -i "s/\(^CmisUser=\).*/\1admin/"  	$CATALINA_HOME/webapps/eform/WEB-INF/classes/application.properties
sudo sed -i "s/\(^CmisPassword=\).*/\1admin/"  	$CATALINA_HOME/webapps/eform/WEB-INF/classes/application.properties
sudo sed -i "s/\(^CmisRootFolder=\).*/\1Data Dictionary/"  $CATALINA_HOME/webapps/eform/WEB-INF/classes/application.properties

. $DEVOPS_HOME/devops-service.sh restart

sudo npm install -g grunt-cli
sudo npm install -g @angular/cli
sudo npm install -g bower
sudo npm install -g gulp

# Eform camunda UI
# git clone https://bitbucket.org/workplace101/eformscamundaui.git $TMP_INSTALL/eformcamundaui
# cd $TMP_INSTALL/eformcamundaui
# npm install
# grunt
# sudo rsync -avz $TMP_INSTALL/eformcamundaui/target/webapp/* 	$CATALINA_HOME/webapps/camunda/

# EForm Renderer
git clone https://bitbucket.org/workplace101/eformsrenderer.git $DEVOPS_HOME/eformsrenderer
cd $DEVOPS_HOME/eformsrenderer
npm install
npm run build

git clone https://bitbucket.org/workplace101/eformsbuilder.git $DEVOPS_HOME/eformsbuilder
cd $DEVOPS_HOME/eformsbuilder
npm install         
bower install       
gulp build
ln -s $DEVOPS_HOME/eformsbuilder/dist $DEVOPS_HOME/eformsrenderer/dist/builder || true

#read -e -p "Please enter the public host name for Eform Renderer (fully qualified domain name)${ques} [`hostname`] " -i "`hostname`" EFORM_RENDERER_HOSTNAME
eforms_line=$(grep "eforms\." $BASE_INSTALL/domain.txt)
IFS='|' read -ra arr <<<"$eforms_line"
eforms_hostname="$(echo -e "${arr[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
sudo rsync -avz $NGINX_CONF/sites-available/domain.conf /etc/nginx/sites-available/$eforms_hostname.conf
sudo ln -s /etc/nginx/sites-available/$eforms_hostname.conf /etc/nginx/sites-enabled/
sudo sed -i "s/@@DNS_DOMAIN@@/$eforms_hostname/g" /etc/nginx/sites-available/$eforms_hostname.conf

DEVOPS_HOME_PATH="${DEVOPS_HOME//\//\\/}"
sudo sed -i "s/##WEB_ROOT##/root $DEVOPS_HOME_PATH\/eformsrenderer\/dist;/g" /etc/nginx/sites-available/$eforms_hostname.conf

sudo service nginx restart

