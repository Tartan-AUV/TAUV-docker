#!/bin/bash

docker build --file platform/Dockerfile.x86-nvidia --tag tauv/x86-nvidia-platform .
docker build --build-arg BASE_IMAGE=tauv/x86-nvidia-platform --file common/Dockerfile.common --tag tauv/x86-nvidia-common .
docker build --build-arg BASE_IMAGE=tauv/x86-nvidia-common --file apps/Dockerfile.workstation --tag tauv/x86-nvidia-workstation .
