## ADDED Requirements

### Requirement: Entry Data Model
每筆閱聽紀錄 (Entry) SHALL 包含以下資料結構：

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| id | string | 是 | 唯一識別碼 |
| type | enum | 是 | book, movie, tv, music, other |
| title | string | 是 | 作品標題 |
| creator | string | 否 | 作者/導演/藝人 |
| creatorId | string | 否 | 外部 API 的創作者 ID |
| coverUrl | string | 否 | 封面圖片 URL |
| coverStoragePath | string | 否 | Firebase Storage 路徑（僅 other 類型）|
| externalId | string | 否 | 外部 API 的作品 ID |
| status | enum | 是 | wishlist, in-progress, completed, dropped, recall |
| rating | number | 否 | 0-10，0.5 為單位 |
| review | string | 否 | 文字心得 |
| tags | string[] | 否 | 標籤 ID 陣列 |
| startDate | timestamp | 否 | 開始日期 |
| endDate | timestamp | 否 | 結束日期 |
| createdAt | timestamp | 是 | 建立時間 |
| updatedAt | timestamp | 是 | 最後更新時間 |
| metadata | map | 否 | 額外資訊 |

#### Scenario: 建立書籍紀錄
- **WHEN** 使用者選擇類型為「書籍」
- **AND** 填寫必填欄位（標題、狀態）
- **THEN** 系統建立 Entry 文件於 Firestore
- **AND** createdAt 和 updatedAt 自動設定為當前時間

### Requirement: Create Entry
使用者 SHALL 能夠建立新的閱聽紀錄。

#### Scenario: 手動建立紀錄
- **WHEN** 使用者點擊「新增」按鈕
- **AND** 選擇媒介類型
- **AND** 填寫標題和狀態
- **THEN** 系統建立新的 Entry
- **AND** 導航至 Entry 詳情頁面

#### Scenario: 透過 API 搜尋建立紀錄
- **WHEN** 使用者在新增頁面搜尋作品名稱
- **AND** 選擇搜尋結果中的一項
- **THEN** 系統自動填入標題、封面 URL、創作者、外部 ID
- **AND** 使用者可繼續填寫其他欄位

### Requirement: Read Entry
使用者 SHALL 能夠瀏覽自己的閱聽紀錄列表和詳情。

#### Scenario: 瀏覽紀錄列表
- **WHEN** 使用者進入 Journal 頁面
- **THEN** 系統顯示使用者的所有 Entry
- **AND** 按 updatedAt 降序排列

#### Scenario: 篩選紀錄
- **WHEN** 使用者選擇篩選條件（類型、狀態、評分）
- **THEN** 系統只顯示符合條件的 Entry

#### Scenario: 查看紀錄詳情
- **WHEN** 使用者點擊某筆 Entry
- **THEN** 系統顯示該 Entry 的完整資訊

### Requirement: Update Entry
使用者 SHALL 能夠編輯現有的閱聽紀錄。

#### Scenario: 編輯紀錄
- **WHEN** 使用者在詳情頁點擊「編輯」
- **AND** 修改任意欄位
- **AND** 點擊「儲存」
- **THEN** 系統更新 Entry
- **AND** updatedAt 自動更新為當前時間

#### Scenario: 更新狀態
- **WHEN** 使用者將狀態從「進行中」改為「已完成」
- **AND** endDate 為空
- **THEN** 系統自動將 endDate 設為當前日期

### Requirement: Delete Entry
使用者 SHALL 能夠刪除閱聽紀錄。

#### Scenario: 刪除紀錄
- **WHEN** 使用者在詳情頁點擊「刪除」
- **AND** 確認刪除操作
- **THEN** 系統刪除該 Entry
- **AND** 若有 coverStoragePath，同時刪除 Storage 檔案
- **AND** 導航回 Journal 頁面

### Requirement: Entry Offline Support
使用者 SHALL 能夠在離線狀態下瀏覽和編輯 Entry。

#### Scenario: 離線瀏覽
- **WHEN** 裝置無網路連線
- **THEN** 系統顯示本地快取的 Entry 資料

#### Scenario: 離線編輯
- **WHEN** 使用者在離線狀態編輯 Entry
- **THEN** 系統將變更存入本地快取
- **AND** 網路恢復後自動同步至 Firestore

### Requirement: Entry Cover Image for Other Type
當 Entry 類型為「其他」時，使用者 SHALL 能夠上傳自訂封面圖片。

#### Scenario: 上傳自訂封面
- **WHEN** 使用者建立或編輯類型為「other」的 Entry
- **AND** 選擇從相簿或相機取得圖片
- **THEN** 系統將圖片壓縮為 WebP 格式（最大 1080p，品質 80%）
- **AND** 上傳至 Firebase Storage
- **AND** 將路徑儲存於 coverStoragePath
