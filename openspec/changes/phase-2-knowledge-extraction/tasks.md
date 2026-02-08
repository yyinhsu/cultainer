## 1. ML Kit OCR 整合

- [ ] 1.1 新增 `google_ml_kit` 依賴
- [ ] 1.2 設定 iOS/Android 相機權限
- [ ] 1.3 建立 `OcrService`
- [ ] 1.4 實作文字辨識功能
- [ ] 1.5 處理多語言支援（中英文）

## 2. 相機 OCR 頁面

- [ ] 2.1 實作相機預覽畫面
- [ ] 2.2 實作拍照功能
- [ ] 2.3 實作即時文字辨識
- [ ] 2.4 顯示辨識結果並允許編輯
- [ ] 2.5 實作儲存為 Excerpt 功能
- [ ] 2.6 支援從相簿選取圖片

## 3. Excerpt 資料模型與 Repository

- [ ] 3.1 建立 `Excerpt` model
- [ ] 3.2 建立 `ExcerptRepository` (CRUD)
- [ ] 3.3 實作 Firestore 子集合存取
- [ ] 3.4 建立單元測試

## 4. Excerpt UI

- [ ] 4.1 在 Entry Detail 新增 Excerpts 區塊
- [ ] 4.2 實作 Excerpt 列表元件
- [ ] 4.3 實作 Excerpt 詳情頁面
- [ ] 4.4 實作 Excerpt 編輯功能
- [ ] 4.5 實作 Excerpt 刪除功能

## 5. Gemini API 整合

- [ ] 5.1 新增 `google_generative_ai` 依賴
- [ ] 5.2 建立 `GeminiService`
- [ ] 5.3 實作 API Key 驗證
- [ ] 5.4 實作文字分析功能
- [ ] 5.5 實作錯誤處理（API Key 無效、額度超限等）

## 6. Gemini API Key 設定

- [ ] 6.1 在 Profile 新增 API Key 輸入欄位
- [ ] 6.2 實作 API Key 加密儲存
- [ ] 6.3 實作 API Key 驗證流程
- [ ] 6.4 顯示 API 使用說明

## 7. AI 輔助功能介面

- [ ] 7.1 在 Excerpt 詳情新增 AI 功能按鈕
- [ ] 7.2 實作「重點解析」功能
- [ ] 7.3 實作「摘要」功能
- [ ] 7.4 實作「心得潤飾」功能（用於 Entry review）
- [ ] 7.5 顯示 AI 分析結果並允許儲存

## 8. 測試

- [ ] 8.1 OcrService 單元測試
- [ ] 8.2 GeminiService 單元測試
- [ ] 8.3 ExcerptRepository 單元測試
- [ ] 8.4 OCR 流程整合測試
