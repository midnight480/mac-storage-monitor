# Code Generation サマリー: Mac Storage Monitor

## ビルド結果
- **ステータス**: ✅ ビルド成功（警告なし）
- **ビルドシステム**: Swift Package Manager
- **ターゲット**: macOS 14.0+ (Sonoma)
- **言語**: Swift 5.9+

## 生成ファイル一覧

### Models/ (5ファイル)
| ファイル | 目的 |
|---|---|
| AppStorageRecord.swift | SwiftData: アプリストレージ記録 |
| RelatedFileRecord.swift | SwiftData: 関連ファイル記録 + FileCategory enum |
| ScanHistory.swift | SwiftData: スキャン履歴 |
| DiskUsageInfo.swift | 非永続化: ディスク使用量情報 |
| InstallSource.swift | enum: インストール元（Homebrew/AppStore/Direct/Unknown） |

### Engines/ (2ファイル)
| ファイル | 目的 |
|---|---|
| StorageScanEngine.swift | ファイルシステムスキャン、関連ファイル検出、サイズ集計 |
| InstallSourceDetector.swift | インストール元判定（brew + Caskroom + MASReceipt） |

### Services/ (3ファイル)
| ファイル | 目的 |
|---|---|
| StorageService.swift | スキャン統合オーケストレーション、SwiftData永続化 |
| ScanSchedulerService.swift | Timer ベース定期スキャン管理 |
| SettingsService.swift | UserDefaults によるスキャン間隔設定管理 |

### ViewModels/ (1ファイル)
| ファイル | 目的 |
|---|---|
| StorageViewModel.swift | @Observable ViewModel、UI状態管理 |

### Views/ (5ファイル)
| ファイル | 目的 |
|---|---|
| PopoverContentView.swift | ポップオーバーメインレイアウト |
| DiskOverviewSection.swift | ディスク使用量プログレスバー表示 |
| AppListSection.swift | アプリTOP10リスト表示 |
| AppStorageInfoRow.swift | 各アプリ行（アイコン、名前、バッジ、サイズ） |
| FooterSection.swift | 再スキャン、間隔設定、終了ボタン |

### Utilities/ (1ファイル)
| ファイル | 目的 |
|---|---|
| FileSizeFormatter.swift | B/KB/MB/GB フォーマッタ |

### ルート (2ファイル)
| ファイル | 目的 |
|---|---|
| MacStorageMonitorApp.swift | @main エントリーポイント、MenuBarExtra |
| Package.swift | Swift Package Manager 設定 |

### その他 (1ファイル)
| ファイル | 目的 |
|---|---|
| MacStorageMonitor.entitlements | App Sandbox無効設定 |

## 合計: 20ファイル

## アーキテクチャ実装
- **パターン**: MVVM（@Observable + SwiftUI）
- **非同期処理**: Swift Concurrency（async/await, actor）
- **データ永続化**: SwiftData（@Model）
- **メニューバー**: MenuBarExtra + .menuBarExtraStyle(.window)
- **Dock非表示**: LSUIElement相当（MenuBarExtraのみ使用）
