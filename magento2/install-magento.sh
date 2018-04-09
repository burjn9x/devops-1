#!/bin/bash
# -------
# This is standalone script which configure and install magento
# -------

MAGENTO_VERSION=2.2.3
PHP_VERSION=7.0
export TIME_ZONE="Asia/Ho_Chi_Minh"
export DEVOPS_HOME=/home/devops
export BASE_INSTALL=/home/ubuntu/devops/magento2
export TMP_INSTALL=/tmp/devops-install
export NGINX_CONF=$BASE_INSTALL/_ubuntu/etc/nginx
export APTVERBOSITY="-qq -y"
export DEFAULTYESNO="y"


export MYSQL_DB_PORT_DEFAULT=3306
export MYSQL_DB_DRIVER_DEFAULT=com.mysql.jdbc.Driver
export MYSQL_DB_CONNECTOR_DEFAULT=mysql
export MYSQL_DB_SUFFIX_DEFAULT="\?useSSL=false\&amp;autoReconnect=true\&amp;useUnicode=yes\&amp;characterEncoding=utf8"

export WEB_ROOT=/var/www/m2

WEB_ROOT_PATH="${WEB_ROOT//\//\\/}"



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

##
# Nginx
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Nginx can be used as frontend which redirect request to backend server."
echo "This installation will add config default proxying to server running behind."
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

  # Insert config for letsencrypt
  if [ ! -d "/opt/letsencrypt/.well-known" ]; then
	sudo mkdir -p /opt/letsencrypt/.well-known
	echo "Hello HTTP!" | sudo tee /opt/letsencrypt/index.html
  fi
  
  sudo chown -R www-data:root /opt/letsencrypt
  
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


if [ "`which php`" = "" ]; then
	
	# Install php
	sudo apt-get $APTVERBOSITY install php$PHP_VERSION-fpm php$PHP_VERSION-mcrypt php$PHP_VERSION-curl php$PHP_VERSION-cli php$PHP_VERSION-mysql php$PHP_VERSION-gd php$PHP_VERSION-xsl php$PHP_VERSION-json php$PHP_VERSION-intl php-pear php$PHP_VERSION-dev php$PHP_VERSION-common php$PHP_VERSION-mbstring php$PHP_VERSION-zip php-soap
	
	# Add php config
	if [ -f "/etc/php/$PHP_VERSION/fpm/php.ini" ]; then
		sudo sed -i "s/\(^memory_limit =\).*/\1 1024M/" /etc/php/$PHP_VERSION/fpm/php.ini
		sudo sed -i "s/\(^max_execution_time =\).*/\1 1800/" /etc/php/$PHP_VERSION/fpm/php.ini
		sudo sed -i "s/\(^zlib.output_compression =\).*/\1 On/" /etc/php/$PHP_VERSION/fpm/php.ini
		
		sudo systemctl restart php7.0-fpm
	else
		echo "There is no file php.ini, please check if php is installed correctly."
	fi
	
	if [ ! -d "$WEB_ROOT" ]; then
		sudo mkdir -p $WEB_ROOT
	fi
	
	cd /var/www/m2
	
	read -e -p "Please enter the project name${ques} " PROJECT_NAME
	
	if [ -n "$PROJECT_NAME" ]; then
		sudo composer create-project --repository-url=https://repo.magento.com/magento/project-community-edition:$MAGENTO_VERSION $PROJECT_NAME
		
		# Install database and setup username password based on project name
		. $BASE_INSTALL/scripts/mariadb.sh
		
		# Setup magento
		read -e -p "Please enter your public host name on this server${ques} " HOSTNAME
		if [ -n "$HOSTNAME" ]; then
			sudo php bin/magento setup:install --base-url=http://$HOSTNAME --backend-frontname=admin --db-host=127.0.0.1 --db-name=$MAGENTO_DB \
							--db-password=$MAGENTO_PASSWORD --db-user=$MAGENTO_USER --admin-firstname=admin --admin-lastname=admin --admin-email=admin@mycompany.com \
							--admin-user=admin --admin-password=$MAGENTO_PASSWORD --language=en_US --currency=USD --timezone=$TIME_ZONE --use-rewrites=1
		else
			echo "Please input valid hostname"
		fi
		
		# Setup SSL
		read -e -p "Install SSL${ques} [y/n] " -i "$DEFAULTYESNO" installssl
		if [ "$installssl" = "y" ]; then
			local_port=443
			echo "SSL for domain : $HOSTNAME is being created with port : $local_port"
			if [ ! -f "/etc/letsencrypt/live/$HOSTNAME/fullchain.pem" ]; then
				sudo certbot certonly --authenticator standalone --installer nginx -d $HOSTNAME --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
			fi
			
			if [ -f "/etc/letsencrypt/live/$HOSTNAME/fullchain.pem" ]; then
			
				sudo rsync -avz $NGINX_CONF/snippets/ /etc/nginx/snippets/
				sudo rsync -avz $NGINX_CONF/sites-available/domain.conf.ssl /etc/nginx/sites-available/$HOSTNAME.conf
				sudo ln -s /etc/nginx/sites-available/$HOSTNAME.conf /etc/nginx/sites-enabled/
				  
				sudo sed -i "s/@@WEB_ROOT@@/${WEB_ROOT//\//\\/}/g" /etc/nginx/sites-available/$HOSTNAME.conf
				sudo sed -i "s/@@DNS_DOMAIN@@/$hostname/g" /etc/nginx/sites-available/$HOSTNAME.conf

			
				sudo sed -i "s/@@PORT@@/8080/g" /etc/nginx/sites-available/$HOSTNAME.conf
				
					
				# Add cron job to renew key
				crontab -l | { cat; echo '43 6 * * * root /usr/bin/certbot renew --post-hook "systemctl reload nginx" > /var/log/certbot-renew.log'; } | crontab -
				  
				echo "SSL for domain : $HOSTNAME has been created successfully."
				  
			else
				  echored "There is an error in generating keys for domain $HOSTNAME."
			fi

			
		else
			
			sudo cat <<EOF >/etc/nginx/sites-available/$HOSTNAME.conf
upstream fastcgi_backend {
     server  unix:/run/php/php7.0-fpm.sock;
 }

 server {
     listen 80;
     server_name @@DOMAIN_NAME@@;
     set $MAGE_ROOT @@ROOT_PROJECT_FOLDER@@;
     include @@ROOT_PROJECT_FOLDER@@/nginx.conf.sample;
 }
EOF
			# Replace template with configuration value created in previous step
			sudo sed -i "s/@@DOMAIN_NAME@@/$HOSTNAME/g" 		/etc/nginx/sites-available/$HOSTNAME.conf
			sudo sed -i "s/@@ROOT_PROJECT_FOLDER@@/$$WEB_ROOT_PATH\/$PROJECT_NAME/g" 	/etc/nginx/sites-available/$HOSTNAME.conf
			
		fi
	
	else
		echo "Please input valid name for creating project"
	fi
	
fi
