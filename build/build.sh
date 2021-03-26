#!/bin/bash

ProjectID=$1 
ServiceName=$2 
BuildFolder=$3 

echo "ProjectID = "$ProjectID
echo "ServiceName = "$ServiceName
echo "BuildFolder = "$BuildFolder
echo "EXT_HOME_DIR = " $EXT_HOME_DIR
echo "FRAMEWORK = " $FRAMEWORK

pwd

VAS_DIR=../artifacts/video-analytics-serving

./samples/edgex_bridge/fetch_edgex.sh