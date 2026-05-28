import Foundation
import SwiftData

/// スキャン履歴の記録
@Model
final class ScanHistory {
    /// スキャン実行日時
    var scannedAt: Date
    
    /// スキャンしたアプリ数
    var totalAppsScanned: Int
    
    /// 検出した合計サイズ（バイト）
    var totalSizeDetected: Int64
    
    /// スキャン所要時間（秒）
    var scanDuration: TimeInterval
    
    /// ステータス（"completed" | "failed"）
    var status: String
    
    /// エラーメッセージ（失敗時）
    var errorMessage: String?
    
    init(
        scannedAt: Date = Date(),
        totalAppsScanned: Int,
        totalSizeDetected: Int64,
        scanDuration: TimeInterval,
        status: String = "completed",
        errorMessage: String? = nil
    ) {
        self.scannedAt = scannedAt
        self.totalAppsScanned = totalAppsScanned
        self.totalSizeDetected = totalSizeDetected
        self.scanDuration = scanDuration
        self.status = status
        self.errorMessage = errorMessage
    }
}
