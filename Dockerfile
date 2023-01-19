FROM dustynv/ros:noetic-pytorch-l4t-r35.1.0

WORKDIR /workspace

RUN python3 -m pip install -U pip && \
    python3 -m pip install --extra-index-url https://artifacts.luxonis.com/artifactory/luxonis-python-snapshot-local/ depthai

# RUN mkdir -p darknet_ws/src && \
#     cd darknet_ws/src && \
#     git clone --recursive https://github.com/leggedrobotics/darknet_ros && \
#     cd ../ && \ 
#     catkin build darknet_ros -DCMAKE_BUILD_TYPE=Release

RUN git clone --recurse-submodules https://github.com/Tartan-AUV/TAUV-ROS-Packages.git && \
    sudo chmod 755 -R TAUV-ROS-Packages/

ARG CACHEBUST=1
RUN echo "$CACHEBUST" && \
    cd /workspace/TAUV-ROS-Packages && \
    sudo make deps

CMD ["bash"]
WORKDIR /
