FROM balenalib/raspberrypi3-debian-python:3.7-buster
# The balena base image for building apps on Raspberry Pi 3. 
# Raspbian Stretch required for piwheels support. https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/

RUN echo "BUILD MODULE: CameraCapture"

# Enforces cross-compilation through Quemu
RUN [ "cross-build-start" ]

# Update package index and install dependencies
RUN install_packages \
    #python3 \
    #python3-pip \
    #python3-dev \
    build-essential \
    libopenjp2-7-dev \
    zlib1g-dev \
    libatlas-base-dev \
    wget \
    libboost-python1.62.0 \
    curl \
    libcurl4-openssl-dev \
    libldap2-dev \
    libgtkmm-3.0-dev \
    libarchive-dev \
    libcurl4-openssl-dev \
    intltool

# Required for OpenCV
RUN install_packages \
    # Hierarchical Data Format
    libhdf5-dev libhdf5-serial-dev \
    # for image files
    libjpeg-dev libtiff5-dev libjasper-dev libpng-dev \
    # for video files
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    # for gui
    # libqt5-test libqtgui5 libqtwebkit5 libgtk2.0-dev \
    libqt5gui5 libgtk2.0-dev \
    # high def image processing
    libilmbase-dev libopenexr-dev

# Install Python packages
COPY /build/arm32v7-requirements.txt ./
RUN python -m ensurepip
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install --index-url=https://www.piwheels.org/simple -r arm32v7-requirements.txt

# Cleanup
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoremove

RUN [ "cross-build-end" ]  

ADD /app/ .

# Expose the port
EXPOSE 5012

ENTRYPOINT [ "python3", "-u", "./main.py" ]

