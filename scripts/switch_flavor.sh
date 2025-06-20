#!/usr/bin/env bash

# Usage: ./scripts/switch_flavor.sh wallet|social
# This script swaps the splash/icon config in pubspec.yaml and regenerates splash/icons.

set -e

FLAVOR="$1"
if [[ "$FLAVOR" != "wallet" && "$FLAVOR" != "social" ]]; then
  echo "Usage: $0 wallet|social"
  exit 1
fi

PUBSPEC=pubspec.yaml
WALLET_BLOCK=scripts/pubspec_wallet.yaml
SOCIAL_BLOCK=scripts/pubspec_social.yaml

if [[ "$FLAVOR" == "wallet" ]]; then
  BLOCK="$WALLET_BLOCK"
else
  BLOCK="$SOCIAL_BLOCK"
fi

# Remove old config blocks (from flutter_launcher_icons to flutter_intl or end)
sed -i '/^flutter_launcher_icons:/,/^#flutter_intl:/d' "$PUBSPEC"

# Append the selected block to pubspec.yaml
cat "$BLOCK" >> "$PUBSPEC"

echo "[INFO] Updated pubspec.yaml for $FLAVOR flavor."

flutter pub get
#flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons:main

echo "[INFO] Splash and icons regenerated for $FLAVOR flavor." 
