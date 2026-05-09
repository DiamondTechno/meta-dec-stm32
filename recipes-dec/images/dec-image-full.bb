SUMMARY = "Diamond Technologies STM32MP25 DEC Kit full image"
DESCRIPTION = "Wayland/Weston image (built on core-image-weston) plus \
ST OpenSTLinux framework packagegroups, full developer tooling, and \
NXP IW610 wifi/BT support pulled in at the machine level. Intended as \
the everyday development + bring-up image for the DEC kit."

LICENSE = "MIT"

# Start from upstream core-image-weston and layer our additions on top.
# core-image-weston already provides: splash, package-management,
# hwcodecs, weston, ssh-server-dropbear (we swap to openssh below),
# gtk+3-demo, and the basic Wayland stack.
require recipes-graphics/images/core-image-weston.bb

# Drop dropbear in favor of openssh (richer feature set, sftp, etc.)
IMAGE_FEATURES:remove = "ssh-server-dropbear"

IMAGE_FEATURES += " \
    ssh-server-openssh    \
    tools-debug           \
    tools-profile         \
    tools-sdk             \
    eclipse-debug         \
    allow-empty-password  \
    empty-root-password   \
    post-install-logging  \
    allow-root-login      \
    "

# We do NOT include 'debug-tweaks' (which would re-add
# serial-autologin-root). The granular features above give us the
# passwordless login without the auto-login. Combined with the
# meta-dec-stm32 systemd-serialgetty bbappend, that gets us a proper
# "<host> login:" prompt.

REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_LINGUAS ?= "en-us"

# ST OpenSTLinux framework + dev tools.
# IW610 WLAN driver and firmware come in at the machine level
# (IMAGE_INSTALL:append in stm32mp25-dec-kit.conf) — no need to list
# them here.
IMAGE_INSTALL:append = " \
    \
    resize-helper                       \
    st-hostname                         \
    \
    packagegroup-framework-core-base    \
    packagegroup-framework-tools-base   \
    packagegroup-framework-core         \
    packagegroup-framework-tools        \
    packagegroup-framework-core-extra   \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-core', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'optee', 'packagegroup-optee-test', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'tpm2',  'packagegroup-security-tpm2', '', d)} \
    \
    packagegroup-st-demo                \
    \
    packagegroup-core-tools-debug       \
    packagegroup-core-tools-profile     \
    packagegroup-core-buildessential    \
    \
    curl                                \
    util-linux util-linux-lsblk         \
    iperf3                              \
    can-utils                           \
    i2c-tools                           \
    ppp modemmanager                    \
    u-boot-fw-utils                     \
    mosquitto                           \
    libiio libiio-tests                 \
    tmux mc vim git                     \
    dtc                                 \
    libp11 opensc openssl-bin           \
    net-tools                           \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'connman', \
        'connman-tools connman-tests connman-client', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'networkmanager', \
        'networkmanager networkmanager-nmcli', '', d)} \
    \
    kernel-modules                      \
    kernel-devsrc                       \
    "

# Cap rootfs size — keeps the wic / .raw layouts from being surprised
# by an image that's grown past the partition allocation.
IMAGE_ROOTFS_MAXSIZE = "2097152"
