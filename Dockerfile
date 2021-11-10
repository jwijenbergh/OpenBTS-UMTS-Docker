FROM ubuntu:bionic as base
# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    g++-5 \
    git \
    libortp-dev \
    libosip2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libtool-bin \
    libusb-1.0-0-dev \  
    libuhd-dev \
    uhd-host \
    libzmq3-dev \
    sqlite3 \
    wget \
    tmux \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /OpenBTS-UMTS

# Generate images for uhd
RUN /usr/lib/uhd/utils/uhd_images_downloader.py

# Clone git repository
RUN git clone https://github.com/RangeNetworks/OpenBTS-UMTS .

# Pin commit
RUN git checkout fd69fb2e64046d5362232085687420ec06cd4212

# Update and init submodules
RUN git submodule init && \
    git submodule update

# Build asn1c (see https://github.com/RangeNetworks/OpenBTS-UMTS/issues/7#issuecomment-304220895)
# Unpack and cd to dir for asn1c
RUN tar zxf asn1c-0.9.23.tar.gz && \
    cd vlm-asn1c-0959ffb && \
    ./configure && \
    make && \
    make install

# Build
RUN ./autogen.sh && \
    CC=gcc-5 CXX=g++-5 ./configure && \
    make -j8

# Install
RUN make install

RUN find / -iname openbts*

# Create log directory
RUN mkdir /var/log/OpenBTS-UMTS

# Copy transceiver
RUN cp /OpenBTS-UMTS/TransceiverUHD/transceiver .

# Read sqlite example
RUN sqlite3 /etc/OpenBTS/OpenBTS-UMTS.db ".read /etc/OpenBTS/OpenBTS-UMTS.example.sql"

# Install coredumper
WORKDIR /OpenBTS-UMTS/coredumper

RUN git clone https://github.com/anatol/google-coredumper.git .

RUN ./configure && make -j8 && make install

# Install subscriberRegistry
WORKDIR /OpenBTS-UMTS/subscriberRegistry

RUN git clone https://github.com/RangeNetworks/subscriberRegistry.git .

RUN git submodule init && git submodule update

RUN autoreconf -i && ./configure && make -j8

RUN make install

# Additional folder setup
RUN mkdir /var/lib/asterisk && mkdir /var/lib/asterisk/sqlite3dir

RUN cp apps/comp128 /OpenBTS-UMTS/ && cp apps/comp128 /OpenBTS-UMTS/apps && cp apps/comp128 /OpenBTS

WORKDIR /OpenBTS

ENTRYPOINT [ "sleep", "infinity" ]
