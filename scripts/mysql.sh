#!/bin/bash
# -------
# Script for install of Mariadb to be used with DevOps
# -------

export DEVOPS_DB=devops
export DEVOPS_USER=devops
DB_USERNAME=$DEVOPS_USER
DB_NAME=$DEVOPS_DB

echo
echo "--------------------------------------------"
echo "This script will install MYSQL-DB."
echo "and create DevOps database and user."
echo "You may first be prompted for sudo password."
echo "When prompted during MYSQL-DB Install,"
echo "type the default root password for MYSQL-DB."
echo "--------------------------------------------"
echo

read -e -p "Install MYSQL-DB? [y/n] " -i "n" installmysqldb
if [ "$installmysqldb" = "y" ]; then
  sudo apt-get install mysql-server
fi

read -e -p "Create DevOps Database and user? [y/n] " -i "n" createdb
if [ "$createdb" = "y" ]; then
read -e -p "Enter the DevOps database password:" DEVOPS_PASSWORD
read -e -p "Re-Enter the DevOps database password:" DEVOPS_PASSWORD2
if [ "$DEVOPS_PASSWORD" == "$DEVOPS_PASSWORD2" ]
then
  DB_PASSWORD=$DEVOPS_PASSWORD
  echo "Creating DevOps database and user."
  echo "You must supply the root user password for MYSQL-DB:"
  mysql -u root -p << EOF
create database $DEVOPS_DB default character set utf8 collate utf8_bin;
grant all on $DEVOPS_DB.* to '$DEVOPS_USER'@'localhost' identified by '$DEVOPS_PASSWORD' with grant option;
grant all on $DEVOPS_DB.* to '$DEVOPS_USER'@'localhost.localdomain' identified by '$DEVOPS_PASSWORD' with grant option;

EOF
  echo
  echo "Remember to update alfresco-global.properties with the DevOps database password"
  echo
else
  echo
  echo "Passwords do not match. Please run the script again for better luck!"
  echo
fi
fi