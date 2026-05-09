# Tell BitBake to look for files (config fragments, etc.) here
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Inherit externalsrc here so EXTERNALSRC:pn-linux-stm32mp in local.conf
# (pointing at /home/aford/src/beacon/linux-stm32) is honored. No-op if
# EXTERNALSRC isn't set. Re-add do_patch as a noop because externalsrc.bbclass
# deletes it, and downstream recipes (e.g. usbip) declare a dependency on
# virtual/kernel:do_patch.
inherit externalsrc

python() {
    if d.getVar('EXTERNALSRC'):
        bb.build.addtask('do_patch', 'do_configure', 'do_unpack', d)
        d.setVarFlag('do_patch', 'noexec', '1')
}

# DEC-specific kernel config additions (panels, MAX25221, RTCs, debug aids).
KERNEL_CONFIG_FRAGMENTS:append:stm32mp2common = " ${WORKDIR}/fragments/features/${LINUX_VERSION}/dec_kernel_config_mods.config "

SRC_URI += "file://${LINUX_VERSION}/dec_kernel_config_mods.config;subdir=fragments/features \
            file://fragment.cfg \
            "

SRC_URI:class-devupstream += " file://${LINUX_VERSION}/dec_kernel_config_mods.config;subdir=fragments/features "
