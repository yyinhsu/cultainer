## 1. ML Kit OCR 整合

- [x] 1.1 新增 `google_mlkit_text_recognition` 依賴
- [x] 1.2 設定 iOS/Android 相機權限（需在 Info.plist 設定）
- [x] 1.3 建立 `OcrService`
- [x] 1.4 實作文字辨識功能
- [x] 1.5 處理多語言支援（ML Kit 預設支援中英文）

## 2. 相機 OCR 頁面

- [x] 2.1 實作相機預覽畫面（使用 image_picker）
- [x] 2.2 實作拍照功能
- [x] 2.3 實作即時文字辨識
- [x] 2.4 顯示辨識結果並允許編輯
- [x] 2.5 實作儲存為 Excerpt 功能
- [x] 2.6 支援從相簿選取圖片

## 3. Excerpt 資料模型與 Repository

- [x] 3.1 建立 `Excerpt` model
- [x] 3.2 建立 `ExcerptRepository` (CRUD)
- [x] 3.3 實作 Firestore 子集合存取
- [x] 3.4 建立單元測試

## 4. Excerpt UI

- [x] 4.1 在 Entry Detail 新增 Excerpts 區塊
- [x] 4.2 實作 Excerpt 列表元件
- [x] 4.3 實作 Excerpt 詳情頁面
- [x] 4.4 實作 Excerpt 編輯功能
- [x] 4.5 實作 Excerpt 刪除功能

## 5. Gemini API 整合

- [x] 5.1 新增 `http` 依賴（改用 REST API 而非 `google_generative_ai`）
- [x] 5.2 建立 `GeminiService`
- [x] 5.3 實作 API Key 驗證
- [x] 5.4 實作文字分析功能
- [x] 5.5 實作錯誤處理（API Key 無效、額度超限等）

## 6. Gemini API Key 設定

- [x] 6.1 在 Profile 新增 API Key 輸入欄位
- [x] 6.2 實作 API Key 加密儲存（使用 flutter_secure_storage）
- [x] 6.3 實作 API Key 驗證流程
- [x] 6.4 顯示 API 使用說明

## 7. AI 輔助功能介面

- [x] 7.1 在 Excerpt 詳情新增 AI 功能按鈕
- [x] 7.2 實作「重點解析」功能
- [x] 7.3 實作「摘要」功能
- [x] 7.4 實作「心得潤飾」功能
- [x] 7.5 顯示 AI 分析結果並允許儲存

## 8. 測試

- [x] 8.1 OcrService 單元測試
- [x] 8.2 GeminiService 單元測試
- [x] 8.3 ExcerptRepository 單元測試（需 Firestore mock）
- [x] 8.4 OCR 流程整合測試（需實機）
