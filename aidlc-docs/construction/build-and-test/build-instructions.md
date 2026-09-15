# ビルド手順: Mac Storage Monitor

## 前提条件
- **ビルドツール**: Swift Package Manager (swift 5.9+)
- **OS**: macOS 14.0 (Sonoma) 以上
- **Xcode**: 15.0 以上（Command Line Tools含む）
- **依存関係**: 外部依存なし（Apple標準フレームワークのみ）

## ビルド手順

### 1. リポジトリクローン
```bash
git clone <repository-url>
cd mac-storage-monitor
```

### 2. ビルド実行
```bash
swift build
```

### 3. リリースビルド（最適化あり）
```bash
swift build -c release
```

### 4. ビルド成果物の場所
- **デバッグビルド**: `.build/debug/MacStorageMonitor`
- **リリースビルド**: `.build/release/MacStorageMonitor`

### 5. アプリ実行
```bash
# デバッグビルドを実行
.build/debug/MacStorageMonitor

# リリースビルドを実行
.build/release/MacStorageMonitor
```

### 6. ビルド成功の確認
- 出力に `Build complete!` が表示されること
- 警告（warning）が0件であること
- `.build/debug/MacStorageMonitor` バイナリが生成されていること

## .app バンドルのビルド（macos27-menubar-fix で更新）

メニューバー常駐アプリとして使う場合は、必ずスクリプトで `.app` を生成する。

```bash
./scripts/build-app.sh
```

スクリプトの処理:
1. `swift build -c release`
2. `MacStorageMonitor.app/Contents/MacOS` にバイナリをコピー
3. `Contents/Resources` に `MacStorageMonitor_MacStorageMonitor.bundle`（ローカライズ文字列）をコピー
4. `Contents/Info.plist` を生成（`CFBundleIdentifier=com.local.MacStorageMonitor`, `LSUIElement=true`）
5. `codesign --force --sign - --identifier com.local.MacStorageMonitor` で ad-hoc 署名
6. `codesign --verify --strict` で検証

### 署名の確認
```bash
codesign -dvv MacStorageMonitor.app 2>&1 | grep -E "Identifier|Info.plist|Sealed"
# 期待値:
# Identifier=com.local.MacStorageMonitor
# Info.plist entries=11
# Sealed Resources version=2 rules=13 files=3

codesign --verify --strict --verbose=2 MacStorageMonitor.app
# 期待値: valid on disk / satisfies its Designated Requirement
```

## Xcodeでのビルド（オプション）

Xcodeで開発する場合：

```bash
# Xcodeプロジェクトを生成して開く
open Package.swift
```

Xcode内で:
1. スキーム「MacStorageMonitor」を選択
2. ⌘+B でビルド
3. ⌘+R で実行

## トラブルシューティング

### Swift バージョンエラー
- **原因**: Swift 5.9未満のバージョンを使用
- **解決**: `swift --version` で確認し、Xcode 15以上をインストール

### macOS SDK エラー
- **原因**: macOS 14 SDK が見つからない
- **解決**: `xcode-select --install` でCommand Line Toolsをインストール

### SwiftData コンパイルエラー
- **原因**: macOS 14未満のSDKを使用
- **解決**: Xcode 15以上を使用し、macOS 14+ SDKが含まれていることを確認

### メニューバーに表示されない / メニューバー管理アプリに認識されない（macOS 27+）
- **原因**: `.build/release/MacStorageMonitor` を手動で `.app` に詰めただけで、linker 署名（Identifier=`MacStorageMonitor`, Info.plist not bound）のまま起動している
- **解決**: `./scripts/build-app.sh` で再生成し、`codesign -dvv` で Identifier がバンドルIDになっていることを確認する。Thaw 等を使っている場合は、設定で「Mac Storage Monitor」を表示セクションへ移動する

### 起動後に `could not load resource bundle` でクラッシュ
- **原因**: `.app` にリソースバンドルが同梱されておらず、ビルドディレクトリも存在しない
- **解決**: `./scripts/build-app.sh` で再生成し、`MacStorageMonitor.app/Contents/Resources/MacStorageMonitor_MacStorageMonitor.bundle` があることを確認する
