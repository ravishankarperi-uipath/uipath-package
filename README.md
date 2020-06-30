# UiPath Salesforce Unlocked Package

1.  Create a scratch org:

    ```shell
    sfdx force:org:create --definitionfile config/project-scratch-def.json --durationdays 7 --setalias scratch -v <user@yourdomain.com>
    ```

2)  Set default scratch org

    ```shell
    sfdx force:config:set defaultusername=scratch
    ```

3. Install packages

   ```shell
    sfdx force:package:install --package 04t***** -k test1234 -u scratch
   ```

4. Make changes and pull down locally
5. Run all Local package tests
6. Create new beta versions of packages
   ```shell
   sfdx force:package:version:create -p uipath-core -d uipath-core --wait 1 -v girish@june2020uipath.com -f config/project-scratch-def.json -x`
   `shell sfdx force:package:version:create -p uipath-commons -d uipath-commons --wait 1 -v girish@june2020uipath.com -f config/project-scratch-def.json -x
   ```
