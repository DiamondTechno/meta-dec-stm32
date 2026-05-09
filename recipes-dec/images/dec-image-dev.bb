SUMMARY = "Diamond Technologies STM32MP25 DEC Kit development image (Wayland/Weston)."
LICENSE = "Proprietary"

include recipes-st/images/st-image.inc

inherit core-image features_check

REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_LINGUAS = "en-us"

IMAGE_FEATURES += "\
    splash              \
    package-management  \
    ssh-server-openssh  \
    hwcodecs            \
    tools-profile       \
    eclipse-debug       \
    debug-tweaks        \
    tools-debug         \
    tools-sdk           \
    "

# DEC-specific WLAN packages (NXP IW610 path used on the 00395 SOM)
DEC_WLAN_PACKAGES = "kernel-module-nxp-wlan nxp-wlan-firmware-nxp-common nxp-wlan-firmware-nxpiw610-sdio"

CORE_IMAGE_EXTRA_INSTALL += " \
    resize-helper \
    st-hostname \
    \
    packagegroup-framework-core-base    \
    packagegroup-framework-tools-base   \
    \
    packagegroup-framework-core         \
    packagegroup-framework-tools        \
    \
    packagegroup-framework-core-extra   \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-core', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-test', '', d)} \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'tpm2', 'packagegroup-security-tpm2', '', d)} \
    \
    packagegroup-st-demo \
    \
    curl \
    util-linux \
    util-linux-lsblk \
    iperf3 \
    can-utils \
    i2c-tools \
    ppp modemmanager \
    u-boot-fw-utils \
    mosquitto \
    libiio-tests \
    tmux \
    mc \
    vim \
    git \
    ${@bb.utils.contains('DISTRO_FEATURES', 'connman', 'connman-tools connman-tests connman-client', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'networkmanager', 'networkmanager networkmanager-nmcli', '', d)} \
    dtc \
    libiio libiio-tests \
    libp11 opensc openssl-bin \
    net-tools \
    packagegroup-core-tools-debug \
    packagegroup-core-tools-profile \
    packagegroup-core-buildessential \
    ${DEC_WLAN_PACKAGES} \
    kernel-modules \
    kernel-devsrc \
    "

IMAGE_ROOTFS_MAXSIZE = "2097152"
