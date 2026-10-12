#!/bin/bash
set -euo pipefail

PLIST_DIR="/Library/LaunchDaemons"
die() { echo "Error: $*" >&2; exit 1; }
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "Uso: sudo ./install.sh"
  echo "Comparte una cola CUPS local mediante IPP/Bonjour."
  exit 0
fi
[ "$(id -u)" -eq 0 ] || die "Ejecuta este instalador con sudo."
for command_name in lpstat lpadmin cupsctl dns-sd launchctl scutil ipconfig uuidgen; do
  command -v "$command_name" >/dev/null 2>&1 || die "No se encontró $command_name."
done

printers="$(lpstat -p 2>/dev/null | awk '{print $2}')"
[ -n "$printers" ] || die "No se encontraron impresoras configuradas en CUPS."
selected="$(printf '%s\n' "$printers" | head -n 1)"
count="$(printf '%s\n' "$printers" | wc -l | tr -d ' ')"
if [ "$count" -gt 1 ]; then
  echo "$printers" | nl -w2 -s') '
  printf "Selecciona una impresora [1-%s]: " "$count"
  read -r choice
  case "$choice" in ''|*[!0-9]*) die "Selección no válida." ;; esac
  selected="$(printf '%s\n' "$printers" | sed -n "${choice}p")"
  [ -n "$selected" ] || die "Selección no válida."
fi
case "$selected" in *[!A-Za-z0-9._-]*) die "Nombre de impresora no compatible: $selected" ;; esac

host="$(scutil --get ComputerName 2>/dev/null || hostname -s)"
safe_host="$(printf '%s' "$host" | tr -cd '[:alnum:] ._-')"
safe_host="${safe_host:-Mac}"
interface="$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')"
interface="${interface:-en0}"
local_ip="$(ipconfig getifaddr "$interface" 2>/dev/null || true)"
[ -n "$local_ip" ] || die "No se pudo determinar la IP de $interface."
printer_type="$(lpstat -l -p "$selected" | awk -F': ' '/Description:/{print $2; exit}')"
printer_type="${printer_type:-$selected}"
printer_uuid="$(uuidgen)"
label="com.local.iphone-airprint-$selected"
plist="$PLIST_DIR/$label.plist"

xml_escape() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' -e "s/'/\&apos;/g"; }
instance="$(xml_escape "$selected @ $safe_host")"
note="$(xml_escape "$safe_host")"
type_xml="$(xml_escape "$printer_type")"

cupsctl --share-printers --remote-any
lpadmin -p "$selected" -o printer-is-shared=true
mkdir -p "$PLIST_DIR"
cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>$label</string>
<key>ProgramArguments</key><array>
<string>/usr/bin/dns-sd</string><string>-P</string><string>$instance</string>
<string>_ipp._tcp</string><string>local.</string><string>631</string>
<string>PrinterBridge-$selected.local.</string><string>$local_ip</string>
<string>txtvers=1</string><string>qtotal=1</string><string>rp=printers/$selected</string>
<string>ty=$type_xml</string><string>product=($type_xml)</string><string>note=$note</string>
<string>pdl=application/pdf,image/jpeg,image/png,image/pwg-raster</string>
<string>URF=CP99,W8,OB10,PQ3-4-5,DM1,IS1-4</string>
<string>printer-state=3</string><string>printer-type=0x809006</string><string>UUID=$printer_uuid</string>
</array><key>RunAtLoad</key><true/><key>KeepAlive</key><true/>
</dict></plist>
EOF
chown root:wheel "$plist"
chmod 644 "$plist"
launchctl bootout system "$plist" >/dev/null 2>&1 || true
launchctl bootstrap system "$plist"
echo "Instalado: $plist"
echo "Anunciado como: $selected @ $safe_host"
