# Tell the upstream external-dt recipe where the DEC project tree lives
# (the DEC machine config sets DEC_EXTDT_PROJECT to dec-stm32mp25-kit
# and ENABLE_DEC_EXTDT to 1). This mirrors how meta-cargt-stm32mp-addons
# wires up its CubeMX project — minus the cargt branding.

EXTERNALSRC:stm32mpcommonmx = "${@bb.utils.contains('ENABLE_DEC_EXTDT', '1', '${STAGING_EXTDT_DIR}', '', d)}"
EXTERNALSRC_BUILD:stm32mpcommonmx = "${@bb.utils.contains('ENABLE_DEC_EXTDT', '1', '${STAGING_EXTDT_DIR}', '', d)}"
