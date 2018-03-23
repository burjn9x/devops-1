# Installing & Configuring DevOps Server in Amazon AWS Ubuntu 16.04 LTS.
=======================

## 1. 3rd-Party Software Packagess

| x | ## | Software     		| Version            | Command              | PATH                |
| - | -- | ------------ 		| ------------------ | -------------------- | ------------------- |
| x | 01 | Ubuntu       		| Ubuntu 16.04.3 LTS | lsb_release -a       |                     |
| x | 02 | Nginx        		| 1.10.3             | nginx -v             |                     |
| x | 03 | Oracle Java  		| 1.8.0_151          | java -version        | /etc/java-8-oracle/ |
| x | 04 | MAVEN        		| 3.3.9              | mvn -v               | /usr/share/maven    |
| x | 05 | ANT          		| 1.9.6              | ant -v               | /usr/share/ant      |
| x | 06 | MariaDB      		| 9.4.11             | mysql --version      | DigitalBusiness2018 |
| x | 07 | Tomcat       		| 8.0.38             |         			 	|                     |
| x | 08 | SSL          		|                    |                      |                     |
| - | 09 | Camunda BPM          |                    |                      |                     |
| - | 10 | Alfresco ECM         |                    |                      |                     |
| - | 11 | LibreOffice  		| 5.2.1.2            | libreoffice --version|                     |
| - | 12 | ImageMagick  		| 6.8.9-9            | 						|                     |
| - | 13 | Ghostscript  		| 9.18        		 | 			            |                     |
| - | 14 | Alf PDF Renderer 	| 1.0      			 |             			|                     |


| ## | *.conf          | DNS:Port                          | Version				|					|
| -- | --------------- | --------------------------------- | ----------------------- | ------------------- |
| 01 | camunda         | camunda.smartbiz.vn               | 7.7.0					|					|
| 02 | alfresco        | alfresco.smartbiz.vn:5555         | 5.2					|					|


Current version : ** [Alfresco 201704 Community](https://community.alfresco.com/docs/DOC-6829-draft-alfresco-community-edition-201704-ga-release-draft)**  
Ubuntu Version :  **16.04 LTS** and compatible to **14.04**