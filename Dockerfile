FROM dustynv/ros:noetic-pytorch-l4t-r35.1.0

WORKDIR /workspace

RUN python3 -m pip install -U pip && \
    python3 -m pip install --extra-index-url https://artifacts.luxonis.com/artifactory/luxonis-python-snapshot-local/ depthai

ARG CACHEBUST=1
RUN echo "$CACHEBUST"

RUN sudo apt update && apt install -y \
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
    ros-noetic-catkin \
    ros-noetic-xacro && \
    libboost-all-dev && \
    apt-get clean

RUN python3 -m pip install numpy scipy pyserial bitstring smbus2 grpcio-tools yaml osqp

RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list' && \
    wget http://packages.ros.org/ros.key -O - | sudo apt-key add - && \
    sudo apt-get update && \
    sudo apt-get install -y python3-catkin-tools

RUN mkdir -p darknet_ws/src && 
    cd darknet_ws/src && \
    git clone --recursive https://github.com/leggedrobotics/darknet_ros && \
    cd ../ && \ 
    catkin build darknet_ros -DCMAKE_BUILD_TYPE=Release

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /
