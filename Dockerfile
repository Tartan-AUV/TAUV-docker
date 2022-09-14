FROM nvidia/cudagl:11.1.1-base-ubuntu20.04

# Minimal setup
RUN apt-get update \
    && apt-get install -y locales lsb-release
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg-reconfigure locales

# Install ROS Noetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update \
    && apt-get install -y --no-install-recommends ros-noetic-desktop-full
RUN apt-get install -y --no-install-recommends python3-rosdep
RUN rosdep init \
    && rosdep fix-permissions \
    && rosdep update
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]

# Install Git
RUN apt-get update && apt-get install -y git

# Install CV brdige
RUN apt-get update && apt-get install -y ros-noetic-cv-bridge ros-noetic-vision-opencv

# Install Zed Ros Wrapper
RUN source /opt/ros/noetic/setup.bash \
    mkdir -p zed_ros_ws/src && \
    cd zed_ros_ws/src && \ 
    git clone --recursive https://github.com/stereolabs/zed-ros-wrapper.git && \
    cd ../ && \
    rosdep install --from-paths src --ignore-src -r -y && \
    catkin_make -DCMAKE_BUILD_TYPE=Release && \
    source ./devel/setup.bash

# Install Darkenet Ros
RUN source /opt/ros/noetic/setup.bash \
    mkdir -p darknet_ws/src && \
    cd darknet_ws/src && \
    git clone --recursive git@github.com:leggedrobotics/darknet_ros.git && \
    cd ../ && \
    catkin_make -DCMAKE_BUILD_TYPE=Release


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