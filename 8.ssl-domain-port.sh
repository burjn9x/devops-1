#!/bin/bash
# -------
# This is standalone script which setup SSL for multiple domains 
# -------

# Configure constants
if [ -f "constants.sh" ]; then
	. constants.sh
fi

# Configure colors
if [ -f "colors.sh" ]; then
	. colors.sh
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Begin running...."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

sudo mkdir temp

create_ssl() {
	local_domain=$1
	local_port=$2
    echo "SSL for domain : $local_domain is being created with port : $local_port"
	if [ ! -f "/etc/letsencrypt/live/$local_domain/fullchain.pem" ]; then
		# sudo letsencrypt certonly --webroot -w /opt/letsencrypt -d $local_domain --email digital@smartbiz.vn --agree-tos
		sudo certbot certonly --authenticator standalone --installer nginx -d $local_domain --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
	fi
	
	if [ -f "/etc/letsencrypt/live/$local_domain/fullchain.pem" ]; then
		
		if [ "$local_domain" = "alfresco" ] || [ "$local_domain" = "camunda" ]; then
			echo "choosing alfresco and camunda"
			# Check if ssl is found
			ssl_found=0
			if [ -f "/etc/nginx/sites-available/$local_domain.conf" ]; then
				ssl_found=$(grep -o "443" /etc/nginx/sites-available/$local_domain.conf | wc -l)
			fi
			
			if [ "$ssl_found" = 0 ]; then
				sudo rsync -avz $NGINX_CONF/sites-available/domain.conf.ssl /etc/nginx/sites-available/$local_domain.conf
				sudo ln -s /etc/nginx/sites-available/$local_domain.conf /etc/nginx/sites-enabled/
				  
				#sudo sed -i "s/@@WEB_ROOT@@/${WEB_ROOT//\//\\/}/g" /etc/nginx/sites-available/$local_domain.conf
				sudo sed -i "s/@@DNS_DOMAIN@@/$local_domain/g" /etc/nginx/sites-available/$local_domain.conf
				echo "Local domain : $local_domain"
				if [ "$local_domain" = "alfresco" ]; then
					echo "choosing alfresco"
					# Insert cache config
					sudo sed -i '1 i\proxy_cache_path \/var\/cache\/nginx\/alfresco levels=1 keys_zone=alfrescocache:256m max_size=512m inactive=1440m;\n' /etc/nginx/sites-available/$local_domain.conf
					sudo sed -i "0,/server/s/server/upstream alfresco {	\n\tserver localhost\:$local_port;	\n}	\n\n upstream share {    \n\tserver localhost:$local_port;	\n}\n\n&/" /etc/nginx/sites-available/$local_domain.conf
					sudo sed -i "s/##REWRITE##/rewrite \^\/\$	\/share;/g" /etc/nginx/sites-available/$local_domain.conf
					sudo cp $NGINX_CONF/sites-available/alfresco.snippet	temp/
					sudo sed -e '/##ALFRESCO##/ {' -e 'r temp/alfresco.snippet' -e 'd' -e '}' -i /etc/nginx/sites-available/$local_domain.conf
					sudo mkdir -p /var/cache/nginx/alfresco

					sudo chown -R www-data:root /var/cache/nginx/alfresco
					
					# Change https in alfresco-global.properties
					sudo sed -i "s/\(^share.protocol=\).*/\1https/"  $CATALINA_HOME/shared/classes/alfresco-global.properties
					sudo sed -i "s/\(^opencmis.server.value=\).*/\1https:\/\/$local_domain/"  $CATALINA_HOME/shared/classes/alfresco-global.properties
					sudo sed -i "s/\(^share.port=\).*/\1443/"  $CATALINA_HOME/shared/classes/alfresco-global.properties
				else
					echo "choosing camunda"
					 sudo sed -i "0,/server/s/server/upstream camunda {    \n\tserver localhost\:$local_port;	\n}	\n\n	upstream engine-rest {	    \n\tserver localhost:$local_port;	\n}\n\n&/" /etc/nginx/sites-available/$local_domain.conf
					 sudo sed -i "s/##REWRITE##/rewrite \^\/\$	\/camunda;/g" /etc/nginx/sites-available/$local_domain.conf
					 sudo cp $NGINX_CONF/sites-available/camunda.snippet	temp/
					 sudo sed -e '/##CAMUNDA##/ {' -e 'r temp/camunda.snippet' -e 'd' -e '}' -i /etc/nginx/sites-available/$local_domain.conf
				fi
			fi
		else
			sudo rsync -avz $NGINX_CONF/sites-available/domain.conf.ssl /etc/nginx/sites-available/$local_domain.conf
			sudo ln -s /etc/nginx/sites-available/$local_domain.conf /etc/nginx/sites-enabled/
				  
			sudo sed -i "s/@@DNS_DOMAIN@@/$local_domain/g" /etc/nginx/sites-available/$local_domain.conf
			sudo cp $NGINX_CONF/sites-available/common.snippet	temp/
			sudo sed -e '/##COMMON##/ {' -e 'r temp/common.snippet' -e 'd' -e '}' -i /etc/nginx/sites-available/$local_domain.conf
			  
			sudo sed -i "s/@@PORT@@/$local_port/g" /etc/nginx/sites-available/$local_domain.conf
		fi
		  
		echo "SSL for domain : $local_domain has been created successfully."
		  
	  else
		  echored "There is an error in generating keys for domain $local_domain."
	  fi
}

read -e -p "Please enter the public host name for your server (only domain name, not subdomain)${ques} [`hostname`] " -i "`hostname`" DOMAIN_NAME
sudo sed -i "s/MYCOMPANY.COM/$DOMAIN_NAME/g" $BASE_INSTALL/domain.txt

DOMAIN_INFOS=()

count=1
while read line || [[ -n "$line" ]] ; do
# for line in $(cat $BASE_INSTALL/domain.txt) ; do
	count=`expr $count + 1`
	if [ $count -gt 3 ]; then
		IFS='|' read -ra arr <<<"$line"
		domain="$(echo -e "${arr[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
		port="$(echo -e "${arr[3]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
		#echo $line;
		#if [[ $domain =~ ^(([a-zA-Z]|[a-zA-Z][a-zA-Z\-]*[a-zA-Z])\.)*([A-Za-z]|[A-Za-z][A-Za-z\-]*[A-Za-z])$ ]]; then
			# echo $domain;
			# sudo systemctl reload nginx
			if [ $port != "xxxx" ]; then
				DOMAIN_INFOS+=("$domain:$port")
			fi
		#else
		#	echo "$domain is an invalid name, please check again."
		#fi

	fi
done < $BASE_INSTALL/domain.txt

for DOMAIN_INFO in ${DOMAIN_INFOS[@]}
do
	domain=${DOMAIN_INFO%%:*}
    port=${DOMAIN_INFO#*:}
	create_ssl $domain $port
done

sudo systemctl restart nginx
echogreen "Finished installing SSL"

sudo rm -rf temp

# Add cron job to renew key
crontab -l | { cat; echo '43 6 * * * root /usr/bin/certbot renew --post-hook "systemctl reload nginx" > /var/log/certbot-renew.log'; } | crontab -
