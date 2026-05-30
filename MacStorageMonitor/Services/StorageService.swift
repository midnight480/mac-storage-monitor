import Foundation
import SwiftData

/// ストレージスキャンの統合オーケストレーター
/// StorageScanEngine と InstallSourceDetector を組み合わせてスキャンを実行し、
/// 結果をSwiftDataに永続化する
@MainActor
final class StorageService {
    
    private let scanEngine = StorageScanEngine()
    private let installDetector = InstallSourceDetector()
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// フルスキャンを実行し、結果をSwiftDataに保存する
    func performFullScan() async throws -> [AppStorageRecord] {
        let startTime = Date()
        
        // インストール元検出キャッシュをクリア
        await installDetector.clearCache()
        
        // 全アプリスキャン
        let scannedApps = await scanEngine.scanAllApplications(installSourceDetector: installDetector)
        
        print("[StorageService] スキャン結果: \(scannedApps.count) アプリ")
        
        // 既存レコードを取得
        let existingRecords = try modelContext.fetch(FetchDescriptor<AppStorageRecord>())
        let existingMap = Dictionary(uniqueKeysWithValues: existingRecords.map { ($0.bundleIdentifier, $0) })
        
        // スキャン結果で更新/作成
        var updatedRecords: [AppStorageRecord] = []
        var scannedBundleIDs = Set<String>()
        
        for app in scannedApps {
            scannedBundleIDs.insert(app.bundleIdentifier)
            
            if let existing = existingMap[app.bundleIdentifier] {
                // 既存レコード更新
                existing.name = app.name
                existing.appPath = app.appURL.path
                existing.totalSize = app.totalSize
                existing.appBundleSize = app.appBundleSize
                existing.installSource = app.installSource
                existing.lastScannedAt = Date()
                
                // 関連ファイルを再作成
                existing.relatedFiles.forEach { modelContext.delete($0) }
                existing.relatedFiles = app.relatedFiles.map { file in
                    RelatedFileRecord(path: file.url.path, size: file.size, category: file.category)
                }
                
                updatedRecords.append(existing)
            } else {
                // 新規レコード作成
                let record = AppStorageRecord(
                    bundleIdentifier: app.bundleIdentifier,
                    name: app.name,
                    appPath: app.appURL.path,
                    totalSize: app.totalSize,
                    appBundleSize: app.appBundleSize,
                    installSource: app.installSource
                )
                record.relatedFiles = app.relatedFiles.map { file in
                    RelatedFileRecord(path: file.url.path, size: file.size, category: file.category)
                }
                modelContext.insert(record)
                updatedRecords.append(record)
            }
        }
        
        // 削除されたアプリのレコードを削除
        for (bundleID, record) in existingMap {
            if !scannedBundleIDs.contains(bundleID) {
                modelContext.delete(record)
            }
        }
        
        // スキャン履歴を記録
        let scanDuration = Date().timeIntervalSince(startTime)
        let totalSize = updatedRecords.reduce(Int64(0)) { $0 + $1.totalSize }
        let history = ScanHistory(
            totalAppsScanned: updatedRecords.count,
            totalSizeDetected: totalSize,
            scanDuration: scanDuration
        )
        modelContext.insert(history)
        
        // 古い履歴を削除（30日以上前）
        cleanOldHistory()
        
        // 保存
        try modelContext.save()
        
        print("[StorageService] 保存完了: \(updatedRecords.count) レコード")
        
        return updatedRecords
    }
    
    /// TOP Nアプリをサイズ降順で取得
    func getTopApps(limit: Int = 10) throws -> [AppStorageRecord] {
        var descriptor = FetchDescriptor<AppStorageRecord>(
            sortBy: [SortDescriptor(\.totalSize, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }

    /// TOP10以外で指定サイズ以上のアプリをサイズ降順で取得
    func getAppsBeyondTop10(minBytes: Int64) throws -> [AppStorageRecord] {
        let descriptor = FetchDescriptor<AppStorageRecord>(
            sortBy: [SortDescriptor(\.totalSize, order: .reverse)]
        )
        let allRecords = try modelContext.fetch(descriptor)
        return Array(allRecords.dropFirst(10)).filter { $0.totalSize >= minBytes }
    }
    
    /// ディスク全体の使用量情報を取得
    func getDiskOverview() async throws -> DiskUsageInfo {
        try await scanEngine.getDiskUsage()
    }
    
    /// 30日以上前のスキャン履歴を削除
    private func cleanOldHistory() {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let descriptor = FetchDescriptor<ScanHistory>(
            predicate: #Predicate { $0.scannedAt < thirtyDaysAgo }
        )
        
        if let oldRecords = try? modelContext.fetch(descriptor) {
            for record in oldRecords {
                modelContext.delete(record)
            }
        }
    }
}
