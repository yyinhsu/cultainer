## ADDED Requirements

### Requirement: On-Device OCR
系統 SHALL 使用 Google ML Kit 在裝置端進行文字辨識，無需網路連線。

#### Scenario: 離線辨識
- **WHEN** 裝置無網路連線
- **AND** 使用者拍攝書本頁面
- **THEN** 系統仍可正常進行 OCR 辨識

### Requirement: Multi-Language OCR Support
系統 SHALL 支援中文和英文的文字辨識。

#### Scenario: 中文書籍辨識
- **WHEN** 使用者拍攝中文書籍頁面
- **THEN** 系統正確辨識繁體中文和簡體中文

#### Scenario: 英文書籍辨識
- **WHEN** 使用者拍攝英文書籍頁面
- **THEN** 系統正確辨識英文文字

#### Scenario: 中英混合辨識
- **WHEN** 書頁包含中英文混合內容
- **THEN** 系統同時辨識兩種語言

### Requirement: Camera Preview for OCR
系統 SHALL 提供相機預覽畫面進行 OCR 拍攝。

#### Scenario: 相機預覽
- **WHEN** 使用者進入 OCR 拍攝頁面
- **THEN** 系統顯示相機即時預覽
- **AND** 提供拍攝按鈕

#### Scenario: 拍攝確認
- **WHEN** 使用者按下拍攝按鈕
- **THEN** 系統擷取當前畫面
- **AND** 立即進行文字辨識
- **AND** 顯示辨識結果

### Requirement: OCR Result Editing
使用者 SHALL 能夠編輯 OCR 辨識結果後再儲存。

#### Scenario: 修正辨識錯誤
- **WHEN** OCR 辨識結果有錯誤
- **THEN** 使用者可直接在文字框中修改
- **AND** 修改後的內容將被儲存

### Requirement: OCR Performance
OCR 辨識 SHALL 在合理時間內完成。

#### Scenario: 辨識效能
- **WHEN** 使用者拍攝一般書籍頁面（約 500 字）
- **THEN** 辨識結果在 3 秒內顯示
