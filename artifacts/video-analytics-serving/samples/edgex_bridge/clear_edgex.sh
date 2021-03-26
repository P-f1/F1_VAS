read -r -p "This will DESTROY all EdgeX data and metadata. Are you sure? [y/N] " response

# Fetch EdgeX launch instructions
cd $VAS_SOURCE/edgex
EDGEX_DIR_REPO_DEVELOPER_SCRIPTS="./developer-scripts/"
if rm -Rf "$EDGEX_DIR_REPO_DEVELOPER_SCRIPTS"; then
    if git clone -b v1.3.1 https://github.com/edgexfoundry/developer-scripts.git $EDGEX_DIR_REPO_DEVELOPER_SCRIPTS; then
        cd "./$EDGEX_DIR_REPO_DEVELOPER_SCRIPTS/compose-builder/"
        if make compose no-secty mqtt-broker ds-mqtt ; then
            cp ../releases/hanoi/compose-files/docker-compose-hanoi-no-secty-mqtt.yml $VAS_SOURCE/edgex/docker-compose.yml
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
