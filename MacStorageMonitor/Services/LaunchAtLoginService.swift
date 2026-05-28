import Foundation
import ServiceManagement

/// ログイン時自動起動の管理サービス
/// SMAppService.mainApp を使用してLogin Items登録/解除を行う
final class LaunchAtLoginService {
    
    /// 共有インスタンス
    static let shared = LaunchAtLoginService()
    
    /// SMAppServiceインスタンス
    private let appService = SMAppService.mainApp
    
    private init() {}
    
    // MARK: - 公開プロパティ
    
    /// 現在のLogin Items登録状態
    var isEnabled: Bool {
        appService.status == .enabled
    }
    
    // MARK: - 公開メソッド
    
    /// ログイン時自動起動を有効にする
    /// - Throws: 登録に失敗した場合
    func enable() throws {
        try appService.register()
    }
    
    /// ログイン時自動起動を無効にする
    /// - Throws: 解除に失敗した場合
    func disable() throws {
        try appService.unregister()
    }
    
    /// ログイン時自動起動の状態を設定する
    /// - Parameter enabled: true で有効化、false で無効化
    /// - Throws: 登録/解除に失敗した場合
    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try enable()
        } else {
            try disable()
        }
    }
}
