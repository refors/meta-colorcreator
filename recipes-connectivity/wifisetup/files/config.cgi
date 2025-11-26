#!/bin/bash
echo "Content-type: text/html"
echo ""

read -n "${CONTENT_LENGTH:-0}" POST_DATA

urldecode() {
  local s="${1//+/ }"
  printf '%b' "${s//%/\\x}"
}

SSID=$(echo "$POST_DATA" | tr '&' '\n' | sed -n 's/^ssid=//p' | head -n1)
PASS=$(echo "$POST_DATA" | tr '&' '\n' | sed -n 's/^password=//p' | head -n1)

SSID=$(urldecode "$SSID")
PASS=$(urldecode "$PASS")

mkdir -p /etc/colorcreator

cat > /etc/colorcreator/wifi.conf << CONF
AP_SSID=color
AP_PASSWORD=
WIFI_MODE=client
CLIENT_SSID=$SSID
CLIENT_PASSWORD=$PASS
CONF

cat << HTML
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Connecting</title>
<style>
body{font-family:system-ui;background:linear-gradient(135deg,#667eea,#764ba2);min-height:100vh;display:flex;justify-content:center;align-items:center}
.c{background:#fff;border-radius:20px;padding:40px;text-align:center;box-shadow:0 20px 60px rgba(0,0,0,.3)}
h1{color:#667eea;margin-bottom:10px}
p{color:#555}
b{font-family:monospace}
</style></head>
<body><div class="c">
<h1>🎨 Connecting…</h1>
<p>Connecting to <b>$SSID</b></p>
<p>Wi-Fi will restart in 2 seconds.</p>
<p>Then open: <b>http://color.local</b></p>
</div></body></html>
HTML

/bin/sh -c "sleep 2; nohup /usr/sbin/wifisetup.sh restart >/dev/null 2>&1 &" >/dev/null 2>&1 &
