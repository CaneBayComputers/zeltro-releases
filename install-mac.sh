#!/usr/bin/env bash
# Zeltro (desktop app) for macOS: installs Zeltro CLI if it isn't there yet
# (which brings Homebrew and Docker), then the app from the Zeltro Homebrew tap,
# so `brew upgrade` (or Updates, in the app) keeps it current.
#
#   curl -fsSL https://dist.canebaycomputers.com/zeltro/mac | bash
#
# Apple Silicon and Intel. Run as your normal user.
set -euo pipefail

CLI="https://raw.githubusercontent.com/CaneBayComputers/zeltro-cli/master"
CASK="canebaycomputers/zeltro/zeltro"

say() { printf '\033[1;36m%s\033[0m\n' "$*"; }
die() { printf '\033[1;31m%s\033[0m\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || die "This installer is for macOS. Linux: https://zeltro.build/download"
[ "$(id -u)" -ne 0 ] || die "Run this as your normal user, not root."

# The app is a front end for Zeltro CLI, so the CLI goes first. Its installer
# also sets up Homebrew, Docker and the Xcode command line tools.
if command -v zeltro >/dev/null 2>&1 || [ -x /usr/local/bin/zeltro ]; then
  say "✓ Zeltro CLI already installed"
else
  say "Installing Zeltro CLI…"
  curl -fsSL "$CLI/install-mac.sh" | bash
fi

for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [ -x "$b" ] && eval "$("$b" shellenv)" && break
done
command -v brew >/dev/null 2>&1 || die "Homebrew isn't installed. Install it from https://brew.sh, then run this again."

if brew list --cask zeltro >/dev/null 2>&1; then
  say "Updating the Zeltro app…"
  brew upgrade --cask "$CASK" || true
else
  say "Installing the Zeltro app…"
  brew install --cask "$CASK"
fi

say "✓ Zeltro installed. Open it from Applications."
echo "  Updates: Updates, in the app's footer, or: brew upgrade --cask zeltro"
echo "  If the CLI was installed just now, start Docker Desktop once before your first project."
echo "  Free for personal use. Business use: https://zeltro.build/commercial"
