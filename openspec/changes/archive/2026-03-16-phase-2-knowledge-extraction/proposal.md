# Change: Phase 2 - 知識擷取系統

## Why

Cultainer 的核心價值之一是幫助使用者從閱聽內容中擷取知識。Phase 2 專注於：
- OCR 精選段落功能：讓使用者拍照書本內容，自動轉為純文字
- AI 輔助功能：透過 Gemini Pro 進行摘要、解析、潤飾
- 精選段落管理：瀏覽、編輯、刪除已擷取的段落

這些功能將大幅提升「書籍」類型 Entry 的使用價值。

## What Changes

### 新增功能
- Google ML Kit 整合（on-device OCR）
- 相機拍攝 + 即時文字辨識
- Excerpt（精選段落）CRUD
- Gemini API 整合
- AI 輔助功能介面
  - 段落解析
  - 重點摘要
  - 心得潤飾
- Gemini API Key 設定介面

### 涉及畫面
- Entry Detail Page（新增 Excerpts 區塊）
- Camera OCR Page（新增）
- Excerpt Detail Page（新增）
- Profile Page（新增 Gemini API Key 設定）

## Impact

- **Affected specs**: 
  - `specs/excerpt/spec.md` (新增)
  - `specs/ocr/spec.md` (新增)
  - `specs/ai-assistant/spec.md` (新增)

- **Affected code**: 
  - `lib/features/entry/` - 新增 excerpt 相關元件
  - `lib/features/ocr/` - 新增 OCR 功能
  - `lib/features/profile/` - 新增 API Key 設定
  - `lib/services/` - 新增 ML Kit 和 Gemini 服務

## Dependencies

- Phase 1 完成
- Google ML Kit SDK
- Google AI SDK (Gemini)

## Success Criteria

- [ ] 可拍攝書本頁面並辨識文字
- [ ] OCR 結果可編輯後儲存
- [ ] 使用者可輸入 Gemini API Key
- [ ] AI 可對精選段落進行分析
- [ ] Excerpt 列表可正常顯示於 Entry 詳情
