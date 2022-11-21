FROM nvcr.io/nvidia/l4t-ml:r35.1.0-py3

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

RUN mkdir ros_catkin_ws && \
    cd ros_catkin_ws && \
    rosinstall_generator ros_base vision_msgs --rosdistro noetic --deps --tar > noetic-ros_base.rosinstall && \
    mkdir src && \
    vcs import --input noetic-ros_base.rosinstall ./src && \
    apt-get update && \
    rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -DPYTHON_EXECUTABLE=/usr/bin/python3 --skip-keys python3-pykdl -y && \
    python3 ./src/catkin/bin/catkin_make_isolated --install --install-space /opt/ros/noetic -DCMAKE_BUILD_TYPE=Release && \
    rm -rf /var/lib/apt/lists/*


RUN python3 -m pip install -U pip && \
    python3 -m pip install --extra-index-url https://artifacts.luxonis.com/artifactory/luxonis-python-snapshot-local/ depthai

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