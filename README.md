# Mac Storage Monitor

macOS メニューバーに常駐し、ディスク使用量とアプリごとのストレージ消費をモニタリングするユーティリティアプリです。

## 機能

- **メニューバー常駐**: ディスク使用率をメニューバーにリアルタイム表示
- **ディスク概要**: 全体のディスク使用量/空き容量を一目で確認
- **TOP 10 アプリ使用量**: ストレージを多く消費しているアプリをランキング表示
- **インストール元検出**: App Store / Homebrew / 手動インストールを自動判別
- **定期スキャン**: 設定可能な間隔で自動スキャン（5分〜24時間）
- **ログイン時自動起動**: macOSログイン時にアプリを自動起動するON/OFF設定

## スクリーンショット

メニューバーにディスク使用率（%）が表示され、クリックするとポップオーバーで詳細情報を確認できます。

## 動作環境

- macOS 14 (Sonoma) 以降
- Apple Silicon / Intel Mac

## ビルド方法

Swift Package Manager を使用しています。

```bash
# デバッグビルド
swift build

# リリースビルド
swift build -c release
```

## .app バンドルの作成とインストール

ローカルでビルドして `.app` を生成します。

```bash
# .app バンドルを生成
./scripts/build-app.sh

# /Applications にインストール
cp -r MacStorageMonitor.app /Applications/

# または直接起動
open MacStorageMonitor.app
```

> **Note**: コード署名の都合上、GitHub Actions でのビルド配布は行っていません。ローカルでビルドしてご利用ください。

## プロジェクト構成

```
MacStorageMonitor/
├── MacStorageMonitorApp.swift    # アプリエントリポイント（MenuBarExtra）
├── Models/
│   ├── AppStorageRecord.swift    # アプリストレージ情報モデル（SwiftData）
│   ├── DiskUsageInfo.swift       # ディスク使用量情報
│   ├── InstallSource.swift       # インストール元列挙型
│   ├── RelatedFileRecord.swift   # 関連ファイル情報モデル
│   └── ScanHistory.swift         # スキャン履歴モデル
├── Services/
│   ├── LaunchAtLoginService.swift   # ログイン時自動起動管理
│   ├── ScanSchedulerService.swift   # スキャンスケジューラ
│   ├── SettingsService.swift        # ユーザー設定管理
│   └── StorageService.swift         # ストレージ情報取得
├── ViewModels/
│   └── StorageViewModel.swift    # メインViewModel
├── Views/
│   ├── AppStorageInfoRow.swift   # アプリ情報行
│   ├── DiskOverviewSection.swift # ディスク概要セクション
│   ├── FooterSection.swift       # フッターセクション
│   ├── PopoverContentView.swift  # ポップオーバーメインビュー
│   └── SettingsView.swift        # 設定画面
├── Engines/
│   └── ...                       # スキャンエンジン
└── Utilities/
    └── ...                       # ユーティリティ
```

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 言語 | Swift 5.9+ |
| UI | SwiftUI (MenuBarExtra) |
| データ永続化 | SwiftData |
| 設定管理 | UserDefaults |
| 自動起動 | ServiceManagement (SMAppService) |
| ビルド | Swift Package Manager |
| 対象OS | macOS 14+ |

## 設定項目

| 設定 | 説明 | デフォルト |
|---|---|---|
| スキャン間隔 | 自動スキャンの実行間隔 | 1時間 |
| ログイン時自動起動 | macOSログイン時にアプリを自動起動 | OFF |

## 開発ワークフロー

このプロジェクトは [AI-DLC (AI-Driven Development Life Cycle)](https://github.com/aws-samples/ai-dlc) ワークフローを使用して開発されています。ワークフロー定義は `.kiro/steering/aws-aidlc-rules/` に格納されています。

## ライセンス

Private repository.
