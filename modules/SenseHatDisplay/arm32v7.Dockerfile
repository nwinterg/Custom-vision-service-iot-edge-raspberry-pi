FROM balenalib/raspberrypi3-debian-python:3.7
# The balena base image for building apps on Raspberry Pi 3. 
# Raspbian Stretch required for piwheels support. https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/

RUN echo "BUILD MODULE: SenseHatDisplay"

RUN [ "cross-build-start" ]

# Update package index and install python
RUN install_packages \
    python3 \
    python3-pip \
    python3-dev

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3    

# Install Python packages
COPY /build/arm32v7-requirements.txt ./
RUN python3 -m pip install --upgrade pip 
RUN python3 -m pip install --upgrade setuptools
RUN python3 -m pip install --index-url=https://www.piwheels.org/simple -r arm32v7-requirements.txt

# Needed by iothub_client
RUN install_packages \
    libboost-python1.74.0 \
    curl \
    libcurl4-openssl-dev

# Extra dependencies to use sense-hat on this distribution
RUN install_packages \
    libatlas-base-dev \
    libopenjp2-7 \
    libtiff-tools \
    i2c-tools \
    libxcb1

# Cleanup
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoremove

RUN [ "cross-build-end" ]

ADD /app/ .
ADD /build/ .

ENTRYPOINT ["python3","-u", "./main.py"]
