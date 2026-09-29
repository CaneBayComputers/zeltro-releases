# Zeltro — downloads

Installers for **Zeltro**, the desktop app for building and running projects with AI. This repository holds release builds only; the app is closed source. More at **[zeltro.ai](https://zeltro.ai)**.

## Install

**Windows 10 (2004+) / 11:** download **[Zeltro-Setup.exe](https://github.com/CaneBayComputers/zeltro-releases/releases/latest/download/Zeltro-Setup.exe)** and run it. It installs for your account only, with no administrator rights. The installer isn't code-signed yet, so the first time Windows shows *"Windows protected your PC"*: click **More info**, then **Run anyway**.

**Linux** (Ubuntu/Debian, Fedora/RHEL, Arch; x86_64):

```bash
curl -fsSL https://dist.canebaycomputers.com/zeltro/ubuntu | bash
```

This installs [Zeltro CLI](https://github.com/CaneBayComputers/zeltro-cli) if it's missing, adds the signed Zeltro package repository, and installs the app from it, so it updates with the rest of your system (`apt upgrade`, `dnf upgrade`, `pacman -Syu`). The packages are also attached to each [release](https://github.com/CaneBayComputers/zeltro-releases/releases); a `.deb` or `.rpm` installed by hand adds the repository itself.

The repositories, if you'd rather set one up yourself (key fingerprint `1DEA 3164 BE9F 0679 D991  3315 0970 B41F FA5E 9F7B`, at [packages.zeltro.ai/zeltro.asc](https://packages.zeltro.ai/zeltro.asc)):

| | |
|---|---|
| apt | `deb [arch=amd64 signed-by=/etc/apt/keyrings/zeltro.asc] https://packages.zeltro.ai/apt stable main` |
| dnf | [`packages.zeltro.ai/rpm/zeltro.repo`](https://packages.zeltro.ai/rpm/zeltro.repo) into `/etc/yum.repos.d/` |
| pacman | `[zeltro]` · `SigLevel = Required DatabaseRequired` · `Server = https://packages.zeltro.ai/arch/$arch` |

**macOS** (Apple Silicon and Intel):

```bash
curl -fsSL https://raw.githubusercontent.com/CaneBayComputers/zeltro-releases/main/install-mac.sh | bash
```

This installs Zeltro CLI if it's missing (with Homebrew and Docker Desktop), then the app from the [Zeltro Homebrew tap](https://github.com/CaneBayComputers/homebrew-zeltro): `brew install --cask canebaycomputers/zeltro/zeltro`. Update with **Updates** in the app, or `brew upgrade --cask zeltro`.

Installed copies can also update themselves: **Updates**, in the app's footer.

## License

Free for personal use. Commercial use needs a **Lifetime Commercial License**, paid once, per business: see [zeltro.ai/commercial](https://zeltro.ai/commercial).

Use is governed by the [End User License Agreement](https://zeltro.ai/terms). The app sends usage counts and scrubbed error reports, and our servers record the IP address they come from; see the [privacy policy](https://zeltro.ai/privacy).

## Support

canebaycomputers@gmail.com · Cane Bay Computers & Mobile
