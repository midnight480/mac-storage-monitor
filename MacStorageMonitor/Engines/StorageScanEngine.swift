import Foundation
import os

/// ファイルシステムスキャンエンジン
/// アプリケーションの関連ファイルを検出し、サイズを集計する
actor StorageScanEngine {
    
    private let fileManager = FileManager.default
    private let logger = Logger(subsystem: "com.mac-storage-monitor", category: "StorageScanEngine")
    
    /// アプリ情報（スキャン結果の一時構造体）
    struct ScannedApp: Sendable {
        let name: String
        let bundleIdentifier: String
        let appURL: URL
        let totalSize: Int64
        let appBundleSize: Int64
        let relatedFiles: [RelatedFile]
        let installSource: InstallSource
        
        struct RelatedFile: Sendable {
            let url: URL
            let size: Int64
            let category: FileCategory
        }
    }
    
    // MARK: - 公開メソッド
    
    /// /Applications/ 内の全アプリをスキャンし、関連ファイルサイズを集計する
    func scanAllApplications(installSourceDetector: InstallSourceDetector) async -> [ScannedApp] {
        let applicationsURL = URL(fileURLWithPath: "/Applications")
        
        let contents: [URL]
        do {
            contents = try fileManager.contentsOfDirectory(
                at: applicationsURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
        } catch {
            logger.error("Failed to read /Applications/: \(error.localizedDescription)")
            return []
        }
        
        let appURLs = contents.filter { $0.pathExtension == "app" }
        logger.info("Detected apps: \(appURLs.count)")
        
        var results: [ScannedApp] = []
        
        for appURL in appURLs {
            if let appInfo = await scanApplication(at: appURL, installSourceDetector: installSourceDetector) {
                results.append(appInfo)
            }
        }
        
        logger.info("Scan completed: \(results.count) apps")
        return results
    }
    
    /// ディスク全体の使用量/空き容量を取得する
    func getDiskUsage() throws -> DiskUsageInfo {
        let attributes = try fileManager.attributesOfFileSystem(forPath: "/")
        
        guard let totalSize = attributes[.systemSize] as? Int64,
              let freeSize = attributes[.systemFreeSize] as? Int64 else {
            throw ScanError.diskInfoUnavailable
        }
        
        return DiskUsageInfo(
            totalCapacity: totalSize,
            usedSpace: totalSize - freeSize,
            freeSpace: freeSize
        )
    }
    
    // MARK: - 内部メソッド
    
    /// 特定アプリの関連ファイルを検出し、サイズを集計する
    private func scanApplication(at appURL: URL, installSourceDetector: InstallSourceDetector) async -> ScannedApp? {
        let appName = appURL.deletingPathExtension().lastPathComponent
        
        // バンドルIDを取得（Info.plistから直接読む）
        let bundleIdentifier = readBundleIdentifier(at: appURL) ?? "unknown.\(appName)"
        
        // アプリ本体サイズ
        let appBundleSize = calculateDirectorySize(at: appURL)
        
        // 関連ファイル検出
        var relatedFiles: [ScannedApp.RelatedFile] = []
        
        // Application Support
        let appSupportFiles = findRelatedFiles(
            bundleIdentifier: bundleIdentifier,
            appName: appName,
            in: libraryURL("Application Support"),
            category: .applicationSupport
        )
        relatedFiles.append(contentsOf: appSupportFiles)
        
        // Preferences
        let prefFiles = findPreferenceFiles(bundleIdentifier: bundleIdentifier)
        relatedFiles.append(contentsOf: prefFiles)
        
        // Containers
        let containerFiles = findRelatedFiles(
            bundleIdentifier: bundleIdentifier,
            appName: appName,
            in: libraryURL("Containers"),
            category: .containers
        )
        relatedFiles.append(contentsOf: containerFiles)
        
        // Logs
        let logFiles = findRelatedFiles(
            bundleIdentifier: bundleIdentifier,
            appName: appName,
            in: libraryURL("Logs"),
            category: .logs
        )
        relatedFiles.append(contentsOf: logFiles)
        
        // Saved Application State
        let savedStateURL = libraryURL("Saved Application State")
            .appendingPathComponent("\(bundleIdentifier).savedState")
        if isDirectory(at: savedStateURL) {
            let size = calculateDirectorySize(at: savedStateURL)
            if size > 0 {
                relatedFiles.append(ScannedApp.RelatedFile(url: savedStateURL, size: size, category: .savedState))
            }
        }
        
        // 合計サイズ
        let relatedSize = relatedFiles.reduce(Int64(0)) { $0 + $1.size }
        let totalSize = appBundleSize + relatedSize
        
        // インストール元判定
        let installSource = await installSourceDetector.detectInstallSource(for: appURL)
        
        return ScannedApp(
            name: appName,
            bundleIdentifier: bundleIdentifier,
            appURL: appURL,
            totalSize: totalSize,
            appBundleSize: appBundleSize,
            relatedFiles: relatedFiles,
            installSource: installSource
        )
    }
    
    /// Info.plistからバンドルIDを直接読み取る
    private func readBundleIdentifier(at appURL: URL) -> String? {
        let infoPlistURL = appURL.appendingPathComponent("Contents/Info.plist")
        
        do {
            let data = try Data(contentsOf: infoPlistURL)
            guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                  let bundleID = plist["CFBundleIdentifier"] as? String else {
                logger.debug("No CFBundleIdentifier in plist: \(infoPlistURL.path, privacy: .private)")
                return nil
            }
            return bundleID
        } catch {
            logger.debug("Failed to read Info.plist at \(infoPlistURL.path, privacy: .private): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 指定ディレクトリ内でバンドルIDまたはアプリ名に一致するフォルダを検索
    private func findRelatedFiles(
        bundleIdentifier: String,
        appName: String,
        in directory: URL,
        category: FileCategory
    ) -> [ScannedApp.RelatedFile] {
        guard isDirectory(at: directory) else { return [] }
        
        var results: [ScannedApp.RelatedFile] = []
        
        // バンドルIDで検索
        let bundleIDPath = directory.appendingPathComponent(bundleIdentifier)
        if isDirectory(at: bundleIDPath) {
            let size = calculateDirectorySize(at: bundleIDPath)
            if size > 0 {
                results.append(ScannedApp.RelatedFile(url: bundleIDPath, size: size, category: category))
            }
        }
        
        // アプリ名で検索（バンドルIDと異なる場合のみ）
        let appNamePath = directory.appendingPathComponent(appName)
        if appNamePath.path != bundleIDPath.path && isDirectory(at: appNamePath) {
            let size = calculateDirectorySize(at: appNamePath)
            if size > 0 {
                results.append(ScannedApp.RelatedFile(url: appNamePath, size: size, category: category))
            }
        }
        
        return results
    }
    
    /// PreferencesディレクトリでバンドルIDに一致するplistファイルを検索
    private func findPreferenceFiles(bundleIdentifier: String) -> [ScannedApp.RelatedFile] {
        let prefsDir = libraryURL("Preferences")
        guard isDirectory(at: prefsDir) else { return [] }
        
        var results: [ScannedApp.RelatedFile] = []
        
        let contents: [URL]
        do {
            contents = try fileManager.contentsOfDirectory(
                at: prefsDir,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            )
        } catch {
            logger.warning("Failed to read Preferences directory: \(error.localizedDescription)")
            return []
        }
        
        // バンドルIDで始まるファイルを検索
        let matchingFiles = contents.filter { url in
            url.lastPathComponent.lowercased().hasPrefix(bundleIdentifier.lowercased())
        }
        
        for file in matchingFiles {
            do {
                let resourceValues = try file.resourceValues(forKeys: [.fileSizeKey])
                if let size = resourceValues.fileSize {
                    results.append(ScannedApp.RelatedFile(url: file, size: Int64(size), category: .preferences))
                }
            } catch {
                logger.debug("Failed to get file size for \(file.path, privacy: .private): \(error.localizedDescription)")
            }
        }
        
        return results
    }
    
    /// ディレクトリの再帰的サイズ計算
    private func calculateDirectorySize(at url: URL) -> Int64 {
        var totalSize: Int64 = 0
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isSymbolicLinkKey],
            options: []
        ) else { return 0 }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(
                    forKeys: [.fileSizeKey, .isSymbolicLinkKey]
                )
                
                // シンボリックリンクはスキップ
                if resourceValues.isSymbolicLink == true {
                    enumerator.skipDescendants()
                    continue
                }
                
                if let fileSize = resourceValues.fileSize {
                    totalSize += Int64(fileSize)
                }
            } catch {
                logger.debug("Failed to get resource values for \(fileURL.path, privacy: .private): \(error.localizedDescription)")
                continue
            }
        }
        
        return totalSize
    }
    
    /// ~/Library/ 配下のディレクトリURLを取得
    /// - Parameter subdirectory: Library配下のサブディレクトリ名（パストラバーサル防止のため「..」を含む値は拒否）
    private func libraryURL(_ subdirectory: String) -> URL {
        precondition(!subdirectory.contains(".."), "Path traversal detected in subdirectory: '\(subdirectory)'")
        let homeDir = fileManager.homeDirectoryForCurrentUser
        return homeDir.appendingPathComponent("Library/\(subdirectory)")
    }
    
    /// シンボリックリンクを追跡せずにディレクトリの存在を確認する（TOCTOU対策）
    private func isDirectory(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDir) else { return false }
        guard isDir.boolValue else { return false }
        // シンボリックリンクでないことを確認
        let attributes = try? fileManager.attributesOfItem(atPath: url.path)
        return attributes?[.type] as? FileAttributeType != .typeSymbolicLink
    }
}

// MARK: - エラー定義

enum ScanError: Error, LocalizedError {
    case diskInfoUnavailable
    case scanFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .diskInfoUnavailable:
            return "ディスク情報を取得できませんでした"
        case .scanFailed(let message):
            return "スキャンに失敗しました: \(message)"
        }
    }
}
