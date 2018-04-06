#!/bin/bash
# -------
# Script to configure and setup Nginx, NVM, PM2, Nodejs, Redis, MongoDB, CertbotSSL, SSL
#
# -------

#export DEVOPS_HOME=/opt/devops
export BASE_INSTALL=/home/ubuntu/devops
export NGINX_CONF=$BASE_INSTALL/_ubuntu/etc/nginx
export TMP_INSTALL=/tmp/devops-install

export APTVERBOSITY="-qq -y"
export DEFAULTYESNO="y"

export NVMURL=https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh
export NODEJSURL=https://deb.nodesource.com/setup_6.x



# size of swapfile in megabytes = 2X
# default is 8192MB (8GBx1024); 16384MB (16GBx1024)
swapsize=16G

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


URLERROR=0

for REMOTE in $NVMURL $NODEJSURL
do
        wget --spider $REMOTE --no-check-certificate >& /dev/null
        if [ $? != 0 ]
        then
                echored "Please fix this URL: $REMOTE and try again later"
                URLERROR=1
        fi
done

if [ $URLERROR = 1 ]
then
    echo
    echored "Please fix the above errors and rerun."
    echo
    exit
fi

# Create temporary folder for storing downloaded files
if [ ! -d "$TMP_INSTALL" ]; then
  mkdir -p $TMP_INSTALL
fi


##
# Nginx
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Nginx can be used as frontend to Tomcat."
echo "This installation will add config default proxying to tomcat running behind."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install nginx${ques} [y/n] " -i "$DEFAULTYESNO" installnginx
if [ "$installnginx" = "y" ]; then

  # Remove nginx if already installed
  if [ "`which nginx`" != "" ]; then
	 sudo apt-get remove --auto-remove nginx nginx-common
	 sudo apt-get purge --auto-remove nginx nginx-common
  fi
  echoblue "Installing nginx. Fetching packages..."
  echo

#@Deprecated
#sudo -s << EOF
#  echo "deb http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" >> /etc/apt/sources.list
#  sudo curl -# -o $TMP_INSTALL/nginx_signing.key http://nginx.org/keys/nginx_signing.key
#  apt-key add $TMP_INSTALL/nginx_signing.key
  #echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
  # Alternate with spdy support and more, change  apt install -> nginx-custom
  #echo "deb http://ppa.launchpad.net/brianmercer/nginx/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D0DC64F
#EOF

  sudo apt-get $APTVERBOSITY update && sudo apt-get $APTVERBOSITY install nginx
  # Enable Nginx to auto start when Ubuntu is booted
  sudo systemctl enable nginx
  # Check Nginx status
  #systemctl status nginx
  
  #TODO: sudo service nginx stop
  #sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
  #sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.sample
  
  #WEB_ROOT=$WORKFORCE_HOME/www
  
  # Make the ssl dir as this is what is used in sample config
  #TODO: sudo mkdir -p /etc/nginx/ssl
  
  # Compatible with Apache, we check if there is already existing apache web root. If it is, we use it by default. 
  # If not, $WORKFORCE_HOME should be a folder contains webroot
  #if [ ! -d "/var/www" ]; then
	#sudo mkdir -p $WORKFORCE_HOME/www
  #else
	#WEB_ROOT="/var/www"
  #fi
  
#  sudo mkdir -p /var/cache/nginx/workforce
  #if [ ! -f "$WEB_ROOT/www/maintenance.html" ]; then
  #  echo "Copying maintenance html page..."
#	sudo rsync -avz $NGINX_CONF/maintenance.html $WEB_ROOT
#  fi
#  sudo chown -R www-data:root /var/cache/nginx/workforce
#  sudo chown -R www-data:root $WEB_ROOT
  #TODO: sudo chown -R www-data:root /usr/share/nginx
  
#  sudo chmod 2775 $WEB_ROOT
#  sudo find $WEB_ROOT -type d -exec sudo chmod 2775 {} \;
#  sudo find $WEB_ROOT -type f -exec sudo chmod 0664 {} \;
  
#  sudo rsync -avz $NGINX_CONF/ /etc/nginx/
#  if [ ! -f "/etc/nginx/maintenance.html" ]; then
#	rm -f /etc/nginx/maintenance.html
#  fi
  
  #escape for sed
#  WEB_ROOT_PATH="${WEB_ROOT//\//\\/}"
#  sed -i "s/@@WEB_ROOT@@/$WEB_ROOT_PATH/g" /etc/nginx/conf.d/workforce.conf
#  sed -i "s/@@WEB_ROOT@@/$WEB_ROOT_PATH/g" /etc/nginx/conf.d/workforce.conf.ssl

  # Insert config for letsencrypt
  if [ ! -d "/opt/letsencrypt/.well-known" ]; then
	sudo mkdir -p /opt/letsencrypt/.well-known
	echo "Hello HTTP!" | sudo tee /opt/letsencrypt/index.html
  fi
  
  sudo chown -R www-data:root /opt/letsencrypt
  
  if [ ! -f "/etc/nginx/conf.d/default.conf" ]; then
	sudo rsync -avz $NGINX_CONF/conf.d/default.conf /etc/nginx/conf.d/		
  else
	sed -i '/^\(}\)/ i location \/\.well-known {\n  alias \/opt\/letsencrypt\/\.well-known\/;\n  allow all;	\n  }' /etc/nginx/conf.d/default.conf
  fi
  
  if [ -f "/etc/nginx/sites-available/default" ]; then
	sed -i '/^\(}\)/ i location \/\.well-known {\n  alias \/opt\/letsencrypt\/\.well-known\/;\n  allow all;	\n  }' /etc/nginx/sites-available/default
  fi
  
  
  ## Reload config file
  #TODO: sudo service nginx start
  sudo systemctl restart nginx
  
  sudo ufw enable
  if [ ! -f "/etc/ufw/applications.d/nginx.ufw.profile" ]; then
	echo "There is no profile for nginx within ufw, so we decide to create it."
	sudo cat <<EOF >/etc/ufw/applications.d/nginx.ufw.profile
[Nginx HTTP]
title=Web Server (Nginx, HTTP)
description=Small, but very powerful and efficient web server
ports=80/tcp

[Nginx HTTPS]
title=Web Server (Nginx, HTTPS)
description=Small, but very powerful and efficient web server
ports=443/tcp

[Nginx Full]
title=Web Server (Nginx, HTTP + HTTPS)
description=Small, but very powerful and efficient web server
ports=80,443/tcp
EOF

	sudo ufw app update nginx
  fi

  sudo ufw allow 'Nginx HTTP'
  sudo ufw allow 'Nginx HTTPS'
  sudo ufw allow 'OpenSSH'


  echo
  echogreen "Finished installing nginx"
  echo
else
  echo "Skipping install of nginx"
fi

##
# NVM
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Begin setting up a nvm..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install nvm${ques} [y/n] " -i "$DEFAULTYESNO" installnvm
if [ "$installnvm" = "y" ]; then
  curl -# -o $TMP_INSTALL/install.sh $NVMURL
  sh $TMP_INSTALL/install.sh
  echo
  echogreen "Finished installing NVM"

fi

##
# Node JS
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Begin setting up a nodejs..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install nodejs${ques} [y/n] " -i "$DEFAULTYESNO" installnodejs
if [ "$installnodejs" = "y" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Installing & Configuring NodeJS LTS (v6.12.2)"
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	curl -sL $NODEJSURL | sudo -E bash -
	sudo apt-get $APTVERBOSITY install nodejs
	sudo npm install -g npm@latest
	
	# [Optional] Some NPM packages will probably throw errors when compiling
	sudo apt-get $APTVERBOSITY install build-essential
fi

##
# PM2
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Begin setting up a PM2..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install PM2${ques} [y/n] " -i "$DEFAULTYESNO" installpm2
if [ "$installpm2" = "y" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install PM2"
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sudo npm install -g pm2
	
    # Launch PM2 and its managed processes on server boots
    pm2 startup systemd
    sudo chown ubuntu:ubuntu /home/ubuntu/.pm2/rpc.sock /home/ubuntu/.pm2/pub.sock
    pm2 list
fi

##
# Redis
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Begin setting up a Redis..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Redis${ques} [y/n] " -i "$DEFAULTYESNO" installredis
if [ "$installredis" = "y" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install Redis"
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sudo apt-get $APTVERBOSITY install redis-server
	# sudo chmod 770 /etc/redis/redis.conf
	echo "maxmemory 1024mb" | sudo tee --append /etc/redis/redis.conf
    echo "maxmemory-policy allkeys-lru" | sudo tee --append /etc/redis/redis.conf
	sudo systemctl enable redis-server.service
fi

##
# MongoDB
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Begin setting up a MongoDB..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install MongoDB${ques} [y/n] " -i "$DEFAULTYESNO" installmongodb
if [ "$installmongodb" = "y" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install MongoDB"
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	
	# Import the key for the official MongoDB repository
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
	
    # Create a list file for MongoDB
    echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
	
    sudo apt-get $APTVERBOSITY update
	
    # Install mongodb-org, which includes the daemon, configuration and init scripts, shell, and management tools on the server. 
    sudo apt-get $APTVERBOSITY install -y mongodb-org
	
    # Ensure that MongoDB restarts automatically at boot
    sudo systemctl enable mongod   
    sudo systemctl start mongod
fi

##
# Certbot SSL
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Certbot SSL"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install certbot${ques} [y/n] " -i "$DEFAULTYESNO" installcertbot
if [ "$installcertbot" = "y" ]; then

  # Remove nginx if already installed
  if [ "`which certbot`" != "" ]; then
    # Uninstall Certbot
    sudo apt-get purge python-certbot-nginx
    sudo rm -rf /etc/letsencrypt
  fi
  echoblue "Installing Certbot. Fetching packages..."
  echo  
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt-get $APTVERBOSITY update
  sudo apt-get $APTVERBOSITY install python-certbot-nginx
  echo
  echogreen "Finished installing Certbot"
  echo
else
  echo "Skipping install of Certbot"
fi


##
# SSL
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Begin setting up a SSL..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install ssl${ques} [y/n] " -i "$DEFAULTYESNO" installssl
if [ "$installssl" = "y" ]; then
	local_port=443
	read -e -p "Please enter the public host name for your server (fully qualified domain name)${ques} [`hostname`] " -i "`hostname`" hostname
	if [[ $hostname =~ ^(([a-zA-Z]|[a-zA-Z][a-zA-Z\-]*[a-zA-Z])\.)*([A-Za-z]|[A-Za-z][A-Za-z\-]*[A-Za-z])$ ]]; then
		#sudo letsencrypt certonly --webroot -w /opt/letsencrypt -d $hostname --email digital@smartbiz.vn --agree-tos
	#fi
		echo "SSL for domain : $hostname is being created with port : $local_port"
		if [ ! -f "/etc/letsencrypt/live/$hostname/fullchain.pem" ]; then
			# sudo letsencrypt certonly --webroot -w /opt/letsencrypt -d $local_domain --email digital@smartbiz.vn --agree-tos
			sudo certbot certonly --authenticator standalone --installer nginx -d $hostname --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
		fi
		
		if [ -f "/etc/letsencrypt/live/$hostname/fullchain.pem" ]; then
		
			sudo rsync -avz $NGINX_CONF/snippets/ /etc/nginx/snippets/
			sudo rsync -avz $NGINX_CONF/sites-available/domain.conf.ssl /etc/nginx/sites-available/$hostname.conf
			sudo ln -s /etc/nginx/sites-available/$hostname.conf /etc/nginx/sites-enabled/
			  
			sudo sed -i "s/@@WEB_ROOT@@/${WEB_ROOT//\//\\/}/g" /etc/nginx/sites-available/$hostname.conf
			sudo sed -i "s/@@DNS_DOMAIN@@/$hostname/g" /etc/nginx/sites-available/$hostname.conf

			# Replace nginx ssl config with generated keys
			#sudo sed -i "s/@@CERTIFICATE@@/\/etc\/letsencrypt\/live\/$hostname\/fullchain.pem/g" /etc/nginx/sites-available/$hostname.conf 
			#sudo sed -i "s/@@CERTIFICATE_KEY@@/\/etc\/letsencrypt\/live\/$hostname\/privkey.pem/g" /etc/nginx/sites-available/$hostname.conf
			  
			sudo sed -i "s/@@PORT@@/8080/g" /etc/nginx/sites-available/$hostname.conf
			
			sudo mkdir -p /var/cache/nginx/devops
			sudo chown -R www-data:root /var/cache/nginx/devops
			  
			echo "SSL for domain : $hostname has been created successfully."
			  
		else
			  echored "There is an error in generating keys for domain $hostname."
		fi
	else
		echored "$hostname is not a valid hostname, please check and try again."
	fi
fi
