# Check http://releases.llvm.org/download.html#7.0.1 for the latest available binaries
FROM ubuntu:18.04 as base

# Make sure the image is updated, install some prerequisites,
RUN apt-get update && apt-get install -y xz-utils build-essential curl libxml2-dev git automake libtool uuid-dev libssl1.0-dev  && rm -rf /var/lib/apt/lists/*

# Install clang from tar and setup bashrc
RUN curl -SL http://releases.llvm.org/7.0.1/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz | tar -xJC . \
    && mv clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04 clang

# Install cmake from tar
RUN curl -SL https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.tar.gz | tar -xvz \
    && mv cmake-3.13.4-Linux-x86_64 cmake 

# ---------------------------
# MacOS Cross Toolchain
# ---------------------------

# Cache busting, due to git ????
ARG CACHE_BUSTER=okay

# Clone the osxcross toolchain github repo
RUN git clone https://github.com/tpoechtrager/osxcross /osxcross

ENV PATH=/cmake/bin:/clang/bin:$PATH
ENV LD_LIBRARY_PATH=/clang/lib:osxcross/target/lib:$LD_LIBRARY_PATH

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

COPY add_links.sh /
RUN /add_links.sh /clang/bin llvm
RUN /add_links.sh /osxcross/target/bin x86_64-apple-darwin18
    
FROM ubuntu:18.04 as compile_base

COPY --from=base cmake /cmake
COPY --from=base clang /clang
COPY --from=base osxcross/target/ /cctools/

# Unpack the osx sdk
ADD sdks/12.tar.gz /xcode/

COPY apple-toolchain.cmake /cmake/toolchains/

ENV PATH=${PATH}:/cctools/bin:/cmake/bin:/clang/bin
ENV LD_LIBRARY_PATH=/clang/lib:/cctools/lib:${LD_LIBRARY_PATH}
ENV SDKROOT=/xcode/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk

# Start from a Bash prompt
CMD [ "/bin/bash" ]
