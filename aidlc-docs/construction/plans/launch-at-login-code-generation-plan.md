# Code Generation Plan — ログイン時自動起動ON/OFF設定

## ユニットコンテキスト
- **ユニット名**: launch-at-login
- **対象要件**: FR-1（自動起動制御）、FR-2（設定画面新設）、FR-3（設定永続化）
- **依存関係**: ServiceManagement framework、既存SettingsService
- **プロジェクトタイプ**: Brownfield（既存コード修正 + 新規ファイル追加）

## コード生成ステップ

### Step 1: LaunchAtLoginService 新規作成
- [x] `MacStorageMonitor/Services/LaunchAtLoginService.swift` を新規作成
- ServiceManagement frameworkの `SMAppService.mainApp` を使用
- 自動起動の登録/解除メソッド
- 現在の登録状態を取得するプロパティ
- App Sandbox対応

### Step 2: SettingsService 拡張
- [x] `MacStorageMonitor/Services/SettingsService.swift` を修正
- `launchAtLogin` プロパティ追加（UserDefaults永続化）
- Keys enumに `launchAtLogin` キー追加
- デフォルト値: false

### Step 3: StorageViewModel 拡張
- [x] `MacStorageMonitor/ViewModels/StorageViewModel.swift` を修正
- `launchAtLogin` Published プロパティ追加
- `LaunchAtLoginService` インスタンス保持
- トグル変更時にServiceManagement APIを呼び出すロジック

### Step 4: SettingsView 新規作成
- [x] `MacStorageMonitor/Views/SettingsView.swift` を新規作成
- 設定セクションUI（Toggle: ログイン時に自動起動）
- 将来の設定項目追加に対応できる構造
- data-testid相当のaccessibilityIdentifier付与

### Step 5: FooterSection 修正（設定画面への導線追加）
- [x] `MacStorageMonitor/Views/FooterSection.swift` を修正
- 設定ボタン（歯車アイコン）を追加して設定画面を表示
- または PopoverContentView に設定画面への導線を追加

### Step 6: PopoverContentView 修正（設定画面統合）
- [x] `MacStorageMonitor/Views/PopoverContentView.swift` を修正
- 設定画面への遷移/表示ロジック追加
- SettingsViewをポップオーバー内に組み込む

### Step 7: コード生成サマリー作成
- [x] `aidlc-docs/construction/launch-at-login/code/code-summary.md` を作成
- 生成/修正したファイル一覧
- 実装の概要説明

## 生成ファイル一覧

| ファイル | 操作 | 説明 |
|---|---|---|
| `MacStorageMonitor/Services/LaunchAtLoginService.swift` | 新規作成 | ServiceManagement連携サービス |
| `MacStorageMonitor/Services/SettingsService.swift` | 修正 | launchAtLoginプロパティ追加 |
| `MacStorageMonitor/ViewModels/StorageViewModel.swift` | 修正 | launchAtLoginバインディング追加 |
| `MacStorageMonitor/Views/SettingsView.swift` | 新規作成 | 設定画面UI |
| `MacStorageMonitor/Views/FooterSection.swift` | 修正 | 設定ボタン追加 |
| `MacStorageMonitor/Views/PopoverContentView.swift` | 修正 | 設定画面統合 |
