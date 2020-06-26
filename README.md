# UiPath Salesforce Core

sfdx force:org:create --definitionfile config/project-scratch-def.json --durationdays 7 --setalias scratch -v girish@bigmantra100.com

sfdx force:config:set defaultusername=scratch

sfdx force:package:install --package 04t1v000002Gy6MAAS -k test1234 -u scratch

sfdx force:package:create --name uipath-core --description "uipath shared library" --packagetype Unlocked --path uipath-core --nonamespace --targetdevhubusername girish@june2020uipath.com

sfdx force:package:create --name uipath-commons --description "uipath common objects like Accounts Contacts etc" --packagetype Unlocked --path uipath-commons --nonamespace --targetdevhubusername girish@june2020uipath.com

sfdx force:package:version:create -p uipath-core -d uipath-core --wait 1 -v girish@june2020uipath.com -f config/project-scratch-def.json -x
sfdx force:package:version:create -p uipath-commons -d uipath-commons --wait 1 -v girish@june2020uipath.com -f config/project-scratch-def.json -x
