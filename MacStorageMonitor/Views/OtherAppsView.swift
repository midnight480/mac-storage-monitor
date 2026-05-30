import SwiftUI

/// TOP10以外で1MB以上のアプリを一覧表示する別画面
/// 設定画面と同様に、ポップオーバー内でメインコンテンツと切り替えて表示する
struct OtherAppsView: View {
    let apps: [AppDisplayItem]
    let totalBytes: Int64
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.otherAppsTitle)
                        .font(.headline)
                    Text(L10n.otherAppsSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("other-apps-dismiss-button")
            }

            Divider()

            // サマリー（件数・合計サイズ）
            HStack {
                Text(L10n.otherAppsCount(apps.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(L10n.otherAppsTotal(FileSizeFormatter.format(totalBytes)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Divider()

            // アプリ一覧
            if apps.isEmpty {
                Text(L10n.otherAppsEmpty)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(apps) { app in
                            AppStorageInfoRow(app: app)
                        }
                    }
                }
                .frame(maxHeight: 320)
            }
        }
    }
}
