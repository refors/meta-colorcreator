#!/bin/bash
echo "Content-type: application/json"
echo ""

if [ -f /tmp/wifi_error_ssid ]; then
  SSID=$(cat /tmp/wifi_error_ssid)
  MSG=$(cat /tmp/wifi_error_msg)
  echo "{\"error\":true,\"ssid\":\"$SSID\",\"message\":\"$MSG\"}"
else
  echo "{\"error\":false}"
fi
