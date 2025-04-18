#!/bin/bash
set -euo pipefail
echo "Restoring enabled GNOME extensions..."

if ! command -v gnome-extensions &>/dev/null; then
  echo "❌ gnome-extensions CLI not found."
  exit 1
fi

while read -r uuid || [[ -n "$uuid" ]]; do
  [ -z "$uuid" ] && continue
  ext_dir="$HOME/.local/share/gnome-shell/extensions/$uuid"
  sys_ext_dir="/usr/share/gnome-shell/extensions/$uuid"

  if [ -d "$ext_dir" ] || [ -d "$sys_ext_dir" ]; then
    echo "✅ Found $uuid locally or system-wide, enabling..."
    gnome-extensions enable "$uuid"
  else
    echo "🌐 $uuid missing. Trying to install from GNOME Extensions website..."
    if command -v gnome-shell-extension-installer &>/dev/null; then
      gnome-shell-extension-installer --yes "$uuid" || echo "❌ Could not install $uuid"
      gnome-extensions enable "$uuid" || echo "❌ Could not enable $uuid"
    else
      echo "❌ gnome-shell-extension-installer not found"
    fi
  fi
done < "$HOME/.dotfiles/gnome-extensions-enabled.txt"
