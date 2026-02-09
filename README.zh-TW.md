# Cultainer

全方位跨平台（iOS / macOS / Web）閱聽紀錄與知識擷取工具。

[English](README.md) | **繁體中文**

## 功能特色

- 📚 **統一管理** - 書籍、電影、影集、音樂閱聽紀錄
- 📸 **OCR 擷取** - 拍照即時辨識書本文字
- 🤖 **AI 輔助** - Gemini Pro 智慧分析與摘要
- 🔍 **探索推薦** - 基於創作者的相關作品推薦
- 📅 **時間軸** - 月曆視圖回顧閱聽歷程
- ☁️ **雲端同步** - Firebase 跨裝置同步

## 技術架構

- **前端**: Flutter (Dart)
- **後端**: Firebase (Firestore, Auth, Storage)
- **AI**: Google ML Kit (OCR), Gemini Pro
- **外部 API**: Google Books, TMDB, Spotify

## 開發環境設定

### 前置需求

- Flutter SDK >= 3.19
- Dart SDK >= 3.3
- VS Code + Flutter 擴充套件（主要開發環境）
- Xcode（僅用於 iOS/macOS 模擬器執行與發布簽名）
- Android Studio 或 Android SDK（Android 模擬器）
- Firebase CLI

> 💡 **開發策略**: 日常開發使用 VS Code，僅在 App Store 上架時才需要開啟 Xcode 進行簽名設定。

### 安裝步驟

```bash
# 1. Clone 專案
git clone https://github.com/your-username/cultainer.git
cd cultainer

# 2. 安裝依賴
flutter pub get

# 3. 設定環境變數
cp .env.example .env
# 編輯 .env 填入 API Keys

# 4. 設定 Firebase
flutterfire configure

# 5. 安裝 pre-commit hooks
dart pub global activate lefthook
lefthook install

# 6. 執行應用程式
flutter run
```

### 環境變數

建立 `.env` 檔案：

```env
TMDB_API_KEY=your_tmdb_api_key
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
```

## 專案結構

```
lib/
├── main.dart              # 應用程式入口
├── app/                   # App 設定、路由
├── core/                  # 共用元件、主題、工具
├── features/              # 功能模組
│   ├── auth/              # 認證
│   ├── home/              # 首頁
│   ├── journal/           # 日誌
│   ├── explore/           # 探索
│   ├── calendar/          # 月曆
│   ├── profile/           # 個人頁
│   └── entry/             # 紀錄管理
├── models/                # 資料模型
├── repositories/          # 資料存取層
└── services/              # 外部服務整合
```

## 開發指令

```bash
# 格式化程式碼
dart format lib test

# 靜態分析
flutter analyze

# 執行測試
flutter test

# 產生程式碼（freezed, json_serializable）
dart run build_runner build

# 建置 iOS
flutter build ios

# 建置 macOS
flutter build macos

# 建置 Web
flutter build web
```

## VS Code 快捷操作

### 啟動與除錯

| 快捷鍵 | 功能 |
|--------|------|
| `F5` | 啟動 Debug 模式（可在左側面板選擇目標裝置） |
| `Ctrl+F5` | 啟動 Release 模式 |
| `Shift+F5` | 停止執行 |
| `Cmd+Shift+F5` | 重新啟動 |

### 常用任務

按 `Cmd+Shift+P` → 輸入 `Tasks: Run Task`，可執行：

| 任務名稱 | 功能 |
|----------|------|
| Flutter: Get Packages | 安裝依賴 (`flutter pub get`) |
| Flutter: Build Runner | 產生程式碼 (freezed, json_serializable) |
| Flutter: Build Runner (Watch) | 持續監聽並產生程式碼 |
| Flutter: Run Tests | 執行測試 |
| Flutter: Run Tests with Coverage | 執行測試並產生覆蓋率報告 |
| Flutter: Analyze | 靜態分析 |
| Flutter: Format | 格式化程式碼 |
| Flutter: Clean | 清除快取並重新安裝依賴 |
| Flutter: Build iOS (Release) | 建置 iOS Release 版本 |
| Flutter: Build Web | 建置 Web 版本 |
| Pre-commit Check | 完整檢查（格式化 + 分析 + 測試） |

### 除錯設定

在 `Run and Debug` 面板（`Cmd+Shift+D`）可選擇：

| 設定名稱 | 說明 |
|----------|------|
| cultainer (debug) | 預設 Debug 模式 |
| cultainer (profile) | Profile 模式（效能分析） |
| cultainer (release) | Release 模式 |
| cultainer (iOS Simulator) | 在 iOS 模擬器執行 |
| cultainer (Chrome) | 在 Chrome 瀏覽器執行 |
| cultainer (macOS) | 在 macOS 執行 |

### 推薦擴充套件

首次開啟專案時，VS Code 會提示安裝推薦擴充套件：

- **Dart** - Dart 語言支援
- **Flutter** - Flutter 開發工具
- **Awesome Flutter Snippets** - 程式碼片段
- **Error Lens** - 即時錯誤提示
- **GitLens** - Git 增強工具
- **Todo Tree** - TODO 註解追蹤

## 開發規範

- 遵循 [Conventional Commits](https://www.conventionalcommits.org/) 格式
- 使用 `very_good_analysis` linter
- 程式碼需通過 pre-commit hooks 檢查
- 詳見 [openspec/project.md](openspec/project.md)

## 授權

MIT License
