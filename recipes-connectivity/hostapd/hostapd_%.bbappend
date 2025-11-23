# Remove default hostapd config and init script
# We manage hostapd via wifisetup package

# Disable init script registration - prevents postinst from failing
INITSCRIPT_PACKAGES = ""

do_install:append() {
    # Remove default config that has ssid=test
    rm -f ${D}${sysconfdir}/hostapd.conf
    # Remove init script - we use S99wifi instead
    rm -f ${D}${sysconfdir}/init.d/hostapd
}
