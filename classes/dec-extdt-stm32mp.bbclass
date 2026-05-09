# DEC external-DT plumbing for STM32MP recipes.
#
# Forked from meta-cargt-stm32mp-addons' cubemx-stm32mp.bbclass with the
# cargt naming stripped. Provides the per-component (tf-a/u-boot/optee/
# kernel) external-DT directory layout used by ST recipes that consume
# extra device trees through the external-dt mechanism.

# Configure generation of device tree binary with DEC project files
ENABLE_DEC_EXTDT ??= "0"
# Check that the configured DTB exists in the project before do_compile
ENABLE_DEC_EXTDT_CHK ??= "1"

# Project DTB name (e.g. dec-stm32mp25-kit)
DEC_EXTDT_DTB ??= ""
# Path to the project tree (looked up via BBPATH)
DEC_EXTDT_PROJECT ??= ""
# Project name within the tree
DEC_EXTDT_PROJECT_NAME ??= ""

# Hook into the upstream external-dt class
inherit external-dt

EXTERNAL_DT_ENABLED:stm32mpcommonmx = "1"

STAGING_EXTDT_DIR:stm32mpcommonmx = "${@dec_extdt_search(d.getVar('DEC_EXTDT_PROJECT'),d)[1]}"

EXTDT_DIR_TF_A:stm32mp2commonmx  = "CA35/DeviceTree/${DEC_EXTDT_PROJECT_NAME}/tf-a"
EXTDT_DIR_TF_A_SERIAL:stm32mpcommonmx = "${@bb.utils.contains('MACHINE_FEATURES', 'm33td', 'ExtMemLoader/DeviceTree/tf-a', '${EXTDT_DIR_TF_A}', d)}"
EXTDT_DIR_UBOOT:stm32mp2commonmx  = "CA35/DeviceTree/${DEC_EXTDT_PROJECT_NAME}/u-boot"
EXTDT_DIR_UBOOT_SERIAL:stm32mpcommonmx = "${@bb.utils.contains('MACHINE_FEATURES', 'm33td', 'ExtMemLoader/DeviceTree/u-boot', '${EXTDT_DIR_UBOOT}', d)}"
EXTDT_DIR_OPTEE:stm32mp2commonmx  = "CA35/DeviceTree/${DEC_EXTDT_PROJECT_NAME}/optee-os"
EXTDT_DIR_OPTEE_SERIAL:stm32mpcommonmx = "${@bb.utils.contains('MACHINE_FEATURES', 'm33td', 'ExtMemLoader/DeviceTree/optee-os', '${EXTDT_DIR_OPTEE}', d)}"
EXTDT_DIR_LINUX:stm32mp2commonmx  = "CA35/DeviceTree/${DEC_EXTDT_PROJECT_NAME}/kernel"

# Optional Makefile generation for external DT — off by default for DEC
DEC_EXTDT_ENABLE_MK ??= "0"
DEC_EXTDT_FORCE_MK ??= "0"

def dec_extdt_search(dirs, d):
    """
    Locate the DEC external-DT project directory via BBPATH. Returns
    (found, abs_path).
    """
    search_path = d.getVar("BBPATH").split(":")
    for dir in dirs.split():
        for p in search_path:
            dir_path = os.path.join(p, dir)
            if os.path.isdir(dir_path):
                return (True, dir_path)
    return (False, "")

python __anonymous() {
    if d.getVar('ENABLE_DEC_EXTDT') == "0":
        return

    project = d.getVar('DEC_EXTDT_PROJECT')
    if project == "":
        raise bb.parse.SkipRecipe('\n[dec-extdt-stm32mp] DEC_EXTDT_PROJECT is empty for %s.\n' % d.getVar("MACHINE"))
    dtb = d.getVar('DEC_EXTDT_DTB')
    if dtb == "":
        raise bb.parse.SkipRecipe('\n[dec-extdt-stm32mp] DEC_EXTDT_DTB is empty for %s.\n' % d.getVar("MACHINE"))

    found, project_dir = dec_extdt_search(project, d)
    if found:
        bb.debug(1, "Found DEC external-DT project at: %s" % project_dir)
    else:
        bbpaths = d.getVar('BBPATH').replace(':','\n\t')
        bb.fatal('\n[dec-extdt-stm32mp] Cannot find "%s" on BBPATH:\n\t%s.' % (project, bbpaths))

    if d.getVar('ENABLE_DEC_EXTDT_CHK') == "1":
        d.prependVarFlag('do_compile', 'prefuncs', "check_dec_extdt ")

    for extdt_conf in d.getVar('EXTDT_DIR_CONFIG').split():
        provider = extdt_conf.split(':')[0]
        sub_path = extdt_conf.split(':')[1]
        if provider in d.getVar('PROVIDES').split():
            extdt_dir = os.path.join(d.getVar('STAGING_EXTDT_DIR'), sub_path)
            extdt_src_configure(d, extdt_dir)
            break
}

python check_dec_extdt() {
    for extdt_conf in d.getVar('EXTDT_DIR_CONFIG').split():
        provider = extdt_conf.split(':')[0]
        sub_path = extdt_conf.split(':')[1]
        if provider in d.getVar('PROVIDES').split():
            dts_file = os.path.join(d.getVar('STAGING_EXTDT_DIR'), sub_path, d.getVar('DEC_EXTDT_DTB') + '.dts')
            if os.path.exists(dts_file):
                break
            elif d.getVar('EXTDT_USE_SUFFIX') == '1':
                found = False
                suffix_list = ""
                for storage in d.getVar('EXTDT_SUFFIX_STORAGE').split():
                    suffix = d.getVar('EXTDT_SUFFIX_%s' % storage) or ""
                    if suffix:
                        suffix_list += ' ' + suffix
                        raw = os.path.join(d.getVar('STAGING_EXTDT_DIR'), sub_path, d.getVar('DEC_EXTDT_DTB'))
                        if os.path.exists(raw + suffix + '.dts'):
                            found = True
                            break
                if found:
                    break
                else:
                    bb.fatal('File %s[%s].dts not found: compile aborted for %s DT.' % (raw, suffix_list, d.getVar('BPN')))
            else:
                bb.fatal('File %s not found: compile aborted for %s DT.' % (dts_file, d.getVar('BPN')))
}
