# Code Generation Plan — macOS 27 メニューバー非表示の修正

## ユニットコンテキスト
- **ユニット名**: macos27-menubar-fix
- **対象要件**: FR-1〜FR-4（`aidlc-docs/inception/requirements/macos27-menubar-fix-requirements.md`）
- **ブランチ**: `fix/macos27-menubar-not-showing`
- **プロジェクトタイプ**: Brownfield（既存ファイル修正のみ）

## コード生成ステップ

### Step 1: メニューバー項目の識別名を固定（FR-1, FR-2）
- [x] `MacStorageMonitor/MacStorageMonitorApp.swift` の `MenuBarExtra` ラベルに以下を追加
  - `.accessibilityElement(children: .ignore)`
  - `.accessibilityLabel("Mac Storage Monitor")`（言語設定で変わらないよう非ローカライズ固定）
  - `.accessibilityValue("\(viewModel.diskUsagePercentage)%")`

### Step 2: リソースバンドル解決を .app 同梱に対応（FR-4）
- [x] `MacStorageMonitor/Utilities/L10n.swift` に `Contents/Resources/MacStorageMonitor_MacStorageMonitor.bundle` を優先し、無ければ `Bundle.module` にフォールバックするバンドル解決を追加

### Step 3: ビルドスクリプト修正（FR-3, FR-4）
- [x] `scripts/build-app.sh` でリソースバンドルを `Contents/Resources` へコピー
- [x] Info.plist 生成後に `codesign --force --sign - --identifier com.local.MacStorageMonitor` で署名し、`codesign --verify` で検証

### Step 4: ドキュメント
- [x] `README.md` に macOS 27 / メニューバー管理アプリ（Thaw 等）利用時の注意を追記
- [x] `aidlc-docs/construction/macos27-menubar-fix/code/code-summary.md` を作成

### Step 5: ビルド・動作確認
- [x] `./scripts/build-app.sh` 実行、`codesign -dvv` で Identifier / Info.plist バインドを確認
- [x] `.build` の絶対パスに依存せずにローカライズが読み込めることを確認（スクラッチ領域に .app をコピーして起動）
- [x] MenuBarAgent / Thaw ログで識別子 `com.local.MacStorageMonitor:Mac Storage Monitor` を確認
