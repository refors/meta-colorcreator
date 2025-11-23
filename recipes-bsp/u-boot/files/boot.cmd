# U-Boot boot script for LCPI-PC-T113
# This script sets correct boot parameters and loads kernel

# Set bootargs with proper console configuration
setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootwait rw

# Load device tree
load mmc 0:1 ${fdt_addr_r} sun8i-t113-mangopi-dual.dtb

# Load kernel
load mmc 0:1 ${kernel_addr_r} zImage

# Boot kernel with device tree
bootz ${kernel_addr_r} - ${fdt_addr_r}
