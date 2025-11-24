#!/bin/bash
echo "Content-type: application/json"
echo ""

# Scan WiFi networks
iw dev wlan0 scan 2>/dev/null | awk '
BEGIN { print "[" }
/^BSS / { 
    if (ssid != "") {
        printf "%s{\"ssid\":\"%s\",\"signal\":%d,\"security\":\"%s\"}", sep, ssid, signal, security
        sep = ","
    }
    signal = -100
    security = "open"
    ssid = ""
}
/signal:/ { signal = $2 }
/SSID:/ { 
    ssid = substr($0, index($0, "SSID:") + 6)
    gsub(/^[ \t]+|[ \t]+$/, "", ssid)
}
/WPA/ { security = "wpa" }
/RSN/ { security = "wpa2" }
END {
    if (ssid != "") {
        printf "%s{\"ssid\":\"%s\",\"signal\":%d,\"security\":\"%s\"}", sep, ssid, signal, security
    }
    print "\n]"
}
'
