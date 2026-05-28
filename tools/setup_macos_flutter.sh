#!/usr/bin/env bash
# One-time setup for `flutter run -d macos` after Xcode is installed from App Store.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_APP="$ROOT/flutter_app"

echo "==> Checking Xcode..."
if [[ ! -d /Applications/Xcode.app ]]; then
  echo "Xcode not found. Install it from App Store, then run this script again:"
  echo "  open 'macappstore://apps.apple.com/app/xcode/id497799835'"
  exit 1
fi

echo "==> Selecting Xcode (needs your Mac password)..."
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

echo "==> Accepting Xcode license (if prompted)..."
sudo xcodebuild -license accept 2>/dev/null || true

echo "==> CocoaPods..."
if ! command -v pod >/dev/null 2>&1; then
  brew install cocoapods
fi

echo "==> macOS pods..."
cd "$FLUTTER_APP/macos"
pod install

echo "==> Flutter macOS desktop..."
cd "$FLUTTER_APP"
flutter config --enable-macos-desktop
flutter pub get

echo "==> Verifying..."
flutter doctor

echo ""
echo "Done. Start backend, then run:"
echo "  cd $FLUTTER_APP"
echo "  flutter run -d macos"
