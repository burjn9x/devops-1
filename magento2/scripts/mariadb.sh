#!/bin/bash
# -------
# Script for install of Mariadb
# -------

export MAGENTO_DB_DEFAULT=magento
export MAGENTO_USER_DEFAULT=magento
export MAGENTO_DB=$MAGENTO_DB_DEFAULT
export MAGENTO_USER=$MAGENTO_USER_DEFAULT

if [ -n "$PROJECT_NAME" ]; then
	MAGENTO_DB=$PROJECT_NAME
	MAGENTO_USER=$PROJECT_NAME
fi

echo
echo "--------------------------------------------"
echo "This script will install MariaDB."
echo "and create Magento database and user."
echo "You may first be prompted for sudo password."
echo "When prompted during MariaDB Install,"
echo "type the default root password for MariaDB."
echo "--------------------------------------------"
echo

read -e -p "Install MariaDB? [y/n] " -i "y" installmariadb
if [ "$installmariadb" = "y" ]; then
  sudo apt-get remove --purge *mysql\*
  sudo apt-get autoremove
  sudo apt-get autoclean
  sudo deluser mysql
  sudo rm -rf /var/lib/mysql
  sudo rm -rf /var/log/mysql
  sudo rm -rf /etc/mysql
  sudo apt-get install software-properties-common
  sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
  sudo add-apt-repository "deb [arch=amd64,i386,ppc64el] http://ftp.ddg.lth.se/mariadb/repo/10.1/ubuntu $(lsb_release -cs) main"
  sudo apt-get update
  sudo apt-get install mariadb-server
  sudo mysql_secure_installation
  #Tuning database by setting config
  echo "key_buffer_size         = 128M" >> /etc/mysql/conf.d/mariadb.cnf
  echo "max_allowed_packet      = 128M" >> /etc/mysql/conf.d/mariadb.cnf
  echo "thread_stack            = 1024K" >> /etc/mysql/conf.d/mariadb.cnf
  echo "innodb_log_file_size    = 128M" >> /etc/mysql/conf.d/mariadb.cnf
fi

read -e -p "Create Magento Database and user? [y/n] " -i "y" createdbmagento
if [ "$createdbmagento" = "y" ]; then
  read -s -p "Enter the Magento database password:"  MAGENTO_PASSWORD
  echo ""
  read -s -p "Re-Enter the Magento database password:" MAGENTO_PASSWORD2
  if [ "$MAGENTO_PASSWORD" == "$MAGENTO_PASSWORD2" ]; then
    echo "Creating Magento database and user."
    echo "You must supply the root user password for MariaDB:"
    mysql -u root -p << EOF
    #create workforce db
    CREATE DATABASE $MAGENTO_DB DEFAULT CHARACTER SET utf8;
    DELETE FROM mysql.user WHERE User = '$MAGENTO_USER';
    CREATE USER '$MAGENTO_USER'@'localhost' IDENTIFIED BY '$ALFRESCO_PASSWORD';
    GRANT ALL PRIVILEGES ON $MAGENTO_DB.* TO '$MAGENTO_USER'@'localhost' WITH GRANT OPTION;
EOF
  echo
  echo "Remember to update configuration with the Magento database password"
  echo
  else
    echo
    echo "Passwords do not match. Please run the script again for better luck!"
    echo
  fi
fi

