#!/bin/bash
echo "Content-type: application/json"
echo ""

iw dev wlan0 scan 2>/dev/null | awk '
function jesc(s) { gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s); return s }
BEGIN { print "["; sep=""; signal=-100; security="open"; ssid="" }
/^BSS / {
  if (ssid != "") {
    printf "%s{\"ssid\":\"%s\",\"signal\":%d,\"security\":\"%s\"}", sep, jesc(ssid), signal, security
    sep=","
  }
  signal=-100; security="open"; ssid=""
}
/signal:/ { gsub(/\..*/, "", $2); signal=$2 }
/SSID:/   { ssid=substr($0, index($0,"SSID:")+6); gsub(/^[ \t]+|[ \t]+$/, "", ssid) }
/WPA/     { security="wpa" }
/RSN/     { security="wpa2" }
END {
  if (ssid != "") {
    printf "%s{\"ssid\":\"%s\",\"signal\":%d,\"security\":\"%s\"}", sep, jesc(ssid), signal, security
  }
  print "]"
}'
