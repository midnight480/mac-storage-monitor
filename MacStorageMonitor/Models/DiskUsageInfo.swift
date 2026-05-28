import Foundation

/// ディスク使用量情報（非永続化）
struct DiskUsageInfo {
    /// 総容量（バイト）
    let totalCapacity: Int64
    
    /// 使用量（バイト）
    let usedSpace: Int64
    
    /// 空き容量（バイト）
    let freeSpace: Int64
    
    /// 使用率（パーセンテージ、整数）
    var usagePercentage: Int {
        guard totalCapacity > 0 else { return 0 }
        return Int((Double(usedSpace) / Double(totalCapacity)) * 100)
    }
}
