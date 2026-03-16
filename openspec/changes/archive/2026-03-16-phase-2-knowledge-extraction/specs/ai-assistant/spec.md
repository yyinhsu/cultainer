## ADDED Requirements

### Requirement: Gemini API Key Configuration
使用者 SHALL 能夠設定自己的 Gemini API Key 以使用 AI 功能。

#### Scenario: 設定 API Key
- **WHEN** 使用者進入 Profile > Settings > AI Assistant
- **AND** 輸入 Gemini API Key
- **THEN** 系統驗證 API Key 有效性
- **AND** 加密儲存於使用者 profile

#### Scenario: API Key 無效
- **WHEN** 使用者輸入無效的 API Key
- **THEN** 系統顯示錯誤訊息「API Key 無效，請確認後重試」

#### Scenario: 未設定 API Key
- **WHEN** 使用者嘗試使用 AI 功能
- **AND** 尚未設定 API Key
- **THEN** 系統導向 API Key 設定頁面

### Requirement: Excerpt Analysis
使用者 SHALL 能夠對精選段落進行 AI 分析。

#### Scenario: 重點解析
- **WHEN** 使用者在 Excerpt 詳情頁點擊「AI 解析」
- **THEN** 系統呼叫 Gemini API 分析該段落
- **AND** 顯示分析結果（關鍵概念、背景知識、延伸思考）

#### Scenario: 儲存分析結果
- **WHEN** AI 分析完成
- **AND** 使用者點擊「儲存分析」
- **THEN** 系統將分析結果存入 Excerpt.aiAnalysis

### Requirement: Summary Generation
使用者 SHALL 能夠對多個精選段落生成摘要。

#### Scenario: 生成書籍摘要
- **WHEN** 使用者在 Entry 詳情頁點擊「AI 摘要」
- **AND** Entry 有多個 Excerpt
- **THEN** 系統將所有 Excerpt 文字傳送給 Gemini
- **AND** 生成整合性摘要

### Requirement: Review Enhancement
使用者 SHALL 能夠使用 AI 潤飾心得文字。

#### Scenario: 心得潤飾
- **WHEN** 使用者在 Entry 編輯頁的「心得」欄位
- **AND** 點擊「AI 潤飾」按鈕
- **THEN** 系統將心得文字傳送給 Gemini
- **AND** 返回潤飾後的版本供使用者選擇

#### Scenario: 接受或拒絕潤飾
- **WHEN** AI 返回潤飾結果
- **THEN** 使用者可選擇「採用」或「保留原文」

### Requirement: AI Error Handling
系統 SHALL 妥善處理 AI 相關錯誤。

#### Scenario: API 額度超限
- **WHEN** 使用者的 Gemini API 額度用盡
- **THEN** 系統顯示「API 額度已用盡，請稍後再試或升級方案」

#### Scenario: 網路錯誤
- **WHEN** AI 請求因網路問題失敗
- **THEN** 系統顯示「網路連線異常，請檢查網路後重試」
- **AND** 提供重試按鈕

#### Scenario: 內容過長
- **WHEN** 傳送給 AI 的內容超過 token 限制
- **THEN** 系統自動截斷或分批處理
- **AND** 通知使用者「內容較長，已分段處理」
