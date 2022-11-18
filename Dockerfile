FROM nvcr.io/nvidia/l4t-ml:r35.1.0-py3


# RUN rm /etc/apt/sources.list.d/* && \
#     echo "deb https://repo.download.nvidia.com/jetson/common r35.1 main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
#     echo "deb https://repo.download.nvidia.com/jetson/t234 r35.1 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
# FROM stereolabs/zed:3.7-tools-devel-jetson-jp5.0.2

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