#
# this dockerfile roughly follows the 'Installing from source' from:
#   http://wiki.ros.org/noetic/Installation/Source
#
ARG BASE_IMAGE=ros:noetic-perception
FROM ${BASE_IMAGE}









# Python and pip
RUN apt-get update -y && apt-get install --no-install-recommends python3 python3-pip python3-dev python3-setuptools build-essential python3-numpy -y


RUN pip3 install --upgrade pip && \ 
    pip3 install scipy pyserial bitstring smbus2 grpcio-tools


RUN sudo apt-get update && apt-get install libusb-1.0-0-dev vim iputils-ping -y 


WORKDIR /workspace
SHELL ["/bin/bash", "-c"] 




#  setup entrypoint

COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash' >> /root/.bashrc
RUN echo 'source /opt/tauv/packages/setup.bash' >> /root/.bashrc
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /
