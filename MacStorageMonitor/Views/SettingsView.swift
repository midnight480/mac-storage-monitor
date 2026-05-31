import SwiftUI

/// 設定画面ビュー
struct SettingsView: View {
    @Binding var launchAtLogin: Bool
    @Binding var language: SettingsService.AppLanguage
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ヘッダー
            HStack {
                Text(L10n.settingsTitle)
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings-dismiss-button")
            }
            
            Divider()
            
            // 一般設定セクション
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.settingsGeneral)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // ログイン時自動起動トグル
                Toggle(L10n.settingsLaunchAtLogin, isOn: $launchAtLogin)
                    .toggleStyle(.switch)
                    .accessibilityIdentifier("settings-launch-at-login-toggle")
                
                // 言語設定
                HStack {
                    Text(L10n.settingsLanguage)
                    Spacer()
                    Picker("", selection: $language) {
                        Text(L10n.settingsLanguageSystem).tag(SettingsService.AppLanguage.system)
                        Text(L10n.settingsLanguageJa).tag(SettingsService.AppLanguage.ja)
                        Text(L10n.settingsLanguageEn).tag(SettingsService.AppLanguage.en)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    .accessibilityIdentifier("settings-language-picker")
                }
            }
            
            Spacer()
        }
    }
}
