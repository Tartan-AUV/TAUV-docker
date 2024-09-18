#!/bin/bash

if [[ -z "${DOCKER_SHARED_DIR}" ]]; then
    mkdir -p $HOME/shared
    SHARED_DIR=$HOME/shared
else
    SHARED_DIR=$DOCKER_SHARED_DIR
fi

echo "Using shared folder: $SHARED_DIR"

echo "Starting container, SSH port 22$(id -u | rev | cut -c1-3 | rev)."

rocker --nvidia --x11 --privileged --port 22$(id -u | rev | cut -c1-3 | rev):22 --volume $SHARED_DIR:$SHARED_DIR -- tauv/x86-nvidia-workstation


