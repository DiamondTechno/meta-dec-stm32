# Hook DEC external-DT into TF-M (Trusted Firmware for Cortex-M).
#
# This bbappend only matters when the M33 co-processor is being used
# with TF-M secure firmware — typically when "m33td" is in
# MACHINE_FEATURES. With m33td unset (the default for the DEC kit),
# the upstream tf-m-stm32mp recipe stays out of the build, so this
# bbappend is a no-op and won't cause any build pressure.
#
# Note: actually building TF-M for the DEC kit additionally requires a
# CM33/DeviceTree/dec-stm32mp25-kit/{tf-m,mcuboot}/ subtree under
# meta-dec-stm32/dec-stm32mp25-kit/ — which we have NOT ported from
# the cargt project. Add those DTSes (and an "m33td" feature) before
# expecting `bitbake tf-m-stm32mp` to succeed.
inherit dec-extdt-stm32mp

# The TF-M build's do_compile validates DT files itself, so suppress
# the dec-extdt-stm32mp class's own pre-compile DT existence check.
ENABLE_DEC_EXTDT_CHK = "0"

# TF-M uses these to construct DT filenames (BL2 / non-secure / secure
# variants). For the stm32mp2 family, no BL2 suffix; secure/non-secure
# get -s and -ns suffixes UNLESS m33td is enabled (in which case the
# project DTSes are named without the suffix).
BL2_TYPE:stm32mp2commonmx    = ""
DTS_TYPE_NS:stm32mp2commonmx = "${@bb.utils.contains('MACHINE_FEATURES', 'm33td', '', '-ns', d)}"
DTS_TYPE_S:stm32mp2commonmx  = "${@bb.utils.contains('MACHINE_FEATURES', 'm33td', '', '-s', d)}"
