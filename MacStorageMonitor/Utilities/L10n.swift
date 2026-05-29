import Foundation

/// ローカライズ文字列ヘルパー
/// OS言語設定が日本語の場合は日本語、それ以外は英語を表示
enum L10n {
    // MARK: - Disk Overview
    static var diskTitle: String { localized("disk.title") }
    static func diskUsed(_ used: String, _ total: String) -> String {
        String(format: localized("disk.used"), used, total)
    }
    static func diskFree(_ free: String) -> String {
        String(format: localized("disk.free"), free)
    }
    static var diskLoading: String { localized("disk.loading") }
    
    // MARK: - App List
    static var appListTitle: String { localized("appList.title") }
    static var appListScanning: String { localized("appList.scanning") }
    static var appListNoData: String { localized("appList.noData") }
    static func appListError(_ error: String) -> String {
        String(format: localized("appList.error"), error)
    }

    // MARK: - Other Apps (beyond TOP10)
    static var otherAppsTitle: String { localized("otherApps.title") }
    static var otherAppsSubtitle: String { localized("otherApps.subtitle") }
    static var otherAppsButton: String { localized("otherApps.button") }
    static func otherAppsCount(_ count: Int) -> String {
        String(format: localized("otherApps.count"), count)
    }
    static func otherAppsTotal(_ total: String) -> String {
        String(format: localized("otherApps.total"), total)
    }
    static var otherAppsEmpty: String { localized("otherApps.empty") }

    // MARK: - Footer
    static func footerLastScan(_ date: String) -> String {
        String(format: localized("footer.lastScan"), date)
    }
    static var footerRescan: String { localized("footer.rescan") }
    static var footerInterval: String { localized("footer.interval") }
    static var footerSettings: String { localized("footer.settings") }
    static var footerQuit: String { localized("footer.quit") }
    
    // MARK: - Settings
    static var settingsTitle: String { localized("settings.title") }
    static var settingsGeneral: String { localized("settings.general") }
    static var settingsLaunchAtLogin: String { localized("settings.launchAtLogin") }
    static var settingsScanInterval: String { localized("settings.scanInterval") }
    
    // MARK: - Interval Presets
    static var interval5min: String { localized("interval.5min") }
    static var interval15min: String { localized("interval.15min") }
    static var interval30min: String { localized("interval.30min") }
    static var interval1hour: String { localized("interval.1hour") }
    static var interval6hours: String { localized("interval.6hours") }
    static var interval24hours: String { localized("interval.24hours") }
    
    // MARK: - Install Source
    static var installSourceUnknown: String { localized("installSource.unknown") }
    
    // MARK: - Private
    
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: .module, comment: "")
    }
}
