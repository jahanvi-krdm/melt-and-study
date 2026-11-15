#!/bin/zsh
# Builds "Melt & Study.app" next to this script.
set -e
cd "$(dirname "$0")"
APP="Melt & Study.app"
BUILD=".build"
rm -rf "$APP" "$BUILD"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$BUILD/icon.iconset"

swiftc -O src/main.swift -o "$APP/Contents/MacOS/MeltStudy" -framework Cocoa -framework WebKit
cp src/index.html "$APP/Contents/Resources/"

# app icon
swift src/make_icon.swift "$BUILD/icon.png"
for s in 16 32 128 256 512; do
  sips -z $s $s "$BUILD/icon.png" --out "$BUILD/icon.iconset/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) "$BUILD/icon.png" --out "$BUILD/icon.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$BUILD/icon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Melt &amp; Study</string>
  <key>CFBundleDisplayName</key><string>Melt &amp; Study</string>
  <key>CFBundleIdentifier</key><string>local.meltstudy</string>
  <key>CFBundleExecutable</key><string>MeltStudy</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

codesign --force --deep -s - "$APP" 2>/dev/null || true
rm -rf "$BUILD"
echo "Built: $(pwd)/$APP"
