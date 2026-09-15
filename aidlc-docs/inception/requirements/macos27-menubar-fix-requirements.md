# Requirements — macOS 27 メニューバー非表示の修正

## Intent Analysis
- **User Request**: macOS 27.0 にアップデート後、メニューバーにアプリが表示されない（メニューバー管理アプリからもアイコンが認識されない）
- **Request Type**: Bug Fix
- **Scope**: 単一コンポーネント（アプリ起動部 + ビルドスクリプト + ローカライズのバンドル解決）
- **Complexity**: Simple
- **Depth**: Minimal

## 調査結果（根本原因）
| # | 事象 | 根拠 |
|---|---|---|
| 1 | `.app` が linker 署名のみ（Identifier=`MacStorageMonitor`, Info.plist not bound, Sealed Resources=none） | `codesign -dvv` |
| 2 | macOS 27 の MenuBarAgent 上で項目キーが `status:MacStorageMonitor::Item-0` となり、バンドルID起点の他アプリと異なる。Thaw（メニューバー管理アプリ）がアプリを識別できない | MenuBarAgent / Thaw ログ |
| 3 | Info.plist をバインドして identifier=`com.local.MacStorageMonitor` で署名すると `com.local.MacStorageMonitor:69%` として認識される | 検証ビルド exp2 |
| 4 | 項目名がラベル文字列（使用率 `69%`）から決まるため、使用率が変わるたびに識別子が変わり、Thaw の配置設定が保持されない | Thaw ログ（`observedChanges=status:com.local.MacStorageMonitor::69%`） |
| 5 | ラベルにアクセシビリティラベル `Mac Storage Monitor` を付けると識別子が `com.local.MacStorageMonitor:Mac Storage Monitor` に固定される | 検証ビルド exp3 + Thaw ログ `migrated saved entry` |
| 6 | Thaw 終了時は外部ディスプレイで `💽 69%` が表示される（内蔵ディスプレイは項目過多で macOS 27 のオーバーフロー `«` 内） | スクリーンショット |
| 7 | `build-app.sh` がリソースバンドルを `.app` にコピーしておらず、`Bundle.module` がビルドディレクトリの絶対パスにフォールバックして動作している（別環境/`.build` 削除時にクラッシュ） | `resource_bundle_accessor.swift` |

## Functional Requirements
- **FR-1**: メニューバー項目は、使用率に依存しない安定した識別名（`Mac Storage Monitor`）を持つこと。表示（アイコン + 使用率%）は変更しない
- **FR-2**: VoiceOver では項目名 `Mac Storage Monitor` と値（使用率%）を読み上げること
- **FR-3**: `scripts/build-app.sh` で生成する `.app` は、Info.plist をバインドし、識別子 `com.local.MacStorageMonitor` で ad-hoc 署名されること
- **FR-4**: `.app` はリソースバンドルを `Contents/Resources` に同梱し、ビルドディレクトリが無くてもローカライズ文字列を読み込めること

## Non-Functional Requirements
- 対象 OS は macOS 14+ を維持（API 追加なし）
- 外部依存の追加なし

## 対象外
- Thaw 側の設定（非表示セクションからの移動）はユーザー操作で対応
- 内蔵ディスプレイで項目が多いときの macOS 標準オーバーフロー

## Extension Configuration
- Security Baseline: No（前回サイクル決定を継続）
- Property-Based Testing: No（前回サイクル決定を継続）
