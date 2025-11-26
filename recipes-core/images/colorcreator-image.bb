SUMMARY = "ColorCreator Image for LCPI-PC-T113"
LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL = "packagegroup-core-boot"

# WiFi (драйвер из meta-lcpi-pc-t113)
IMAGE_INSTALL += "kernel-modules rtl8189ftv wireless-regdb wpa-supplicant hostapd dnsmasq iw iptables util-linux-rfkill"

# Web interface
IMAGE_INSTALL += "lighttpd lighttpd-module-cgi lighttpd-module-alias"

# SSH
IMAGE_INSTALL += "dropbear"

# GPIO and peripherals
IMAGE_INSTALL += "i2c-tools libgpiod libgpiod-tools"

# Development tools
IMAGE_INSTALL += "gcc g++ make cmake"

# Real-Time testing tools
IMAGE_INSTALL += "rt-tests stress-ng"

# Utils
IMAGE_INSTALL += "nano htop procps util-linux bash curl wget"

# Custom packages
IMAGE_INSTALL += "wifisetup usb-gadget"

# mDNS
IMAGE_INSTALL += "avahi-daemon avahi-utils libnss-mdns avahi-config"

IMAGE_FEATURES += "ssh-server-dropbear"
EXTRA_IMAGE_FEATURES += "debug-tweaks"

IMAGE_ROOTFS_EXTRA_SPACE = "102400"

# Разрешаем перезапись для avahi-config
OPKG_ARGS:append = " --force-overwrite"
