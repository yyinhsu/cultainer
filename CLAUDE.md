<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Cultainer - 專案指引

## 專案概述

Cultainer 是一個全方位跨平台（iOS / macOS / Web）閱聽紀錄與知識擷取工具。

## 快速參考

### 技術棧
- **Frontend**: Flutter (Dart) + Riverpod
- **Backend**: Firebase (Firestore, Auth, Storage)
- **AI**: Google ML Kit (OCR), Gemini Pro
- **APIs**: Google Books, TMDB, Spotify
- **IDE**: VS Code（開發）→ Xcode（僅發布簽名）

### 常用指令
```bash
flutter run                    # 執行開發版
flutter test                   # 執行測試
flutter analyze                # 靜態分析
dart format lib test           # 格式化程式碼
dart run build_runner build    # 產生程式碼
```

### 目錄結構
- `lib/features/` - 功能模組（auth, home, journal, explore, calendar, profile, entry）
- `lib/core/` - 共用元件、主題、工具
- `lib/models/` - 資料模型
- `lib/repositories/` - 資料存取層
- `lib/services/` - 外部服務整合

### 開發規範
- Commit 格式：`type(scope): description`
- Linter：`very_good_analysis`
- 檔案命名：`snake_case.dart`
- 類別命名：`PascalCase`

## 開發階段

| Phase | 狀態 | 內容 |
|-------|------|------|
| 1 | 待開發 | 核心基礎（Auth、Entry CRUD、API 整合） |
| 2 | 待開發 | 知識擷取（OCR、AI 輔助） |
| 3 | 待開發 | 探索推薦（Explore、Calendar） |
| 4 | 待開發 | 平台擴展與發布 |

詳見 `openspec/changes/` 目錄中的各階段提案。