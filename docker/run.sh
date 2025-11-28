#!/usr/bin/env bash

set -e

# Allow X11 clients from any host (required for GUI apps in Docker)
sudo xhost +

mkdir -p ./docker/isaac-sim/cache/main
mkdir -p ./docker/isaac-sim/cache/computecache
mkdir -p ./docker/isaac-sim/logs
mkdir -p ./docker/isaac-sim/config
mkdir -p ./docker/isaac-sim/data
mkdir -p ./docker/isaac-sim/pkg

# Always run from the directory where this script is located (docker/)
SCRIPT_NAME="$(readlink -f "$0")"
cd "$(dirname "$SCRIPT_NAME")"

BUILD=""
BUILD_KIT=""
WORLD_NAME=""
ROBOT_NAME=""

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

WORLD_PATH=""
ROBOT_PATH=""

# If a world name is provided, map it to the isaac_worlds directory
if [ -n "$WORLD_NAME" ]; then
    WORLD_PATH="./src/andino_isaac/isaac_worlds/${WORLD_NAME}"
fi

# If a robot name is provided, map it to the description directory
if [ -n "$ROBOT_NAME" ]; then
    ROBOT_PATH="./src/andino_isaac/andino_isaac_description/${ROBOT_NAME}"
fi

# Enable BuildKit for docker builds if requested
if [ -n "$BUILD_KIT" ]; then
    export DOCKER_BUILDKIT=1
fi

# Run the container, passing world/robot to the container as env vars
docker compose run ${BUILD} --rm --remove-orphans \
    -e WORLD_FILE="${WORLD_PATH}" \
    -e ROBOT_FILE="${ROBOT_PATH}" \
    -e LOCAL_UID=$(id -u) \
    -e LOCAL_GID=$(id -g) \
    andino_isaac
