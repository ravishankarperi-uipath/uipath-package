#!/usr/bin/env bash

read -r -d '' applescriptCode <<'EOF'
   set dialogText to text returned of (display dialog "Scratch Org Name" default answer "scratch")
   return dialogText
EOF

scratchOrgName=$(osascript -e "$applescriptCode");

read -r -d '' applescriptCode1 <<'EOF'
   set dialogText to text returned of (display dialog "Dev Hub Alias or UserName" default answer "UIPATH_PROD")
   return dialogText
EOF

devHub=$(osascript -e "$applescriptCode1");

echo Attempting to delete scratch org with name $scratchOrgName;

sfdx force:org:delete -p -v $devHub -u $scratchOrgName;
sfdx force:org:create -f config/project-scratch-def.json -d 7 -s -a $scratchOrgName -v $devHub

echo Installing uipath-core package
coreLatestVersion=$(sfdx force:package:version:list -p 0Ho1Q000000CaTDSA0 -v $devHub -o CreatedDate --concise | tail -1 | awk '{print $3}')
sfdx force:package:install --package $coreLatestVersion -u $scratchOrgName -w 10 -k unlockedclear --noprompt

echo Installing dnbOptimizer package
sfdx force:package:install --package 04t1I000003FJbZQAW -u scratch1 --noprompt -w 10

echo Installing uipath-commons package
commonsLatestVersion=$(sfdx force:package:version:list -p 0Ho1Q000000CaTISA0 -v $devHub -o CreatedDate --concise | tail -1 | awk '{print $3}')
sfdx force:package:install --package $commonsLatestVersion -u $scratchOrgName -w 15 -k unlockedclear --noprompt

echo Reseting tracking
sfdx force:source:tracking:reset

echo Run a dummy push to new scratch org to start tracking again
sfdx force:source:push -u $scratchOrgName