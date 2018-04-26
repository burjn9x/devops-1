# Installing & Configuring DevOps Ubuntu 16.04 LTS.
=======================

## Installation Guideline

| Step | Function Name        | Description      |
| :--- |:-------------------- | :--------------- |
| 01   | 1.ubuntu-upgrade.sh  | curl, wget, rsync, zip, unzip, git, python, pip, mkdocs, awscli; and SwapFile, en_US.utf8, TimeZone |
| 02   | 2.install-MEAN.sh    | nginx, nvm, nodejs, pm2, redis, mongo, certbot,  |


## 1. 3rd-Party Software Packagess

| x | ## | Software     		| Version            | Command              | PATH                |
| - | -- | ------------ 		| ------------------ | -------------------- | ------------------- |
| x | 01 | Ubuntu       		| Ubuntu 16.04.4 LTS | lsb_release -a       |                     |
| x | 02 | Nginx        		| 1.10.3             | nginx -v             |                     |
| x | 03 | Oracle Java  		| 1.8.0_162          | java -version        | /etc/java-8-oracle/ |
| x | 04 | MAVEN        		| 3.3.9              | mvn -v               | /usr/share/maven    |
| x | 05 | ANT          		| 1.9.6              | ant -v               | /usr/share/ant      |
| x | 06 | MariaDB      		| 15.1 > 10.1.32     | mysql --version      |  |
| x | 07 | Tomcat       		| 8.5.29             |         			 	      |                     |
| x | 08 | SSL          		|                    |                      |                     |
| - | 09 | Camunda BPM      |                    |                      |                     |
| - | 10 | Alfresco ECM     |                    |                      |                     |
| - | 11 | LibreOffice  		| 5.2.1.2            | libreoffice --version|                     |
| - | 12 | ImageMagick  		| 6.8.9-9            | 						          |                     |
| - | 13 | Ghostscript  		| 9.18        		   | 			                |                     |
| - | 14 | Alf PDF Renderer | 1.0      			     |             			    |                     |
| - | 15 | Node.JS          | 8.11.1      			 | node -v            	|                     |
| - | 16 | PM2              | 2.10.2      			 | pm2 -v            		|                     |
| - | 17 | Redis            | 3.0.6      	       | redis-server -v      |                     |
| - | 18 | Mongo DB         | 3.4.14      			 | mongo -version       |                     |


> **Checklist**

```
lsb_release -a               &&
timedatectl                  &&
free -h                      &&
service nginx status         &&
sudo ufw status numbered     &&
node -v                      &&
npm -v                       &&
pm2 list                     &&
redis-server -v              &&
mongo -version               &&
java -version                &&
mvn -v                       &&
ant -v                       &&
sudo certbot renew --dry-run &&
sudo systemctl status jenkins 
```

Ubuntu Version :  **16.04 LTS** and compatible to **14.04**

- [x] 