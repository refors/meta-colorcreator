SUMMARY = "Avahi configuration for ColorCreator"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://avahi-daemon.conf"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/avahi
    install -m 0644 ${WORKDIR}/avahi-daemon.conf ${D}${sysconfdir}/avahi/
}

FILES:${PN} = "${sysconfdir}/avahi/avahi-daemon.conf"
