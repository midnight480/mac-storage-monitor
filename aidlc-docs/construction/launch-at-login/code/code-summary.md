# コード生成サマリー — ログイン時自動起動ON/OFF設定

## 生成日時
2026-05-29

## 変更ファイル一覧

### 新規作成
| ファイル | 説明 |
|---|---|
| `MacStorageMonitor/Services/LaunchAtLoginService.swift` | ServiceManagement framework連携。SMAppService.mainAppを使用したLogin Items登録/解除 |
| `MacStorageMonitor/Views/SettingsView.swift` | 設定画面UI。ログイン時自動起動トグル + スキャン間隔設定 |

### 修正
| ファイル | 変更内容 |
|---|---|
| `MacStorageMonitor/Services/SettingsService.swift` | `launchAtLogin` プロパティ追加（UserDefaults永続化） |
| `MacStorageMonitor/ViewModels/StorageViewModel.swift` | `launchAtLogin` Published プロパティ + LaunchAtLoginService連携 |
| `MacStorageMonitor/Views/FooterSection.swift` | 設定ボタン（歯車アイコン）追加、`onOpenSettings` コールバック追加 |
| `MacStorageMonitor/Views/PopoverContentView.swift` | 設定画面表示切替ロジック（`showSettings` state） |

### ドキュメント更新
| ファイル | 変更内容 |
|---|---|
| `README.md` | アプリケーションREADMEとして全面書き直し |

## 実装概要

### アーキテクチャ
```
SettingsView (Toggle) 
  ↓ Binding
StorageViewModel.launchAtLogin (@Published)
  ↓ didSet
LaunchAtLoginService.setEnabled()
  ↓
SMAppService.mainApp.register() / unregister()
```

### 画面遷移
```
PopoverContentView (メイン画面)
  → FooterSection [設定ボタン]
    → SettingsView (設定画面)
      → [×ボタン] → PopoverContentView に戻る
```

## ビルド結果
- `swift build` 成功確認済み
