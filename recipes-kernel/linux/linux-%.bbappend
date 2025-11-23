# Kernel configuration for LCPI-PC-T113
# Fixes boot hang and UART console

# Set correct serial console for T113 (UART0)
SERIAL_CONSOLES = "115200;ttyS0"

# Kernel boot arguments
KERNEL_BOOTARGS = "console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootwait rw"

# Alternative method using device tree bootargs (if above doesn't work)
do_configure:prepend() {
    # Ensure console output is enabled
    if [ -f ${S}/.config ]; then
        # Enable early printk for debugging
        echo "CONFIG_EARLY_PRINTK=y" >> ${S}/.config
        echo "CONFIG_SERIAL_8250_CONSOLE=y" >> ${S}/.config
        echo "CONFIG_SERIAL_SUNXI_CONSOLE=y" >> ${S}/.config
    fi
}
