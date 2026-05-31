import Foundation
import SwiftData
import Combine
import AppKit
import os

/// メインViewModel — UI状態管理、スキャン実行、TOP10提供
@MainActor
final class StorageViewModel: ObservableObject {
    
    // MARK: - 公開プロパティ（UI向け）
    
    /// アプリ使用量TOP10リスト
    @Published var appStorageList: [AppDisplayItem] = []

    /// TOP10以外で1MB以上のアプリリスト（サイズ降順）
    @Published var otherAppsList: [AppDisplayItem] = []

    /// 1MBのバイト数（10進。FileSizeFormatterの表示単位に合わせる）
    static let oneMegabyteInBytes: Int64 = 1_000_000

    /// TOP10以外アプリの合計サイズ（バイト）
    var otherAppsTotalBytes: Int64 {
        otherAppsList.reduce(0) { $0 + $1.totalSize }
    }
    
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
                logger.error("Failed to set launch at login: \(error.localizedDescription)")
                // 失敗時は元の状態に戻す
                launchAtLogin = launchAtLoginService.isEnabled
                settingsService.launchAtLogin = launchAtLogin
            }
        }
    }
    
    /// アプリ内言語設定
    @Published var language: SettingsService.AppLanguage {
        didSet {
            settingsService.language = language
            objectWillChange.send()
        }
    }
    
    /// エラーメッセージ
    @Published var errorMessage: String?
    
    // MARK: - 内部プロパティ
    
    private let storageService: StorageService
    private let scheduler: ScanSchedulerService
    private let settingsService: SettingsService
    private let launchAtLoginService: LaunchAtLoginService
    private let logger = Logger(subsystem: "com.mac-storage-monitor", category: "ViewModel")
    
    // MARK: - 初期化
    
    init(modelContext: ModelContext) {
        let settingsService = SettingsService()
        self.settingsService = settingsService
        self.scanInterval = settingsService.scanInterval
        self.launchAtLoginService = LaunchAtLoginService.shared
        self.launchAtLogin = LaunchAtLoginService.shared.isEnabled
        self.language = settingsService.language
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
            logger.info("Disk info retrieved: \(self.diskUsage?.usagePercentage ?? 0)%")
            
            // フルスキャン実行
            let results = try await storageService.performFullScan()
            logger.info("Full scan completed: \(results.count) apps")
            
            // TOP10取得してUI用モデルに変換
            let topRecords = try storageService.getTopApps(limit: 10)
            appStorageList = topRecords.map(Self.makeDisplayItem)
            logger.info("Top 10 retrieved: \(self.appStorageList.count) items")

            // TOP10以外で1MB以上のアプリを取得
            let otherRecords = try storageService.getAppsBeyondTop10(minBytes: Self.oneMegabyteInBytes)
            otherAppsList = otherRecords.map(Self.makeDisplayItem)
            logger.info("Other apps (>=1MB): \(self.otherAppsList.count) items")
            
            lastScanDate = Date()
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Scan error: \(error.localizedDescription)")
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
            appStorageList = topRecords.map(Self.makeDisplayItem)
            let otherRecords = try storageService.getAppsBeyondTop10(minBytes: Self.oneMegabyteInBytes)
            otherAppsList = otherRecords.map(Self.makeDisplayItem)
            diskUsage = try await storageService.getDiskOverview()
        } catch {
            // 初回起動時はデータなしで問題ない
        }
    }

    /// AppStorageRecord を UI 表示用モデルに変換する
    private static func makeDisplayItem(_ record: AppStorageRecord) -> AppDisplayItem {
        AppDisplayItem(
            id: record.bundleIdentifier,
            name: record.name,
            appPath: record.appPath,
            totalSize: record.totalSize,
            installSource: record.installSource
        )
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
