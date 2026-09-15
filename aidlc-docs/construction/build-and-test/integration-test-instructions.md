# 統合テスト手順: Mac Storage Monitor

## 目的
コンポーネント間の連携が正しく動作することを確認する。

## テストシナリオ

### シナリオ 1: フルスキャンフロー
**説明**: StorageService → StorageScanEngine → InstallSourceDetector の連携テスト

**前提条件**:
- /Applications/ にアプリが存在すること
- macOS 14以上で実行すること

**テスト手順**:
1. インメモリ SwiftData コンテナを作成
2. StorageService を初期化
3. `performFullScan()` を実行
4. 結果を検証

**期待結果**:
- スキャン結果が1件以上返される
- 各アプリに bundleIdentifier が設定されている
- totalSize > 0 である
- installSource が有効な値である
- SwiftData に保存されている

**確認コマンド**:
```bash
# アプリを実行して手動確認
.build/debug/MacStorageMonitor
# メニューバーにパーセンテージが表示されることを確認
# ポップオーバーにアプリ一覧が表示されることを確認
```

---

### シナリオ 2: Homebrew検出フロー
**説明**: InstallSourceDetector の Homebrew 検出が正しく動作するか

**前提条件**:
- Homebrew がインストールされていること
- 1つ以上の Cask アプリがインストールされていること

**テスト手順**:
1. `brew list --cask` で既知のCaskアプリを確認
2. InstallSourceDetector を初期化
3. 既知のCaskアプリに対して `detectInstallSource()` を実行
4. `.homebrew` が返されることを確認

**期待結果**:
- Homebrew Cask アプリが `.homebrew` と判定される
- App Store アプリが `.appStore` と判定される
- その他のアプリが `.directDownload` と判定される

**確認コマンド**:
```bash
# Homebrewアプリの確認
brew list --cask
# アプリ実行後、ポップオーバーでバッジを確認
```

---

### シナリオ 3: スケジューラ連携
**説明**: ScanSchedulerService → StorageService → ViewModel の連携テスト

**テスト手順**:
1. アプリを起動
2. 初回スキャンが自動実行されることを確認
3. 手動再スキャンボタンを押す
4. スキャンが再実行されることを確認
5. スキャン間隔を変更する
6. 設定が保存されることを確認（アプリ再起動後も維持）

**期待結果**:
- 起動時に自動スキャンが実行される
- 手動スキャンが即座に実行される
- スキャン間隔変更がUserDefaultsに保存される
- アプリ再起動後も設定が維持される

---

### シナリオ 4: SwiftData永続化
**説明**: スキャン結果がSwiftDataに正しく保存・更新されるか

**テスト手順**:
1. アプリを起動し初回スキャンを実行
2. アプリを終了
3. アプリを再起動
4. 前回のスキャン結果が即座に表示されることを確認
5. 新規スキャン後にデータが更新されることを確認

**期待結果**:
- 再起動後に前回データが即座に表示される
- 新規スキャンでデータが更新される
- 削除されたアプリのレコードが消える

---

## 手動統合テストチェックリスト

アプリを実行して以下を確認:

- [ ] メニューバーにディスクアイコンとパーセンテージが表示される
- [ ] パーセンテージが妥当な値である（0-100%）
- [ ] クリックでポップオーバーが表示される
- [ ] ディスク使用量のプログレスバーが表示される
- [ ] 使用量/総容量/空き容量が表示される
- [ ] アプリ一覧が最大10件表示される
- [ ] 各アプリにアイコンが表示される
- [ ] 各アプリにインストール元バッジが表示される
- [ ] Homebrewアプリに🍺バッジが表示される
- [ ] App Storeアプリに🏪バッジが表示される
- [ ] 使用量が大きい順にソートされている
- [ ] 再スキャンボタンが動作する
- [ ] スキャン中にプログレス表示される
- [ ] スキャン間隔の変更が保存される
- [ ] 終了ボタンでアプリが終了する

---

## macos27-menubar-fix サイクル（2026-09-15）

### シナリオ A: 署名済み .app が MenuBarAgent にバンドルIDで登録される
- **Setup**: `./scripts/build-app.sh`、既存プロセスを終了
- **Test Steps**:
  ```bash
  T=$(date "+%Y-%m-%d %H:%M:%S"); open MacStorageMonitor.app; sleep 10
  /usr/bin/log show --start "$T" --info --debug --style compact \
    --predicate 'process == "MenuBarAgent" AND subsystem == "com.apple.menubar" AND (eventMessage CONTAINS "MacStorageMonitor" OR eventMessage CONTAINS "Creating status item")'
  ```
  （zsh では `log` がシェル組み込みコマンドと衝突するため `/usr/bin/log` を使う）
- **Expected**: `Started to track application .bundle(com.local.MacStorageMonitor)` と `Creating status item ..., isAllowed: true`
- **Result**: ✅

### シナリオ B: メニューバー管理アプリ（Thaw）で安定した識別名になる
- **Test Steps**:
  ```bash
  /usr/bin/log show --last 10m --info --style compact --predicate 'process == "Thaw" AND eventMessage CONTAINS "MacStorage"'
  ```
- **Expected**: 識別子が `com.local.MacStorageMonitor:Mac Storage Monitor`（使用率 `NN%` を含まない）
- **Result**: ✅ `migrated saved entry com.local.MacStorageMonitor:69% to live identifier com.local.MacStorageMonitor:Mac Storage Monitor`

### シナリオ C: ビルドディレクトリが無くても起動・操作できる
- **Setup**: `.app` を別ディレクトリにコピーし、`.build/arm64-apple-macosx/release/MacStorageMonitor_MacStorageMonitor.bundle` を一時的にリネーム
- **Test Steps**: コピーした `.app` を起動し、メニューバー項目をクリック（`osascript ... click menu bar item 1 of menu bar 2`）、プロセスが生存していることを確認、リネームを戻す
- **Expected**: `could not load resource bundle` で落ちない
- **Result**: ✅ クリック後もプロセス生存

### 手動チェックリスト（macOS 27）
- [ ] Thaw 等のメニューバー管理アプリ未使用時、メニューバーに 💽 + 使用率% が表示される
- [ ] Thaw の設定一覧に「Mac Storage Monitor」が表示され、表示セクションへ移動できる
- [ ] 使用率が変化しても Thaw 上の配置が維持される
- [ ] ポップオーバーの文字列が設定言語（システム / 日本語 / English）で表示される
- [ ] `/Applications` にコピーした `.app` でも同様に動作する
- [ ] ログイン時自動起動 ON の状態で再ログイン後に表示される
