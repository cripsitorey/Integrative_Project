FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    bison \
    flex \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    texinfo \
    libisl-dev \
    nasm \
    grub-pc-bin \
    grub-common \
    xorriso \
    mtools \
    wget \
    make \
    && rm -rf /var/lib/apt/lists/*

# Cross-compiler target and install prefix
ENV TARGET="x86_64-elf"
ENV PREFIX="/usr/local/cross"
ENV PATH="$PREFIX/bin:$PATH"

# Build binutils 2.41
ARG BINUTILS_VERSION=2.41
RUN wget -q https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz && \
    tar xf binutils-${BINUTILS_VERSION}.tar.gz && \
    mkdir build-binutils && \
    cd build-binutils && \
    ../binutils-${BINUTILS_VERSION}/configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --with-sysroot \
        --disable-nls \
        --disable-werror && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf binutils-${BINUTILS_VERSION} build-binutils binutils-${BINUTILS_VERSION}.tar.gz

# Build GCC 13.2.0 cross-compiler (C only, no headers)
ARG GCC_VERSION=13.2.0
RUN wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
    tar xf gcc-${GCC_VERSION}.tar.gz && \
    cd gcc-${GCC_VERSION} && \
    contrib/download_prerequisites && \
    cd .. && \
    mkdir build-gcc && \
    cd build-gcc && \
    ../gcc-${GCC_VERSION}/configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --disable-nls \
        --enable-languages=c \
        --without-headers && \
    make -j$(nproc) all-gcc && \
    make -j$(nproc) all-target-libgcc && \
    make install-gcc && \
    make install-target-libgcc && \
    cd .. && \
    rm -rf gcc-${GCC_VERSION} build-gcc gcc-${GCC_VERSION}.tar.gz

WORKDIR /root/kernel
