# FROM nvcr.io/nvidia/l4t-ml:r35.1.0-py3

ARG BASE_IMAGE=nvcr.io/nvidia/l4t-base:r32.4.4
# ARG PYTORCH_IMAGE
# ARG TENSORFLOW_IMAGE

# FROM ${PYTORCH_IMAGE} as pytorch
# FROM ${TENSORFLOW_IMAGE} as tensorflow
FROM ${BASE_IMAGE}

#
# setup environment
#
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME="/usr/local/cuda"
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
ENV LLVM_CONFIG="/usr/bin/llvm-config-9"

ARG MAKEFLAGS=-j$(nproc) 
ARG PYTHON3_VERSION=3.11

RUN printenv


WORKDIR /workspace

#
# apt packages
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip \
    python3-dev \
    python3-matplotlib \
    build-essential \
    gfortran \
    git \
    cmake \
    curl \
    libopenblas-dev \
    liblapack-dev \
    libblas-dev \
    libhdf5-serial-dev \
    hdf5-tools \
    libhdf5-dev \
    zlib1g-dev \
    zip \
    libjpeg8-dev \
    libopenmpi3 \
    openmpi-bin \
    openmpi-common \
    protobuf-compiler \
    libprotoc-dev \
    llvm-9 \
    llvm-9-dev \
    libffi-dev \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


#
# pull protobuf-cpp from TF container
#
# ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp

# COPY --from=tensorflow /usr/local/bin/protoc /usr/local/bin
# COPY --from=tensorflow /usr/local/lib/libproto* /usr/local/lib/
# COPY --from=tensorflow /usr/local/include/google /usr/local/include/google


#
# python packages from TF/PyTorch containers
# note:  this is done in this order bc TF has some specific version dependencies
#
# COPY --from=pytorch /usr/local/lib/python2.7/dist-packages/ /usr/local/lib/python2.7/dist-packages/
# COPY --from=pytorch /usr/local/lib/python${PYTHON3_VERSION}/dist-packages/ /usr/local/lib/python${PYTHON3_VERSION}/dist-packages/

# COPY --from=tensorflow /usr/local/lib/python2.7/dist-packages/ /usr/local/lib/python2.7/dist-packages/
# COPY --from=tensorflow /usr/local/lib/python${PYTHON3_VERSION}/dist-packages/ /usr/local/lib/python${PYTHON3_VERSION}/dist-packages/


#
# python pip packages
#
RUN pip3 install --no-cache-dir --ignore-installed pybind11 
RUN pip3 install --no-cache-dir --verbose onnx
RUN pip3 install --no-cache-dir --verbose scipy
RUN pip3 install --no-cache-dir --verbose scikit-learn
RUN pip3 install --no-cache-dir --verbose pandas
RUN pip3 install --no-cache-dir --verbose pycuda
RUN pip3 install --no-cache-dir --verbose numba


#
# CuPy
#
ARG CUPY_VERSION=v11.3.0
ARG CUPY_NVCC_GENERATE_CODE="arch=compute_53,code=sm_53;arch=compute_62,code=sm_62;arch=compute_72,code=sm_72;arch=compute_87,code=sm_87"

RUN git clone -b ${CUPY_VERSION} --recursive https://github.com/cupy/cupy cupy && \
    cd cupy && \
    pip3 install --no-cache-dir fastrlock && \
    python3 setup.py install --verbose && \
    cd ../ && \
    rm -rf cupy


#
# PyCUDA
#
RUN pip3 uninstall -y pycuda
RUN pip3 install --no-cache-dir --verbose pycuda six


# 
# install OpenCV (with CUDA)
#
ARG OPENCV_URL=https://nvidia.box.com/shared/static/5v89u6g5rb62fpz4lh0rz531ajo2t5ef.gz
ARG OPENCV_DEB=OpenCV-4.5.4-aarch64.tar.gz

COPY scripts/opencv_install.sh /tmp/opencv_install.sh
RUN cd /tmp && ./opencv_install.sh ${OPENCV_URL} ${OPENCV_DEB}


#
# JupyterLab
#
# RUN pip3 install --no-cache-dir --verbose jupyter jupyterlab && \
#     pip3 install --no-cache-dir --verbose jupyterlab_widgets

# RUN jupyter lab --generate-config
# RUN python3 -c "from notebook.auth.security import set_password; set_password('nvidia', '/root/.jupyter/jupyter_notebook_config.json')"

# CMD /bin/bash -c "jupyter lab --ip 0.0.0.0 --port 8888 --allow-root &> /var/log/jupyter.log" & \
# 	echo "allow 10 sec for JupyterLab to start @ http://$(hostname -I | cut -d' ' -f1):8888 (password nvidia)" && \
# 	echo "JupterLab logging location:  /var/log/jupyter.log  (inside the container)" && \
# 	/bin/bash

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

# RUN mkdir ros_catkin_ws && \
#     cd ros_catkin_ws && \
#     rosinstall_generator ros_base vision_msgs --rosdistro noetic --deps --tar > noetic-ros_base.rosinstall && \
#     mkdir src && \
#     vcs import --input noetic-ros_base.rosinstall ./src && \
#     apt-get update && \
#     rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic --skip-keys python3-pykdl -y && \
#     python3 ./src/catkin/bin/catkin_make_isolated --install --install-space /opt/ros/noetic -DCMAKE_BUILD_TYPE=Release && \
#     rm -rf /var/lib/apt/lists/*
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ros-noetic-desktop-full \
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