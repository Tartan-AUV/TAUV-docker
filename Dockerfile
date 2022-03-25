#
# this dockerfile roughly follows the 'Installing from source' from:
#   http://wiki.ros.org/noetic/Installation/Source
#
ARG BASE_IMAGE=tartanauv/tauvcontainer:base 
FROM ${BASE_IMAGE}



WORKDIR /workspace
SHELL ["/bin/bash", "-c"] 



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

RUN source /opt/tauv/packages/setup.bash && \
    mkdir -p darknet_ws/src && \
    cd darknet_ws/src && \
    git clone --recursive https://github.com/leggedrobotics/darknet_ros && \
    cd ../ && \ 
    rosinstall_generator cv_bridge --rosdistro noetic --tar > darknet.rosinstall && \ 
    vcs import --input darknet.rosinstall ./src && \ 
    sed -i 's/python37/python3/' src/vision_opencv/cv_bridge/CMakeLists.txt && \ 
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DBOOST_THREAD_INTERNAL_CLOCK_IS_MONO=True && \
    catkin config --install --install-space /opt/tauv/packages && \
    catkin build && \ 
    source /opt/tauv/packages/setup.bash

#  setup entrypoint

COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash' >> /root/.bashrc
RUN echo 'source /opt/tauv/packages/setup.bash' >> /root/.bashrc
RUN echo 'source /workspace/tauv_ws/devel/setup.bash' >> /root/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /
