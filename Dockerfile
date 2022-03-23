#
# this dockerfile roughly follows the 'Installing from source' from:
#   http://wiki.ros.org/noetic/Installation/Source
#
ARG BASE_IMAGE=dustynv/ros:noetic-ros-base-l4t-r32.6.1
FROM ${BASE_IMAGE}





# install OpenCV (with CUDA)

ARG OPENCV_URL=https://nvidia.box.com/shared/static/5v89u6g5rb62fpz4lh0rz531ajo2t5ef.gz
ARG OPENCV_DEB=OpenCV-4.5.0-aarch64.tar.gz

RUN mkdir opencv && \
    cd opencv && \
    wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate ${OPENCV_URL} -O ${OPENCV_DEB} && \
    tar -xzvf ${OPENCV_DEB} && \
    dpkg -i --force-depends *.deb && \
    apt-get update && \
    apt-get install -y -f --no-install-recommends && \
    dpkg -i *.deb && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    cd ../ && \
    rm -rf opencv



#This environment variable is needed to use the streaming features on Jetson inside a container
ENV LOGNAME root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y && apt-get install --no-install-recommends lsb-release wget less udev sudo apt-transport-https -y && \
    echo "# R32 (release), REVISION: 6.1" > /etc/nv_tegra_release ; \
    wget -q --no-check-certificate -O ZED_SDK_Linux_JP.run https://download.stereolabs.com/zedsdk/3.7/jp46/jetsons && \
    chmod +x ZED_SDK_Linux_JP.run ; ./ZED_SDK_Linux_JP.run silent skip_tools && \
    rm -rf /usr/local/zed/resources/* \
    rm -rf ZED_SDK_Linux_JP.run && \
    rm -rf /var/lib/apt/lists/*

# ZED Python API
RUN apt-get update -y && apt-get install --no-install-recommends python3 python3-pip python3-dev python3-setuptools build-essential python3-numpy -y && \
    wget download.stereolabs.com/zedsdk/pyzed -O /usr/local/zed/get_python_api.py && \
    python3 /usr/local/zed/get_python_api.py && \
    python3 -m pip install cython wheel && \
    python3 -m pip install pyopengl *.whl && \
    apt-get remove --purge build-essential -y && apt-get autoremove -y && \
    rm *.whl ; rm -rf /var/lib/apt/lists/*

#This symbolic link is needed to use the streaming features on Jetson inside a container
RUN ln -sf /usr/lib/aarch64-linux-gnu/tegra/libv4l2.so.0 /usr/lib/aarch64-linux-gnu/libv4l2.so

# install ROS Dependencies for ZED and TAUV Packages
RUN apt-get update -y && apt-get install --no-install-recommends build-essential -y
RUN mkdir ros_core_pkg_ws && \
    cd ros_core_pkg_ws && \
    rosinstall_generator usb_cam nav_msgs tf2_geometry_msgs message_runtime catkin roscpp stereo_msgs rosconsole robot_state_publisher urdf sensor_msgs image_transport roslint diagnostic_updater dynamic_reconfigure tf2_ros message_generation nodelet xacro robot_localization vision_msgs jsk_recognition_msgs actionlib class_loader common_msgs gencpp geneus genlisp genmsg gennodejs genpy message_generation message_runtime pluginlib python_qt_binding qt_gui_core ros_comm rqt rqt_console rqt_logger_level rqt_reconfigure --rosdistro noetic --deps --tar > ZED.rosinstall && \
    mkdir src && \
    vcs import --input ZED.rosinstall ./src && \
    apt-get update && \
    rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic --skip-keys python3-pykdl -y && \
    pip3 install catkin_tools && \
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DBOOST_THREAD_INTERNAL_CLOCK_IS_MONO=True && \
    catkin config --install --install-space /opt/tauv/packages && \
    catkin build && \
    rm -rf /var/lib/apt/lists/* && \ 
    cd ../ 


WORKDIR /workspace
SHELL ["/bin/bash", "-c"] 

RUN pip3 install --upgrade pip && \ 
    pip3 install scipy pyserial bitstring smbus2 grpcio-tools


RUN sudo apt-get update && apt-get install libusb-1.0-0-dev -y 

RUN source /opt/tauv/packages/setup.bash && \
    mkdir -p zed_ros_ws/src && \
    cd zed_ros_ws/src && \ 
    git clone --recursive https://github.com/stereolabs/zed-ros-wrapper.git && \
    cd ../ && \ 
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DBOOST_THREAD_INTERNAL_CLOCK_IS_MONO=True && \
    catkin config --install --install-space /opt/tauv/packages && \
    catkin build && \ 
    source ./devel/setup.bash

RUN source /opt/tauv/packages/setup.bash && \
    mkdir -p tauv_ws/src && \
    cd tauv_ws/src && \
    git clone --recurse-submodules https://github.com/Tartan-AUV/TAUV-ROS-Packages && \
    cd TAUV-ROS-Packages && \
    git checkout kingfisher_deploy && \
    cd ../../ && \
    catkin build && \
    source ./devel/setup.bash
#  setup entrypoint

COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash' >> /root/.bashrc
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /
