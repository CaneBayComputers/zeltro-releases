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
  # Run from a file, not piped into bash: piped, bash reads the script from
  # stdin, and any command in it that also reads stdin (brew does) swallows
  # the rest of the script, which then ends early and "succeeds".
  cli_installer="$(mktemp)"
  curl -fsSL "$CLI/$cli" -o "$cli_installer"
  bash "$cli_installer"
  rm -f "$cli_installer"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

say "Adding the Zeltro package repository…"
# The key is part of this script rather than downloaded, so trusting the
# repository never depends on what a server hands back.
cat > "$tmp/zeltro.asc" <<'KEY'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBGq7MdkBEADCzWp3nxiq1isFntODLbmAfW05mpILlqYw5awZ/lt2seRl2PIY
Yl5zbQadQgGGgRECAgWYmwShwKHOGzaZGnsHnkTmNcoeZyoQFwu1f/dSaBTjmFlk
SEpLcCJcdi7yImEMz0oEPsNdgzuMYeMLQOcTP6vHvhTiIjutQrEQXkf5pH+mZoHf
PqYiG1F+5lhIdCpPPIPmynALIfXKQmt4RrhXoTMQ+aZEHACawVXgoXn5f50Juccj
UqmqHpV369VIneVTcI3EJJBeyqVxj5+72wMYCrLlBhvit8v7xXNGTd0DEUHpOQKH
KOqfWSIIXvELfa/6yNA4L3jG84/Gf+i9aJ4c78qH9dkl79yQIhiwAtpMTdo/H1ca
0/mlZJyLmG1ZCjNHvrTg5r6DpxdtAmoJMtkr1advzNEdbPMqWYuomBdQVuSRw2NR
/QeOPl4SwMZ6qdliMhv5zogF6oj4KzfkVVqJeU5pq44SAImSbvHX7WATZxKTqyMC
/RboG05P8RF+yPeLRL4f1qv2Ypqufs3sU7mqS4uHMpB7oRa2WANVrQQzS1jGKhZW
C358GkRSdUriY2MuKNfHMoLivG7jIKLj7Um/ofErvrw1/GI4m1gu5EaJxiCJFQ8Y
YckUlsl2tPPiGtrHUvx3rGR5XFAeakMVkuH729HSkO9nVDEYbi2mepiDowARAQAB
tCxaZWx0cm8gUGFja2FnZXMgPGNhbmViYXljb21wdXRlcnNAZ21haWwuY29tPokC
UQQTAQoAOxYhBB3qMWS+nwZ52ZEzFQlwtB/6Xp97BQJquzHZAhsDBQsJCAcCAiIC
BhUKCQgLAgQWAgMBAh4HAheAAAoJEAlwtB/6Xp97ZxAQAJ3dWsdyp8QBOZE6rkJ8
BaLi4zIogYtokhxMAmnH4rxUBUXUte/0iH9CBdIKrvXgmj9YLVb9g9PYtPsWkP03
ejgoPiw+2P2xQFSOxPmMHy6Yj9kevTwxY5VOxjSTxxFifiQoIdJN1D/zGDaVNzMi
xIMA4E450e/lfuG1WaysWoQjpITiatfqs/B39rD5tq+edwCOWx0L/MEuVAgCs0fk
WjlN3/Gn+DHOD8WKqmrDxDew0jZZkS/aV3lGZoTv77yvDmyu9/JtQRphwObYUxWq
7JPIduxCPz/rk2xPUYlHJ2Yexxh+L5L8nBXolRl4/YB062kfHZcBFxMF1xih4zF4
shaKipxK0DloUH/UfNvScsy6z76xyEY3hi1UGKhPzmEOVSY+Hu/ZRfxiIEZamuug
pZdyzx7rdSmtkejjwM0ZgvpdoUAiU6CNpgHWaYFC58OFkJ0VfxQpgW/DGcuOSsqg
ZA+wN9tIjE++p2+6BR392jeMV8ppp/QDPT4QvRgrXls9GDzflpLc5Webg4KmJfSu
hUGBNvPo3PDn4VC655osBxcHgkzwY1WaoQg7M3smxBgdtK1HjFfcAVBCRS6HBTrG
1EVX9Hc8LZ1Mt2czydpDqz+2LJGuHXESg+hge4ySDxZOXHap6k/TxsU/oSQsYCl+
08SXh7yjOR15QBm0RN0UyNpE
=gRIH
-----END PGP PUBLIC KEY BLOCK-----
KEY

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
      'repo_gpgcheck=1' 'metadata_expire=6h' 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zeltro' \
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
    # -Syu, not -Sy: Arch does not support partial upgrades. That makes this a
    # full system upgrade, so pacman shows the list and asks. Its question is
    # read from the terminal: under `curl | bash`, stdin is this script.
    echo "  On Arch this also upgrades the rest of the system (Arch does not support partial upgrades)."
    if [ -r /dev/tty ] && : </dev/tty 2>/dev/null; then
      sudo pacman -Syu --needed zeltro-gui </dev/tty
    else
      sudo pacman -Syu --needed --noconfirm zeltro-gui
    fi ;;
esac

say "✓ Zeltro installed. Open it from your applications menu."
echo "  Updates arrive with your system's own (apt upgrade, dnf upgrade, pacman -Syu)."
echo "  If the CLI was installed just now, log out and back in first so Docker works."
echo "  Free for personal use. Business use: https://zeltro.build/commercial"
