# UiPath Salesforce Unlocked Package

## Prerequisites:

-Your local machine is setup with all necessary tooling like VS Code(or other IDE), Any IDE extensions or plugins, Git, NPM, SFDX CLI

-You have the uipath packaging repository cloned locally

## Steps

1. Authenticate to Production DevHub if you haven't already

   ```shell
   sfdx force:auth:web:login -d -a DevHub
   ```

2. Create a scratch org:

   ```shell
   sfdx force:org:create -s -f config/project-scratch-def.json --durationdays 7 --setalias scratch -v DevHub
   ```

3. Install packages (get list of Ids from sfdx-project.json and run one by one)

   ```shell
    sfdx force:package:install --package 0Ho4K000000PB0iSAG -k test1234 -u scratch
   ```

4. Open scratch org

   ```
   sfdx force:org:open
   ```

5. Create a new feature branch
6. Make changes and pull down locally
7. Run all Local package tests
8. Commit changes into Git, Push and raise Pull Request
9. wait for CI job to run all package tests
10. Get approver to approve PR
11. Merge PR
12. CI job creates new build version and installs to SIT
    (CI job also runs all tests in Org to see if any non-package tests are broken)
13. RM installs package to UAT when appropriate
14. When UAT passes. RM creates a Release version of package(s)
15. RM installs package in Production
