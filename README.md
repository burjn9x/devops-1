# Installing & Configuring DevOps Ubuntu 16.04 LTS.
=======================

## 1. 3rd-Party Software Packagess

|  x  | ## | Software     		| Version            | Command              | PATH                |
| --- | -- | ------------ 		| ------------------ | -------------------- | ------------------- |
| [x] | 01 | Ubuntu       		| Ubuntu 16.04.4 LTS | lsb_release -a       |                     |
| x | 02 | Nginx        		| 1.10.3             | nginx -v             |                     |
| x | 03 | Oracle Java  		| 1.8.0_161          | java -version        | /etc/java-8-oracle/ |
| x | 04 | MAVEN        		| 3.3.9              | mvn -v               | /usr/share/maven    |
| x | 05 | ANT          		| 1.9.6              | ant -v               | /usr/share/ant      |
| x | 06 | MariaDB      		| 9.4.11             | mysql --version      |  |
| x | 07 | Tomcat       		| 8.5.29             |         			 	      |                     |
| x | 08 | SSL          		|                    |                      |                     |
| [ ] | 09 | Camunda BPM      |                    |                      |                     |
| - | 10 | Alfresco ECM     |                    |                      |                     |
| - | 11 | LibreOffice  		| 5.2.1.2            | libreoffice --version|                     |
| - | 12 | ImageMagick  		| 6.8.9-9            | 						          |                     |
| - | 13 | Ghostscript  		| 9.18        		   | 			                |                     |
| - | 14 | Alf PDF Renderer | 1.0      			     |             			    |                     |
| - | 15 | Node.JS          | 6.x      			     |             			    |                     |
| - | 16 | PM2              |       			     |             			    |                     |
| - | 17 | Redis            |       			     |             			    |                     |
| - | 18 | Mongo DB         |       			     |             			    |                     |


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
