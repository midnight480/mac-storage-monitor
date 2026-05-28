// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacStorageMonitor",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "MacStorageMonitor",
            path: "MacStorageMonitor",
            exclude: ["MacStorageMonitor.entitlements"]
        )
    ]
)
