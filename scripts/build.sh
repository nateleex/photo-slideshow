#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/PhotoSlideshow.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "==> Cleaning build directory..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS" "$RESOURCES"

# Fix SwiftBridging module redefinition by creating a VFS overlay
# that hides the duplicate bridging.modulemap
OVERLAY_DIR="$BUILD_DIR/vfs"
mkdir -p "$OVERLAY_DIR"
SWIFT_INCLUDE="/Library/Developer/CommandLineTools/usr/include/swift"

# Create a fixed module.modulemap that doesn't conflict
cp "$SWIFT_INCLUDE/module.modulemap" "$OVERLAY_DIR/module.modulemap"
# Create empty bridging.modulemap to prevent redefinition
cat > "$OVERLAY_DIR/bridging.modulemap" << 'MODMAP'
// intentionally empty - SwiftBridging defined in module.modulemap
MODMAP

cat > "$BUILD_DIR/vfs-overlay.yaml" << YAML
{
  "version": 0,
  "case-sensitive": "false",
  "roots": [
    {
      "name": "$SWIFT_INCLUDE",
      "type": "directory",
      "contents": [
        {
          "name": "bridging.modulemap",
          "type": "file",
          "external-contents": "$OVERLAY_DIR/bridging.modulemap"
        }
      ]
    }
  ]
}
YAML

echo "==> Compiling..."
cd "$PROJECT_DIR"

SOURCES=$(find Sources -name '*.swift' | sort)

swiftc \
    -O \
    -target arm64-apple-macosx14.0 \
    -sdk "$(xcrun --show-sdk-path)" \
    -framework AppKit \
    -framework SwiftUI \
    -framework Photos \
    -Xfrontend -vfsoverlay -Xfrontend "$BUILD_DIR/vfs-overlay.yaml" \
    -o "$MACOS/PhotoSlideshow" \
    $SOURCES \
    2>&1

echo "==> Assembling app bundle..."
cp "$PROJECT_DIR/resources/Info.plist" "$CONTENTS/Info.plist"

echo "==> Ad-hoc signing..."
codesign --force --sign - \
    --entitlements "$PROJECT_DIR/resources/PhotoSlideshow.entitlements" \
    "$APP_BUNDLE"

echo "==> Done: $APP_BUNDLE"
