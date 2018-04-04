#!/bin/bash
# -------
# Script to check and initialize all necessary stuffs before installing devops
#
# -------

export DEVOPS_HOME=/home/devops
export BASE_INSTALL=/home/ubuntu/devops
export TIME_ZONE="Asia/Ho_Chi_Minh"
export NGINX_CONF=$BASE_INSTALL/_ubuntu/etc/nginx

export APTVERBOSITY="-qq -y"
export DEFAULTYESNO="y"

export DEVOPSURL=https://github.com/o2oprotocol/DevOps.git
export NVMURL=https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh


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

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Preparing for install. Updating and upgrading the apt package index files..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo apt-get $APTVERBOSITY update && sudo apt-get $APTVERBOSITY upgrade;
echo

if [ "`which curl`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install curl. Curl is used for downloading components to install."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sudo apt-get $APTVERBOSITY install curl;
fi

if [ "`which wget`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install wget. Wget is used for downloading components to install."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sudo apt-get $APTVERBOSITY install wget;
fi

if [ "`which rsync`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install rsync. rsync is used for copying or synchronizing data in local or remote ."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sudo apt-get $APTVERBOSITY install rsync;
fi

if [ "`which zip`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install zip. zip is used for compressing data."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sudo apt-get $APTVERBOSITY install zip;
fi

if [ "`which unzip`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install unzip. unzip is used for uncompressing data ."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sudo apt-get $APTVERBOSITY install unzip;
fi

if [ "`which git`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install git."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sudo apt-get $APTVERBOSITY install git;
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Checking for the availability of the URLs inside script..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Preparing for install. Updating the apt package index files..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo apt-get $APTVERBOSITY update;
echo

if [ "`which systemctl`" = "" ]; then
  export ISON1604=n
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "You are installing for version 14.04 (using upstart for services)."
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  read -e -p "Is this correct [y/n] " -i "$DEFAULTYESNO" useupstart
  if [ "$useupstart" = "n" ]; then
    export ISON1604=y
  fi
else 
  export ISON1604=y
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "You are installing for version 16.04 or later (using systemd for services)."
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  read -e -p "Is this correct [y/n] " -i "$DEFAULTYESNO" useupstart
  if [ "$useupstart" = "n" ]; then
    export ISON1604=n
  fi
fi

URLERROR=0

for REMOTE in $DEVOPSURL
do
        wget --spider $REMOTE --no-check-certificate >& /dev/null
        if [ $? != 0 ]
        then
                echored "In alfinstall.sh, please fix this URL: $REMOTE"
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

##
# Timezone
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Begin setting up TimeZone..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo timedatectl set-timezone $TIME_ZONE


##
# MAVEN 3.3.9
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Maven is a build automation tool used primarily for Java projects "
echo "You will also get the option to install this build tool"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install MAVEN build tool${ques} [y/n] " -i "$DEFAULTYESNO" installmaven

if [ "$installmaven" = "y" ]; then
  echogreen "Installing Maven"
  echo "Downloading Maven..."
  curl -# -o $TMP_INSTALL/apache-maven-$MAVEN_VERSION.tar.gz $APACHEMAVEN
  #curl -# -L -O $APACHEMAVEN
  echo "Extracting..."
  sudo tar -xf $TMP_INSTALL/apache-maven-$MAVEN_VERSION.tar.gz -C $TMP_INSTALL
  sudo mv $TMP_INSTALL/apache-maven-$MAVEN_VERSION $TMP_INSTALL/maven
  sudo mv $TMP_INSTALL/maven $DEVOPS_HOME
  cat << EOF > /etc/profile.d/maven.sh
#!/bin/sh
export MAVEN_HOME=$DEVOPS_HOME/maven
export M2_HOME=$DEVOPS_HOME/maven
export M2=$DEVOPS_HOME/maven/bin
export PATH=$PATH:$DEVOPS_HOME/maven/bin
EOF

  sudo chmod a+x /etc/profile.d/maven.sh
  source /etc/profile.d/maven.sh
  echo
  echogreen "Finished installing Maven"
  echo  
else
  echo "Skipping install of Maven"
  echo
fi  
  
  
##
# ANT 1.9.9
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "ANT is a tool used for controlling build process "
echo "You will also get the option to install this tool"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install ANT tool${ques} [y/n] " -i "$DEFAULTYESNO" installant

if [ "$installant" = "y" ]; then
  echogreen "Installing Ant"
  echo "Downloading Ant..."
  #cd $TMP_INSTALL
  #curl -# -L -O $APACHEANT
  curl -# -o $TMP_INSTALL/apache-ant-$ANT_VERSION.tar.gz $APACHEANT
  echo "Extracting..."
  sudo tar -xf $TMP_INSTALL/apache-ant-$ANT_VERSION.tar.gz -C $TMP_INSTALL
  sudo mv $TMP_INSTALL/apache-ant-$ANT_VERSION $TMP_INSTALL/ant
  sudo mv $TMP_INSTALL/ant $DEVOPS_HOME
  cat << EOF > /etc/profile.d/ant.sh
#!/bin/sh
export ANT_HOME=$DEVOPS_HOME/ant
export PATH=$PATH:$DEVOPS_HOME/ant/bin
EOF

  chmod a+x /etc/profile.d/ant.sh
  source /etc/profile.d/ant.sh
  echo
  echogreen "Finished installing Ant"
  echo  
else
  echo "Skipping install of Ant"
  echo
fi

##
# Java 8 SDK
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Java JDK."
echo "This will install Oracle Java 8 version of Java. If you prefer OpenJDK"
echo "you need to download and install that manually."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Oracle Java 8${ques} [y/n] " -i "$DEFAULTYESNO" installjdk
if [ "$installjdk" = "y" ]; then
  echoblue "Installing Oracle Java 8. Fetching packages..."

  JDK_VERSION=`echo $JAVA8URL | rev | cut -d "/" -f1 | rev`

  declare -a PLATFORMS=("-linux-x64.tar.gz")

  for platform in "${PLATFORMS[@]}"
  do
     wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${JAVA8URL}${platform}" -P $TMP_INSTALL
     ### curl -C - -L -O -# -H "Cookie: oraclelicense=accept-securebackup-cookie" "${JAVA8URL}${platform}"
  done
  sudo mkdir /usr/java
  sudo tar xvzf $TMP_INSTALL/jdk-8u161-linux-x64.tar.gz -C /usr/java
  
  JAVA_DEST=jdk1.8.0_161
  export JAVA_HOME=/usr/java/$JAVA_DEST/
  sudo update-alternatives --install /usr/bin/java java ${JAVA_HOME%*/}/bin/java 1
  sudo update-alternatives --install /usr/bin/javac javac ${JAVA_HOME%*/}/bin/javac 1

  echo
  echogreen "Finished installing Oracle Java 8"
  echo
else
  echo "Skipping install of Oracle Java 8"
  echored "IMPORTANT: You need to install other JDK and adjust paths for the install to be complete"
  echo
fi

##
# System user
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to add a system user that runs the tomcat DevOps instance."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add devops system user${ques} [y/n] " -i "$DEFAULTYESNO" adddevops
if [ "$adddevops" = "y" ]; then
  sudo adduser --system --disabled-login --disabled-password --group $DEVOPS_USER
  echo
  echogreen "Finished adding devops user"
  echo
else
  echo "Skipping adding devops user"
  echo
fi

##
# Tomcat
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Tomcat is a web application server."
echo "You will also get the option to install jdbc lib for Postgresql or MySql/MariaDB."
echo "Install the jdbc lib for the database you intend to use."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Tomcat${ques} [y/n] " -i "$DEFAULTYESNO" installtomcat

if [ "$installtomcat" = "y" ]; then
  echogreen "Installing Tomcat"
  if [ ! -f "$TMP_INSTALL/apache-tomcat-$TOMCAT8_VERSION.tar.gz" ]; then
	echo "Downloading tomcat..."
	curl -# -L -O $TOMCAT_DOWNLOAD
  fi
  # Make sure install dir exists, including logs dir
  sudo mkdir -p $DEVOPS_HOME/logs
  echo "Extracting..."
  tar xf $TMP_INSTALL/apache-tomcat-$TOMCAT8_VERSION.tar.gz
  sudo mv $TMP_INSTALL/apache-tomcat-$TOMCAT8_VERSION $CATALINA_HOME
  # Remove apps not needed
  sudo rm -rf $CATALINA_HOME/webapps/*
  # Create Tomcat conf folder
  sudo mkdir -p $CATALINA_HOME/conf/Catalina/localhost
  # Get Alfresco config
  echo "Downloading tomcat configuration files..."

  sudo rsync -avz $BASE_INSTALL/tomcat/server.xml $CATALINA_HOME/conf/
  sudo rsync -avz $BASE_INSTALL/tomcat/catalina.properties $CATALINA_HOME/conf/
  sudo rsync -avz $BASE_INSTALL/tomcat/tomcat-users.xml $CATALINA_HOME/conf/
  sudo rsync -avz $BASE_INSTALL/tomcat/context.xml $CATALINA_HOME/conf/

  echo
  read -e -p "Install Postgres JDBC Connector${ques} [y/n] " -i "$DEFAULTYESNO" installpg
  if [ "$installpg" = "y" ]; then
	curl -# -O $JDBCPOSTGRESURL/$JDBCPOSTGRES
	sudo mv $JDBCPOSTGRES $CATALINA_HOME/lib
  fi
  echo
  read -e -p "Install Mysql JDBC Connector${ques} [y/n] " -i "$DEFAULTYESNO" installmy
  if [ "$installmy" = "y" ]; then
    cd $TMP_INSTALL
	curl -# -L -O $JDBCMYSQLURL/$JDBCMYSQL
	tar xf $JDBCMYSQL
	cd "$(find . -type d -name "mysql-connector*")"
	sudo mv mysql-connector*.jar $CATALINA_HOME/lib
  fi
  echo
  echogreen "Finished installing Tomcat"
  echo

else
  echo "Skipping install of Tomcat"
  echo
fi

##
# Database
##
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Database"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Please select on of these : [P]osgresql, [MY]sql, [MA]riadb, [Q]uit " -i "$DEFAULTDB" installdb

    case $installdb in
        "P")
			echo "Choosing posgresql..."
			DB_DRIVER=org.postgresql.Driver
			DB_PORT=5432
			DB_SUFFIX=''
			DB_CONNECTOR=postgresql
            . $BASE_INSTALL/scripts/postgresql.sh
            ;;
        "MY")
			echo "Choosing mysql..."
            . $BASE_INSTALL/scripts/mysql.sh
            ;;
        "MA")
			echo "Choosing mariadb..."
            . $BASE_INSTALL/scripts/mariadb.sh
            ;;
		"Q")
			echo "Quitting..."
			;;
        *) echo invalid option;;
    esac

	
##
# Jenkins
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Jenkins is a en source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project "
echo "You will also get the option to install this server"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Jenkins automation server${ques} [y/n] " -i "$DEFAULTYESNO" installjenkins
if [ "$installjenkins" = "y" ]; then
	wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
	sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get -qq -y install jenkins
	sudo systemctl start jenkins
fi

	
##
# Camunda
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Camunda is an open source used to create and manage workflow process "
echo "You will also get the option to install Camunda framework"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Camunda framework${ques} [y/n] " -i "$DEFAULTYESNO" installcamunda
if [ "$installcamunda" = "y" ]; then
	. $BASE_INSTALL/scripts/camunda-install.sh
fi

##
# Alfresco Community
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Alfresco is an open source Enterprise Content Management software that handles any type of content, allowing users to easily share and collaborate on content. "
echo "You will also get the option to install Alfresco framework"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Alfresco framework${ques} [y/n] " -i "$DEFAULTYESNO" installalfresco
if [ "$installalfresco" = "y" ]; then
	. $BASE_INSTALL/scripts/alfresco-install.sh
	
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Ubuntu default for number of allowed open files in the file system is too low"
	echo "for alfresco use and tomcat may because of this stop with the error"
	echo "\"too many open files\". You should update this value if you have not done so."
	echo "Read more at http://wiki.alfresco.com/wiki/Too_many_open_files"
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

	count=$(grep -o "alfresco  soft  nofile  8192" /etc/security/limits.conf | wc -l)
	if [ $count != 0 ]; then
		echo "limits.conf is already updated, so skipping updating it."
	else
		read -e -p "Add limits.conf${ques} [y/n] " -i "$DEFAULTYESNO" updatelimits
		if [ "$updatelimits" = "y" ]; then
		  echo "alfresco  soft  nofile  8192" | sudo tee -a /etc/security/limits.conf
		  echo "alfresco  hard  nofile  65536" | sudo tee -a /etc/security/limits.conf
		  echo
		  echogreen "Updated /etc/security/limits.conf"
		  echo
		  echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session
		  echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session-noninteractive
		  echo
		  echogreen "Updated /etc/security/common-session*"
		  echo
		else
		  echo "Skipped updating limits.conf"
		  echo
		fi
	fi
fi


##
# Firewall
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Begin setting up a firewall..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

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
sudo ufw status numbered