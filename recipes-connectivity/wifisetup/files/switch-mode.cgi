#!/bin/bash
echo "Content-type: text/html"
echo ""

read -n "${CONTENT_LENGTH:-0}" POST_DATA
MODE=$(echo "$POST_DATA" | tr '&' '\n' | sed -n 's/^mode=//p' | head -n1)

mkdir -p /etc/colorcreator

if [ "$MODE" = "ap" ]; then
  cat > /etc/colorcreator/wifi.conf << CONF
AP_SSID=color
AP_PASSWORD=
WIFI_MODE=ap
CLIENT_SSID=
CLIENT_PASSWORD=
CONF

  cat << HTML
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Switching Mode</title>
<style>
body{font-family:system-ui;background:linear-gradient(135deg,#667eea,#764ba2);min-height:100vh;display:flex;justify-content:center;align-items:center}
.c{background:#fff;border-radius:20px;padding:40px;text-align:center;box-shadow:0 20px 60px rgba(0,0,0,.3)}
h1{color:#667eea;margin-bottom:10px}
p{color:#555}
b{font-family:monospace}
</style></head>
<body><div class="c">
<h1>🎨 Switching to AP Mode…</h1>
<p>Connect to Wi-Fi: <b>color</b> (no password)</p>
<p>Then open: <b>http://color.local</b> or <b>http://192.168.77.1</b></p>
</div></body></html>
HTML

  /bin/sh -c "sleep 2; nohup /usr/sbin/wifisetup.sh restart >/dev/null 2>&1 &" >/dev/null 2>&1 &
else
  echo "Invalid mode"
fi
