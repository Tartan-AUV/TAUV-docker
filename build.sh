#!/bin/bash

docker build --file platform/Dockerfile.x86-nvidia --tag tauv/x86-nvidia-platform .
docker build --build-arg BASE_IMAGE=tauv/x86-nvidia-platform --file common/Dockerfile.common --tag tauv/x86-nvidia-common .

read -sp "Enter the password for the Docker user: " PASSWORD
echo
read -sp "Confirm the password: " PASSWORD_CONFIRM
echo
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Passwords do not match. Please try again."
    exit 1
fi

echo "Using user name $USER"

docker build --build-arg BASE_IMAGE=tauv/x86-nvidia-common --build-arg USER_NAME="$USER" --build-arg USER_PASSWORD="$PASSWORD" --file apps/Dockerfile.workstation --tag tauv/x86-nvidia-workstation .

echo -e "\n\n\nFinished building the workstation image.\nYour SSH port is 22$(id -u | rev | cut -c1-3 | rev)."

