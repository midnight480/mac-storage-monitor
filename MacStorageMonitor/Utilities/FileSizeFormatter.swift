import Foundation

/// ファイルサイズのフォーマッタ
/// SI単位（1000ベース: KB/MB/GB）で表示する
enum FileSizeFormatter {
    
    /// バイト数を人間が読みやすい形式にフォーマットする（SI単位: 1000ベース）
    /// - Parameter bytes: サイズ（バイト）
    /// - Returns: フォーマット済み文字列（例: "45.2 MB", "2.34 GB"）
    static func format(_ bytes: Int64) -> String {
        let absBytes = abs(bytes)
        
        switch absBytes {
        case 0..<1_000:
            return "\(absBytes) B"
        case 1_000..<1_000_000:
            let kb = Double(absBytes) / 1_000.0
            return "\(Int(kb)) KB"
        case 1_000_000..<1_000_000_000:
            let mb = Double(absBytes) / 1_000_000.0
            return String(format: "%.1f MB", mb)
        default:
            let gb = Double(absBytes) / 1_000_000_000.0
            return String(format: "%.2f GB", gb)
        }
    }
}
