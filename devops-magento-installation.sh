#!/bin/bash
# -------
# Script to setup, install and configure magento devops environment
#
# -------

# Configure constants
. constants.sh

# Configure colors
. colors.sh

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Begin running...."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo


# Run initializing script to setup environment for magento (Nginx, Composer, PHP)
. $BASE_INSTALL/magento2/install-lemp.sh

# Run script to generate and configure magento project
. $BASE_INSTALL/magento2/install-magento.sh




