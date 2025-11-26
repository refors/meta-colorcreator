#!/bin/bash
echo "Content-type: application/json"
echo ""

CONF="/etc/colorcreator/wifi.conf"
WIFI_MODE="ap"
AP_SSID="color"

if [ -f "$CONF" ]; then
  . "$CONF" 2>/dev/null || true
fi

MODE="${WIFI_MODE:-ap}"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

SSID=""
SIGNAL=""
IPADDR=""

if [ "$MODE" = "client" ]; then
  SSID="$(iw dev wlan0 link 2>/dev/null | sed -n 's/^[[:space:]]*SSID: //p' | head -n1)"
  SIGNAL="$(iw dev wlan0 link 2>/dev/null | awk '/signal:/{print $2; exit}')"
  IPADDR="$(ip -4 addr show wlan0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"
else
  SSID="${AP_SSID:-color}"
  IPADDR="$(ip -4 addr show wlan0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"
fi

if [ -n "$SIGNAL" ]; then
  SIGJSON="$SIGNAL"
else
  SIGJSON="null"
fi

SSID_ESC="$(json_escape "$SSID")"
IP_ESC="$(json_escape "$IPADDR")"

cat << JSON
{
  "mode": "$(json_escape "$MODE")",
  "ssid": "$SSID_ESC",
  "signal": $SIGJSON,
  "ip": "$IP_ESC"
}
JSON
