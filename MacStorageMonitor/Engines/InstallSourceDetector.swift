import Foundation

/// アプリのインストール元を判定するエンジン
actor InstallSourceDetector {
    
    private let fileManager = FileManager.default
    
    /// Homebrew Cask管理アプリのキャッシュ（スキャンごとに1回取得）
    private var homebrewCaskApps: Set<String>?
    
    /// brewコマンドのタイムアウト（秒）
    private let brewTimeout: TimeInterval = 10.0
    
    // MARK: - 公開メソッド
    
    /// アプリのインストール元を判定する
    func detectInstallSource(for appURL: URL) -> InstallSource {
        let appName = appURL.deletingPathExtension().lastPathComponent
        
        // 1. Homebrew チェック
        if isHomebrewApp(appName: appName) {
            return .homebrew
        }
        
        // 2. App Store チェック
        if hasAppStoreReceipt(at: appURL) {
            return .appStore
        }
        
        // 3. /Applications/ に存在すれば直接ダウンロード
        if appURL.path.hasPrefix("/Applications/") {
            return .directDownload
        }
        
        // 4. 不明
        return .unknown
    }
    
    /// Homebrew Caskアプリ一覧のキャッシュをリフレッシュする
    func refreshHomebrewCache() async {
        homebrewCaskApps = nil
        _ = await getHomebrewCaskApps()
    }
    
    /// キャッシュをクリアする（次回スキャン用）
    func clearCache() {
        homebrewCaskApps = nil
    }
    
    // MARK: - Homebrew判定
    
    /// Homebrewで管理されているアプリかどうか判定
    private func isHomebrewApp(appName: String) -> Bool {
        // キャッシュがなければ取得を試みる（同期的に）
        if homebrewCaskApps == nil {
            homebrewCaskApps = loadHomebrewCaskApps()
        }
        
        guard let caskApps = homebrewCaskApps else { return false }
        
        // Cask名とアプリ名の照合（大文字小文字無視）
        let normalizedAppName = appName.lowercased()
        
        // 完全一致
        if caskApps.contains(normalizedAppName) {
            return true
        }
        
        // ハイフン/スペース変換で照合
        let hyphenated = normalizedAppName.replacingOccurrences(of: " ", with: "-")
        if caskApps.contains(hyphenated) {
            return true
        }
        
        // Caskroomディレクトリスキャンで照合
        return isCaskroomApp(appName: appName)
    }
    
    /// brew list --cask と Caskroomスキャンの結果を統合して取得
    private func loadHomebrewCaskApps() -> Set<String> {
        var result = Set<String>()
        
        // 方法1: brew list --cask コマンド実行
        if let brewApps = executeBrewListCask() {
            result.formUnion(brewApps)
        }
        
        // 方法2: Caskroomディレクトリスキャン
        let caskroomApps = scanCaskroomDirectory()
        result.formUnion(caskroomApps)
        
        return result
    }
    
    /// `brew list --cask` コマンドを実行して結果をパースする
    private func executeBrewListCask() -> Set<String>? {
        // brewのパスを検出（絶対パスのみ許可）
        let brewPaths = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
        guard let brewPath = brewPaths.first(where: { fileManager.fileExists(atPath: $0) }) else {
            return nil
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: brewPath)
        process.arguments = ["list", "--cask"]
        // セキュリティ: 環境変数をクリアしてPATH操作攻撃を防止
        process.environment = [:]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        do {
            try process.run()

            // デッドロック防止: パイプの読み取りをプロセス終了待ちの前に実行
            // パイプバッファが満杯になるとプロセスがブロックされるため
            let data = pipe.fileHandleForReading.readDataToEndOfFile()

            // タイムアウト付きでプロセス終了を待機
            let deadline = Date().addingTimeInterval(brewTimeout)
            while process.isRunning && Date() < deadline {
                Thread.sleep(forTimeInterval: 0.1)
            }
            if process.isRunning {
                process.terminate()
                return nil
            }

            guard process.terminationStatus == 0 else { return nil }
            guard let output = String(data: data, encoding: .utf8) else { return nil }
            
            let casks = output
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                .filter { !$0.isEmpty }
            
            return Set(casks)
        } catch {
            return nil
        }
    }
    
    /// /opt/homebrew/Caskroom/ をスキャンしてCask名を取得
    private func scanCaskroomDirectory() -> Set<String> {
        let caskroomPaths = ["/opt/homebrew/Caskroom", "/usr/local/Caskroom"]
        
        var result = Set<String>()
        
        for caskroomPath in caskroomPaths {
            let caskroomURL = URL(fileURLWithPath: caskroomPath)
            guard fileManager.fileExists(atPath: caskroomPath) else { continue }
            
            guard let contents = try? fileManager.contentsOfDirectory(
                at: caskroomURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            
            for item in contents {
                result.insert(item.lastPathComponent.lowercased())
            }
        }
        
        return result
    }
    
    /// Caskroom内にアプリ名に対応するフォルダがあるか確認
    private func isCaskroomApp(appName: String) -> Bool {
        let caskroomPaths = ["/opt/homebrew/Caskroom", "/usr/local/Caskroom"]
        let normalizedName = appName.lowercased().replacingOccurrences(of: " ", with: "-")

        for caskroomPath in caskroomPaths {
            let caskroomURL = URL(fileURLWithPath: caskroomPath)
            let appCaskURL = caskroomURL.appendingPathComponent(normalizedName)

            // パストラバーサル防止: Caskroomディレクトリ外へのアクセスを拒否
            let resolved = appCaskURL.standardized.path
            let parent = caskroomURL.standardized.path + "/"
            guard resolved.hasPrefix(parent) else { continue }

            if fileManager.fileExists(atPath: appCaskURL.path) {
                return true
            }
        }

        return false
    }
    
    // MARK: - App Store判定
    
    /// App Storeレシートの存在を確認する
    private func hasAppStoreReceipt(at appURL: URL) -> Bool {
        let receiptPath = appURL
            .appendingPathComponent("Contents/_MASReceipt/receipt")
        return fileManager.fileExists(atPath: receiptPath.path)
    }
    
    // MARK: - ユーティリティ
    
    /// Homebrew Caskアプリ一覧を取得（外部公開用）
    func getHomebrewCaskApps() async -> Set<String> {
        if let cached = homebrewCaskApps {
            return cached
        }
        let apps = loadHomebrewCaskApps()
        homebrewCaskApps = apps
        return apps
    }
}
