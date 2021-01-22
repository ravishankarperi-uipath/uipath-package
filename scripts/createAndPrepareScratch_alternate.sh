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

echo Installing dnbOptimizer package
sfdx force:package:install --package 04t1I000003FJbZQAW -u scratch1 --noprompt -w 10

echo Installing uipath connector package
sfdx force:package:install --package 04t1U000007TwtzQAC -u scratch1 --noprompt -w 10

sfdx force:source:push -u $scratchOrgName;
