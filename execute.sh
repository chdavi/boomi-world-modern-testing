#!/usr/bin/env bash

COMPONENT=$1

# The queryfilter.json template should be hosted someplace easy to access from the CI/CD system.

SCRIPT_URL="https://PATH_TO_QueryFilter"


data="{\"processId\" : \"$COMPONENT\",\"atomId\":\"${bamboo.boomi.atomid}\"}"
echo "Starting process execution"
echo $data

# Execute the deployed process
START_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "Executing process..."
curl -s -u ${bamboo.boomi.username}:${bamboo.boomi.password} -d "$data" -H 'Accept: application/json' -H 'Content-Type: application/json' ${bamboo.boomi.api.url}/executeProcess

echo "Downloading template"
curl $SCRIPT_URL -o boomi_execution_query.json

echo "Generating search payload"
payload=$(<boomi_execution_query.json)
payload=$(echo $payload | jq "(.QueryFilter.expression.nestedExpression[] | select(.property==\"atomId\")        | .argument[0])=\"${bamboo.boomi.atomid}\"")
payload=$(echo $payload | jq "(.QueryFilter.expression.nestedExpression[] | select(.property==\"processId\")     | .argument[0])=\"$COMPONENT\"")
payload=$(echo $payload | jq "(.QueryFilter.expression.nestedExpression[] | select(.property==\"executionTime\") | .argument[0])=\"$START_TIME\"")
echo $payload

complete=false
echo "Searching for execution"
until [ "$complete" = true ]; do
  sleep 5s
  result=$(curl -s -u ${bamboo.boomi.username}:${bamboo.boomi.password} -d "$payload" -H 'Accept: application/json' -H 'Content-Type: application/json' ${bamboo.boomi.api.url}/ExecutionRecord/query)
  count=$(echo $result | jq ".numberOfResults")
  echo "Found $count results"

  if [ $count -eq 1 ]; then

    status=$(echo $result | jq -r ".result[0] | .status")
    echo "Status '$status'"

    if [ "$status" = "COMPLETE" ]; then
        echo "Success!"
        complete=true
        exit 0
    fi

    if [ "$status" = "ERROR"]; then
        echo "Failure!"
        complete=true
        exit 1
    fi
  fi
done