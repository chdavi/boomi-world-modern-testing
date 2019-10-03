Boomi CI/CD Automation
======================

Scripts for deploying and testing Boomi processes in a CI/CD environment. Separate scripts are 
used for deployment and execution of the test harness. The deployment script can be used for 
both testing and deploying to environments.  

These scripts are optimized for Atlassian Bamboo. They can be adapted for other CI/CD systems 
relatively easily. These scripts rely on Bamboo variable replacement to update the values in the script. 

The deploy.sh and execute.sh scripts can be copied and pasted into your CI/CD system process. 
The queryfilter.json template should be hosted where the CI/CD system can call it.  

Deployment 
---------

This script deploys a process to a Boomi environment.

Usage  
`deployment.sh componentId` 

Execute and Reporting
---------------------

This script executes a process, then if it fails exits with a non-zero exit code.

Usage  
`execute.sh componentId`