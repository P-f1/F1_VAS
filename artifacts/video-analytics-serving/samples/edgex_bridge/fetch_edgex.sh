# This script builds a docker-compose file for EdgeX
# and fetches a configuration template for device-mqtt-go.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VAS_SOURCE=$SCRIPT_DIR/../..
cd $VAS_SOURCE/edgex
echo "Working folder: $PWD"

# Fetch config template from published EdgeX device-mqtt-go docker image.
CONFIG_TARGET=$VAS_SOURCE/edgex/res/device-mqtt-go
mkdir -p $CONFIG_TARGET
docker create --rm --name dev_mqtt \
    -v $CONFIG_TARGET:/tmp \
    nexus3.edgexfoundry.org:10004/docker-device-mqtt-go:master \
    /bin/sh
docker cp dev_mqtt:/res/configuration.toml $VAS_SOURCE/edgex/res/device-mqtt-go/configuration.toml.edgex
docker rm -f dev_mqtt

# Fetch EdgeX launch instructions
cd $VAS_SOURCE/edgex
EDGEX_DIR_REPO_DEVELOPER_SCRIPTS="./developer-scripts/"
if rm -Rf "$EDGEX_DIR_REPO_DEVELOPER_SCRIPTS"; then
    if git clone -b v1.3.1 https://github.com/edgexfoundry/developer-scripts.git $EDGEX_DIR_REPO_DEVELOPER_SCRIPTS; then
        cd "./$EDGEX_DIR_REPO_DEVELOPER_SCRIPTS/compose-builder/"
        if make compose no-secty ds-mqtt; then
            cp ../releases/hanoi/compose-files/docker-compose-hanoi-no-secty.yml $VAS_SOURCE/edgex/docker-compose.yml
            echo "Successfully fetched repo and produced compose file."
            cd $VAS_SOURCE
        else
            echo "ERROR making EdgeX compose file!"
            exit $?
        fi
    else
        echo "ERROR cloning $EDGEX_DIR_REPO_DEVELOPER_SCRIPTS repo!"
        exit $?
    fi
else
    echo "ERROR removing existing $EDGEX_DIR_REPO_DEVELOPER_SCRIPTS folder!"
    exit $?
fi


#######################################################################
# Fetch EdgeX launch instructions
#cd $VAS_SOURCE/edgex
#git clone https://github.com/edgexfoundry/developer-scripts.git
#cd ./developer-scripts/releases/nightly-build/compose-files
#make run no-secty
#cp ../docker-compose-nexus-no-secty-mqtt.yml $VAS_SOURCE/edgex/docker-compose.yml
#cd $VAS_SOURCE

#echo "Next steps:"
#echo ./docker/build.sh
#echo ./docker/run.sh --dev
#echo python3 samples/edgex_bridge/edgex_bridge.py --topic object_events --generate
#echo "docker-compose up -d"
#echo python3 samples/edgex_bridge/edgex_bridge.py --topic object_events
