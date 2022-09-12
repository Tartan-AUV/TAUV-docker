FROM ros:noetic

RUN apt-get update && apt-get install -y \
    rm -rf /var/lib/apt/lists/*

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

FROM stereolabs/zed:3.7-gl-devel-cuda11.4-ubuntu20.04

FROM daisukekobayashi/darknet:gpu-cv-cc86

RUN pip3 install simple_pid dataclasses osqp 

RUN apt-get install -y tmux vim
COPY ./.tmux.conf /root/.tmux.conf
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash' >> /root/.bashrc
RUN echo 'source /opt/tauv/packages/setup.bash' >> /root/.bashrc
RUN echo 'source /shared/tauv_ws/devel/setup.bash' >> /root/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /