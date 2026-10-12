# macOS IPP / Bonjour Printer Bridge

Comparte una impresora CUPS, incluidas impresoras USB, mediante IPP y Bonjour para que un iPhone o iPad de la misma red pueda intentar descubrirla desde **Compartir → Imprimir**.

El Mac debe permanecer encendido y en la misma red local. Esto no convierte la impresora en un dispositivo AirPrint certificado; la compatibilidad final depende de iOS y del controlador CUPS.

## Instalación

Revisa el script antes de ejecutarlo:

```bash
git clone https://github.com/r03r/mac-printer-bridge.git
cd mac-printer-bridge
sudo ./install.sh
```

El instalador detecta las colas CUPS, permite elegir una si hay varias y crea un LaunchDaemon en `/Library/LaunchDaemons`.

## Desinstalación

```bash
sudo ./uninstall.sh M2020
```

## Diagnóstico

```bash
lpstat -p -d
dns-sd -B _ipp._tcp local.
```

Las redes de invitados, el aislamiento de clientes y una VPN pueden impedir Bonjour.

## Homebrew

La fórmula de `Formula/mac-printer-bridge.rb` está preparada para un tap propio. Para publicarla como fórmula estable, crea primero una release/tag y actualiza el `url` y el `sha256` de esa release.

## Licencia

MIT. Consulta [LICENSE](LICENSE).
