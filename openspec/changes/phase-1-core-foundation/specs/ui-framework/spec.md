## ADDED Requirements

### Requirement: Dark Theme Design System
應用程式 SHALL 使用深色主題設計系統，基於 mobile.pen 設計稿。

#### 色彩系統
| Token | Hex | 用途 |
|-------|-----|------|
| background | #0B0B0E | 主背景 |
| surface | #16161A | 卡片、輸入框背景 |
| surfaceVariant | #1A1A1E | 按鈕、Tab Bar 背景 |
| border | #2A2A2E | 邊框、分隔線 |
| textPrimary | #FAFAF9 | 主要文字 |
| textSecondary | #6B6B70 | 次要文字、placeholder |
| textTertiary | #4A4A50 | 最淡文字 |
| primary | #6366F1 | 主色調（Indigo） |
| error | #DC2626 | 錯誤、刪除 |

#### Scenario: 一致的視覺風格
- **WHEN** 使用者瀏覽任何頁面
- **THEN** 所有 UI 元件遵循統一的色彩和間距規範

### Requirement: Typography System
應用程式 SHALL 使用一致的字型系統。

#### 字型配置
| 用途 | 字型 | 範例 |
|------|------|------|
| 標題 | Fraunces | 頁面標題、卡片標題 |
| 內文 | DM Sans | 段落文字、按鈕文字 |
| 系統 | Inter | 狀態列、數字 |

#### 字級規範
| Token | Size | Weight | 用途 |
|-------|------|--------|------|
| displayLarge | 28px | 600 | 頁面主標題 |
| headlineMedium | 22px | 600 | 區塊標題 |
| headlineSmall | 18px | 600 | 卡片標題 |
| bodyLarge | 16px | 500 | 主要內文 |
| bodyMedium | 14px | 400 | 一般內文 |
| bodySmall | 13px | 500 | 次要資訊 |
| labelSmall | 12px | 400 | 標籤、時間戳 |

#### Scenario: 標題使用 Fraunces
- **WHEN** 顯示頁面標題（如「Calendar」「Explore」）
- **THEN** 使用 Fraunces 字型，fontSize 28，fontWeight 600

### Requirement: Bottom Tab Bar
應用程式 SHALL 提供底部導航列，包含 5 個主要功能入口。

#### Tab 配置
| 順序 | 圖示 | 標籤 | 目標頁面 |
|------|------|------|----------|
| 1 | house | Home | Home Page |
| 2 | compass | Explore | Explore Page |
| 3 | plus | - | 新增 Entry |
| 4 | book-open | Journal | Journal Page |
| 5 | user | Profile | Profile Page |

#### Scenario: 導航切換
- **WHEN** 使用者點擊 Tab Bar 中的項目
- **THEN** 切換至對應頁面
- **AND** 更新 Tab 的選中狀態（圖示填充 + 標籤顯示）

#### Scenario: 新增按鈕特殊處理
- **WHEN** 使用者點擊中間的「+」按鈕
- **THEN** 彈出新增 Entry 的 modal 或導航至新增頁面

### Requirement: Card Component
系統 SHALL 提供統一的卡片元件樣式。

#### 樣式規範
- 背景色：#16161A
- 圓角：16px（一般）/ 20px（大卡片）
- 陰影：color #00000040, blur 16, spread -4, offsetY 4
- 內間距：14-16px

#### Scenario: Review Card
- **WHEN** 顯示 Entry 卡片
- **THEN** 包含封面圖（圓角 12px）、標題、創作者、評分、日期

### Requirement: Button Components
系統 SHALL 提供多種按鈕樣式。

#### 按鈕類型
| 類型 | 背景 | 用途 |
|------|------|------|
| Primary | #6366F1 | 主要操作 |
| Secondary | #1A1A1E + border | 次要操作 |
| Ghost | 透明 | 文字連結 |
| Destructive | #DC262615 | 刪除操作 |
| Icon | #1A1A1E 圓形 | 圖示按鈕 |

#### Scenario: Primary Button
- **WHEN** 需要強調主要操作（如「儲存」「確認」）
- **THEN** 使用 Primary 按鈕樣式

### Requirement: Filter Chips
系統 SHALL 提供篩選標籤元件。

#### 樣式規範
- 未選中：背景 #1A1A1E，邊框 #2A2A2E，圓角 20px
- 選中：背景 #6366F1，無邊框

#### Scenario: Category Filter
- **WHEN** 使用者在 Journal 或 Explore 頁面篩選類型
- **THEN** 顯示 All / Albums / Movies / Books 等 Filter Chips
- **AND** 點擊時切換選中狀態

### Requirement: Status Bar
每個頁面 SHALL 包含模擬的 iOS 狀態列（用於設計一致性）。

#### Scenario: 狀態列顯示
- **WHEN** 顯示任何頁面
- **THEN** 頂部顯示時間（左）和系統圖示（右：訊號、WiFi、電量）
- **AND** 高度 54px，內間距 horizontal 24px

### Requirement: Page Header
每個頁面 SHALL 包含一致的頁面標題區域。

#### Scenario: 標準頁面標題
- **WHEN** 顯示頁面
- **THEN** 標題區域包含：
  - 左側：頁面標題（Fraunces, 28px, 600）
  - 右側：操作按鈕（可選）
