import Foundation

/// ファイルサイズのフォーマッタ
/// B/KB/MB/GB の適切な単位で表示する
enum FileSizeFormatter {
    
    /// バイト数を人間が読みやすい形式にフォーマットする
    /// - Parameter bytes: サイズ（バイト）
    /// - Returns: フォーマット済み文字列（例: "45.2 MB", "2.34 GB"）
    static func format(_ bytes: Int64) -> String {
        let absBytes = abs(bytes)
        
        switch absBytes {
        case 0..<1024:
            return "\(absBytes) B"
        case 1024..<(1024 * 1024):
            let kb = Double(absBytes) / 1024.0
            return "\(Int(kb)) KB"
        case (1024 * 1024)..<(1024 * 1024 * 1024):
            let mb = Double(absBytes) / (1024.0 * 1024.0)
            return String(format: "%.1f MB", mb)
        default:
            let gb = Double(absBytes) / (1024.0 * 1024.0 * 1024.0)
            return String(format: "%.2f GB", gb)
        }
    }
}
