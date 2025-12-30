#!/bin/bash

# Build Release script for SoundMax
# Creates a DMG installer for distribution

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="SoundMax"
DMG_NAME="SoundMax-Installer"

echo "=== Building SoundMax Release ==="

# Clean previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build release version
echo "Building release..."
cd "$PROJECT_DIR"
xcodebuild -project SoundMax.xcodeproj \
    -scheme SoundMax \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    clean build

# Find the built app
APP_PATH="$BUILD_DIR/DerivedData/Build/Products/Release/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Could not find built app at $APP_PATH"
    exit 1
fi

echo "App built successfully at: $APP_PATH"

# Create DMG
echo "Creating DMG..."
DMG_DIR="$BUILD_DIR/dmg"
mkdir -p "$DMG_DIR"

# Copy app to DMG staging
cp -R "$APP_PATH" "$DMG_DIR/"

# Create symbolic link to Applications
ln -s /Applications "$DMG_DIR/Applications"

# Create the DMG
DMG_PATH="$BUILD_DIR/$DMG_NAME.dmg"
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

echo ""
echo "=== Build Complete ==="
echo "DMG created at: $DMG_PATH"
echo ""
echo "To distribute:"
echo "1. For unsigned distribution: Users right-click > Open to bypass Gatekeeper"
echo "2. For signed distribution: Sign with 'codesign' and notarize with 'xcrun notarytool'"
