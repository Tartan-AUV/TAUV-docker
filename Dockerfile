FROM dustynv/ros:noetic-pytorch-l4t-r35.1.0

WORKDIR /workspace

RUN python3 -m pip install -U pip && \
    python3 -m pip install --extra-index-url https://artifacts.luxonis.com/artifactory/luxonis-python-snapshot-local/ depthai

# RUN mkdir -p darknet_ws/src && \
#     cd darknet_ws/src && \
#     git clone --recursive https://github.com/leggedrobotics/darknet_ros && \
#     cd ../ && \ 
#     catkin build darknet_ros -DCMAKE_BUILD_TYPE=Release

RUN git clone --recurse-submodules https://github.com/Tartan-AUV/TAUV-ROS-Packages.git && \
    sudo chmod 755 -R TAUV-ROS-Packages/

ARG CACHEBUST=1
RUN echo "$CACHEBUST"

RUN sudo apt update && apt install -y \
    python3-pip \
    python3-yaml \
    python3-numpy \
    python3-smbus \
    ros-noetic-gazebo-ros-control \
    ros-noetic-fkie-multimaster \
    ros-noetic-imu-transformer \
    ros-noetic-jsk-recognition-msgs \
    ros-noetic-vision-msgs \
    ros-noetic-phidgets-ik \
    ros-noetic-imu-filter-madgwick \
    libi2c-dev \
    ros-noetic-image-transport \
    ros-noetic-robot-localization \
    ros-noetic-xacro && \
    apt-get clean

# && \
#    cd /workspace/TAUV-ROS-Packages && \
#    sudo make deps

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /
