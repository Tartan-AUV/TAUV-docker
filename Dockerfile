FROM dustynv/ros:noetic-pytorch-l4t-r35.1.0

WORKDIR /workspace

RUN python3 -m pip install -U pip && \
    python3 -m pip install --extra-index-url https://artifacts.luxonis.com/artifactory/luxonis-python-snapshot-local/ depthai

RUN source /opt/tauv/packages/setup.bash && \
    mkdir -p darknet_ws/src && \
    cd darknet_ws/src && \
    git clone --recursive https://github.com/leggedrobotics/darknet_ros && \
    cd ../ && \ 
    catkin build darknet_ros -DCMAKE_BUILD_TYPE=Release && \
    source /opt/tauv/packages/setup.bash

COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
WORKDIR /