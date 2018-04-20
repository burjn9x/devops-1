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

sudo git clone https://DigitalBusiness@bitbucket.org/workplace101/workplacebpm.git $TMP_INSTALL/workplacebpm

if [ ! -d "$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/input" ]; then
	sudo mkdir -p $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/input
	echored "There is no input file for this dmn conversion..."
	exit 1
fi

if [ ! -f "$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/input/RACI-Decision-Making-Criteria.xlsx" ]; then
	echored "There is no input file for this dmn conversion..."
	echored "Please put RACI excel file : RACI-Decision-Making-Criteria.xlsx  into $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/input and run this script again.."
	exit 1
fi

if [ ! -d "$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/output" ]; then
	sudo mkdir -p $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/output
else
	sudo rm -rf $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/output/*.*
fi

sudo sed -i "s/\(^eform.cli.raci.filePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.departmentMaster.filePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.bom.filePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.bufferDepartment.filePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/input\/RACI-Decision-Making-Criteria.xlsx/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.dmn.bom.outputFilePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/ouput\/BOMApproval.dmn/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.dmn.bom.bufferFilePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/ouput\/BOMApproval.dmn/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties

sudo sed -i "s/\(^eform.cli.dmn.department.outputFilePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/ouput\/DepartmentApproval.dmn/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties
sudo sed -i "s/\(^eform.cli.dmn.department.bufferFilePath=\).*/\1$TMP_INSTALL\/workplacebpm\/src\/workforce-dmn-xlsx\/ouput\/DepartmentApproval.dmn/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties

sudo sed -i "s/\(^eform.cli.bpmn.deployFilePath=\).*/\1/" 	$TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/src/main/resources/application.properties


cd $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx
source /etc/profile.d/maven.sh
mvn clean install

java -jar $TMP_INSTALL/workplacebpm/src/workforce-dmn-xlsx/xlsx-dmn-cli/target/dmn-xlsx-cli-2.0.1.RELEASE.jar