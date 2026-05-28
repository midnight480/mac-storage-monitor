# ビジネスロジックモデル: Mac Storage Monitor

## 1. ストレージスキャンアルゴリズム

### 1.1 全体スキャンフロー

```
開始
  |
  v
/Applications/ 内の .app バンドルを列挙
  |
  v
各 .app に対して:
  |
  +-> バンドルID (CFBundleIdentifier) を取得
  |
  +-> アプリ本体サイズを計算
  |
  +-> 関連ファイル検索（6ディレクトリ）
  |     |
  |     +-> ~/Library/Application Support/{bundleID or appName}/
  |     +-> ~/Library/Preferences/{bundleID}.*
  |     +-> ~/Library/Containers/{bundleID}/
  |     +-> ~/Library/Logs/{bundleID or appName}/
  |     +-> ~/Library/Saved Application State/{bundleID}.savedState/
  |     +-> ~/Library/Application Support/ (アプリ名部分一致)
  |
  +-> インストール元判定
  |
  +-> AppStorageInfo 生成
  |
  v
全アプリの結果をサイズ降順ソート
  |
  v
TOP10を抽出
  |
  v
SwiftData に保存
  |
  v
完了
```

### 1.2 アプリ関連ファイル検出ロジック

**検索戦略**: バンドルIDベース + アプリ名ベースの二重検索

1. **バンドルIDによる検索**（優先）:
   - `Info.plist` から `CFBundleIdentifier` を読み取る
   - 各対象ディレクトリで `{bundleIdentifier}` に一致するフォルダ/ファイルを検索

2. **アプリ名による検索**（補完）:
   - `.app` バンドル名から拡張子を除いたアプリ名を使用
   - Application Support 内でアプリ名に一致するフォルダを検索
   - Logs 内でアプリ名に一致するフォルダを検索

3. **サイズ計算**:
   - 検出した各ファイル/フォルダの再帰的サイズ合計
   - シンボリックリンクは追跡しない（無限ループ防止）
   - アクセス権限エラーのファイルはスキップ（サイズ0として扱う）

### 1.3 インストール元判定アルゴリズム

**判定優先順位**（上から順に評価、最初にマッチしたものを採用）:

```
1. Homebrew Cask チェック
   |
   +-> `brew list --cask` の出力に含まれる？ → YES → .homebrew
   |
   +-> /opt/homebrew/Caskroom/ 内にアプリ名のフォルダがある？ → YES → .homebrew
   |
   v
2. Mac App Store チェック
   |
   +-> .app/Contents/_MASReceipt/receipt が存在する？ → YES → .appStore
   |
   v
3. 直接ダウンロード判定
   |
   +-> /Applications/ に存在し、上記に該当しない → .directDownload
   |
   v
4. 不明
   |
   +-> 上記すべてに該当しない → .unknown
```

**Homebrew検出の詳細**:
- `brew list --cask` はアプリ起動時に1回実行し、結果をキャッシュ
- Caskroomスキャンは `/opt/homebrew/Caskroom/` の存在確認後に実行
- Homebrew未インストールの場合はスキップ（エラーにしない）
- Cask名とアプリ名のマッピング: Caskroom内の `.app` ファイル名で照合

### 1.4 TOP10ソートロジック

- `totalSize`（アプリ本体 + 全関連ファイル）の降順でソート
- 同サイズの場合はアプリ名のアルファベット順
- 上位10件のみを表示用に抽出
- 全データはSwiftDataに保持（将来の拡張用）

---

## 2. バックグラウンドスキャンスケジューラ

### 2.1 スケジューリングロジック

```
アプリ起動
  |
  v
前回スキャン結果をSwiftDataから読み込み → UI即時表示
  |
  v
初回スキャン実行（バックグラウンド）
  |
  v
Timer開始（設定間隔で繰り返し）
  |
  +-> 間隔経過 → スキャン実行 → 結果保存 → UI更新
  |
  +-> ユーザーが手動スキャン → Timer リセット → スキャン実行
  |
  v
アプリ終了 → Timer停止
```

### 2.2 スキャン状態管理

```
状態遷移:
  idle → scanning → completed
                  → failed (エラー時)
  
  failed → idle (次回スキャン時にリセット)
```

---

## 3. ディスク使用量取得

### 3.1 取得方法

- `FileManager.attributesOfFileSystem(forPath:)` を使用
- 取得項目:
  - `NSFileSystemSize` → 総容量
  - `NSFileSystemFreeSize` → 空き容量
  - 使用量 = 総容量 - 空き容量
- パーセンテージ = (使用量 / 総容量) × 100（小数点以下切り捨て）
