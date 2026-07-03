# セキュリティ監査レポート

## 概要
本レポートは、`mac-storage-monitor` プロジェクトのソースコードおよび設定ファイルを対象に実施したセキュリティ監査の結果をまとめたものです。監査は「Baseline Security Rules」および一般的なセキュリティのベストプラクティスに基づいて行われました。

## 監査対象
- `MacStorageMonitor/Engines/StorageScanEngine.swift`: ファイルスキャンロジック
- `MacStorageMonitor/Engines/InstallSourceDetector.swift`: インストール元判定ロジック
- `MacStorageMonitor/Services/StorageService.swift`: スキャンオーケストレーター
- `MacStorageMonitor/MacStorageMonitor.entitlements`: アプリの権限設定

---

## 検出された脆弱性とリスク

### 1. パストラバーサルのリスク (低〜中)
**箇所**: `MacStorageMonitor/Engines/StorageScanEngine.swift` 内の `libraryURL(_:)` メソッド
**内容**: ユーザーのホームディレクトリ配下の `Library` フォルダへのパスを生成していますが、引数 `subdirectory` に対するバリデーションが行われていません。
**リスク**: 外部から意図しないパス（例: `../../Documents`）が渡された場合、想定外のディレクトリをスキャンする可能性があります。現状はハードコードされた呼び出しのみですが、将来的な拡張で脆弱性になる可能性があります。

### 2. コマンドインジェクションのリスク (低)
**箇所**: `MacStorageMonitor/Engines/InstallSourceDetector.swift` 内の `executeBrewListCask()` メソッド
**内容**: `Process` クラスを使用して `brew` コマンドを実行しています。引数は `["list", "--cask"]` と固定されており、現状インジェクションの余地はありません。
**リスク**: 将来的にユーザー入力を引数に含めるような変更が行われた場合、適切なエスケープがないとコマンドインジェクションが発生するリスクがあります。

### 3. ログ出力における機密情報の露出 (低)
**箇所**: プロジェクト全体
**内容**: `print()` 文によるデバッグログが散見されます。
**リスク**: ユーザーのアプリケーション名やパス、バンドルIDなどがコンソールログに出力されます。これ自体は致命的ではありませんが、セキュリティルール `SECURITY-03`（構造化ロギングと機密情報の除外）に抵触します。

### 4. エラーハンドリングの不備 (低)
**箇所**: `StorageScanEngine.swift` の `readBundleIdentifier(at:)` など
**内容**: `try?` によるサイレントな失敗が多く、エラーの原因が特定しにくい箇所があります。
**リスク**: 予期せぬエラーが発生した際に、システムが「失敗」した状態で動作を継続し、不正確なデータを提供する可能性があります（`SECURITY-15` 関連）。

---

## セキュリティルール遵守状況 (Baseline Security Rules)

| ルールID | ステータス | 備考 |
|---|---|---|
| SECURITY-01 | N/A | 暗号化が必要な外部通信やDBなし (SwiftDataはローカル) |
| SECURITY-03 | **非準拠** | 構造化ロギング未導入、`print`を使用 |
| SECURITY-05 | 準拠 | 内部処理のみで外部APIパラメータなし |
| SECURITY-06 | 準拠 | 必要最小限のEntitlements設定 |
| SECURITY-11 | 準拠 | スキャンロジックがEngineに分離されている |
| SECURITY-15 | **一部非準拠** | `try?` 多用による不透明なエラー処理 |

---

## 推奨される対策

1. **パスバリデーションの導入**: `StorageScanEngine.swift` でディレクトリパスを生成する際、ディレクトリトラバーサルを防ぐためのバリデーション（例: `..` の除去や正規化後のプレフィックスチェック）を追加する。
2. **構造化ロギングへの移行**: `os.Logger` を使用し、プライバシーに関わる情報（パスなど）には `.private` 属性を付与する。
3. **エラーハンドリングの強化**: `try?` を避け、適切なエラースローとキャッチを行うことで、失敗時の挙動を明確にする。
