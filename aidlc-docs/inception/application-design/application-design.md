# Application Design 統合ドキュメント: Mac Storage Monitor

## 設計概要

| 項目 | 決定事項 |
|------|----------|
| **アーキテクチャ** | MVVM（Model-View-ViewModel） |
| **UIフレームワーク** | SwiftUI + MenuBarExtra |
| **データ永続化** | SwiftData |
| **非同期処理** | Swift Concurrency（async/await） |
| **スケジューリング** | Timer ベースのバックグラウンドスキャン |

---

## コンポーネント一覧（9コンポーネント）

| # | コンポーネント | レイヤー | 目的 |
|---|---|---|---|
| 1 | MacStorageMonitorApp | App | エントリーポイント、メニューバー常駐 |
| 2 | StorageScanEngine | Engine | ファイルシステムスキャン、サイズ集計 |
| 3 | InstallSourceDetector | Engine | インストール元判定（Homebrew/AppStore/直接DL） |
| 4 | ScanScheduler | Service | 定期スキャンスケジューリング |
| 5 | StorageViewModel | ViewModel | UI-データ接続、状態管理 |
| 6 | MenuBarView | View | メニューバーパーセンテージ表示 |
| 7 | PopoverContentView | View | ポップオーバーメインUI |
| 8 | AppStorageInfoRow | View | アプリ一覧の各行表示 |
| 9 | DataModels | Data | SwiftDataモデル定義 |

---

## サービス層（3サービス）

| # | サービス | 目的 |
|---|---|---|
| 1 | StorageService | スキャン統合オーケストレーション |
| 2 | ScanSchedulerService | バックグラウンドスキャン管理 |
| 3 | SettingsService | ユーザー設定管理 |

---

## レイヤー構成

```
+------------------------------------------+
|            Presentation Layer             |
|  MenuBarView | PopoverContentView        |
|  AppStorageInfoRow                        |
+------------------------------------------+
|            ViewModel Layer                |
|  StorageViewModel                         |
+------------------------------------------+
|            Service Layer                  |
|  StorageService | ScanSchedulerService   |
|  SettingsService                          |
+------------------------------------------+
|            Engine Layer                   |
|  StorageScanEngine | InstallSourceDetector|
+------------------------------------------+
|            Data Layer                     |
|  SwiftData Models | UserDefaults          |
+------------------------------------------+
|            System Layer                   |
|  FileManager | Process | NSWorkspace      |
+------------------------------------------+
```

---

## 主要データフロー

1. **起動時**: App → ScanSchedulerService.start() → StorageService.performFullScan() → ViewModel更新
2. **定期スキャン**: Timer発火 → ScanSchedulerService → StorageService → ViewModel更新 → UI自動更新
3. **手動スキャン**: ユーザーボタン → ViewModel.performScan() → StorageService → UI更新
4. **メニューバー表示**: ViewModel.diskUsagePercentage() → MenuBarView（常時更新）

---

## Homebrew検出戦略

二重検出方式を採用:
1. `brew list --cask` コマンド実行 → インストール済みCask一覧取得
2. `/opt/homebrew/Caskroom/` ディレクトリスキャン → Caskroom内のアプリ検出
3. 両方の結果をマージして確実な検出を実現

---

## 詳細ドキュメント参照

- コンポーネント詳細: `components.md`
- メソッド定義: `component-methods.md`
- サービス定義: `services.md`
- 依存関係: `component-dependency.md`
