# Code Generation 計画: Mac Storage Monitor

## ユニットコンテキスト
- **プロジェクトタイプ**: Greenfield、単一ユニット
- **言語/フレームワーク**: Swift + SwiftUI
- **アーキテクチャ**: MVVM
- **データ永続化**: SwiftData
- **ターゲット**: macOS メニューバー常駐アプリ
- **コード配置**: ワークスペースルート直下に Xcode プロジェクト構造

## プロジェクト構造

```
MacStorageMonitor/
├── MacStorageMonitor.xcodeproj/
├── MacStorageMonitor/
│   ├── MacStorageMonitorApp.swift          # エントリーポイント
│   ├── Models/
│   │   ├── AppStorageRecord.swift          # SwiftData モデル
│   │   ├── RelatedFileRecord.swift         # SwiftData モデル
│   │   ├── ScanHistory.swift               # SwiftData モデル
│   │   ├── DiskUsageInfo.swift             # 非永続化モデル
│   │   └── InstallSource.swift             # enum
│   ├── ViewModels/
│   │   └── StorageViewModel.swift          # メインViewModel
│   ├── Views/
│   │   ├── PopoverContentView.swift        # ポップオーバー本体
│   │   ├── DiskOverviewSection.swift       # ディスク概要セクション
│   │   ├── AppListSection.swift            # アプリ一覧セクション
│   │   ├── AppStorageInfoRow.swift         # アプリ行表示
│   │   └── FooterSection.swift             # フッターセクション
│   ├── Services/
│   │   ├── StorageService.swift            # メインオーケストレーター
│   │   ├── ScanSchedulerService.swift      # スケジューラ
│   │   └── SettingsService.swift           # 設定管理
│   ├── Engines/
│   │   ├── StorageScanEngine.swift         # ファイルスキャンエンジン
│   │   └── InstallSourceDetector.swift     # インストール元判定
│   ├── Utilities/
│   │   └── FileSizeFormatter.swift         # サイズフォーマッタ
│   └── Assets.xcassets/
│       └── AppIcon.appiconset/
└── MacStorageMonitor.entitlements
```

---

## 生成ステップ

### Step 1: プロジェクト構造セットアップ
- [x] Xcode プロジェクトディレクトリ構造を作成
- [x] Info.plist 相当の設定（LSUIElement = true でDock非表示）
- [x] Entitlements ファイル作成（App Sandbox無効 — ローカルビルド専用）

### Step 2: データモデル生成
- [x] AppStorageRecord.swift（SwiftData @Model）
- [x] RelatedFileRecord.swift（SwiftData @Model）
- [x] ScanHistory.swift（SwiftData @Model）
- [x] DiskUsageInfo.swift（struct）
- [x] InstallSource.swift（enum）

### Step 3: エンジン層生成
- [x] StorageScanEngine.swift — ファイルシステムスキャン、関連ファイル検出、サイズ集計
- [x] InstallSourceDetector.swift — Homebrew/AppStore/直接DL判定

### Step 4: サービス層生成
- [x] StorageService.swift — スキャン統合オーケストレーション、SwiftData永続化
- [x] ScanSchedulerService.swift — Timer ベース定期スキャン
- [x] SettingsService.swift — UserDefaults によるスキャン間隔管理

### Step 5: ViewModel生成
- [x] StorageViewModel.swift — UI状態管理、スキャン実行、TOP10提供

### Step 6: View層生成
- [x] PopoverContentView.swift — ポップオーバーメインレイアウト
- [x] DiskOverviewSection.swift — ディスク使用量表示
- [x] AppListSection.swift — アプリ一覧TOP10
- [x] AppStorageInfoRow.swift — 各アプリ行（アイコン、名前、バッジ、サイズ）
- [x] FooterSection.swift — 再スキャン、間隔設定、終了

### Step 7: ユーティリティ生成
- [x] FileSizeFormatter.swift — B/KB/MB/GB フォーマット

### Step 8: アプリエントリーポイント生成
- [x] MacStorageMonitorApp.swift — @main、MenuBarExtra、SwiftData Container初期化

### Step 9: ビルド設定
- [x] Package.swift または .xcodeproj 設定（macOS deployment target、signing無効）

### Step 10: ドキュメント生成
- [x] aidlc-docs/construction/mac-storage-monitor/code/code-summary.md — 生成コードのサマリー

---

## 生成方針
- Swift 5.9+ / macOS 14.0+ (Sonoma) ターゲット
- SwiftUI の MenuBarExtra API を使用（macOS 13+）
- SwiftData を使用（macOS 14+）
- @Observable マクロ（macOS 14+）を使用
- async/await による非同期処理
- App Sandbox 無効（Full Disk Access不要、~/Library/ アクセスのため）
- コード署名なし（ローカルビルド専用）
- コメントは日本語
