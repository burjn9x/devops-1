#!/bin/bash
# -------
# Script to setup, install and configure all-in-one devops environment
#
# -------

# Configure constants
. $BASE_INSTALL/constants.sh

# Configure colors
. $BASE_INSTALL/colors.sh

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Begin running...."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo


# Run initializing script for ubuntu
. $BASE_INSTALL/ubuntu-upgrade.sh

# Run script to setup Nginx, NVM, PM2, Nodejs, Redis, MongoDB, CertbotSSL, SSL
. $BASE_INSTALL/install-MEAN.sh

# Run script to setup Maven, Ant, Java, Tomcat, Database, Jenkins
. $BASE_INSTALL/install-JAVA-TOMCAT.sh

# Run script to setup Alfresco
# TODO for temporary, we need to install Alfresco before Camunda because they use the same server.xml (tomcat)
# but we will find a way to insert alfresco configuration into server.xml instead of overwriting the existing server.xml
. $BASE_INSTALL/install-alfresco.sh

# Run script to setup Camunda
. $BASE_INSTALL/install-camunda.sh

# Create devops service
sudo rsync -avz $BASE_INSTALL/tomcat/devops.service /etc/systemd/system/
sudo rsync -avz $BASE_INSTALL/scripts/devops-service.sh $DEVOPS_HOME/
sudo chmod 755 $DEVOPS_HOME/devops-service.sh
sudo sed -i "s/@@LOCALESUPPORT@@/$LOCALESUPPORT/g" $DEVOPS_HOME/devops-service.sh

# Change owner of devops home
sudo chown -R $DEVOPS_USER:$DEVOPS_GROUP $DEVOPS_HOME

# Enable the service
sudo systemctl enable devops.service
sudo systemctl daemon-reload

. $DEVOPS_HOME/devops-service.sh start


