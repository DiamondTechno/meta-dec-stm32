#!/bin/bash
# setup_dec_stm32.sh — wrapper around ST's envsetup.sh that:
#   1. presets DISTRO=openstlinux-weston and MACHINE=stm32mp25-dec-kit
#      so the user doesn't have to navigate the interactive menu
#   2. wires EXTERNALSRC for the linux-stm32 / uboot-stm32 working
#      trees synced under sources/, so the kernel and u-boot are built
#      from those instead of being re-fetched
#
# Usage (must be SOURCED, not executed):
#     source ./setup_dec_stm32.sh                # defaults
#     BUILD_DIR=my-build source ./setup_dec_stm32.sh
#     MACHINE=stm32mp25-dec-kit source ./setup_dec_stm32.sh
#
# After sourcing you'll be cd'd into the build dir with bitbake on PATH.
# Run `bitbake dec-image-full` from there.

# Bail if not sourced — the script needs to modify the caller's env.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "[ERROR] setup_dec_stm32.sh must be sourced, not executed."
    echo "        Run:  source ./setup_dec_stm32.sh"
    exit 1
fi

# Where this script lives (handles being invoked from a symlink in the
# repo root via the manifest linkfile).
_SETUP_DEC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_REPO_ROOT="$(cd "${_SETUP_DEC_DIR}/.." && pwd)"

# Find the ST envsetup.sh in the synced layers.
_ST_ENVSETUP="${_REPO_ROOT}/layers/meta-st/scripts/envsetup.sh"
if [ ! -f "${_ST_ENVSETUP}" ]; then
    echo "[ERROR] ST envsetup.sh not found at ${_ST_ENVSETUP}"
    echo "        Did you run 'repo sync' yet?"
    return 1
fi

# Defaults — caller can override by exporting these before sourcing.
DISTRO="${DISTRO:-openstlinux-weston}"
MACHINE="${MACHINE:-stm32mp25-dec-kit}"

# Hand off to ST's envsetup.sh non-interactively. It still pauses at the
# EULA on first run; that's intentional (the user has to read it once).
DISTRO="${DISTRO}" MACHINE="${MACHINE}" \
    source "${_ST_ENVSETUP}" --no-ui

# After envsetup.sh runs we should be cd'd into the build dir, with
# bitbake on PATH. Append the EXTERNALSRC pointers to local.conf if
# they're not already present. Idempotent — re-sourcing won't double up.
_LOCAL_CONF="${PWD}/conf/local.conf"
if [ -f "${_LOCAL_CONF}" ]; then
    if ! grep -q "^EXTERNALSRC:pn-linux-stm32mp" "${_LOCAL_CONF}"; then
        cat >> "${_LOCAL_CONF}" <<'EOF'

# Build kernel and u-boot from the local working trees synced by repo
# under sources/ (instead of re-fetching the upstream tarball/git).
# Added by setup_dec_stm32.sh.
EXTERNALSRC:pn-linux-stm32mp  = "${TOPDIR}/../sources/linux-stm32"
EXTERNALSRC:pn-u-boot-stm32mp = "${TOPDIR}/../sources/uboot-stm32"
EOF
        echo "[setup_dec_stm32] Added EXTERNALSRC pointers to ${_LOCAL_CONF}"
    fi
fi

# Cleanup
unset _SETUP_DEC_DIR _REPO_ROOT _ST_ENVSETUP _LOCAL_CONF

cat <<EOF

==============================================================================
DEC STM32 build environment ready.
  MACHINE  = ${MACHINE}
  DISTRO   = ${DISTRO}
  BUILDDIR = ${PWD}

Next:
    bitbake dec-image-full
==============================================================================
EOF
