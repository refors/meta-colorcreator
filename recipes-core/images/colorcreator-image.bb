SUMMARY = "ColorCreator Image for LCPI-PC-T113"
LICENSE = "MIT"
inherit core-image

IMAGE_INSTALL = "packagegroup-core-boot"

IMAGE_INSTALL += "kernel-modules rtl8189ftv wireless-regdb wpa-supplicant hostapd dnsmasq iw iptables util-linux-rfkill"
IMAGE_INSTALL += "lighttpd lighttpd-module-cgi"
IMAGE_INSTALL += "dropbear"
IMAGE_INSTALL += "i2c-tools libgpiod libgpiod-tools"
IMAGE_INSTALL += "gcc g++ make cmake"
IMAGE_INSTALL += "nano htop procps util-linux bash curl wget"
IMAGE_INSTALL += "wifisetup usb-gadget"

IMAGE_FEATURES += "ssh-server-dropbear"
EXTRA_IMAGE_FEATURES += "debug-tweaks"
IMAGE_ROOTFS_EXTRA_SPACE = "102400"
