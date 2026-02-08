## ADDED Requirements

### Requirement: Creator-Based Recommendations
系統 SHALL 基於使用者最近紀錄的創作者，推薦該創作者的其他作品。

#### Scenario: 推薦導演其他電影
- **WHEN** 使用者最近記錄了導演 A 的電影
- **AND** 進入 Explore 頁面
- **THEN** 系統顯示導演 A 的其他電影作品
- **AND** 標示「因為你記錄了《電影名》」

#### Scenario: 推薦作者其他書籍
- **WHEN** 使用者最近記錄了作者 B 的書籍
- **THEN** 系統顯示作者 B 的其他著作

#### Scenario: 推薦藝人其他專輯
- **WHEN** 使用者最近記錄了藝人 C 的專輯
- **THEN** 系統顯示藝人 C 的其他專輯

### Requirement: Recommendation Algorithm
推薦演算法 SHALL 在本地端執行，無需雲端運算。

#### 演算法流程
1. 取得最近 10 筆有 creatorId 的 Entry
2. 提取不重複的 creatorId 列表
3. 依類型呼叫對應 API 取得創作者其他作品
4. 過濾已存在於使用者 Entry 的作品
5. 合併結果，按日期（新→舊）排序

#### Scenario: 無重複推薦
- **WHEN** 使用者已記錄某作品
- **THEN** 該作品不會出現在推薦列表中

#### Scenario: 無紀錄時的空狀態
- **WHEN** 使用者沒有任何 Entry
- **THEN** 顯示「開始記錄你的閱聽體驗，探索更多相關作品」

### Requirement: Category Filtering
使用者 SHALL 能夠依類型篩選推薦內容。

#### Scenario: 篩選電影
- **WHEN** 使用者點擊「Movies」篩選標籤
- **THEN** 只顯示電影類型的推薦

#### Scenario: 顯示全部
- **WHEN** 使用者點擊「All」篩選標籤
- **THEN** 顯示所有類型的推薦

### Requirement: Quick Add to Wishlist
使用者 SHALL 能夠快速將推薦項目加入 wishlist。

#### Scenario: 一鍵加入
- **WHEN** 使用者點擊推薦卡片上的「加入」按鈕
- **THEN** 系統建立新的 Entry（status: wishlist）
- **AND** 自動填入標題、封面、創作者資訊
- **AND** 顯示確認提示

### Requirement: Recommendation Caching
系統 SHALL 快取推薦結果以支援離線瀏覽。

#### Scenario: 快取推薦
- **WHEN** 成功獲取推薦結果
- **THEN** 系統將結果儲存於本地快取

#### Scenario: 離線瀏覽
- **WHEN** 裝置離線
- **AND** 使用者進入 Explore 頁面
- **THEN** 系統顯示上次快取的推薦結果
- **AND** 提示「離線模式 - 顯示快取內容」

#### Scenario: 自動刷新
- **WHEN** 網路恢復
- **AND** 快取超過 1 小時
- **THEN** 系統自動刷新推薦內容
