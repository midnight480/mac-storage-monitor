import Foundation
import SwiftData

/// アプリケーションのストレージ使用量記録
@Model
final class AppStorageRecord {
    /// バンドルID（ユニーク制約）
    @Attribute(.unique)
    var bundleIdentifier: String
    
    /// アプリ名
    var name: String
    
    /// アプリ本体のパス（/Applications/xxx.app）
    var appPath: String
    
    /// 合計サイズ（バイト）
    var totalSize: Int64
    
    /// アプリ本体サイズ（バイト）
    var appBundleSize: Int64
    
    /// インストール元（"homebrew" | "appStore" | "directDownload" | "unknown"）
    var installSourceRaw: String
    
    /// 最終スキャン日時
    var lastScannedAt: Date
    
    /// 関連ファイル一覧
    @Relationship(deleteRule: .cascade)
    var relatedFiles: [RelatedFileRecord]
    
    /// インストール元のenum変換
    var installSource: InstallSource {
        get { InstallSource(rawValue: installSourceRaw) ?? .unknown }
        set { installSourceRaw = newValue.rawValue }
    }
    
    init(
        bundleIdentifier: String,
        name: String,
        appPath: String,
        totalSize: Int64,
        appBundleSize: Int64,
        installSource: InstallSource,
        lastScannedAt: Date = Date(),
        relatedFiles: [RelatedFileRecord] = []
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.appPath = appPath
        self.totalSize = totalSize
        self.appBundleSize = appBundleSize
        self.installSourceRaw = installSource.rawValue
        self.lastScannedAt = lastScannedAt
        self.relatedFiles = relatedFiles
    }
}
