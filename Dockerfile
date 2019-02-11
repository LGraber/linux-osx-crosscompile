# Check http://releases.llvm.org/download.html#7.0.1 for the latest available binaries
FROM ubuntu:18.04

# Make sure the image is updated, install some prerequisites,
RUN apt-get update && apt-get install -y xz-utils build-essential curl libxml2-dev git automake libtool uuid-dev libssl1.0-dev  && rm -rf /var/lib/apt/lists/*

# We update bashrc for now just for testing

# Install clang from tar and setup bashrc
RUN curl -SL http://releases.llvm.org/7.0.1/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz | tar -xJC . \
    && mv clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04 clang \
    && echo '# Setting up clang' >> ~/.bashrc \
    && echo 'export PATH=/clang/bin:$PATH' >> ~/.bashrc \
    && echo 'export LD_LIBRARY_PATH=/clang/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

ENV PATH=/clang/bin:$PATH
ENV LD_LIBRARY_PATH=/clang/lib:$LD_LIBRARY_PATH

# Install cmake from tar
RUN curl -SL https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.tar.gz | tar -xvz \
    && mv cmake-3.13.4-Linux-x86_64 cmake \
    && echo '# Setting up cmake' >> ~/.bashrc \
    && echo 'export PATH=/cmake/bin:$PATH' >> ~/.bashrc

ENV PATH=/cmake/bin:$PATH

# ---------------------------
# MacOS Cross Toolchain
# ---------------------------

# Cache busting, due to git ????
ARG CACHE_BUSTER=okay

# Clone the osxcross toolchain github repo
RUN git clone https://github.com/tpoechtrager/osxcross /osxcross

ENV LD_LIBRARY_PATH=osxcross/target/lib:$LD_LIBRARY_PATH

# Clone and build libtapi
RUN git clone https://github.com/tpoechtrager/apple-libtapi.git /tmp/tapi && \
    cd /tmp/tapi && \
    INSTALLPREFIX=/osxcross/target ./build.sh && \
    ./install.sh && \
    cd / && \
    rm -rf /tmp/tapi

# Clone and build cctools
RUN git clone https://github.com/tpoechtrager/cctools-port.git /tmp/cctools && \
    cd /tmp/cctools/cctools && \
    ./configure --prefix=/osxcross/target --target=x86_64-apple-darwin18 --with-libtapi=/osxcross/target && \
    make -j8 && \
    make install && \
    cd / && \
    rm -rf /tmp/cctools
    
# Start from a Bash prompt
CMD [ "/bin/bash" ]
