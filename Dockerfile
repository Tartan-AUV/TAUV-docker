FROM dustynv/ros:noetic-pytorch-l4t-r35.1.0

WORKDIR /workspace

# This looks funky
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
    apt-get clean

RUN sudo apt-get clean && apt-get autoremove

RUN python3 -m pip install numpy scipy pyserial bitstring smbus2 grpcio-tools osqp

RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list' && \
    wget http://packages.ros.org/ros.key -O - | sudo apt-key add - && \
    sudo apt-get update && \
    sudo apt-get install -y python3-catkin-tools

RUN mkdir -p darknet_ws/src && \
    cd darknet_ws/src && \
    git clone --recursive https://github.com/Tartan-AUV/darknet_ros_orin.git darknet_ros

RUN mkdir -p cv_bridge_ws/src && \
    cd cv_bridge_ws/src && \
    git clone --recursive https://github.com/ros-perception/vision_opencv.git && \
    cd vision_opencv && \
    git checkout noetic

SHELL ["/bin/bash", "-c"] 

RUN cd cv_bridge_ws && \
    source /opt/ros/noetic/setup.bash && \
    catkin config --install --install-space /opt/tauv/packages && \
    catkin build cv_bridge -DCMAKE_BUILD_TYPE=Release && \
    source /opt/tauv/packages/setup.bash

RUN cd darknet_ws && \
    source /opt/ros/noetic/setup.bash && \
    source /opt/tauv/packages/setup.bash && \
    catkin config --install --install-space /opt/tauv/packages && \
    catkin build darknet_ros -DCMAKE_BUILD_TYPE=Release && \
    source /opt/tauv/packages/setup.bash

RUN sudo apt-get update -y

RUN sudo apt-get install -y tmux vim

# RUN echo "deb https://repo.download.nvidia.com/jetson/ffmpeg main main" |  sudo tee -a /etc/apt/sources.list && \
    # echo "deb-src https://repo.download.nvidia.com/jetson/ffmpeg main main" |  sudo tee -a /etc/apt/sources.list && \
    # sudo apt-get update -y && \
    # sudo apt-get install -y -o DPkg::options::="--force-overwrite" ffmpeg

RUN sudo apt-mark hold libopencv libopencv-core4.2 libopencv-dev && \ 
     sudo apt-get install -y \
     gstreamer1.0-tools \
     gstreamer1.0-alsa \
     gstreamer1.0-plugins-base \
     gstreamer1.0-plugins-good \
     gstreamer1.0-plugins-bad \
     gstreamer1.0-plugins-ugly \
     gstreamer1.0-libav

RUN sudo apt-get install -y \
     libgstreamer1.0-dev \
     libgstreamer-plugins-base1.0-dev \
     libgstreamer-plugins-good1.0-dev && \
     sudo apt-mark unhold libopencv libopencv-core4.2 libopencv-dev

RUN echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc
RUN echo 'source /opt/tauv/packages/setup.bash' >> /root/.bashrc
RUN echo 'source /shared/catkin_ws/devel/setup.bash' >> /root/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /
