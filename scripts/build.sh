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
# that hides the duplicate bridging.modulemap (CLT-specific issue)
SWIFT_INCLUDE="/Library/Developer/CommandLineTools/usr/include/swift"
VFS_FLAGS=""

if [[ -f "$SWIFT_INCLUDE/bridging.modulemap" && -f "$SWIFT_INCLUDE/module.modulemap" ]]; then
    echo "==> Creating VFS overlay (CLT bridging.modulemap workaround)..."
    OVERLAY_DIR="$BUILD_DIR/vfs"
    mkdir -p "$OVERLAY_DIR"

    cp "$SWIFT_INCLUDE/module.modulemap" "$OVERLAY_DIR/module.modulemap"
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
    VFS_FLAGS="-Xfrontend -vfsoverlay -Xfrontend $BUILD_DIR/vfs-overlay.yaml"
fi

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
    $VFS_FLAGS \
    -o "$MACOS/PhotoSlideshow" \
    $SOURCES \
    2>&1

echo "==> Assembling app bundle..."
cp "$PROJECT_DIR/resources/Info.plist" "$CONTENTS/Info.plist"
cp "$PROJECT_DIR/resources/AppIcon.icns" "$RESOURCES/AppIcon.icns"

# Inject version from git tag (e.g. v1.1.0 -> 1.1.0)
VERSION=$(git -C "$PROJECT_DIR" describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
if [[ -n "$VERSION" ]]; then
    echo "==> Setting version to $VERSION"
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$CONTENTS/Info.plist"
    BUILD_NUM=$(git -C "$PROJECT_DIR" rev-list "$(git -C "$PROJECT_DIR" describe --tags --abbrev=0)"..HEAD --count 2>/dev/null || echo "0")
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUM" "$CONTENTS/Info.plist"
fi

echo "==> Ad-hoc signing..."
codesign --force --sign - \
    --entitlements "$PROJECT_DIR/resources/PhotoSlideshow.entitlements" \
    "$APP_BUNDLE"

echo "==> Done: $APP_BUNDLE"
