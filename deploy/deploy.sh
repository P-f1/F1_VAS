#!/bin/bash

Namespace=$1
DeployType=$2
ServiceName=$3
ProjectID=$4

echo $Namespace
echo $DeployType
echo $ServiceName
echo $ProjectID
echo $Username
echo $TargetServer

if [ -d "./$DeployType" ] 
then
    rm -rf ./$DeployType/* 
else
    mkdir -p ./$DeployType
fi

cp -R ../artifacts/docker-compose.yml ./$DeployType
cp -R ../artifacts/.env.f1 ./$DeployType

cd ./$DeployType

if [[ -v TargetServer ]]; then
	echo "Deploy Remotely !!"
	#docker-compose --context $DockerContext up -d
	docker-compose -H "ssh://$Username@$TargetServer" up --build
else
	echo "Deploy Locally !!"
	docker-compose --env-file ./.env.f1 up
fi