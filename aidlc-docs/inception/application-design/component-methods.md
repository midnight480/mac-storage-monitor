# コンポーネントメソッド定義: Mac Storage Monitor

## StorageScanEngine

```swift
// アプリ一覧を取得し、関連ファイルサイズを集計してスキャン結果を返す
func scanAllApplications() async throws -> [AppStorageInfo]

// 特定アプリの関連ファイルパスとサイズを検出する
func scanApplication(at appURL: URL) throws -> AppStorageInfo

// 指定ディレクトリ内でアプリに関連するファイルを検索する
func findRelatedFiles(for bundleIdentifier: String, in directory: URL) throws -> [FileInfo]

// ディスク全体の使用量/空き容量を取得する
func getDiskUsage() throws -> DiskUsageInfo
```

---

## InstallSourceDetector

```swift
// アプリのインストール元を判定する
func detectInstallSource(for app: URL) async -> InstallSource

// Homebrew Caskで管理されているアプリ一覧を取得する
func getHomebrewCaskApps() async throws -> Set<String>

// /opt/homebrew/Caskroom/ をスキャンしてCask管理アプリを検出する
func scanCaskroomDirectory() throws -> Set<String>

// App Storeレシートの存在を確認する
func hasAppStoreReceipt(at appURL: URL) -> Bool
```

---

## ScanScheduler

```swift
// 定期スキャンを開始する（指定間隔で繰り返し）
func startScheduledScan(interval: TimeInterval)

// 定期スキャンを停止する
func stopScheduledScan()

// 即時スキャンを実行する
func triggerImmediateScan() async

// スキャン間隔を変更する
func updateInterval(_ interval: TimeInterval)
```

---

## StorageViewModel

```swift
// @Published プロパティ
var appStorageList: [AppStorageInfo]    // TOP10アプリ一覧
var diskUsage: DiskUsageInfo?           // ディスク全体情報
var isScanning: Bool                    // スキャン中フラグ
var lastScanDate: Date?                 // 最終スキャン日時
var scanInterval: TimeInterval          // スキャン間隔（秒）

// スキャンを実行し結果を更新する
func performScan() async

// スキャン間隔を設定する
func setScanInterval(_ interval: TimeInterval)

// ディスク使用率パーセンテージを計算する
func diskUsagePercentage() -> Int
```

---

## 入出力型定義

```swift
// アプリのストレージ情報
struct AppStorageInfo {
    let name: String              // アプリ名
    let bundleIdentifier: String  // バンドルID
    let appURL: URL               // .appのパス
    let icon: NSImage?            // アプリアイコン
    let totalSize: Int64          // 合計サイズ（バイト）
    let appBundleSize: Int64      // アプリ本体サイズ
    let relatedFiles: [FileInfo]  // 関連ファイル一覧
    let installSource: InstallSource  // インストール元
}

// ファイル情報
struct FileInfo {
    let url: URL                  // ファイルパス
    let size: Int64               // サイズ（バイト）
    let category: FileCategory    // カテゴリ
}

// ファイルカテゴリ
enum FileCategory {
    case appBundle               // アプリ本体
    case applicationSupport      // Application Support
    case preferences             // Preferences
    case containers              // Containers
    case logs                    // Logs
    case savedState              // Saved Application State
}

// インストール元
enum InstallSource {
    case homebrew                // Homebrew Cask
    case appStore                // Mac App Store
    case directDownload          // 直接ダウンロード
    case unknown                 // 不明
}

// ディスク使用量情報
struct DiskUsageInfo {
    let totalCapacity: Int64     // 総容量
    let usedSpace: Int64         // 使用量
    let freeSpace: Int64         // 空き容量
}
```
