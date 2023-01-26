FROM ros:noetic-ros-core

WORKDIR /workspace
SHELL ["/bin/bash", "-c"] 

RUN sudo apt update && apt install -y \
    python3 \
    python3-scipy \
    python3-numpy

COPY ./ros_entrypoint.sh /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /
