# Hook DEC external-DT into trusted-firmware-a-stm32mp.
inherit dec-extdt-stm32mp

# TF-A's plat/st/stm32mp2/platform.mk auto-detects the SoC variant by
# grepping DTB_FILE_NAME for mp21/mp23/mp25 substrings. Our DEC kit DTB
# (stm32mp-dec-kit.dtb) doesn't contain "mp25", so the auto-detect fails
# with "Cannot enable 2 flags STM32MP2X". Force the flag explicitly.
EXTRA_OEMAKE += "STM32MP25=1"

# The eMMC fitted on the cargt-00395 / DEC SOM does not come up fast enough
# for upstream TF-A defaults: BL2 panics with "CMD13 failed after 5 retries"
# during FIP load on POR. The patch raises MMC retries 5->50 and SDMMC2
# power-cycle delays 2ms->20ms. Originally from meta-st-cargt.
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += "file://0001-Increase-delays-and-retries-to-avoid-a-panic-if-the-.patch"
