# U-Boot configuration for LCPI-PC-T113
# Sets correct boot arguments to fix kernel hang

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://boot.cmd"

# Set default boot arguments
UBOOT_BOOTARGS = "console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootwait rw"

do_compile:append() {
    # Compile boot script if boot.cmd exists
    if [ -f ${WORKDIR}/boot.cmd ]; then
        mkimage -C none -A arm -T script -d ${WORKDIR}/boot.cmd ${WORKDIR}/boot.scr
    fi
}

do_deploy:append() {
    # Deploy boot script
    if [ -f ${WORKDIR}/boot.scr ]; then
        install -m 0644 ${WORKDIR}/boot.scr ${DEPLOYDIR}/
    fi
}
