# Change: Phase 1 - 核心基礎建設

## Why

Cultainer 需要一個穩固的基礎架構來支撐後續所有功能。Phase 1 專注於：
- Flutter 專案初始化與開發環境設定
- Firebase 整合（Auth、Firestore、Storage）
- 核心 UI 框架與導航系統
- 媒介紀錄 (Entry) 的完整 CRUD 功能
- 外部 API 整合（Google Books、TMDB、Spotify）

這是整個專案的地基，後續所有功能都將依賴這些基礎設施。

## What Changes

### 新增功能
- Flutter 專案骨架與目錄結構
- Pre-commit hooks 設定（linter、formatter、tests）
- Firebase 專案設定與 SDK 整合
- 使用者認證流程（Google Sign-In）
- 深色主題 UI 系統（基於 mobile.pen 設計）
- 底部導航列（Home、Explore、Add、Journal、Profile）
- Entry Model 與 Repository
- Entry CRUD 介面（新增、編輯、刪除、列表）
- 外部 API 服務整合
- 自動封面抓取功能
- 自訂 Tags 管理
- Firestore 離線支援

### 涉及畫面
- Home Page
- Journal Page
- Profile Page
- Entry Detail Page (新增)
- Entry Edit Page (新增)
- Tags Management Page (新增)

## Impact

- **Affected specs**: 
  - `specs/auth/spec.md` (新增)
  - `specs/entry/spec.md` (新增)
  - `specs/media-api/spec.md` (新增)
  - `specs/ui-framework/spec.md` (新增)

- **Affected code**: 
  - 整個 `lib/` 目錄結構
  - Firebase 設定檔
  - Pre-commit 設定檔

## Dependencies

- Flutter SDK >= 3.19
- Dart SDK >= 3.3
- Firebase CLI
- TMDB API Key
- Google Books API (無需 key)
- Spotify Developer App

## Success Criteria

- [ ] Flutter 專案可在 iOS Simulator 和 Chrome 上執行
- [ ] 使用者可用 Google 帳號登入/登出
- [ ] 可新增、編輯、刪除各類型的 Entry
- [ ] 搜尋書籍/電影/音樂時自動載入封面
- [ ] 離線時可瀏覽已同步的資料
- [ ] Pre-commit hooks 正常運作
