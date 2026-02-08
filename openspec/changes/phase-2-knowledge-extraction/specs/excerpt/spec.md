## ADDED Requirements

### Requirement: Excerpt Data Model
精選段落 (Excerpt) SHALL 包含以下資料結構：

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| id | string | 是 | 唯一識別碼 |
| text | string | 是 | 擷取的文字內容 |
| pageNumber | number | 否 | 書本頁碼 |
| imageUrl | string | 否 | 原始拍攝圖片 URL |
| aiAnalysis | string | 否 | AI 分析結果 |
| createdAt | timestamp | 是 | 建立時間 |
| updatedAt | timestamp | 是 | 最後更新時間 |

#### Scenario: 建立 Excerpt
- **WHEN** 使用者完成 OCR 辨識並確認文字
- **THEN** 系統建立 Excerpt 文件於該 Entry 的子集合

### Requirement: Create Excerpt via OCR
使用者 SHALL 能夠透過拍照自動辨識書本文字並儲存為精選段落。

#### Scenario: 拍照辨識
- **WHEN** 使用者在 Entry 詳情頁點擊「新增段落」
- **AND** 使用相機拍攝書本頁面
- **THEN** 系統自動辨識圖片中的文字
- **AND** 顯示辨識結果供使用者編輯

#### Scenario: 確認儲存
- **WHEN** 使用者編輯完辨識結果
- **AND** 點擊「儲存」
- **THEN** 系統建立新的 Excerpt
- **AND** 可選擇性輸入頁碼

#### Scenario: 從相簿選取
- **WHEN** 使用者選擇從相簿匯入圖片
- **THEN** 系統對選取的圖片進行 OCR
- **AND** 顯示辨識結果

### Requirement: List Excerpts
使用者 SHALL 能夠在 Entry 詳情頁瀏覽所有精選段落。

#### Scenario: 顯示段落列表
- **WHEN** 使用者進入書籍類型的 Entry 詳情頁
- **THEN** 系統顯示該 Entry 的所有 Excerpt
- **AND** 按 createdAt 降序排列

#### Scenario: 空列表提示
- **WHEN** Entry 沒有任何 Excerpt
- **THEN** 顯示「尚無精選段落」提示
- **AND** 顯示「新增段落」按鈕

### Requirement: Read Excerpt Detail
使用者 SHALL 能夠查看精選段落的完整內容。

#### Scenario: 查看詳情
- **WHEN** 使用者點擊某個 Excerpt
- **THEN** 系統顯示完整文字內容
- **AND** 若有 AI 分析結果，一併顯示

### Requirement: Update Excerpt
使用者 SHALL 能夠編輯精選段落的內容。

#### Scenario: 編輯文字
- **WHEN** 使用者在 Excerpt 詳情頁點擊「編輯」
- **AND** 修改文字內容或頁碼
- **THEN** 系統更新該 Excerpt

### Requirement: Delete Excerpt
使用者 SHALL 能夠刪除精選段落。

#### Scenario: 刪除段落
- **WHEN** 使用者點擊「刪除」並確認
- **THEN** 系統刪除該 Excerpt
- **AND** 若有關聯圖片，同時刪除
