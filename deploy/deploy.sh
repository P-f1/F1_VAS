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

################################
#       Build EdgeX Bridge
################################

cd ../artifacts/video-analytics-serving

pwd

./samples/edgex_bridge/fetch_edgex.sh

chmod -R a+wx ./edgex

################################
#         Deploy VAS
################################

cd ../../deploy

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
	docker-compose -H "ssh://$Username@$TargetServer" up
else
	echo "Deploy Locally !!"
	docker-compose up
fi
