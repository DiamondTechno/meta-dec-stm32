# meta-dec-stm32

Diamond Technologies BSP layer for STM32MP25-based DEC kits.

Target hardware is the DEC kit: the STM32MP257F DEC SOM, **rev02**, on
the DEC carrier board, with the optional 5.5" MIPI DSI, 7.0" LVDS and
10.1" LVDS displays. The rev02 SOM differs from rev00 in its carrier
I2C routing (I2C3 instead of I2C1), uSD power (PMIC LDO7 instead of a
GPIO switch) and WLAN reset GPIO (PG8); the device trees here describe
rev02 only.

This layer provides the machine configuration, image recipes, and BSP
component overrides (kernel, u-boot, TF-A, OP-TEE) needed to build a
DEC-branded STM32MP25 system. It deliberately has **no dependency on**
`meta-st-cargt` or `meta-cargt-stm32mp-addons` — the previous cargt
machinery has been forked here and renamed.

## Layout

- `conf/machine/stm32mp25-dec-kit.conf` — DEC kit machine configuration
- `conf/eula/` — STMicroelectronics EULA acceptance files (per machine)
- `classes/dec-extdt-stm32mp.bbclass` — external-DT plumbing for the
  DEC CubeMX-style project tree below
- `dec-stm32mp25-kit/CA35/DeviceTree/dec-stm32mp25-kit/{tf-a,u-boot,optee-os}/`
  — per-component DTSes the upstream ST recipes consume via external-DT
- `recipes-bsp/u-boot`, `recipes-bsp/trusted-firmware-a`,
  `recipes-security/optee` — bbappends that hook the external-DT
  mechanism into the upstream ST recipes
- `recipes-kernel/linux` — kernel config fragments
- `recipes-dec/images/dec-image-full.bb` — development image recipe

## Companion layers

- `meta-dec-common` — vendor-neutral DEC userland (eeprom services,
  benchmarks, tools)

## Distro

This layer is designed to be used with upstream `openstlinux-weston`
(no distro fork). systemd + NetworkManager are turned on via the
machine config's `DISTRO_FEATURES:append`, not via a forked distro.
