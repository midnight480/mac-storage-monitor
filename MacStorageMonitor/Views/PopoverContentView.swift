import SwiftUI

/// ポップオーバーのメインコンテンツビュー
struct PopoverContentView: View {
    @ObservedObject var viewModel: StorageViewModel
    @State private var showSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showSettings {
                SettingsView(
                    launchAtLogin: $viewModel.launchAtLogin,
                    scanInterval: $viewModel.scanInterval,
                    onDismiss: { showSettings = false }
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
            
            if let error = viewModel.errorMessage {
                Text(L10n.appListError(error))
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
    }
}
