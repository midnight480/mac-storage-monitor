# コンポーネント定義: Mac Storage Monitor

## 1. MacStorageMonitorApp
**目的**: アプリケーションのエントリーポイント、メニューバー常駐管理

**責務**:
- アプリケーションライフサイクル管理
- メニューバーアイテム（NSStatusItem）の初期化
- SwiftDataコンテナの初期化
- バックグラウンドスキャンスケジューラの起動

**インターフェース**:
- SwiftUI `@main` App構造体
- MenuBarExtra を使用したメニューバー統合

---

## 2. StorageScanEngine
**目的**: ファイルシステムをスキャンし、アプリごとの使用量を集計する

**責務**:
- /Applications ディレクトリのアプリ一覧取得
- 各アプリの関連ファイルパス検出
- ファイルサイズの集計
- スキャン結果のモデル生成
- Caches/一時ファイルの除外フィルタリング

**検出対象ディレクトリ**:
- `/Applications/*.app`（アプリ本体）
- `~/Library/Application Support/`
- `~/Library/Preferences/`
- `~/Library/Containers/`
- `~/Library/Logs/`
- `~/Library/Saved Application State/`

---

## 3. InstallSourceDetector
**目的**: アプリのインストール元を判定する

**責務**:
- Homebrew Cask管理アプリの検出（`brew list --cask` + `/opt/homebrew/Caskroom/` スキャン）
- Mac App Storeアプリの検出（レシート確認）
- 直接ダウンロードアプリの判定
- インストール元カテゴリの割り当て

**インストール元カテゴリ**:
- `.homebrew` — Homebrew Cask管理
- `.appStore` — Mac App Store
- `.directDownload` — インターネットから直接ダウンロード
- `.unknown` — 判定不能

---

## 4. ScanScheduler
**目的**: バックグラウンドでの定期スキャンを管理する

**責務**:
- 定期スキャンのスケジューリング（Timer/DispatchSourceTimer）
- スキャン間隔の設定管理
- 手動スキャントリガー
- スキャン状態の管理（実行中/完了/エラー）

---

## 5. StorageViewModel
**目的**: UIとデータ層を接続するViewModel（MVVM）

**責務**:
- スキャン結果の保持と公開（@Published）
- ディスク全体の使用量/空き容量の取得
- アプリ一覧のTOP10ソート
- スキャン状態のUI向け変換
- スキャン間隔設定の管理

---

## 6. MenuBarView
**目的**: メニューバーに表示するディスク使用率パーセンテージ

**責務**:
- ディスク使用率のパーセンテージ表示
- アイコン表示

---

## 7. PopoverContentView
**目的**: ポップオーバー内のメインUI

**責務**:
- ディスク全体の使用量/空き容量表示
- アプリ使用量TOP10リスト表示
- 各アプリのアイコン、名前、サイズ、インストール元バッジ表示
- 手動再スキャンボタン
- スキャン間隔設定UI

---

## 8. AppStorageInfoRow
**目的**: アプリ一覧の各行のUI表示

**責務**:
- アプリアイコン表示
- アプリ名表示
- 使用量表示（フォーマット済み）
- インストール元バッジ表示（Homebrew/App Store/直接DL/不明）

---

## 9. DataModels（SwiftData）
**目的**: スキャン結果の永続化モデル

**責務**:
- アプリ情報の永続化（名前、パス、サイズ、インストール元）
- スキャン履歴の保持
- 最終スキャン日時の記録
