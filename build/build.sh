#!/bin/bash

ProjectID=$1 
ServiceName=$2 
BuildFolder=$3 

echo "ProjectID = "$ProjectID
echo "ServiceName = "$ServiceName
echo "BuildFolder = "$BuildFolder
echo "EXT_HOME_DIR = " $EXT_HOME_DIR

pwd

cp -R ../artifacts/video-analytics-serving ./

docker run -i --rm \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving/tools:/home/video-analytics-serving/tools \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving/models_list:/models_yml \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving:/output \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving:/home/video-analytics-serving/ \
	-v /tmp:/tmp -v /dev:/dev \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving/models:/home/video-analytics-serving/models \
	-v $EXT_HOME_DIR/projects/F1_VAS/build/video-analytics-serving/pipelines/gstreamer:/home/video-analytics-serving/pipelines \
	--network=host \
	--name openvino_ubuntu18_data_dev_2021.1 \
	--privileged --user 0 openvino/ubuntu18_data_dev:2021.1 \
    /bin/bash -c "pip3 install -r /home/video-analytics-serving/tools/model_downloader/requirements.txt ; python3 -u /home/video-analytics-serving/tools/model_downloader --model-list /models_yml/models.list.yml --output /output"