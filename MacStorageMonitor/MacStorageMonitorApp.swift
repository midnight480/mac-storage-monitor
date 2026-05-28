import SwiftUI
import SwiftData

/// Mac Storage Monitor — メニューバー常駐ストレージ管理アプリ
@main
struct MacStorageMonitorApp: App {
    
    /// SwiftData モデルコンテナ
    let modelContainer: ModelContainer
    
    /// メインViewModel
    @StateObject private var viewModel: StorageViewModel
    
    init() {
        // SwiftData コンテナ初期化
        let schema = Schema([
            AppStorageRecord.self,
            RelatedFileRecord.self,
            ScanHistory.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContainer = container
            
            // ViewModel初期化（メインコンテキスト使用）
            let context = container.mainContext
            self._viewModel = StateObject(wrappedValue: StorageViewModel(modelContext: context))
        } catch {
            fatalError("SwiftData ModelContainer の初期化に失敗しました: \(error)")
        }
    }
    
    var body: some Scene {
        // メニューバー常駐（MenuBarExtra）
        MenuBarExtra {
            PopoverContentView(viewModel: viewModel)
        } label: {
            // メニューバーに表示するラベル
            HStack(spacing: 4) {
                Image(systemName: "internaldrive")
                Text("\(viewModel.diskUsagePercentage)%")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
        }
        .menuBarExtraStyle(.window)
    }
}
