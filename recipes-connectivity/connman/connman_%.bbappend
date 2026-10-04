# connman is the DEC network manager on STM32MP25. meta-st-openstlinux's
# connman bbappend assumes connman is installed but unused: it disables
# connman.service, drops connman's resolv.conf tmpfile and lowers its
# resolv-conf alternative below systemd's. Undo that so connman starts at
# boot and owns /etc/resolv.conf (connman 1.42 has no systemd-resolved
# backend, so its DNS servers only reach /run/connman/resolv.conf).

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://main.conf"

SYSTEMD_AUTO_ENABLE:${PN} = "enable"

ALTERNATIVE_PRIORITY[resolv-conf] = "100"

do_install:append() {
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${B}/scripts/connman_resolvconf.conf ${D}${sysconfdir}/tmpfiles.d/

    install -d ${D}${sysconfdir}/connman
    install -m 0644 ${WORKDIR}/main.conf ${D}${sysconfdir}/connman/
}

CONFFILES:${PN} += "${sysconfdir}/connman/main.conf"
