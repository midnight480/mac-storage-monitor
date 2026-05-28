import Foundation

/// バックグラウンドスキャンのスケジューリングを管理する
@MainActor
final class ScanSchedulerService {
    
    /// スキャン実行時のコールバック
    var onScanRequested: (() async -> Void)?
    
    /// 定期スキャン用タイマー
    private var timer: Timer?
    
    /// 現在のスキャン間隔（秒）
    private(set) var currentInterval: TimeInterval
    
    init(interval: TimeInterval = 3600) {
        self.currentInterval = interval
    }
    
    /// 定期スキャンを開始する
    func start(interval: TimeInterval? = nil) {
        if let interval = interval {
            currentInterval = interval
        }
        
        stop()
        
        timer = Timer.scheduledTimer(withTimeInterval: currentInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.onScanRequested?()
            }
        }
    }
    
    /// 定期スキャンを停止する
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    /// スキャン間隔を変更する（タイマーを再スケジュール）
    func reschedule(interval: TimeInterval) {
        currentInterval = interval
        if timer != nil {
            start(interval: interval)
        }
    }
    
    /// 即時スキャンを実行し、タイマーをリセットする
    func triggerImmediateScan() async {
        await onScanRequested?()
        // タイマーリセット（次回は間隔後に実行）
        if timer != nil {
            start()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
