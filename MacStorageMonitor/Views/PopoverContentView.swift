import SwiftUI

/// ポップオーバーのメインコンテンツビュー
struct PopoverContentView: View {
    @ObservedObject var viewModel: StorageViewModel
    @State private var showSettings = false
    
    var body: some View {
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
        .padding(16)
        .frame(width: 320)
    }
    
    @ViewBuilder
    private var appListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TOP 10 アプリ使用量")
                .font(.headline)
            
            if viewModel.isScanning && viewModel.appStorageList.isEmpty {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("スキャン中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else if viewModel.appStorageList.isEmpty {
                Text("データなし")
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
                Text("エラー: \(error)")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
    }
}
