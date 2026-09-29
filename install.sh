#!/usr/bin/env bash
# Zeltro (desktop app) for Linux: installs Zeltro CLI if it isn't there yet,
# adds the Zeltro package repository (packages.zeltro.build, signed), and
# installs the app from it, so it updates with the system's own updates
# (apt upgrade / dnf upgrade / pacman -Syu). Run as your normal user; it uses
# sudo where it has to.
#
#   curl -fsSL https://dist.canebaycomputers.com/zeltro/ubuntu | bash
#
# Ubuntu/Debian (.deb), Fedora/RHEL (.rpm) and Arch (pacman), x86_64.
set -euo pipefail

REPO="https://packages.zeltro.build"
# The Zeltro Packages signing key. The downloaded key must match it.
FPR="1DEA3164BE9F0679D99133150970B41FFA5E9F7B"
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
  *" ubuntu "*|*" debian "*)                      kind=deb;  cli=install-ubuntu.sh ;;
  *" fedora "*|*" rhel "*|*" centos "*)          kind=rpm;  cli=install-fedora.sh ;;
  *" arch "*)                                     kind=arch; cli=install-arch.sh ;;
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
trap 'rm -rf "$tmp"' EXIT

say "Adding the Zeltro package repository…"
curl -fsSL -o "$tmp/zeltro.asc" "$REPO/zeltro.asc"
if command -v gpg >/dev/null 2>&1; then
  got="$(gpg --show-keys --with-colons "$tmp/zeltro.asc" 2>/dev/null | awk -F: '/^fpr/ { print $10; exit }')"
  [ "$got" = "$FPR" ] || die "The repository key is not the Zeltro key (got ${got:-nothing}). Stopping."
fi

case "$kind" in
  deb)
    sudo install -D -m 644 "$tmp/zeltro.asc" /etc/apt/keyrings/zeltro.asc
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/zeltro.asc] $REPO/apt stable main" \
      | sudo tee /etc/apt/sources.list.d/zeltro.list >/dev/null
    sudo apt-get update -o Dir::Etc::sourcelist=sources.list.d/zeltro.list \
      -o Dir::Etc::sourceparts=- -o APT::Get::List-Cleanup=0 >/dev/null
    say "Installing the Zeltro app…"
    sudo apt-get install -y zeltro-gui ;;
  rpm)
    sudo install -D -m 644 "$tmp/zeltro.asc" /etc/pki/rpm-gpg/RPM-GPG-KEY-zeltro
    printf '%s\n' '[zeltro]' 'name=Zeltro' "baseurl=$REPO/rpm" 'enabled=1' 'gpgcheck=1' \
      'repo_gpgcheck=1' 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zeltro' \
      | sudo tee /etc/yum.repos.d/zeltro.repo >/dev/null
    say "Installing the Zeltro app…"
    sudo dnf install -y zeltro-gui ;;
  arch)
    sudo pacman-key --add "$tmp/zeltro.asc" >/dev/null
    sudo pacman-key --lsign-key "$FPR" >/dev/null
    if ! grep -q '^\[zeltro\]' /etc/pacman.conf; then
      printf '\n[zeltro]\nSigLevel = Required DatabaseRequired\nServer = %s/arch/$arch\n' "$REPO" \
        | sudo tee -a /etc/pacman.conf >/dev/null
    fi
    say "Installing the Zeltro app…"
    # -Syu, not -Sy: Arch does not support partial upgrades.
    sudo pacman -Syu --needed --noconfirm zeltro-gui ;;
esac

say "✓ Zeltro installed. Open it from your applications menu."
echo "  Updates arrive with your system's own (apt upgrade, dnf upgrade, pacman -Syu)."
echo "  If the CLI was installed just now, log out and back in first so Docker works."
echo "  Free for personal use. Business use: https://zeltro.build/commercial"
