SUMMARY = "WiFi Setup for ColorCreator"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://wifisetup.sh \
           file://S99wifi \
           file://hostapd.conf \
           file://dnsmasq.conf \
           file://index.html \
           file://config.html \
           file://status.html \
           file://config.cgi \
           file://scan.cgi \
           file://status.cgi \
           file://switch-mode.cgi \
           file://error.cgi \
           file://50-cgi.conf"

S = "${WORKDIR}"

RDEPENDS:${PN} = "bash hostapd dnsmasq wpa-supplicant lighttpd iw"

inherit update-rc.d

INITSCRIPT_NAME = "S99wifi"
INITSCRIPT_PARAMS = "start 99 2 3 4 5 ."

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/wifisetup.sh ${D}${sbindir}/

    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/S99wifi ${D}${sysconfdir}/init.d/

    install -d ${D}${sysconfdir}/hostapd
    install -m 0644 ${WORKDIR}/hostapd.conf ${D}${sysconfdir}/hostapd/

    install -d ${D}${sysconfdir}/dnsmasq.d
    install -m 0644 ${WORKDIR}/dnsmasq.conf ${D}${sysconfdir}/dnsmasq.d/wifisetup.conf

    install -d ${D}${sysconfdir}/lighttpd.d
    install -m 0644 ${WORKDIR}/50-cgi.conf ${D}${sysconfdir}/lighttpd.d/

    install -d ${D}/www/pages
    install -m 0644 ${WORKDIR}/index.html ${D}/www/pages/
    install -m 0644 ${WORKDIR}/config.html ${D}/www/pages/
    install -m 0644 ${WORKDIR}/status.html ${D}/www/pages/

    install -d ${D}/www/cgi-bin
    install -m 0755 ${WORKDIR}/config.cgi ${D}/www/cgi-bin/
    install -m 0755 ${WORKDIR}/scan.cgi ${D}/www/cgi-bin/
    install -m 0755 ${WORKDIR}/status.cgi ${D}/www/cgi-bin/
    install -m 0755 ${WORKDIR}/switch-mode.cgi ${D}/www/cgi-bin/
    install -m 0755 ${WORKDIR}/error.cgi ${D}/www/cgi-bin/
}

FILES:${PN} += "/www/pages/* /www/cgi-bin/*"
