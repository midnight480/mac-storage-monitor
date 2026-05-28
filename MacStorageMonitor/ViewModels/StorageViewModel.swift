import Foundation
import SwiftData
import Combine
import AppKit

/// メインViewModel — UI状態管理、スキャン実行、TOP10提供
@MainActor
final class StorageViewModel: ObservableObject {
    
    // MARK: - 公開プロパティ（UI向け）
    
    /// アプリ使用量TOP10リスト
    @Published var appStorageList: [AppDisplayItem] = []
    
    /// ディスク全体情報
    @Published var diskUsage: DiskUsageInfo?
    
    /// スキャン中フラグ
    @Published var isScanning: Bool = false
    
    /// 最終スキャン日時
    @Published var lastScanDate: Date?
    
    /// スキャン間隔（秒）
    @Published var scanInterval: TimeInterval {
        didSet {
            settingsService.scanInterval = scanInterval
            scheduler.reschedule(interval: scanInterval)
        }
    }
    
    /// ログイン時自動起動
    @Published var launchAtLogin: Bool {
        didSet {
            settingsService.launchAtLogin = launchAtLogin
            do {
                try launchAtLoginService.setEnabled(launchAtLogin)
            } catch {
                print("[ViewModel] ログイン時自動起動の設定に失敗: \(error)")
                // 失敗時は元の状態に戻す
                launchAtLogin = launchAtLoginService.isEnabled
                settingsService.launchAtLogin = launchAtLogin
            }
        }
    }
    
    /// エラーメッセージ
    @Published var errorMessage: String?
    
    // MARK: - 内部プロパティ
    
    private let storageService: StorageService
    private let scheduler: ScanSchedulerService
    private let settingsService: SettingsService
    private let launchAtLoginService: LaunchAtLoginService
    
    // MARK: - 初期化
    
    init(modelContext: ModelContext) {
        let settingsService = SettingsService()
        self.settingsService = settingsService
        self.scanInterval = settingsService.scanInterval
        self.launchAtLoginService = LaunchAtLoginService.shared
        self.launchAtLogin = LaunchAtLoginService.shared.isEnabled
        self.storageService = StorageService(modelContext: modelContext)
        self.scheduler = ScanSchedulerService(interval: settingsService.scanInterval)
        
        // スケジューラのコールバック設定
        scheduler.onScanRequested = { [weak self] in
            await self?.performScan()
        }
        
        // 初期データ読み込み + スキャン開始
        Task {
            await loadCachedData()
            await performScan()
            scheduler.start()
        }
    }
    
    // MARK: - 公開メソッド
    
    /// スキャンを実行し結果を更新する
    func performScan() async {
        guard !isScanning else { return }
        
        isScanning = true
        errorMessage = nil
        
        do {
            // ディスク情報取得
            diskUsage = try await storageService.getDiskOverview()
            print("[ViewModel] ディスク情報取得完了: \(diskUsage?.usagePercentage ?? 0)%")
            
            // フルスキャン実行
            let results = try await storageService.performFullScan()
            print("[ViewModel] フルスキャン完了: \(results.count) アプリ")
            
            // TOP10取得してUI用モデルに変換
            let topRecords = try storageService.getTopApps(limit: 10)
            appStorageList = topRecords.map { record in
                AppDisplayItem(
                    id: record.bundleIdentifier,
                    name: record.name,
                    appPath: record.appPath,
                    totalSize: record.totalSize,
                    installSource: record.installSource
                )
            }
            print("[ViewModel] TOP10取得: \(appStorageList.count) 件")
            
            lastScanDate = Date()
        } catch {
            errorMessage = error.localizedDescription
            print("[ViewModel] エラー: \(error)")
        }
        
        isScanning = false
    }
    
    /// 手動再スキャンを実行する
    func triggerManualScan() async {
        await scheduler.triggerImmediateScan()
    }
    
    /// ディスク使用率パーセンテージを取得する
    var diskUsagePercentage: Int {
        diskUsage?.usagePercentage ?? 0
    }
    
    /// スキャン間隔を設定する
    func setScanInterval(_ interval: TimeInterval) {
        scanInterval = interval
    }
    
    // MARK: - 内部メソッド
    
    /// キャッシュされたデータを読み込む（起動時即時表示用）
    private func loadCachedData() async {
        do {
            let topRecords = try storageService.getTopApps(limit: 10)
            appStorageList = topRecords.map { record in
                AppDisplayItem(
                    id: record.bundleIdentifier,
                    name: record.name,
                    appPath: record.appPath,
                    totalSize: record.totalSize,
                    installSource: record.installSource
                )
            }
            diskUsage = try await storageService.getDiskOverview()
        } catch {
            // 初回起動時はデータなしで問題ない
        }
    }
}

// MARK: - UI表示用モデル（SwiftDataから独立）

/// UI表示用のアプリ情報（値型、Identifiable）
struct AppDisplayItem: Identifiable {
    let id: String
    let name: String
    let appPath: String
    let totalSize: Int64
    let installSource: InstallSource
}
