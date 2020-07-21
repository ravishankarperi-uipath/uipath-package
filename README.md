# UiPath Salesforce Unlocked Package

## Prerequisites:

- Your local machine is setup with all necessary tooling like VS Code(or other IDE), Any IDE extensions or plugins, Git, NPM, SFDX CLI
- You have the uipath packaging repository cloned locally

## For Mac

Authenticate to Production DevHub if you haven't already

```shell
sfdx force:auth:web:login -d -a DevHub
```

Run Scratch org create script (only on Mac)

```bash
./scripts/scripts/createAndPrepareScratch.sh
```

## For Windows

Authenticate to Production DevHub if you haven't already

```shell
sfdx force:auth:web:login -d -a DevHub
```

### Create a scratch org:

```bash
sfdx force:org:create -s -f config/project-scratch-def.json --durationdays 30 --setalias scratch -v DevHub
```

### Install packages using the 04t ids

#### Obtain the 04t Ids for unlocked packages by running:

```bash
sfdx force:package:version:list -v UIPATH_PROD
```

#### Obtain the 04t Ids for managed packages by running:

```bash
sfdx force:package:installed:list -u UIPATH_PROD
```

#### Install packages:

- uipath-core

```bash
 sfdx force:package:install --package 04t... -k test1234 -u scratch
```

- dnbOptimizer

```bash
sfdx force:package:install --package 04t... -u scratch1 --noprompt
```

- uipath-commons

```bash
sfdx force:package:install --package 04t.... -k test1234 -u scratch
```

## Work on Feature and Release

1. Create a new feature branch
2. Make changes and pull down locally
3. Run all Local package tests
4. Commit changes into Git, Push and raise Pull Request
5. wait for CI job to run all package tests
6. Get approver to approve PR
7. Merge PR
8. CI job creates new build version and installs to SIT
   (CI job also runs all tests in Org to see if any non-package tests are broken)
9. RM installs package to UAT when appropriate
10. When UAT passes. RM creates a Release version of package(s)
11. RM installs package in Production
