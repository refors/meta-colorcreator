#!/bin/sh

CONF_FILE="/etc/colorcreator/wifi.conf"
LOG="/var/log/wifisetup.log"
MODULE="8189fs"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"; }

load_config() {
  mkdir -p /etc/colorcreator
  if [ -f "$CONF_FILE" ]; then
    . "$CONF_FILE" 2>/dev/null || true
  else
    AP_SSID="color"
    AP_PASSWORD=""
    WIFI_MODE="ap"
    CLIENT_SSID=""
    CLIENT_PASSWORD=""
    cat > "$CONF_FILE" << CONF
AP_SSID=color
AP_PASSWORD=
WIFI_MODE=ap
CLIENT_SSID=
CLIENT_PASSWORD=
CONF
  fi

  AP_SSID="${AP_SSID:-color}"
  AP_PASSWORD=""
  WIFI_MODE="${WIFI_MODE:-ap}"
}

wait_for_interface() {
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    if ip link show wlan0 >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.2
  done
  log "ERROR: wlan0 interface not found after 4 seconds"
  return 1
}

load_driver() {
  if ! lsmod | grep -q "^${MODULE}\b"; then
    log "Loading WiFi module: $MODULE"
    if modprobe "$MODULE" 2>>/var/log/wifisetup.log; then
      log "WiFi module loaded successfully"
      wait_for_interface || log "Warning: wlan0 not ready after module load"
    else
      log "ERROR: Failed to load WiFi module $MODULE"
      return 1
    fi
  else
    log "WiFi module $MODULE already loaded"
  fi
  return 0
}

kill_procs() {
  killall hostapd 2>/dev/null
  killall dnsmasq 2>/dev/null
  killall wpa_supplicant 2>/dev/null
  killall udhcpc 2>/dev/null
}

stop_wifi() {
  log "Stopping WiFi"
  kill_procs
  ip addr flush dev wlan0 2>/dev/null
  ip link set wlan0 down 2>/dev/null
}

ensure_open_hostapd_conf() {
  [ -f /etc/hostapd/hostapd.conf ] || return 0
  sed -i "s/^ssid=.*/ssid=$AP_SSID/" /etc/hostapd/hostapd.conf
  if grep -q '^wpa=' /etc/hostapd/hostapd.conf; then
    sed -i 's/^wpa=.*/wpa=0/' /etc/hostapd/hostapd.conf
  else
    echo "wpa=0" >> /etc/hostapd/hostapd.conf
  fi
  sed -i '/^wpa_passphrase=/d' /etc/hostapd/hostapd.conf
}

wait_for_ip() {
  for i in 1 2 3 4 5 6 7 8 9 10; do
    IP="$(ip -4 addr show wlan0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"
    if [ -n "$IP" ]; then
      return 0
    fi
    sleep 0.3
  done
  return 1
}

start_ap() {
  log "Starting AP mode: SSID=$AP_SSID"
  
  if ! wait_for_interface; then
    log "Error: wlan0 not available"
    return 1
  fi
  
  ip link set wlan0 up 2>/dev/null || true
  sleep 2
  ip addr add 192.168.77.1/24 dev wlan0 2>/dev/null || true

  ensure_open_hostapd_conf

  hostapd -B /etc/hostapd/hostapd.conf 2>>/var/log/hostapd.log
  dnsmasq -C /etc/dnsmasq.d/wifisetup.conf >/dev/null 2>&1
  
  if wait_for_ip; then
    log "AP mode ready, IP=$(ip -4 addr show wlan0 | awk '/inet /{print $2}' | cut -d/ -f1)"
  fi
}

write_wpa_conf() {
  SSID="$1"
  PASS="$2"
  mkdir -p /run/wpa_supplicant
  
  if [ -z "$PASS" ]; then
    cat > /tmp/wpa_supplicant.conf << WPA
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=0
update_config=1
network={
  ssid="$SSID"
  key_mgmt=NONE
}
WPA
  else
    cat > /tmp/wpa_supplicant.conf << WPA
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=0
update_config=1
WPA
    wpa_passphrase "$SSID" "$PASS" >> /tmp/wpa_supplicant.conf
  fi
}

wait_connected() {
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if iw wlan0 link 2>/dev/null | grep -q "Connected"; then
      return 0
    fi
    sleep 1
  done
  return 1
}

start_client() {
  log "Starting Client mode: SSID=$CLIENT_SSID"
  
  if [ -z "$CLIENT_SSID" ]; then
    log "CLIENT_SSID empty -> fallback to AP"
    sed -i 's/^WIFI_MODE=.*/WIFI_MODE=ap/' "$CONF_FILE"
    start_ap
    return
  fi

  if ! wait_for_interface; then
    log "Error: wlan0 not available"
    return 1
  fi

  ip link set wlan0 up 2>/dev/null || true
  sleep 2
  ip addr flush dev wlan0 2>/dev/null

  write_wpa_conf "$CLIENT_SSID" "$CLIENT_PASSWORD"

  wpa_supplicant -B -i wlan0 -c /tmp/wpa_supplicant.conf -D nl80211 >/dev/null 2>&1

  if ! wait_connected; then
    log "WiFi connect failed -> revert to AP"
    echo "$CLIENT_SSID" > /tmp/wifi_error_ssid
    echo "Failed to connect. Possible reasons: incorrect password, network out of range, or authentication failed." > /tmp/wifi_error_msg
    sed -i 's/^WIFI_MODE=.*/WIFI_MODE=ap/' "$CONF_FILE"
    kill_procs
    start_ap
    return
  fi

  rm -f /tmp/wifi_error_ssid /tmp/wifi_error_msg

  udhcpc -i wlan0 -q -n -t 5 -T 3 >/dev/null 2>&1 || true

  IP="$(ip -4 addr show wlan0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"
  if [ -z "$IP" ]; then
    log "DHCP failed -> revert to AP"
    echo "$CLIENT_SSID" > /tmp/wifi_error_ssid
    echo "Connected to network but DHCP failed. Router may not be providing IP addresses." > /tmp/wifi_error_msg
    sed -i 's/^WIFI_MODE=.*/WIFI_MODE=ap/' "$CONF_FILE"
    kill_procs
    start_ap
    return
  fi

  log "Client mode OK, IP=$IP"
}

case "$1" in
  start)
    load_config
    load_driver || exit 1
    stop_wifi
    if [ "$WIFI_MODE" = "client" ]; then start_client; else start_ap; fi
    ;;
  restart)
    load_config
    load_driver || exit 1
    stop_wifi
    if [ "$WIFI_MODE" = "client" ]; then start_client; else start_ap; fi
    ;;
  stop)
    stop_wifi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
