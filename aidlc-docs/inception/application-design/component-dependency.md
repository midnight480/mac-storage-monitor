# コンポーネント依存関係: Mac Storage Monitor

## 依存関係マトリクス

| コンポーネント | 依存先 |
|---|---|
| MacStorageMonitorApp | StorageViewModel, ScanSchedulerService, SwiftData ModelContainer |
| StorageViewModel | StorageService, ScanSchedulerService, SettingsService |
| StorageService | StorageScanEngine, InstallSourceDetector, SwiftData ModelContext |
| ScanSchedulerService | StorageService |
| SettingsService | UserDefaults |
| StorageScanEngine | FileManager, Process (brew コマンド) |
| InstallSourceDetector | Process (brew コマンド), FileManager |
| PopoverContentView | StorageViewModel |
| MenuBarView | StorageViewModel |
| AppStorageInfoRow | (なし — 純粋なView) |

---

## データフロー図

```
+-------------------+
|  MenuBarView      |  ← diskUsagePercentage
+-------------------+
        |
        v
+-------------------+     +---------------------+
| PopoverContentView| --> | AppStorageInfoRow    |
+-------------------+     +---------------------+
        |
        | @ObservedObject
        v
+-------------------+
| StorageViewModel  |  ← appStorageList, diskUsage, isScanning
+-------------------+
        |
        | async calls
        v
+-------------------+     +---------------------+
| StorageService    | --> | SwiftData           |
+-------------------+     | (ModelContext)       |
    |           |         +---------------------+
    v           v
+-----------+  +----------------------+
| Storage   |  | InstallSource        |
| ScanEngine|  | Detector             |
+-----------+  +----------------------+
    |               |
    v               v
+-----------+  +----------------------+
| FileManager|  | Process (brew)      |
|           |  | FileManager          |
+-----------+  | (/opt/homebrew/)     |
               +----------------------+
```

---

## 通信パターン

### 1. UI → ViewModel（データバインディング）
- SwiftUI の `@Observable` / `@ObservedObject` によるリアクティブバインディング
- View は ViewModel のプロパティを監視し自動更新

### 2. ViewModel → Service（非同期呼び出し）
- `async/await` による非同期メソッド呼び出し
- メインスレッドでの状態更新は `@MainActor` で保証

### 3. Service → Engine（同期/非同期呼び出し）
- StorageScanEngine: ファイルシステムアクセスは `async` で実行
- InstallSourceDetector: `brew` コマンド実行は `async` で実行

### 4. ScanScheduler → ViewModel（通知）
- スキャン完了時に ViewModel の `performScan()` を呼び出し
- Timer ベースの定期実行

---

## レイヤー構成

```
+------------------------------------------+
|            Presentation Layer             |
|  MenuBarView | PopoverContentView        |
|  AppStorageInfoRow                        |
+------------------------------------------+
|            ViewModel Layer                |
|  StorageViewModel                         |
+------------------------------------------+
|            Service Layer                  |
|  StorageService | ScanSchedulerService   |
|  SettingsService                          |
+------------------------------------------+
|            Engine Layer                   |
|  StorageScanEngine | InstallSourceDetector|
+------------------------------------------+
|            Data Layer                     |
|  SwiftData Models | UserDefaults          |
+------------------------------------------+
|            System Layer                   |
|  FileManager | Process | NSWorkspace      |
+------------------------------------------+
```
