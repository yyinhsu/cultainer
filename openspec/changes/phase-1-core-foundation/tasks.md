## 1. 專案初始化

- [ ] 1.1 建立 Flutter 專案 (`flutter create cultainer`)
- [ ] 1.2 設定目錄結構 (lib/app, lib/core, lib/features, lib/models, lib/repositories, lib/services)
- [ ] 1.3 新增 `very_good_analysis` 並設定 `analysis_options.yaml`
- [ ] 1.4 設定 pre-commit hooks (husky + lint-staged for Dart)
- [ ] 1.5 建立 `.env.example` 和環境變數管理
- [ ] 1.6 設定 Git 忽略規則 (`.gitignore`)

## 2. Firebase 設定

- [ ] 2.1 建立 Firebase 專案
- [ ] 2.2 啟用 Authentication (Google Sign-In)
- [ ] 2.3 啟用 Firestore Database
- [ ] 2.4 啟用 Storage
- [ ] 2.5 設定 Firestore 安全規則
- [ ] 2.6 設定 Storage 安全規則
- [ ] 2.7 整合 `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- [ ] 2.8 設定 iOS Bundle ID 和 Android Package Name
- [ ] 2.9 啟用 Firestore 離線持久化

## 3. 核心 UI 框架

- [ ] 3.1 建立深色主題 (`AppTheme`)，參考 mobile.pen 色彩
- [ ] 3.2 設定字型 (Fraunces, DM Sans, Inter)
- [ ] 3.3 建立共用元件庫 (buttons, cards, inputs, icons)
- [ ] 3.4 實作底部導航列 (Tab Bar)
- [ ] 3.5 設定路由系統 (`go_router`)
- [ ] 3.6 建立空白頁面骨架 (Home, Explore, Journal, Profile)

## 4. 認證功能

- [ ] 4.1 建立 `AuthRepository`
- [ ] 4.2 實作 Google Sign-In 流程
- [ ] 4.3 建立登入頁面 UI
- [ ] 4.4 實作登出功能
- [ ] 4.5 建立認證狀態管理 (Riverpod)
- [ ] 4.6 設定認證路由守衛

## 5. 資料模型

- [ ] 5.1 建立 `User` model
- [ ] 5.2 建立 `Entry` model
- [ ] 5.3 建立 `Tag` model
- [ ] 5.4 建立 `Excerpt` model
- [ ] 5.5 實作 Firestore 序列化/反序列化
- [ ] 5.6 建立 model 單元測試

## 6. Entry 功能

- [ ] 6.1 建立 `EntryRepository` (CRUD)
- [ ] 6.2 實作 Entry 列表頁面 (Journal Page)
- [ ] 6.3 實作 Entry 詳情頁面
- [ ] 6.4 實作新增/編輯 Entry 頁面
- [ ] 6.5 實作刪除 Entry 功能
- [ ] 6.6 實作篩選功能 (by type, status, rating)
- [ ] 6.7 實作搜尋功能

## 7. Tags 功能

- [ ] 7.1 建立 `TagRepository`
- [ ] 7.2 實作 Tags 管理頁面
- [ ] 7.3 實作 Tag 選擇器元件
- [ ] 7.4 整合 Tags 到 Entry 編輯流程

## 8. 外部 API 整合

- [ ] 8.1 建立 `GoogleBooksService`
- [ ] 8.2 建立 `TmdbService`
- [ ] 8.3 建立 `SpotifyService`
- [ ] 8.4 實作媒體搜尋介面
- [ ] 8.5 實作自動封面抓取
- [ ] 8.6 儲存創作者 ID (用於 Explore 推薦)

## 9. Home Page

- [ ] 9.1 實作統計卡片 (Your Stats)
- [ ] 9.2 實作本週活動 (This Week)
- [ ] 9.3 實作最近紀錄 (Recent Reviews)
- [ ] 9.4 實作 Collections 區塊

## 10. Profile Page

- [ ] 10.1 顯示使用者資料
- [ ] 10.2 實作設定選單
- [ ] 10.3 預留 Gemini API Key 輸入欄位
- [ ] 10.4 實作登出按鈕
- [ ] 10.5 顯示版本資訊

## 11. 測試

- [ ] 11.1 Model 單元測試
- [ ] 11.2 Repository 單元測試
- [ ] 11.3 Service 單元測試
- [ ] 11.4 核心 Widget 測試
- [ ] 11.5 認證流程整合測試

## 12. 文件與發布準備

- [ ] 12.1 撰寫 README.md
- [ ] 12.2 建立隱私政策文件
- [ ] 12.3 設定 iOS App 資訊 (Info.plist)
- [ ] 12.4 設定 Android App 資訊 (AndroidManifest.xml)
- [ ] 12.5 建立 App Icons
