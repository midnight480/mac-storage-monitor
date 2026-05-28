# フロントエンドコンポーネント設計: Mac Storage Monitor

## コンポーネント階層

```
MacStorageMonitorApp
  |
  +-- MenuBarExtra (SwiftUI)
        |
        +-- MenuBarLabel (メニューバー表示)
        |     +-- アイコン (SF Symbol: "internaldrive")
        |     +-- パーセンテージテキスト ("67%")
        |
        +-- PopoverContentView (ポップオーバー本体)
              |
              +-- DiskOverviewSection
              |     +-- 使用量プログレスバー
              |     +-- 使用量/総容量テキスト
              |     +-- 空き容量テキスト
              |
              +-- AppListSection
              |     +-- セクションヘッダー ("TOP 10 アプリ使用量")
              |     +-- AppStorageInfoRow × 10
              |           +-- アプリアイコン (32x32)
              |           +-- アプリ名
              |           +-- インストール元バッジ
              |           +-- 使用量テキスト
              |
              +-- FooterSection
                    +-- 最終スキャン日時
                    +-- 再スキャンボタン
                    +-- スキャン間隔設定 (Picker)
                    +-- 終了ボタン
```

---

## 各コンポーネント詳細

### 1. MenuBarLabel

**表示内容**:
- SF Symbol アイコン: `internaldrive`
- ディスク使用率パーセンテージ: `"{percentage}%"`

**状態**:
- `diskUsagePercentage: Int` — ViewModelから取得

**更新タイミング**:
- スキャン完了時に自動更新

---

### 2. PopoverContentView

**レイアウト**: VStack、固定幅 320pt

**状態**:
- `@ObservedObject var viewModel: StorageViewModel`

---

### 3. DiskOverviewSection

**表示内容**:
- プログレスバー（使用率を視覚化）
- テキスト: "使用中: {used} / {total}"
- テキスト: "空き: {free}"

**Props**:
- `diskUsage: DiskUsageInfo?`

---

### 4. AppListSection

**表示内容**:
- セクションヘッダー: "TOP 10 アプリ使用量"
- スキャン中: ProgressView + "スキャン中..."
- データあり: AppStorageInfoRow のリスト
- データなし: "データなし" テキスト

**Props**:
- `apps: [AppStorageInfo]`
- `isScanning: Bool`

---

### 5. AppStorageInfoRow

**表示内容**:
- 左: アプリアイコン (32×32)
- 中央上: アプリ名 (太字)
- 中央下: インストール元バッジ (小さいカプセル型)
- 右: 使用量テキスト (フォーマット済み)

**Props**:
- `app: AppStorageInfo`

**インストール元バッジデザイン**:
| インストール元 | バッジ色 | テキスト |
|---|---|---|
| Homebrew | オレンジ | 🍺 Homebrew |
| App Store | ブルー | 🏪 App Store |
| 直接DL | グリーン | 🌐 Direct |
| 不明 | グレー | ❓ 不明 |

---

### 6. FooterSection

**表示内容**:
- 最終スキャン日時: "最終スキャン: {date}"
- 再スキャンボタン: "🔄 再スキャン" (スキャン中は無効化)
- スキャン間隔Picker: プリセット選択
- 終了ボタン: "終了" (NSApplication.shared.terminate)

**Props**:
- `lastScanDate: Date?`
- `isScanning: Bool`
- `scanInterval: Binding<TimeInterval>`

**ユーザーインタラクション**:
- 再スキャンボタンタップ → `viewModel.performScan()`
- スキャン間隔変更 → `viewModel.setScanInterval(_:)`
- 終了ボタンタップ → アプリ終了

---

## 状態管理フロー

### StorageViewModel の状態

```swift
@Observable
class StorageViewModel {
    var appStorageList: [AppStorageInfo] = []   // TOP10リスト
    var diskUsage: DiskUsageInfo?                // ディスク情報
    var isScanning: Bool = false                 // スキャン中フラグ
    var lastScanDate: Date?                      // 最終スキャン日時
    var scanInterval: TimeInterval = 3600        // スキャン間隔
    var errorMessage: String?                    // エラーメッセージ
}
```

### 状態更新フロー

```
ユーザーアクション / Timer発火
        |
        v
ViewModel.performScan()
        |
        v
isScanning = true, errorMessage = nil
        |
        v
StorageService.performFullScan() [バックグラウンド]
        |
        +-- 成功 --> appStorageList = TOP10結果
        |            diskUsage = ディスク情報
        |            lastScanDate = Date()
        |            isScanning = false
        |
        +-- 失敗 --> errorMessage = エラー内容
                     isScanning = false
                     (前回結果は維持)
```

---

## ポップオーバーサイズ

| 項目 | 値 |
|---|---|
| 幅 | 320 pt |
| 最大高さ | 500 pt |
| パディング | 16 pt |
| 行間 | 8 pt |
| アイコンサイズ | 32 × 32 pt |
| バッジフォントサイズ | 10 pt |
