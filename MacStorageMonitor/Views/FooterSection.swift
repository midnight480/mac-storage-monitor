import SwiftUI

/// フッターセクション（再スキャン、間隔設定、設定、終了）
struct FooterSection: View {
    let lastScanDate: Date?
    let isScanning: Bool
    @Binding var scanInterval: TimeInterval
    let onRescan: () -> Void
    let onOpenSettings: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 最終スキャン日時
            if let date = lastScanDate {
                Text(L10n.footerLastScan(date.formatted(.dateTime.month().day().hour().minute())))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            HStack {
                // 再スキャンボタン
                Button(action: onRescan) {
                    HStack(spacing: 4) {
                        if isScanning {
                            ProgressView()
                                .scaleEffect(0.6)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                        }
                        Text(L10n.footerRescan)
                            .font(.caption)
                    }
                }
                .disabled(isScanning)
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                // スキャン間隔設定
                Picker(L10n.footerInterval, selection: $scanInterval) {
                    ForEach(SettingsService.intervalPresets, id: \.value) { preset in
                        Text(preset.label).tag(preset.value)
                    }
                }
                .pickerStyle(.menu)
                .controlSize(.small)
                .frame(width: 130)
            }
            
            // 設定・終了ボタン
            HStack {
                Spacer()
                Button(action: onOpenSettings) {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape")
                            .font(.caption)
                        Text(L10n.footerSettings)
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("footer-settings-button")
                
                Spacer()
                    .frame(width: 12)
                
                Button(L10n.footerQuit) {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}
