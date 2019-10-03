#!/usr/bin/env bash

if [ -e deployed.json ]
then
    deploymentId=$(jq -r '.deploymentId' deployed.json)

    echo Undeploying deployment $deploymentId

    curl -X DELETE -s -u ${bamboo.boomi.username}:${bamboo.boomi.password} -H 'Accept: application/json' -H 'Content-Type: application/json' "${bamboo.boomi.api.url}/DeployedPackage/$deploymentId"

    echo "\nUndeployed"
fi