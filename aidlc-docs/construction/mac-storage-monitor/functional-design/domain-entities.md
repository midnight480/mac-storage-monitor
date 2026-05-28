# ドメインエンティティ: Mac Storage Monitor

## SwiftData モデル定義

### 1. AppStorageRecord（アプリストレージ記録）

```swift
@Model
class AppStorageRecord {
    @Attribute(.unique) var bundleIdentifier: String
    var name: String
    var appPath: String                    // /Applications/xxx.app
    var totalSize: Int64                   // 合計サイズ（バイト）
    var appBundleSize: Int64              // アプリ本体サイズ
    var installSource: String             // "homebrew" | "appStore" | "directDownload" | "unknown"
    var lastScannedAt: Date               // 最終スキャン日時
    
    @Relationship(deleteRule: .cascade)
    var relatedFiles: [RelatedFileRecord] // 関連ファイル一覧
}
```

### 2. RelatedFileRecord（関連ファイル記録）

```swift
@Model
class RelatedFileRecord {
    var path: String                      // ファイル/フォルダパス
    var size: Int64                       // サイズ（バイト）
    var category: String                  // "applicationSupport" | "preferences" | "containers" | "logs" | "savedState"
    
    var app: AppStorageRecord?            // 親アプリへの参照
}
```

### 3. ScanHistory（スキャン履歴）

```swift
@Model
class ScanHistory {
    var scannedAt: Date                   // スキャン実行日時
    var totalAppsScanned: Int             // スキャンしたアプリ数
    var totalSizeDetected: Int64          // 検出した合計サイズ
    var scanDuration: TimeInterval        // スキャン所要時間（秒）
    var status: String                    // "completed" | "failed"
    var errorMessage: String?             // エラーメッセージ（失敗時）
}
```

---

## エンティティ間リレーションシップ

```
AppStorageRecord (1) ──── (*) RelatedFileRecord
       |
       | bundleIdentifier (unique)
       |
ScanHistory (独立、リレーションなし)
```

### リレーションシップルール
- AppStorageRecord → RelatedFileRecord: 1対多、カスケード削除
- AppStorageRecord の bundleIdentifier はユニーク制約
- スキャン時に既存レコードは更新（upsert）、削除されたアプリのレコードは削除

---

## 非永続化モデル（メモリ内のみ）

### DiskUsageInfo（ディスク使用量）

```swift
struct DiskUsageInfo {
    let totalCapacity: Int64     // 総容量（バイト）
    let usedSpace: Int64         // 使用量（バイト）
    let freeSpace: Int64         // 空き容量（バイト）
    
    var usagePercentage: Int {   // 使用率（%）
        guard totalCapacity > 0 else { return 0 }
        return Int((Double(usedSpace) / Double(totalCapacity)) * 100)
    }
}
```

### InstallSource（インストール元 enum）

```swift
enum InstallSource: String, Codable {
    case homebrew = "homebrew"
    case appStore = "appStore"
    case directDownload = "directDownload"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .homebrew: return "Homebrew"
        case .appStore: return "App Store"
        case .directDownload: return "Direct DL"
        case .unknown: return "不明"
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .homebrew: return .orange
        case .appStore: return .blue
        case .directDownload: return .green
        case .unknown: return .gray
        }
    }
}
```

### ScanState（スキャン状態 enum）

```swift
enum ScanState {
    case idle                    // 待機中
    case scanning                // スキャン中
    case completed               // 完了
    case failed(Error)           // 失敗
}
```

---

## データライフサイクルルール

### 作成
- 初回スキャン時に全アプリのレコードを作成
- 新しいアプリがインストールされた場合、次回スキャンで自動追加

### 更新
- 毎回のスキャンで既存レコードのサイズ・関連ファイルを更新
- `lastScannedAt` を更新

### 削除
- アンインストールされたアプリ（/Applications/ に存在しない）のレコードを削除
- カスケード削除により関連ファイルレコードも自動削除

### スキャン履歴
- 各スキャン完了時に ScanHistory レコードを追加
- 古い履歴の自動削除: 30日以上前のレコードを削除（ストレージ節約）
