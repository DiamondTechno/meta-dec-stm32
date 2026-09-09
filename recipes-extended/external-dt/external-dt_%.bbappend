# Tell the upstream external-dt recipe where the DEC project tree lives
# (the DEC machine config sets DEC_EXTDT_PROJECT to dec-stm32mp25-kit
# and ENABLE_DEC_EXTDT to 1). This mirrors how meta-cargt-stm32mp-addons
# wires up its CubeMX project — minus the cargt branding.

EXTERNALSRC:stm32mpcommonmx = "${@bb.utils.contains('ENABLE_DEC_EXTDT', '1', '${STAGING_EXTDT_DIR}', '', d)}"
EXTERNALSRC_BUILD:stm32mpcommonmx = "${@bb.utils.contains('ENABLE_DEC_EXTDT', '1', '${STAGING_EXTDT_DIR}', '', d)}"

# Work around a stamp-sharing bug between externalsrc.bbclass and
# create-spdx-2.2.bbclass. externalsrc forces STAMP to a MACHINE-independent
# work-shared path whenever EXTERNALSRC is set, which it is for external-dt
# on every stm32mpcommonmx machine (see above). do_collect_spdx_deps has no
# [stamp-extra-info] and its task hash does not vary by MACHINE, so its stamp
# collides across machines sharing one TMPDIR: bitbake skips the task for
# every machine after the first, WORKDIR/spdx/deps.json is never written,
# and do_create_spdx fails with FileNotFoundError. Give the task the same
# per-machine stamp suffix package.bbclass gives do_packagedata.
do_collect_spdx_deps[stamp-extra-info] = "${MACHINE_ARCH}"
