#!/usr/bin/env bash
# Zeltro (desktop app) for Linux: installs Zeltro CLI if it isn't there yet,
# then the newest app package for this distro. Run as your normal user; it uses
# sudo where it has to.
#
#   curl -fsSL https://dist.canebaycomputers.com/zeltro/ubuntu | bash
#
# Ubuntu/Debian (.deb), Fedora/RHEL (.rpm) and Arch (pacman), x86_64.
set -euo pipefail

BASE="https://github.com/CaneBayComputers/zeltro-releases/releases/latest/download"
CLI="https://raw.githubusercontent.com/CaneBayComputers/zeltro-cli/master"

say() { printf '\033[1;36m%s\033[0m\n' "$*"; }
die() { printf '\033[1;31m%s\033[0m\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "Run this as your normal user, not root. It uses sudo where it needs to."
[ "$(uname -s)" = Linux ] || die "This installer is for Linux. Windows: https://zeltro.build/download/windows"
[ "$(uname -m)" = x86_64 ] || die "Zeltro's Linux packages are x86_64 only for now."
[ -r /etc/os-release ] || die "Can't tell which Linux this is (no /etc/os-release)."

. /etc/os-release
ids=" ${ID:-} ${ID_LIKE:-} "
case "$ids" in
  *" ubuntu "*|*" debian "*)                      kind=deb;  cli=install-ubuntu.sh; pkg=zeltro-gui_amd64.deb ;;
  *" fedora "*|*" rhel "*|*" centos "*)          kind=rpm;  cli=install-fedora.sh; pkg=zeltro-gui.x86_64.rpm ;;
  *" arch "*)                                     kind=arch; cli=install-arch.sh;   pkg=zeltro-gui-x86_64.pkg.tar.zst ;;
  *) die "Unsupported Linux (${ID:-unknown}). Zeltro supports Ubuntu/Debian, Fedora/RHEL and Arch." ;;
esac

# The app is a front end for Zeltro CLI, so the CLI goes first.
if command -v zeltro >/dev/null 2>&1 || [ -x /usr/local/bin/zeltro ]; then
  say "✓ Zeltro CLI already installed"
else
  say "Installing Zeltro CLI…"
  curl -fsSL "$CLI/$cli" | bash
fi

tmp="$(mktemp -d)"
chmod 755 "$tmp"   # apt reads the file as its own user
trap 'rm -rf "$tmp"' EXIT

say "Downloading the Zeltro app…"
curl -fL --progress-bar -o "$tmp/$pkg" "$BASE/$pkg"
curl -fsSL -o "$tmp/SHA256SUMS.txt" "$BASE/SHA256SUMS.txt"
want="$(awk -v f="$pkg" '$2 == f { print $1 }' "$tmp/SHA256SUMS.txt")"
have="$(sha256sum "$tmp/$pkg" | awk '{ print $1 }')"
[ -n "$want" ] && [ "$want" = "$have" ] || die "Download check failed: $pkg doesn't match SHA256SUMS.txt."
say "✓ Package verified"

case "$kind" in
  deb)  sudo apt-get install -y "$tmp/$pkg" ;;
  rpm)  sudo dnf install -y "$tmp/$pkg" ;;
  arch) sudo pacman -U --noconfirm "$tmp/$pkg" ;;
esac

say "✓ Zeltro installed. Open it from your applications menu."
echo "  If the CLI was installed just now, log out and back in first so Docker works."
echo "  Free for personal use. Business use: https://zeltro.build/commercial"
