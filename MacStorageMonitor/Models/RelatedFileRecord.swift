import Foundation
import SwiftData

/// アプリに関連するファイル/フォルダの記録
@Model
final class RelatedFileRecord {
    /// ファイル/フォルダのパス
    var path: String
    
    /// サイズ（バイト）
    var size: Int64
    
    /// カテゴリ（"applicationSupport" | "preferences" | "containers" | "logs" | "savedState"）
    var categoryRaw: String
    
    /// 親アプリへの参照
    var app: AppStorageRecord?
    
    /// カテゴリのenum変換
    var category: FileCategory {
        get { FileCategory(rawValue: categoryRaw) ?? .applicationSupport }
        set { categoryRaw = newValue.rawValue }
    }
    
    init(path: String, size: Int64, category: FileCategory) {
        self.path = path
        self.size = size
        self.categoryRaw = category.rawValue
    }
}

/// ファイルカテゴリ
enum FileCategory: String, Codable {
    case appBundle = "appBundle"
    case applicationSupport = "applicationSupport"
    case preferences = "preferences"
    case containers = "containers"
    case logs = "logs"
    case savedState = "savedState"
}
