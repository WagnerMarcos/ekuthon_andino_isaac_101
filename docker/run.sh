#!/usr/bin/env bash

set -e

# Allow X11 clients from any host (required for GUI apps in Docker)
sudo xhost +

# Always run from the directory where this script is located (docker/)
SCRIPT_NAME="$(readlink -f "$0")"
cd "$(dirname "$SCRIPT_NAME")"

mkdir -p ./isaac-sim-cache/cache/main
mkdir -p ./isaac-sim-cache/cache/computecache
mkdir -p ./isaac-sim-cache/logs
mkdir -p ./isaac-sim-cache/config
mkdir -p ./isaac-sim-cache/data
mkdir -p ./isaac-sim-cache/pkg

BUILD=""
BUILD_KIT=""
WORLD_NAME="plain_world.usda"
ROBOT_NAME="andino.usda"

# ---------------------------------------------------------------------
# Parse CLI arguments
#  --build / -b      → docker compose run --build
#  --buildkit / -k   → enable DOCKER_BUILDKIT=1
#  --world <file>    → world USD(A) file in isaac_worlds
#  --robot <file>    → robot USD(A) file in andino_isaac_description
# ---------------------------------------------------------------------
while [ "$#" -gt 0 ]; do
    ARG="$1"

    if [ "$ARG" = "--build" ] || [ "$ARG" = "-b" ]; then
        BUILD="--build"
        shift

    elif [ "$ARG" = "--buildkit" ] || [ "$ARG" = "-k" ]; then
        BUILD="--build"
        BUILD_KIT="1"
        shift

    elif [ "$ARG" = "--world" ]; then
        WORLD_NAME="$2"
        shift 2

    elif [ "$ARG" = "--robot" ]; then
        ROBOT_NAME="$2"
        shift 2

    else
        echo "UNKNOWN ARGUMENT: $ARG"
        exit 1
    fi
done

PATH_TO_WORLD_DIR="./src/andino_isaac/isaac_worlds/"
PATH_TO_ROBOT_DIR="./src/andino_isaac/andino_isaac_description/"
WORLD_PATH="${PATH_TO_WORLD_DIR}${WORLD_NAME}"
ROBOT_PATH="${PATH_TO_ROBOT_DIR}${ROBOT_NAME}"

# Enable BuildKit for docker builds if requested
if [ -n "$BUILD_KIT" ]; then
    export DOCKER_BUILDKIT=1
fi

LOCAL_UID=$(id -u)
LOCAL_GID=$(id -g)
export LOCAL_UID LOCAL_GID

# Run the container, passing world/robot to the container as env vars
docker compose run ${BUILD} --rm --remove-orphans \
    -e WORLD_FILE="${WORLD_PATH}" \
    -e ROBOT_FILE="${ROBOT_PATH}" \
    andino_isaac
