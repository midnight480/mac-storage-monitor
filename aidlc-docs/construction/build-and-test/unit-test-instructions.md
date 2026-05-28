# ユニットテスト手順: Mac Storage Monitor

## テスト対象コンポーネント

### テスト可能なユニット
| コンポーネント | テスト内容 |
|---|---|
| FileSizeFormatter | サイズフォーマット変換の正確性 |
| InstallSource | enum値、表示名、バッジ色の正確性 |
| DiskUsageInfo | パーセンテージ計算の正確性 |
| SettingsService | スキャン間隔の保存/読み込み、範囲制約 |

### モック/スタブが必要なユニット
| コンポーネント | モック対象 |
|---|---|
| StorageScanEngine | FileManager（ファイルシステムアクセス） |
| InstallSourceDetector | Process（brewコマンド）、FileManager |
| StorageService | ModelContext（SwiftData） |
| ScanSchedulerService | Timer、コールバック |

## テスト実行

### 1. テストターゲット追加（Package.swift修正が必要）

```swift
// Package.swift にテストターゲットを追加
.testTarget(
    name: "MacStorageMonitorTests",
    dependencies: ["MacStorageMonitor"],
    path: "Tests"
)
```

### 2. テスト実行コマンド
```bash
swift test
```

### 3. 特定テストのみ実行
```bash
swift test --filter FileSizeFormatterTests
```

## 推奨テストケース

### FileSizeFormatter テスト
```swift
// テストケース:
// - 0 B → "0 B"
// - 512 B → "512 B"
// - 1024 B → "1 KB"
// - 1536 B → "1 KB"
// - 1048576 B → "1.0 MB"
// - 47185920 B → "45.0 MB"
// - 1073741824 B → "1.00 GB"
// - 2516582400 B → "2.34 GB"
```

### DiskUsageInfo テスト
```swift
// テストケース:
// - 正常値: usagePercentage が正しく計算される
// - totalCapacity = 0: usagePercentage = 0（ゼロ除算防止）
// - 100%使用: usagePercentage = 100
```

### SettingsService テスト
```swift
// テストケース:
// - デフォルト値: 3600秒
// - 最小値制約: 300秒未満 → 300秒にクランプ
// - 最大値制約: 86400秒超 → 86400秒にクランプ
// - 正常範囲: そのまま保存
```

### InstallSource テスト
```swift
// テストケース:
// - 各rawValue → enum変換
// - 各displayName の正確性
// - 各badgeEmoji の正確性
// - 不正なrawValue → nil
```

## テスト結果の期待値
- **テスト数**: 約15-20テストケース
- **合格率**: 100%
- **カバレッジ目標**: ユーティリティ/モデル層 90%以上

## 注意事項
- StorageScanEngine と InstallSourceDetector はファイルシステムとプロセス実行に依存するため、統合テストとして扱う
- SwiftData関連のテストはインメモリコンテナを使用する
- UIテスト（View層）は手動確認で代替
