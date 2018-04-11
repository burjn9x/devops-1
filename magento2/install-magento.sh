#!/bin/bash
# -------
# This is standalone script which configure and install magento project
# -------

MAGENTO_VERSION_DEFAULT=2.2.3
export TIME_ZONE="Asia/Ho_Chi_Minh"
export TMP_INSTALL=/tmp
export APTVERBOSITY="-qq -y"
export DEFAULTYESNO="y"


export MAGENTO_DB_DEFAULT="magento"
export MAGENTO_USER_DEFAULT="magento"
export MAGENTO_DB=$MAGENTO_DB_DEFAULT
export MAGENTO_USER=$MAGENTO_USER_DEFAULT
export MAGENTO_ADMIN_PASSWORD_DEFAULT="admin123"


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

read -e -p "Please enter the project name${ques} " PROJECT_NAME

if [ -n "$PROJECT_NAME" ]; then
	cd $WEB_ROOT
	
	read -e -p "Please enter the Magento version${ques} " -i "$MAGENTO_VERSION_DEFAULT" MAGENTO_VERSION
	sudo composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition:$MAGENTO_VERSION $PROJECT_NAME
	
	# Install database and setup username password based on project name
	#read -e -p "Create Magento Database and user? [y/n] " -i "y" createdbmagento
	#if [ "$createdbmagento" = "y" ]; then
	  echo "Installing and configuring magento database and user......"
	  read -s -p "Enter the Magento database password:"  MAGENTO_PASSWORD
	  echo ""
	  read -s -p "Re-Enter the Magento database password:" MAGENTO_PASSWORD2
	  while [ "$MAGENTO_PASSWORD" != "$MAGENTO_PASSWORD2" ]
	  do
		   echo "Password does not match. Please try again"
	  done
	  #if [ "$MAGENTO_PASSWORD" == "$MAGENTO_PASSWORD2" ]; then
		MAGENTO_DB=$PROJECT_NAME
		MAGENTO_USER=$PROJECT_NAME
		echo "Creating Magento database and user."
		echo "You must supply the root user password for MariaDB:"
		mysql -u root -p << EOF
	# Drop user and database if exists
	DROP USER IF EXISTS '$MAGENTO_USER'@'localhost';
	DROP DATABASE IF EXISTS $MAGENTO_DB;
	#create magento db
	CREATE DATABASE $MAGENTO_DB DEFAULT CHARACTER SET utf8;
	DELETE FROM mysql.user WHERE User = '$MAGENTO_USER';
	CREATE USER '$MAGENTO_USER'@'localhost' IDENTIFIED BY '$MAGENTO_PASSWORD';
	GRANT ALL PRIVILEGES ON $MAGENTO_DB.* TO '$MAGENTO_USER'@'localhost' WITH GRANT OPTION;
EOF
	  echo
	  echo "Remember to update configuration with the Magento database password"
	  echo
	  #fi
	#fi
	
	# Setup magento
	read -e -p "Please enter your public host name on this server${ques} " HOSTNAME
	read -e -p "Please enter the protocol to use for public Share server (http or https)${ques} [https] " -i "https" PROTOCOL
	if [ -n "$HOSTNAME" ]; then
		#echo "DB USER : $MAGENTO_USER, DB PASSWORD : $MAGENTO_PASSWORD DB : $MAGENTO_DB"
		sudo php $WEB_ROOT/$PROJECT_NAME/bin/magento setup:install --base-url=$PROTOCOL://$HOSTNAME --backend-frontname=admin --db-host=127.0.0.1 --db-name=$MAGENTO_DB \
						--db-password=$MAGENTO_PASSWORD --db-user=$MAGENTO_USER --admin-firstname=admin --admin-lastname=admin --admin-email=admin@mycompany.com \
						--admin-user=admin --admin-password=$MAGENTO_ADMIN_PASSWORD_DEFAULT --language=en_US --currency=USD --timezone=$TIME_ZONE --use-rewrites=1
						
		# Set permission on project folder
		cd $WEB_ROOT/$PROJECT_NAME
		sudo find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \;
		sudo find var vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} \;
		sudo chown -R :www-data .		
	else
		echo "Please input valid hostname"
	fi
	
	# Setup SSL
	#read -e -p "Install SSL${ques} [y/n] " -i "$DEFAULTYESNO" installssl
	if [ "$PROTOCOL" = "https" ]; then
		local_port=443
		echo "SSL for domain : $HOSTNAME is being created with port : $local_port"
		if [ ! -f "/etc/letsencrypt/live/$HOSTNAME/fullchain.pem" ]; then
			sudo certbot certonly --authenticator standalone --installer nginx -d $HOSTNAME --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
		fi
		
		if [ -f "/etc/letsencrypt/live/$HOSTNAME/fullchain.pem" ]; then
		
			sudo cat <<EOF >/etc/nginx/sites-available/$HOSTNAME.conf
server {
  listen 80;
  server_name @@DNS_DOMAIN@@;
 
  include /etc/nginx/snippets/ssl.conf;

  location / {
    return 301 https://\$host\$request_uri;
  }
}

upstream fastcgi_backend {
  server  unix:/run/php/php7.0-fpm.sock;
}

server {
  server_name @@DNS_DOMAIN@@;
  listen 443 ssl http2;
  
  ssl_certificate /etc/letsencrypt/live/@@DNS_DOMAIN@@/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/@@DNS_DOMAIN@@/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt/live/@@DNS_DOMAIN@@/fullchain.pem;
  include /etc/nginx/snippets/ssl.conf;
  
  access_log /var/log/nginx/magento2-access.log;
  error_log /var/log/nginx/magento2-error.log;

  set \$MAGE_ROOT @@ROOT_PROJECT_FOLDER@@;
  set \$MAGE_MODE developer;
  include @@ROOT_PROJECT_FOLDER@@/nginx.conf.sample;
}
EOF
			# Replace template with configuration value created in previous step
			sudo sed -i "s/@@DNS_DOMAIN@@/$HOSTNAME/g" 		/etc/nginx/sites-available/$HOSTNAME.conf
			sudo sed -i "s/@@ROOT_PROJECT_FOLDER@@/$WEB_ROOT_PATH\/$PROJECT_NAME/g" 	/etc/nginx/sites-available/$HOSTNAME.conf
			sudo ln -s /etc/nginx/sites-available/$HOSTNAME.conf /etc/nginx/sites-enabled/
				
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
     server_name @@DNS_DOMAIN@@;
     set \$MAGE_ROOT @@ROOT_PROJECT_FOLDER@@;
     include @@ROOT_PROJECT_FOLDER@@/nginx.conf.sample;
 }
EOF
		# Replace template with configuration value created in previous step
		sudo sed -i "s/@@DNS_DOMAIN@@/$HOSTNAME/g" 		/etc/nginx/sites-available/$HOSTNAME.conf
		sudo sed -i "s/@@ROOT_PROJECT_FOLDER@@/$WEB_ROOT_PATH\/$PROJECT_NAME/g" 	/etc/nginx/sites-available/$HOSTNAME.conf
		sudo ln -s /etc/nginx/sites-available/$HOSTNAME.conf /etc/nginx/sites-enabled/
		
		sudo service nginx restart
	fi

else
	echo "Please input valid name for creating project"
fi
	
echo
echogreen "- - - - - - - - - - - - - - - - -"
echo "Scripted install complete"
echo
echored "Magento has been installed with following database info : "
echored " DB Name : $MAGENTO_DB"
echored " DB Username : $MAGENTO_USER"
echored " DB Password : $MAGENTO_PASSWORD"
echo
echo "Magento web app can be accessed via URL : "
echored " $PROTOCOL://$HOSTNAME"
echo
echored "Below is admin information which can be used to login into administration page"
echored "admin username : admin and admin password : $MAGENTO_ADMIN_PASSWORD_DEFAULT"
