#!/bin/bash
CONFIG_FILE="/etc/colorcreator/wifi.conf"
WIFI_INTERFACE="wlan0"

load_config() {
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE" || {
        mkdir -p /etc/colorcreator
        echo -e "AP_SSID=system-t113\nAP_PASSWORD=i8o9p0U8\nWIFI_MODE=ap" > "$CONFIG_FILE"
        source "$CONFIG_FILE"
    }
}

load_driver() {
    lsmod | grep -q 8189fs || { modprobe 8189fs; sleep 2; }
    for i in $(seq 1 10); do ip link show $WIFI_INTERFACE &>/dev/null && return 0; sleep 1; done
    return 1
}

stop_wifi() {
    killall hostapd dnsmasq wpa_supplicant 2>/dev/null
    ip addr flush dev $WIFI_INTERFACE 2>/dev/null
    ip link set $WIFI_INTERFACE down 2>/dev/null
}

start_ap() {
    rfkill unblock wifi 2>/dev/null
    ip link set $WIFI_INTERFACE up && sleep 1
    ip addr add 192.168.4.1/24 dev $WIFI_INTERFACE
    
    cat > /etc/hostapd/hostapd.conf << HAPD
interface=$WIFI_INTERFACE
driver=nl80211
ssid=${AP_SSID:-system-t113}
hw_mode=g
channel=6
wpa=2
wpa_passphrase=${AP_PASSWORD:-i8o9p0U8}
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
HAPD
    
    hostapd -B /etc/hostapd/hostapd.conf
    dnsmasq -C /etc/dnsmasq.d/wifisetup.conf --interface=$WIFI_INTERFACE
    mkdir -p /var/log/lighttpd
    /etc/init.d/lighttpd start 2>/dev/null
    echo "AP: SSID=${AP_SSID:-system} IP=192.168.4.1 Web=http://192.168.4.1"
}

start_client() {
    [ -z "$CLIENT_SSID" ] && { start_ap; return; }
    rfkill unblock wifi 2>/dev/null
    cat > /tmp/wpa.conf << WPA
network={
    ssid="$CLIENT_SSID"
    psk="$CLIENT_PASSWORD"
}
WPA
    ip link set $WIFI_INTERFACE up
    wpa_supplicant -B -i $WIFI_INTERFACE -c /tmp/wpa.conf
    sleep 5
    udhcpc -i $WIFI_INTERFACE -q
    echo "Client: Connected to $CLIENT_SSID"
}

case "$1" in
    start) load_config; load_driver && { stop_wifi; [ "$WIFI_MODE" = "client" ] && start_client || start_ap; } ;;
    stop) stop_wifi ;;
    restart) $0 stop; sleep 2; $0 start ;;
    status) load_config; echo "Mode: $WIFI_MODE"; ip addr show $WIFI_INTERFACE 2>/dev/null ;;
    *) echo "Usage: $0 {start|stop|restart|status}" ;;
esac
