import SwiftUI

/// アプリのインストール元
enum InstallSource: String, Codable, CaseIterable {
    case homebrew = "homebrew"
    case appStore = "appStore"
    case directDownload = "directDownload"
    case unknown = "unknown"
    
    /// 表示名
    var displayName: String {
        switch self {
        case .homebrew: return "Homebrew"
        case .appStore: return "App Store"
        case .directDownload: return "Direct"
        case .unknown: return L10n.installSourceUnknown
        }
    }
    
    /// バッジの絵文字
    var badgeEmoji: String {
        switch self {
        case .homebrew: return "🍺"
        case .appStore: return "🏪"
        case .directDownload: return "🌐"
        case .unknown: return "❓"
        }
    }
    
    /// バッジの色
    var badgeColor: Color {
        switch self {
        case .homebrew: return .orange
        case .appStore: return .blue
        case .directDownload: return .green
        case .unknown: return .gray
        }
    }
}
