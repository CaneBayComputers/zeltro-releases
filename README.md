# Zeltro — downloads

Installers for **Zeltro**, the desktop app for building and running projects with AI. This repository holds release builds only; the app is closed source. More at **[zeltro.build](https://zeltro.build)**.

## Install

**Windows 10 (2004+) / 11:** download **[Zeltro-Setup.exe](https://github.com/CaneBayComputers/zeltro-releases/releases/latest/download/Zeltro-Setup.exe)** and run it. It installs for your account only, with no administrator rights. The installer isn't code-signed yet, so the first time Windows shows *"Windows protected your PC"*: click **More info**, then **Run anyway**.

**Linux** (Ubuntu/Debian, Fedora/RHEL, Arch; x86_64):

```bash
curl -fsSL https://dist.canebaycomputers.com/zeltro/ubuntu | bash
```

This installs [Zeltro CLI](https://github.com/CaneBayComputers/zeltro-cli) if it's missing, then the right package for your distro, checked against `SHA256SUMS.txt`. The packages are also attached to each [release](https://github.com/CaneBayComputers/zeltro-releases/releases) if you'd rather install one yourself.

**macOS:** coming soon.

Installed copies update themselves: **Updates**, in the app's footer.

## License

Free for personal use. Commercial use needs a **Lifetime Commercial License: US$99.99 once, per business**, at [zeltro.build/commercial](https://zeltro.build/commercial).

Use is governed by the [End User License Agreement](https://zeltro.build/terms). The app sends anonymous usage counts and scrubbed error reports; see the [privacy policy](https://zeltro.build/privacy).

## Support

canebaycomputers@gmail.com · Cane Bay Computers & Mobile
