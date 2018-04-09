#!/bin/bash
# -------
# This is standalone script which configure and install magento
# -------

MAGENTO_VERSION=7.8
export DEVOPS_HOME=/home/devops
export CATALINA_HOME=$DEVOPS_HOME/tomcat
export BASE_INSTALL=/home/ubuntu/devops
export TMP_INSTALL=/tmp/devops-install
export NGINX_CONF=$BASE_INSTALL/_ubuntu/etc/nginx
export APTVERBOSITY="-qq -y"
export DEFAULTYESNO="y"


export MYSQL_DB_PORT_DEFAULT=3306
export MYSQL_DB_DRIVER_DEFAULT=com.mysql.jdbc.Driver
export MYSQL_DB_CONNECTOR_DEFAULT=mysql
export MYSQL_DB_SUFFIX_DEFAULT="\?useSSL=false\&amp;autoReconnect=true\&amp;useUnicode=yes\&amp;characterEncoding=utf8"



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

