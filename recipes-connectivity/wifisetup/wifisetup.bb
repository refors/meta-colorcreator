SUMMARY = "WiFi Setup for ColorCreator"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SRC_URI = "file://wifisetup.sh file://S99wifi file://hostapd.conf file://dnsmasq.conf  file://index.html file://config.cgi"
S = "${WORKDIR}"
RDEPENDS_${PN} = "bash hostapd dnsmasq wpa-supplicant lighttpd iw"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/wifisetup.sh ${D}${sbindir}/
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/S99wifi ${D}${sysconfdir}/init.d/
    install -d ${D}${sysconfdir}/hostapd
    install -m 0644 ${WORKDIR}/hostapd.conf ${D}${sysconfdir}/hostapd/
    install -d ${D}${sysconfdir}/dnsmasq.d
    install -m 0644 ${WORKDIR}/dnsmasq.conf ${D}${sysconfdir}/dnsmasq.d/wifisetup.conf
    install -d ${D}${sysconfdir}/lighttpd
    install -d ${D}/var/www/html
    install -m 0644 ${WORKDIR}/index.html ${D}/var/www/html/
    install -d ${D}/var/www/cgi-bin
    install -m 0755 ${WORKDIR}/config.cgi ${D}/var/www/cgi-bin/
}
FILES_${PN} += "/var/www/html/* /var/www/cgi-bin/*"
