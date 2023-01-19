FROM dustynv/ros:noetic-pytorch-l4t-r35.1.0

WORKDIR /workspace

RUN python3 -m pip install -U pip && \
    python3 -m pip install --extra-index-url https://artifacts.luxonis.com/artifactory/luxonis-python-snapshot-local/ depthai

RUN mkdir -p darknet_ws/src && \
    cd darknet_ws/src && \
    git clone --recursive https://github.com/leggedrobotics/darknet_ros && \
    cd ../ && \ 
    catkin build darknet_ros -DCMAKE_BUILD_TYPE=Release

RUN git clone --recurse-submodules git@github.com:Tartan-AUV/TAUV-ROS-Packages.git

ARG CACHEBUST=1
WORKDIR /workspace/TAUV-ROS-Packages
RUN sudo make deps

CMD ["bash"]
WORKDIR /