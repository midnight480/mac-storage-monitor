import SwiftUI

/// 設定画面ビュー
struct SettingsView: View {
    @Binding var launchAtLogin: Bool
    @Binding var scanInterval: TimeInterval
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ヘッダー
            HStack {
                Text("設定")
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
                Text("一般")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // ログイン時自動起動トグル
                Toggle("ログイン時に自動起動", isOn: $launchAtLogin)
                    .toggleStyle(.switch)
                    .accessibilityIdentifier("settings-launch-at-login-toggle")
                
                // スキャン間隔設定
                HStack {
                    Text("スキャン間隔")
                    Spacer()
                    Picker("", selection: $scanInterval) {
                        ForEach(SettingsService.intervalPresets, id: \.value) { preset in
                            Text(preset.label).tag(preset.value)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                    .accessibilityIdentifier("settings-scan-interval-picker")
                }
            }
            
            Spacer()
        }
        .padding(16)
        .frame(width: 320, height: 200)
    }
}
