# 要件定義 — ログイン時自動起動ON/OFF設定

## 意図分析サマリー

| 項目 | 内容 |
|---|---|
| ユーザーリクエスト | 「ログイン時に自動起動する」をON/OFFできる設定を追加 |
| リクエストタイプ | New Feature（新機能追加） |
| スコープ | Single Component（設定画面新設 + LaunchAtLogin機能） |
| 複雑度 | Simple |

## 機能要件

### FR-1: ログイン時自動起動の制御
- macOSログイン時にアプリを自動起動するかどうかをユーザーが制御できる
- ON: ログイン時に自動的にアプリが起動する
- OFF: ログイン時にアプリは起動しない（手動起動のみ）
- デフォルト値: OFF（初回インストール時）

### FR-2: 設定画面の新設
- 既存のフッターセクションとは別に、設定セクション/画面を新設する
- 設定画面にトグルスイッチ（Toggle）で自動起動のON/OFFを切り替えられる
- 設定変更は即座に反映される（保存ボタン不要）

### FR-3: 設定の永続化
- 自動起動設定はアプリ終了後も保持される
- macOS標準のLogin Items（ServiceManagement framework）を使用する

## 非機能要件

### NFR-1: macOS互換性
- macOS 14 (Sonoma) 以降をサポート（既存のplatform要件に準拠）
- App Sandbox環境で動作すること

### NFR-2: UX
- 設定変更時にユーザーへの確認ダイアログは不要（トグルで即時反映）
- 設定画面へのアクセスは直感的であること

## 技術的考慮事項

- `ServiceManagement` frameworkの `SMAppService.mainApp` APIを使用（macOS 13+対応）
- App Sandbox環境でLogin Itemsを登録するための標準的なアプローチ
- 既存の `SettingsService` に自動起動設定を追加
- 設定画面は新しいViewとして作成し、PopoverContentViewから遷移可能にする
