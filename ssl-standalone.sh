#!/bin/bash
# -------
# This is standalone script which setup SSL for multiple domains 
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

create_ssl() {
	local_domain=$1
	local_port=$2
    echo "SSL for domain : $local_domain is being created with port : $local_port"
	if [ ! -f "/etc/letsencrypt/live/$local_domain/fullchain.pem" ]; then
		# sudo letsencrypt certonly --webroot -w /opt/letsencrypt -d $local_domain --email digital@smartbiz.vn --agree-tos
		sudo certbot certonly --authenticator standalone --installer nginx -d $local_domain --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
	fi
	
	if [ -f "/etc/letsencrypt/live/$local_domain/fullchain.pem" ]; then
		  
		sudo rsync -avz $NGINX_CONF/sites-available/domain.conf.ssl /etc/nginx/sites-available/$local_domain.conf
		sudo ln -s /etc/nginx/sites-available/$local_domain.conf /etc/nginx/sites-enabled/
		  
		#sudo sed -i "s/@@WEB_ROOT@@/${WEB_ROOT//\//\\/}/g" /etc/nginx/sites-available/$local_domain.conf
		sudo sed -i "s/@@DNS_DOMAIN@@/$local_domain/g" /etc/nginx/sites-available/$local_domain.conf

		# Replace nginx ssl config with generated keys
		#sudo sed -i "s/@@CERTIFICATE@@/\/etc\/letsencrypt\/live\/$local_domain\/fullchain.pem/g" /etc/nginx/sites-available/$local_domain.conf 
		#sudo sed -i "s/@@CERTIFICATE_KEY@@/\/etc\/letsencrypt\/live\/$local_domain\/privkey.pem/g" /etc/nginx/sites-available/$local_domain.conf
		  
		sudo sed -i "s/@@PORT@@/$local_port/g" /etc/nginx/sites-available/$local_domain.conf
		  
		echo "SSL for domain : $local_domain has been created successfully."
		  
	  else
		  echored "There is an error in generating keys for domain $local_domain."
	  fi
}

count=1
while read line || [[ -n "$line" ]] ;
do
	count=`expr $count + 1`
	if [ $count -gt 3 ]; then
		IFS='|' read -ra arr <<<"$line"
		domain="$(echo -e "${arr[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
		port="$(echo -e "${arr[3]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
		#echo $line;
		#if [[ $domain =~ ^(([a-zA-Z]|[a-zA-Z][a-zA-Z\-]*[a-zA-Z])\.)*([A-Za-z]|[A-Za-z][A-Za-z\-]*[A-Za-z])$ ]]; then
			# echo $domain;
			# sudo systemctl reload nginx
			create_ssl $domain $port
		#else
		#	echo "$domain is an invalid name, please check again."
		#fi

	fi
done < $NGINX_CONF/domain.txt

sudo systemctl restart nginx
echogreen "Finished installing SSL"

# Add cron job to renew key
crontab -l | { cat; echo '43 6 * * * root /usr/bin/certbot renew --post-hook "systemctl reload nginx" > /var/log/certbot-renew.log'; } | crontab -
