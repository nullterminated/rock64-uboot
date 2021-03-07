#Build using something like
#docker build -t uboot:`date +%Y-%m-%d` .
#must be done on an aarch64 system presently
#once complete, start a container with the image and copy the build products, like
#docker cp 8af311ee2236:/u-boot/idbloader.img .
#docker cp 8af311ee2236:/u-boot/u-boot.itb .
#where 8af311ee2236 is the container id
FROM debian:10.4
ARG ATF_VERSION=v2.4
ARG UBOOT_VERSION=v2021.01
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y build-essential git gcc-arm-none-eabi device-tree-compiler bison flex swig python3 python3-distutils python3-dev
RUN git clone https://github.com/ARM-software/arm-trusted-firmware.git
WORKDIR /arm-trusted-firmware
RUN git fetch --tags; \
    git checkout $ATF_VERSION;
#Remove any blobs
RUN find . -name '*.bin' -exec rm -rf {} \;
RUN make PLAT=rk3328
WORKDIR /
ENV BL31=/arm-trusted-firmware/build/rk3328/release/bl31/bl31.elf
#This place is slow, using github mirror instead
#RUN git clone https://gitlab.denx.de/u-boot/u-boot.git/
RUN git clone https://github.com/u-boot/u-boot.git
WORKDIR /u-boot
RUN git fetch --tags; \
    git checkout $UBOOT_VERSION;
RUN make rock64-rk3328_defconfig
RUN sed -i 's/CONFIG_IDENT_STRING=""/CONFIG_IDENT_STRING="Arch Linux ARM"/' .config
RUN make

