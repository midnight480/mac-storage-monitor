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
