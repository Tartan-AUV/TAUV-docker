#!/bin/bash

if [[ -z "${DOCKER_SHARED_DIR}" ]]; then
    mkdir -p $HOME/shared
    SHARED_DIR=$HOME/shared
else
    SHARED_DIR=$DOCKER_SHARED_DIR
fi

echo "Using shared folder: $SHARED_DIR"

echo "Starting container, VNC address: http://tauv-dev.lan.local.cmu.edu:60$(id -u | rev | cut -c1-3 | rev)."

rocker --nvidia --privileged --port 60$(id -u | rev | cut -c1-3 | rev):8080 --volume $SHARED_DIR:/shared --volume /dev/shm:/dev/shm -- tauv/x86-nvidia-workstation


