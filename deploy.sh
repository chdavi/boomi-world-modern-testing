#!/usr/bin/env bash



# The component ID of the process to deploy
#
# Find this id by opening the process, clicking Revisions in the lower right, and copying the ID
COMPONENT=$1

# Clean up the old files
echo "Cleaning up old data files"

if [ -e package.json ]
then
    echo "Deleting old package.json"
    rm -rf package.json
fi

if [ -e payload.json ]
then
    echo "Deleting old payload.json"
    rm -rf payload.json
fi
if [ -e deployed.json ]
then
    echo "Deleting old deployment info"
    rm -rf deployed.json
fi

# Create the deployment package
echo "Creating deployment package for component $COMPONENT"
curl -v -s -u ${bamboo.boomi.username}:${bamboo.boomi.password} -d "{\"componentId\": \"$COMPONENT\"}" -H 'Accept: application/json' -H 'Content-Type: application/json' ${bamboo.boomi.api.url}/PackagedComponent >> package.json

jq "." package.json
echo "Created deployment package"

# Extract the package Id
packageId=$(jq '.packageId' package.json)
echo Deploying package: $packageId

# Build the deployment payload and deploy the package
echo '{"environmentId": "${bamboo.boomi.environment}", "packageId": "$packageId"}' | jq ".packageId=$packageId" >> payload.json
echo Generating Deployment Payload:
jq "." payload.json

curl -s -u ${bamboo.boomi.username}:${bamboo.boomi.password} -d @./payload.json -H 'Accept: application/json' -H 'Content-Type: application/json' ${bamboo.boomi.api.url}/DeployedPackage >> deployed.json
echo Package Deployed