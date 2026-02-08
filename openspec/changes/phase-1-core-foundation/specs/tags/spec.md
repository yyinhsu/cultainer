## ADDED Requirements

### Requirement: Tag Data Model
標籤 (Tag) SHALL 包含以下資料結構：

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| id | string | 是 | 唯一識別碼 |
| name | string | 是 | 標籤名稱 |
| color | string | 否 | 標籤顏色（hex） |
| createdAt | timestamp | 是 | 建立時間 |

#### Scenario: 建立標籤
- **WHEN** 使用者輸入標籤名稱
- **THEN** 系統建立 Tag 文件於 Firestore

### Requirement: Create Tag
使用者 SHALL 能夠建立自訂標籤。

#### Scenario: 從 Tags 管理頁面建立
- **WHEN** 使用者進入 Tags 管理頁面
- **AND** 輸入新標籤名稱
- **AND** 選擇顏色（可選）
- **THEN** 系統建立新的 Tag

#### Scenario: 從 Entry 編輯頁面快速建立
- **WHEN** 使用者在 Entry 編輯頁面的標籤選擇器中
- **AND** 輸入不存在的標籤名稱
- **THEN** 系統顯示「建立新標籤」選項
- **AND** 點擊後建立該標籤並加入 Entry

### Requirement: List Tags
使用者 SHALL 能夠查看所有自訂標籤。

#### Scenario: 瀏覽標籤列表
- **WHEN** 使用者進入 Tags 管理頁面
- **THEN** 系統顯示所有 Tag
- **AND** 顯示每個 Tag 被使用的 Entry 數量

### Requirement: Update Tag
使用者 SHALL 能夠編輯標籤名稱和顏色。

#### Scenario: 編輯標籤
- **WHEN** 使用者點擊某個 Tag 的編輯按鈕
- **AND** 修改名稱或顏色
- **THEN** 系統更新該 Tag

### Requirement: Delete Tag
使用者 SHALL 能夠刪除標籤。

#### Scenario: 刪除標籤
- **WHEN** 使用者刪除某個 Tag
- **THEN** 系統刪除該 Tag
- **AND** 從所有關聯 Entry 中移除該 Tag ID

### Requirement: Tag Selector in Entry
Entry 編輯頁面 SHALL 提供標籤選擇器。

#### Scenario: 選擇現有標籤
- **WHEN** 使用者在 Entry 編輯頁面點擊標籤選擇器
- **THEN** 系統顯示所有可用標籤
- **AND** 使用者可勾選多個標籤

#### Scenario: 搜尋標籤
- **WHEN** 使用者在標籤選擇器中輸入文字
- **THEN** 系統篩選顯示名稱匹配的標籤
