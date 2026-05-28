# Application Design 計画: Mac Storage Monitor

## 設計計画

### Phase 1: コンポーネント識別
- [x] メインアプリケーション構造の定義（App, MenuBar, Popover）
- [x] ストレージスキャンエンジンの設計
- [x] インストール元判定エンジンの設計
- [x] UIコンポーネントの設計

### Phase 2: コンポーネントメソッド定義
- [x] 各コンポーネントのメソッドシグネチャ定義
- [x] 入出力型の定義

### Phase 3: サービス層設計
- [x] サービス定義とオーケストレーション
- [x] バックグラウンドスキャンスケジューラ設計

### Phase 4: コンポーネント依存関係
- [x] 依存関係マトリクス作成
- [x] データフロー定義

### Phase 5: 設計検証
- [x] 設計の完全性と一貫性の検証

---

## 設計質問

## Question 1: アプリケーションアーキテクチャパターン
SwiftUIアプリのアーキテクチャパターンはどれを採用しますか？

A) MVVM（Model-View-ViewModel）— SwiftUIとの親和性が高い標準パターン
B) MV（Model-View）— SwiftUIのObservableを活用したシンプルなパターン
C) TCA（The Composable Architecture）— 状態管理が厳密だが学習コスト高
X) Other (please describe after [Answer]: tag below)

[Answer]: A) MVVM（Model-View-ViewModel）— SwiftUIとの親和性が高い標準パターン

## Question 2: データ永続化
スキャン結果のキャッシュ/永続化方法はどうしますか？

A) UserDefaults — シンプル、少量データ向け
B) ファイル保存（JSON/Plist）— 中程度のデータ量に対応
C) SwiftData/CoreData — 構造化データ、クエリ対応
D) 永続化不要（毎回スキャンし直す）
X) Other (please describe after [Answer]: tag below)

[Answer]: C) SwiftData/CoreData — 構造化データ、クエリ対応

## Question 3: Homebrew検出方法
Homebrewでインストールされたアプリの検出方法について：

A) `brew list --cask` コマンドを実行して結果をパースする
B) Homebrewのインストールディレクトリ（/opt/homebrew/Caskroom/）を直接スキャンする
C) A + B の両方を組み合わせて確実に検出する
X) Other (please describe after [Answer]: tag below)

[Answer]: C) A + B の両方を組み合わせて確実に検出する
