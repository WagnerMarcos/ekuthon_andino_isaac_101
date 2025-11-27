#!/usr/bin/env bash

sudo xhost +

mkdir -p ./docker/isaac-sim/cache/main
mkdir -p ./docker/isaac-sim/cache/computecache
mkdir -p ./docker/isaac-sim/logs
mkdir -p ./docker/isaac-sim/config
mkdir -p ./docker/isaac-sim/data
mkdir -p ./docker/isaac-sim/pkg

declare SCRIPT_NAME=$(readlink -f ${BASH_SOURCE[0]})
cd $(dirname $SCRIPT_NAME)

BUILD=""
BUILD_KIT=""

if [[ ! -z "$1" ]]; then
    if [[ "$1" == "--build" || "$1" == "-b" ]]; then
        BUILD="--build"
    elif [[ "$1" == "--buildkit" || "$1" == "-k" ]]; then
        BUILD="--build"
        BUILD_KIT="DOCKER_BUILDKIT=1"    
    else
        echo "Unknown argument ${1}"
        exit 1
    fi
fi

LOCAL_UID=$(id -u) LOCAL_GID=$(id -g) env ${BUILD_KIT} docker compose run ${BUILD} --rm --remove-orphans andino_isaac
