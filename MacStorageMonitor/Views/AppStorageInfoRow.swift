import SwiftUI
import AppKit

/// アプリ一覧の各行表示
struct AppStorageInfoRow: View {
    let app: AppDisplayItem
    
    var body: some View {
        HStack(spacing: 10) {
            // アプリアイコン
            appIcon
                .frame(width: 32, height: 32)
            
            // アプリ名 + インストール元バッジ
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                
                // インストール元バッジ
                installSourceBadge
            }
            
            Spacer()
            
            // 使用量
            Text(FileSizeFormatter.format(app.totalSize))
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(6)
    }
    
    /// アプリアイコンの表示
    @ViewBuilder
    private var appIcon: some View {
        let icon = NSWorkspace.shared.icon(forFile: app.appPath)
        Image(nsImage: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    /// インストール元バッジ
    private var installSourceBadge: some View {
        let source = app.installSource
        return HStack(spacing: 2) {
            Text(source.badgeEmoji)
                .font(.system(size: 8))
            Text(source.displayName)
                .font(.system(size: 9))
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 1)
        .background(source.badgeColor.opacity(0.15))
        .foregroundStyle(source.badgeColor)
        .cornerRadius(4)
    }
}
