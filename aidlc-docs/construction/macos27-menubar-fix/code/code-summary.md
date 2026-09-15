# Code Summary — macos27-menubar-fix

## 変更ファイル
| ファイル | 変更内容 | 要件 |
|---|---|---|
| `MacStorageMonitor/MacStorageMonitorApp.swift` | MenuBarExtra ラベルに `accessibilityLabel("Mac Storage Monitor")` / `accessibilityValue(使用率%)` を付与し、項目識別名を固定 | FR-1, FR-2 |
| `MacStorageMonitor/Utilities/L10n.swift` | `Contents/Resources/MacStorageMonitor_MacStorageMonitor.bundle` を優先するリソースバンドル解決を追加（無ければ `Bundle.module`） | FR-4 |
| `scripts/build-app.sh` | リソースバンドルのコピー、`codesign --sign - --identifier com.local.MacStorageMonitor` による署名と `--verify --strict` 検証を追加 | FR-3, FR-4 |
| `README.md` | macOS 27 でメニューバーに表示されない場合の注意を追記 | - |

## 検証結果
- `codesign -dvv`: Identifier=com.local.MacStorageMonitor / Info.plist entries=11 / Sealed Resources version=2
- 同梱リソースから ja/en の文字列取得を確認（`disk.title` → 「ディスク使用状況」/「Disk Usage」）
- MenuBarAgent: `Creating status item ..., isAllowed: true`
- Thaw: `migrated saved entry com.local.MacStorageMonitor:69% to live identifier com.local.MacStorageMonitor:Mac Storage Monitor`
- Thaw を一時終了した状態で外部ディスプレイのメニューバーに表示されることを確認

## 自動テスト
- 本プロジェクトにテストターゲットは無く、今回もビルド・実機確認で検証
