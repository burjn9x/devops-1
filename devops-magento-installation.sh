#!/bin/bash
# -------
# Script to setup, install and configure magento devops environment
#
# -------


# Run initializing script to setup environment for magento (Nginx, Composer, PHP)
. magento2/install-lemp.sh

# Run script to generate and configure magento project
. magento2/install-magento.sh




