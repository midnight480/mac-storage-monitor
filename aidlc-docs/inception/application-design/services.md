# サービス定義: Mac Storage Monitor

## サービスアーキテクチャ概要

本アプリはMVVMパターンを採用し、以下のサービス層でビジネスロジックをオーケストレーションする。

---

## 1. StorageService（メインオーケストレーター）

**目的**: ストレージスキャンの全体フローを統括する

**責務**:
- StorageScanEngine と InstallSourceDetector を組み合わせた統合スキャン実行
- スキャン結果のSwiftDataへの永続化
- TOP10ソートとフィルタリング

**オーケストレーションフロー**:
1. StorageScanEngine.scanAllApplications() でアプリ一覧とサイズを取得
2. 各アプリに対して InstallSourceDetector.detectInstallSource() でインストール元を判定
3. 結果を AppStorageInfo に統合
4. SwiftData に保存
5. TOP10をソートして返却

```swift
class StorageService {
    let scanEngine: StorageScanEngine
    let installDetector: InstallSourceDetector
    let modelContext: ModelContext
    
    func performFullScan() async throws -> [AppStorageInfo]
    func getTopApps(limit: Int = 10) -> [AppStorageInfo]
    func getDiskOverview() throws -> DiskUsageInfo
}
```

---

## 2. ScanSchedulerService（スケジューリング）

**目的**: バックグラウンドスキャンのライフサイクル管理

**責務**:
- アプリ起動時にスケジューラを開始
- ユーザー設定に基づくスキャン間隔管理
- スキャン完了時のViewModel通知

**連携**:
- StorageService を呼び出してスキャン実行
- StorageViewModel に結果を通知

```swift
class ScanSchedulerService {
    let storageService: StorageService
    
    func start(interval: TimeInterval)
    func stop()
    func reschedule(interval: TimeInterval)
    func scanNow() async
}
```

---

## 3. SettingsService（設定管理）

**目的**: ユーザー設定の永続化と提供

**責務**:
- スキャン間隔の保存/読み込み（UserDefaults）
- 設定変更時のスケジューラ再設定通知

```swift
class SettingsService {
    var scanInterval: TimeInterval { get set }  // デフォルト: 3600秒（1時間）
    
    func save()
    func load()
}
```
