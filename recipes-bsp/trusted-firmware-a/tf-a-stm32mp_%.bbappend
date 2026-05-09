# Hook DEC external-DT into trusted-firmware-a-stm32mp.
inherit dec-extdt-stm32mp

# TF-A's plat/st/stm32mp2/platform.mk auto-detects the SoC variant by
# grepping DTB_FILE_NAME for mp21/mp23/mp25 substrings. Our DEC kit DTB
# (stm32mp-dec-kit.dtb) doesn't contain "mp25", so the auto-detect fails
# with "Cannot enable 2 flags STM32MP2X". Force the flag explicitly.
EXTRA_OEMAKE += "STM32MP25=1"
