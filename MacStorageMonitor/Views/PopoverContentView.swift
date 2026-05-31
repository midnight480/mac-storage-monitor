import SwiftUI

/// ポップオーバーのメインコンテンツビュー
struct PopoverContentView: View {
    @ObservedObject var viewModel: StorageViewModel
    @State private var showSettings = false
    @State private var showOtherApps = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showSettings {
                SettingsView(
                    launchAtLogin: $viewModel.launchAtLogin,
                    language: $viewModel.language,
                    onDismiss: { showSettings = false }
                )
            } else if showOtherApps {
                OtherAppsView(
                    apps: viewModel.otherAppsList,
                    totalBytes: viewModel.otherAppsTotalBytes,
                    onDismiss: { showOtherApps = false }
                )
            } else {
                mainContent
            }
        }
        .padding(16)
        .frame(width: 320)
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ディスク概要セクション
            DiskOverviewSection(diskUsage: viewModel.diskUsage)
            
            Divider()
            
            // アプリ一覧セクション
            appListSection
            
            Divider()
            
            // フッターセクション
            FooterSection(
                lastScanDate: viewModel.lastScanDate,
                isScanning: viewModel.isScanning,
                scanInterval: $viewModel.scanInterval,
                onRescan: {
                    Task {
                        await viewModel.triggerManualScan()
                    }
                },
                onOpenSettings: { showSettings = true }
            )
        }
    }
    
    @ViewBuilder
    private var appListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.appListTitle)
                .font(.headline)
            
            if viewModel.isScanning && viewModel.appStorageList.isEmpty {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text(L10n.appListScanning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else if viewModel.appStorageList.isEmpty {
                Text(L10n.appListNoData)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 4) {
                    ForEach(viewModel.appStorageList) { app in
                        AppStorageInfoRow(app: app)
                    }
                }
            }

            // TOP10以外で1MB以上のアプリがある場合は別画面への導線を表示
            if !viewModel.otherAppsList.isEmpty {
                Button {
                    showOtherApps = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "ellipsis.circle")
                            .font(.caption)
                        Text(L10n.otherAppsButton)
                            .font(.caption)
                        Spacer()
                        Text("\(viewModel.otherAppsList.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .padding(.top, 2)
                .accessibilityIdentifier("show-other-apps-button")
            }

            if let error = viewModel.errorMessage {
                Text(L10n.appListError(error))
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
    }
}
