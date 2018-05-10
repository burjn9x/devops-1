#!/bin/bash
# -------
# This is script to convert RACI Excel to DMN which is later deployed into Camunda

# Configure constants
if [ -f "constants.sh" ]; then
	. constants.sh
fi

# Configure colors
if [ -f "colors.sh" ]; then
	. colors.sh
fi

echogreen "Begin running script to convert file..........."


if [ -d "$TMP_INSTALL/workplacebpm" ]; then
	sudo rm -rf $TMP_INSTALL/workplacebpm
fi

git clone https://bitbucket.org/workplace101/workplacebpm.git $TMP_INSTALL/workplacebpm

if [ ! -d "$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/input" ]; then
	mkdir -p $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/input
	echored "There is no input file for this dmn conversion..."
	exit 1
fi

if [ ! -f "$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/input/RACI-Decision-Making-Criteria.xlsx" ]; then
	echored "There is no input file for this dmn conversion..."
	echored "Please put RACI excel file : RACI-Decision-Making-Criteria.xlsx  into $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/input and run this script again.."
	exit 1
fi

if [ ! -d "$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/output" ]; then
	mkdir -p $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/output
else
	sudo rm -rf $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/output/*.*
fi

read -e -p "Please enter the tenant id for DMN deployment${ques} [TTV] " -i "TTV" TENANT_ID

sudo sed -i "s/\(^eform.cli.raci.filePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.departmentMaster.filePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.bom.filePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.bufferDepartment.filePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.dmn.bom.outputFilePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/ouput\/BOMApproval.dmn/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.dmn.bom.bufferFilePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties

sudo sed -i "s/\(^eform.cli.dmn.department.outputFilePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/ouput\/DepartmentApproval.dmn/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.dmn.department.bufferFilePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties

sudo sed -i "s/\(^eform.cli.bpmn.deployFilePath=\).*/\1/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties

camunda_line=$(grep "camunda" $BASE_INSTALL/domain.txt)
IFS='|' read -ra arr <<<"$camunda_line"
camunda_hostname="$(echo -e "${arr[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

camunda_protocol=https
ssl_found=$(grep -o "443" /etc/nginx/sites-available/$camunda_hostname.conf | wc -l)
if [ $ssl_found = 0 ]; then
	camunda_protocol=http
fi

sudo sed -i "s/\(^eform.cli.dmn.camunda.deploymentName=\).*/\1$TENANT_ID-archive/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.dmn.camunda.tenantId=\).*/\1$TENANT_ID/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.dmn.camunda.url.deployment=\).*/\1$camunda_protocol:\/\/$camunda_hostname\/engine-rest\/engine\/default\/deployment\/create/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties



cd $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx
source /etc/profile.d/maven.sh
mvn clean install

java -jar $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/target/dmn-xlsx-cli-2.0.1.RELEASE.jar