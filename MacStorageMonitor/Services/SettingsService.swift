import Foundation

/// ユーザー設定の永続化と提供
final class SettingsService {
    
    private let defaults = UserDefaults.standard
    
    // MARK: - キー定義
    
    private enum Keys {
        static let scanInterval = "scanInterval"
        static let launchAtLogin = "launchAtLogin"
    }
    
    // MARK: - デフォルト値
    
    /// デフォルトスキャン間隔: 1時間（3600秒）
    static let defaultScanInterval: TimeInterval = 3600
    
    /// 最小スキャン間隔: 5分（300秒）
    static let minimumScanInterval: TimeInterval = 300
    
    /// 最大スキャン間隔: 24時間（86400秒）
    static let maximumScanInterval: TimeInterval = 86400
    
    // MARK: - プロパティ
    
    /// スキャン間隔（秒）
    var scanInterval: TimeInterval {
        get {
            let value = defaults.double(forKey: Keys.scanInterval)
            if value == 0 {
                return Self.defaultScanInterval
            }
            return max(Self.minimumScanInterval, min(Self.maximumScanInterval, value))
        }
        set {
            let clamped = max(Self.minimumScanInterval, min(Self.maximumScanInterval, newValue))
            defaults.set(clamped, forKey: Keys.scanInterval)
        }
    }
    
    /// ログイン時自動起動（デフォルト: OFF）
    var launchAtLogin: Bool {
        get {
            defaults.bool(forKey: Keys.launchAtLogin)
        }
        set {
            defaults.set(newValue, forKey: Keys.launchAtLogin)
        }
    }
    
    // MARK: - スキャン間隔プリセット
    
    /// UI表示用のスキャン間隔プリセット
    static var intervalPresets: [(label: String, value: TimeInterval)] {
        [
            (L10n.interval5min, 300),
            (L10n.interval15min, 900),
            (L10n.interval30min, 1800),
            (L10n.interval1hour, 3600),
            (L10n.interval6hours, 21600),
            (L10n.interval24hours, 86400)
        ]
    }
}
