## ADDED Requirements

### Requirement: Monthly Calendar View
系統 SHALL 提供月曆視圖顯示閱聽紀錄。

#### Scenario: 顯示當月月曆
- **WHEN** 使用者進入 Calendar 頁面
- **THEN** 系統顯示當月的月曆格子
- **AND** 標題顯示「月份 年份」（如 February 2026）

#### Scenario: 月份導航
- **WHEN** 使用者點擊上/下月按鈕
- **THEN** 月曆切換至對應月份

### Requirement: Entry Indicators on Calendar
月曆 SHALL 標示有紀錄的日期。

#### Scenario: 顯示紀錄指示
- **WHEN** 某日期有 Entry（以 endDate 或 createdAt 為準）
- **THEN** 該日期格子顯示指示標記（如封面縮圖或圓點）

#### Scenario: 多筆紀錄
- **WHEN** 同一日期有多筆 Entry
- **THEN** 顯示數量指示（如堆疊效果或數字）

### Requirement: Date Selection
使用者 SHALL 能夠選擇日期查看當日紀錄。

#### Scenario: 選擇日期
- **WHEN** 使用者點擊月曆上的某個日期
- **THEN** 該日期顯示選中樣式
- **AND** 下方顯示該日期的 Entry 列表

#### Scenario: 無紀錄日期
- **WHEN** 選中的日期沒有 Entry
- **THEN** 顯示「這天沒有紀錄」
- **AND** 提供「新增紀錄」按鈕

### Requirement: Today Quick Jump
使用者 SHALL 能夠快速跳轉至今天。

#### Scenario: 跳轉今天
- **WHEN** 使用者點擊「Today」按鈕
- **THEN** 月曆跳轉至當月
- **AND** 自動選中今天的日期

### Requirement: Selected Date Detail
選中日期時 SHALL 顯示該日的紀錄詳情。

#### Scenario: 顯示當日紀錄
- **WHEN** 使用者選中有紀錄的日期
- **THEN** 下方區塊顯示：
  - 日期標題（如 Friday, 6th）
  - Entry 卡片（封面、標題、評分）
  - 可點擊進入詳情

### Requirement: Calendar Performance
月曆 SHALL 高效載入紀錄資料。

#### Scenario: 效能要求
- **WHEN** 使用者切換月份
- **THEN** 月曆在 500ms 內完成渲染
- **AND** Entry 指示標記在 1 秒內載入
