# Install /etc/fw_env.config so the userspace fw_printenv / fw_setenv
# tools can read and modify the u-boot environment from Linux. Without
# this file those tools fail with "Cannot parse config file: No such file
# or directory". The config matches the cargt setup: env lives in the
# u-boot-env GPT partition, two redundant 8 KiB copies at the tail.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:class-target = " file://fw_env.config"

do_install:append:class-target() {
    install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}
}

FILES:${PN}:append:class-target = " ${sysconfdir}"
