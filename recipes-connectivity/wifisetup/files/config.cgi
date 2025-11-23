#!/bin/bash
echo "Content-type: text/html"
echo ""
read -n $CONTENT_LENGTH POST_DATA
SSID=$(echo "$POST_DATA" | tr '&' '\n' | grep "^ssid=" | cut -d= -f2 | sed 's/+/ /g;s/%\(..\)/\\x\1/g' | xargs -0 printf "%b")
PASS=$(echo "$POST_DATA" | tr '&' '\n' | grep "^password=" | cut -d= -f2 | sed 's/+/ /g;s/%\(..\)/\\x\1/g' | xargs -0 printf "%b")
source /etc/colorcreator/wifi.conf 2>/dev/null
cat > /etc/colorcreator/wifi.conf << CONF
AP_SSID=${AP_SSID:-system}
AP_PASSWORD=${AP_PASSWORD:-i8o9p0U8}
WIFI_MODE=client
CLIENT_SSID=$SSID
CLIENT_PASSWORD=$PASS
CONF
cat << HTML
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Connecting</title>
<style>body{font-family:system-ui;background:linear-gradient(135deg,#667eea,#764ba2);min-height:100vh;display:flex;justify-content:center;align-items:center}
.c{background:#fff;border-radius:20px;padding:40px;text-align:center}h1{color:#667eea}</style></head>
<body><div class="c"><h1>🎨 Connecting...</h1><p>Connecting to <b>$SSID</b></p><p>WiFi will restart in 3 seconds</p></div></body></html>
HTML
( sleep 3; /usr/sbin/wifisetup.sh restart ) &
