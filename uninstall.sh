#!/bin/bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Error: ejecuta con sudo." >&2; exit 1; }
printer="${1:-$(lpstat -p 2>/dev/null | awk 'NR==1{print $2}')}"
[ -n "$printer" ] || { echo "Uso: sudo ./uninstall.sh NOMBRE_COLA" >&2; exit 2; }
label="com.local.iphone-airprint-$printer"
plist="/Library/LaunchDaemons/$label.plist"
launchctl bootout system "$plist" >/dev/null 2>&1 || true
rm -f "$plist"
lpadmin -p "$printer" -o printer-is-shared=false || true
echo "Retirado el puente para '$printer'; la cola CUPS no se ha borrado."
