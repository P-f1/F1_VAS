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

ARTIFACTS_DIR=../artifacts
cp -R $ARTIFACTS_DIR/video-analytics-serving ./

DOCKERFILE_DIR=./video-analytics-serving/docker
ENVIRONMENT_FILE_LIST=

cp -f $DOCKERFILE_DIR/Dockerfile $DOCKERFILE_DIR/Dockerfile.env

docker run -i --rm \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving/tools:/home/video-analytics-serving/tools \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving/models_list:/models_yml \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving:/output \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving:/home/video-analytics-serving/ \
	-v /tmp:/tmp \
	-v /dev:/dev \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving/models:/home/video-analytics-serving/models \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving/pipelines/gstreamer:/home/video-analytics-serving/pipelines \
	--network=host \
	--name openvino_ubuntu18_data_dev_2021.1 \
	--privileged --user 0 openvino/ubuntu18_data_dev:2021.1 \
    /bin/bash -c "pip3 install -r /home/video-analytics-serving/tools/model_downloader/requirements.txt ; python3 -u /home/video-analytics-serving/tools/model_downloader --model-list /models_yml/models.list.yml --output /output"
    
ENVIRONMENT_FILE_LIST+="$DOCKERFILE_DIR/openvino_base_environment.txt "

pwd

if [ ! -z "$ENVIRONMENT_FILE_LIST" ]; then
    cat $ENVIRONMENT_FILE_LIST | grep -E '=' | tr '\n' ' ' | tr '\r' ' ' > $DOCKERFILE_DIR/final.env
    echo "  HOME=/home/video-analytics-serving " >> $DOCKERFILE_DIR/final.env
    echo "ENV " | cat - $DOCKERFILE_DIR/final.env | tr -d '\n' >> $DOCKERFILE_DIR/Dockerfile.env
fi

docker build -f ./video-analytics-serving/docker/Dockerfile.env \
	--network=host \
	--build-arg BASE=openvino/ubuntu18_runtime:2021.1 \
	--build-arg FRAMEWORK=$FRAMEWORK \
	--build-arg MODELS_PATH=models \
	--build-arg MODELS_COMMAND=copy_models \
	--build-arg PIPELINES_PATH=pipelines/$FRAMEWORK \
	--build-arg PIPELINES_COMMAND=copy_pipelines \
	--build-arg FINAL_STAGE=video-analytics-serving-service \
	-t video-analytics-serving-$FRAMEWORK \
	--target deploy ./video-analytics-serving
	
echo "FRAMEWORK="$FRAMEWORK > $ARTIFACTS_DIR/.env.f1