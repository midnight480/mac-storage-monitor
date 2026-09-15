#!/bin/bash
# Mac Storage Monitor — .app バンドル生成スクリプト
# 使用方法: ./scripts/build-app.sh

set -e

APP_NAME="MacStorageMonitor"
BUNDLE_ID="com.local.MacStorageMonitor"
RESOURCE_BUNDLE="${APP_NAME}_${APP_NAME}.bundle"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "🔨 リリースビルド中..."
swift build -c release

echo "📦 .app バンドル作成中..."

# 既存のバンドルを削除
rm -rf "${APP_BUNDLE}"

# ディレクトリ構造作成
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# バイナリをコピー
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"

# リソースバンドル（ローカライズ文字列）をコピー
cp -R "${BUILD_DIR}/${RESOURCE_BUNDLE}" "${RESOURCES_DIR}/${RESOURCE_BUNDLE}"

# Info.plist 作成
cat > "${CONTENTS_DIR}/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>ja</string>
    <key>CFBundleExecutable</key>
    <string>MacStorageMonitor</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.MacStorageMonitor</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Mac Storage Monitor</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# ad-hoc 署名（Info.plist・リソースを署名に含め、識別子をバンドルIDに揃える）
# linker 署名のままだと macOS 27 のメニューバーでアプリとして識別されない
echo "🔏 署名中..."
codesign --force --sign - --identifier "${BUNDLE_ID}" "${APP_BUNDLE}"
codesign --verify --strict "${APP_BUNDLE}"

echo "✅ ビルド完了: ${APP_BUNDLE}"
echo ""
echo "実行方法:"
echo "  open ${APP_BUNDLE}"
echo ""
echo "/Applications にインストール:"
echo "  cp -r ${APP_BUNDLE} /Applications/"
