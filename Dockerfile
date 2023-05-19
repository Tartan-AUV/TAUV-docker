FROM ros:noetic-ros-core

WORKDIR /workspace
SHELL ["/bin/bash", "-c"]

RUN sudo apt update

RUN sudo apt install -y \
    python3 \
    python3-scipy \
    python3-numpy

RUN sudo apt install -y \
    tmux \
    vim \
    git \
    cmake \
    g++ \
    make \
    swig

RUN sudo apt install -y \
    libxml2 \
    libxml2-dev \
    bison \
    flex \
    libcdk5-dev \
    python3-setuptools \
    libgoogle-glog-dev

RUN sudo apt install -y \
    libaio-dev \
    libusb-1.0-0-dev \
    libserialport-dev \
    libavahi-client-dev

RUN git clone https://github.com/analogdevicesinc/libiio.git && \
    cd libiio && \
	mkdir build && \
	cd build && \
	cmake ../ -DWITH_SERIAL_BACKEND=ON -DWITH_NETWORK_BACKEND=OFF && \
	make && \
	sudo make install

RUN git clone https://github.com/analogdevicesinc/libm2k.git && \
	cd libm2k && \
	git checkout v0.6.0 && \
	mkdir build && \
	cd build && \
	cmake ../ && \
	make && \
	sudo make install

RUN sudo apt install -y ros-noetic-catkin

RUN sudo apt install -y wget

RUN sudo apt install -y python3-pip

RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list' && \
    wget http://packages.ros.org/ros.key -O - | sudo apt-key add - && \
    sudo apt update && \
    sudo apt install -y python3-catkin-tools

RUN pip3 install RPi.GPIO

RUN sudo apt install -y \
	ros-noetic-vision-msgs \
	ros-noetic-image-transport \
	ros-noetic-xacro \
	ros-noetic-jsk-recognition-msgs

RUN sudo apt install -y \
	ros-noetic-tf2 \
	ros-noetic-tf

RUN sudo apt install -y libyaml-cpp-dev

RUN sudo apt install -y libeigen3-dev

RUN sudo apt remove -y python3-scipy 

RUN pip3 install scipy

RUN echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc
RUN echo 'source /opt/tauv/packages/setup.bash' >> /root/.bashrc
RUN echo 'source /shared/tauv_ws/devel/setup.bash' >> /root/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
WORKDIR /
