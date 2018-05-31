#!/bin/bash
# -------
# Script for install of Postgresql
#
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

export ALFRESCO_DB=alfresco
export ALFRESCO_USER=alfresco
export CAMUNDA_DB=camunda
export CAMUNDA_USER=camunda

echo
echo "--------------------------------------------"
echo "This script will install PostgreSQL."
echo "and create Devops database and user."
echo "You may be prompted for sudo password."
echo "--------------------------------------------"
echo

read -e -p "Install PostgreSQL database? [y/n] " -i "n" installpg
if [ "$installpg" = "y" ]; then
  sudo apt-get install postgresql postgresql-contrib
  echo
  echo "You will now set the default password for the postgres user."
  echo "This will open a psql terminal, enter:"
  echo
  echo "\\password postgres"
  echo
  echo "and follow instructions for setting postgres admin password."
  echo "Press Ctrl+D or type \\q to quit psql terminal"
  echo "START psql --------"
  DB_PASSWORD=postgres
  sudo -u postgres psql postgres
  echo "END psql --------"
  echo
fi

read -e -p "Create Alfresco Database and user? [y/n] " -i "y" createdbalfresco
if [ "$createdbalfresco" = "y" ]; then
  read -s -p "Enter the Alfresco database password:" ALFRESCO_PASSWORD
  echo ""
  read -s -p "Re-Enter the Alfresco database password:" ALFRESCO_PASSWORD2
  if [ "$ALFRESCO_PASSWORD" == "$ALFRESCO_PASSWORD2" ]; then
    echo
    echo "Creating Alfresco database and user."
	sudo -i -u postgres psql -c "CREATE USER $ALFRESCO_USER WITH PASSWORD '"$ALFRESCO_PASSWORD"';"
	sudo -u postgres createdb -O $ALFRESCO_USER $ALFRESCO_DB
  echo
  echo "Remember to update alfresco-global.properties with the Alfresco database password"
  echo
  else
    echo
    echo "Passwords do not match. Please run the script again for better luck!"
    echo
  fi
fi

read -e -p "Create Camunda Database and user? [y/n] " -i "y" createdbcamunda
if [ "$createdbcamunda" = "y" ]; then
  read -s -p "Enter the Camunda database password:" CAMUNDA_PASSWORD
  echo ""
  read -s -p "Re-Enter the Camunda database password:" CAMUNDA_PASSWORD2
  if [ "$CAMUNDA_PASSWORD" == "$CAMUNDA_PASSWORD2" ]; then
    echo
    echo "Creating Camunda database and user."
    sudo -i -u postgres psql -c "CREATE USER $CAMUNDA_USER WITH PASSWORD '"$CAMUNDA_PASSWORD"';"
	sudo -u postgres createdb -O $CAMUNDA_USER $CAMUNDA_DB
  echo
  echo "Remember to update server.xml with the Camunda database password"
  echo
  else
    echo
    echo "Passwords do not match. Please run the script again for better luck!"
    echo
  fi
fi

read -e -p "Install PostgreSQL Admin (Web)? [y/n] " -i "y" createpgadmin
if [ "$createpgadmin" = "y" ]; then
	 sudo apt-get install virtualenv python-pip libpq-dev python-dev
	 cd $DEVOPS_HOME
	 virtualenv pgadmin4
	 cd $DEVOPS_HOME/pgadmin4
	 source bin/activate
	 curl -# -o $DEVOPS_HOME/pgadmin4/pgadmin4-1.2-py2-none-any.whl	https://ftp.postgresql.org/pub/pgadmin3/pgadmin4/v1.2/pip/pgadmin4-1.2-py2-none-any.whl
	 pip install $DEVOPS_HOME/pgadmin4/pgadmin4-1.6-py2.py3-none-any.whl
	 python lib/python3.5/site-packages/pgadmin4/setup.py
	 deactivate
	 PGADMIN4_HOME=$DEVOPS_HOME/pgadmin4
	 PGADMIN4_HOME_ESC="${PGADMIN4_HOME//\//\\/}"
	 sudo rsync -avz $BASE_INSTALL/scripts/pgadmin4.service /etc/systemd/system/
	 sudo sed -i "s/@@PGADMIN4_HOME@@/$PGADMIN4_HOME_ESC/g" /etc/systemd/system/pgadmin4.service
	 sudo systemctl daemon-reload
	 sudo systemctl enable pgadmin4
	 sudo systemctl start pgadmin4
	 
fi

echo
echo "You must update postgresql configuration to allow password based authentication"
echo "(if you have not already done this)."
echo
echo "Add the following to pg_hba.conf or postgresql.conf (depending on version of postgresql installed)"
echo "located in folder /etc/postgresql/<version>/main/"
echo
echo "host all all 127.0.0.1/32 password"
echo
echo "After you have updated, restart the postgres server: sudo service postgresql restart"
echo
