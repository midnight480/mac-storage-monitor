import SwiftUI

/// ディスク全体の使用量概要セクション
struct DiskOverviewSection: View {
    let diskUsage: DiskUsageInfo?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.diskTitle)
                .font(.headline)
            
            if let usage = diskUsage {
                // プログレスバー
                ProgressView(value: Double(usage.usedSpace), total: Double(usage.totalCapacity))
                    .tint(progressColor(percentage: usage.usagePercentage))
                
                // 使用量テキスト
                HStack {
                    Text(L10n.diskUsed(
                        FileSizeFormatter.format(usage.usedSpace),
                        FileSizeFormatter.format(usage.totalCapacity)
                    ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(L10n.diskFree(FileSizeFormatter.format(usage.freeSpace)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(L10n.diskLoading)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    /// 使用率に応じたプログレスバーの色
    private func progressColor(percentage: Int) -> Color {
        switch percentage {
        case 0..<70: return .green
        case 70..<85: return .orange
        default: return .red
        }
    }
}
