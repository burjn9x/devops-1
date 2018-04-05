#!/bin/bash
# -------
# Script for install of Postgresql
#
# -------

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
  sudo apt-get install postgresql
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

read -e -p "Create Alfresco Database and user? [y/n] " -i "n" createdb
if [ "$createdb" = "y" ]; then
  sudo -u postgres createuser -D -A -P $ALFRESCO_USER
  sudo -u postgres createdb -O $ALFRESCO_USER $ALFRESCO_DB
  echo
  echo
fi

read -e -p "Create Camunda Database and user? [y/n] " -i "n" createdb
if [ "$createdb" = "y" ]; then
  sudo -u postgres createuser -D -A -P $CAMUNDA_USER
  sudo -u postgres createdb -O $CAMUNDA_USER $CAMUNDA_DB
  echo
  echo
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
