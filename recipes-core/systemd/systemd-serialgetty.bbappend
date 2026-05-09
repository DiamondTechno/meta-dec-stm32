# meta-st-openstlinux ships a serial-getty@.service with "--autologin root"
# baked into the ExecStart. That overrides the IMAGE_FEATURES mechanism for
# disabling autologin (we can remove serial-autologin-root all we like, but
# THIS service file is still installed and still autologins).
#
# Override with our own copy that drops --autologin so the serial console
# brings up a normal "<host> login:" prompt. Root login still works with no
# password (allow-empty-password + empty-root-password IMAGE_FEATUREs).

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
