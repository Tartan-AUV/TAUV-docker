# FROM nvcr.io/nvidia/l4t-cuda:11.4.14-runtime

# RUN rm /etc/apt/sources.list.d/* && \
#     echo "deb https://repo.download.nvidia.com/jetson/common r35.1 main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
#     echo "deb https://repo.download.nvidia.com/jetson/t234 r35.1 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
FROM stereolabs/zed:3.7-tools-devel-jetson-jp5.0.2

WORKDIR /workspace

RUN apt update && \
    apt install -y --no-install-recommends \
    git \
    cmake \
    build-essential \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN apt update && \
    apt install -y --no-install-recommends \
    libpython3-dev \
    python3-rosdep \
    python3-rosinstall-generator \
    python3-vcstool \
    build-essential && \
    rosdep init && \
    rosdep update && \
    rm -rf /var/lib/apt/lists/*

RUN apt update && \
    apt install -y --no-install-recommends \
    ros-noetic-desktop-full \
    && rm -rf /var/lib/apt/lists/*


RUN python3 -m pip install cython

RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    unzip \
    yasm \
    pkg-config \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavformat-dev \
    libpq-dev \
    libxine2-dev \
    libglew-dev \
    libtiff5-dev \
    zlib1g-dev \
    libjpeg-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libpostproc-dev \
    libswscale-dev \
    libeigen3-dev \
    libtbb-dev \
    libgtk2.0-dev \
    pkg-config \
    python3-dev \
    python3-numpy \
    && rm -rf /var/lib/apt/lists/*


ARG OPENCV_VERSION=4.6.0


RUN cd /opt/ &&\
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip &&\
    unzip $OPENCV_VERSION.zip &&\
    rm $OPENCV_VERSION.zip &&\
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip &&\
    unzip ${OPENCV_VERSION}.zip &&\
    rm ${OPENCV_VERSION}.zip &&\
    mkdir /opt/opencv-${OPENCV_VERSION}/build && cd /opt/opencv-${OPENCV_VERSION}/build &&\
    cmake \
    -DOPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-${OPENCV_VERSION}/modules \
    -DWITH_CUDA=ON \
    -DCUDA_ARCH_BIN=7.5,8.0,8.6 \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    .. &&\
    make -j"$(nproc)" && \
    make install && \
    ldconfig && \
    rm -rf /opt/opencv-${OPENCV_VERSION} && rm -rf /opt/opencv_contrib-${OPENCV_VERSION}


RUN pip3 install --upgrade pip && \ 
    pip3 install scipy pyserial bitstring smbus2 grpcio-tools


RUN sudo apt-get update && apt-get install libusb-1.0-0-dev vim -y 

RUN xhost +si:localuser:root

RUN python3 -m pip install numpy

RUN python3 -m pip install opencv-python pyopengl

RUN python3 /usr/local/zed/get_python_api.py

RUN apt-get update -y && apt-get install --no-install-recommends build-essential -y
RUN mkdir ros_core_pkg_ws && \
    cd ros_core_pkg_ws && \
    rosinstall_generator usb_cam nav_msgs tf2_geometry_msgs message_runtime catkin roscpp stereo_msgs rosconsole robot_state_publisher urdf sensor_msgs image_transport roslint diagnostic_updater dynamic_reconfigure tf2_ros message_generation nodelet xacro robot_localization vision_msgs jsk_recognition_msgs actionlib class_loader common_msgs gencpp geneus genlisp genmsg gennodejs genpy message_generation message_runtime pluginlib python_qt_binding qt_gui_core ros_comm rqt rqt_console rqt_logger_level rqt_reconfigure image_transport --rosdistro noetic --deps --tar > ZED.rosinstall && \
    mkdir src && \
    vcs import --input ZED.rosinstall ./src && \
    apt-get update && \
    rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic --skip-keys python3-pykdl --skip-keys libopencv-dev -y && \
    pip3 install catkin_tools && \
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DBOOST_THREAD_INTERNAL_CLOCK_IS_MONO=True && \
    catkin config --install --install-space /opt/tauv/packages && \
    catkin build && \
    rm -rf /var/lib/apt/lists/* && \ 
    cd ../ 

RUN source /opt/tauv/packages/setup.bash && \
    mkdir -p zed_ros_ws/src && \
    cd zed_ros_ws/src && \ 
    git clone --recursive https://github.com/stereolabs/zed-ros-wrapper.git && \
    cd ../ && \
    rosdep install --from-paths src --ignore-src -r -y && \
    catkin_make -DCMAKE_BUILD_TYPE=Release && \
    source ./devel/setup.bash

RUN source /opt/tauv/packages/setup.bash && \
    mkdir -p darknet_ws/src && \
    darknet_ws/src && \
    git clone --recursive git@github.com:leggedrobotics/darknet_ros.git && \
    cd ../ && \
    catkin_make -DCMAKE_BUILD_TYPE=Release


COPY ./packages/ros_entrypoint.sh /ros_entrypoint.sh
RUN echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
WORKDIR /