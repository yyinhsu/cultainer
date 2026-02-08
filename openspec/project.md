# Project Context

## Purpose

Cultainer 是一個全方位跨平台（iOS / macOS / Web）閱聽紀錄與知識擷取工具。讓使用者記錄書籍、電影、音樂等媒介的閱聽體驗，並透過 AI 輔助進行知識擷取與整理。

### 核心價值
- **統一管理**：書籍、電影、音樂、其他媒介的閱聽紀錄集中管理
- **知識擷取**：OCR 精選段落 + AI 輔助分析
- **空間優化**：優先使用外部 API 封面 URL，最小化雲端儲存使用
- **跨平台同步**：iOS、macOS、Web 無縫同步

## Tech Stack

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **UI Design**: Material 3 with custom dark theme
- **Fonts**: Fraunces (headers), DM Sans (body), Inter (system)

### 開發工具
- **主要 IDE**: VS Code + Flutter/Dart 擴充套件
- **發布工具**: Xcode（僅用於 iOS/macOS 簽名與上架）
- **Android 發布**: Android Studio 或 CLI

### Backend & Infrastructure
- **Database**: Firebase Firestore (with offline persistence)
- **Authentication**: Firebase Auth (Google Sign-In)
- **Storage**: Firebase Storage (僅用於「其他」類型的自拍封面)
- **Functions**: Firebase Cloud Functions (預留，Phase 1 不使用)

### AI & ML
- **OCR**: Google ML Kit (on-device, 免費無限制)
- **AI Assistant**: Google Gemini Pro (使用者自備 API Key)

### External APIs
- **Books**: Google Books API
- **Movies/TV**: TMDB API
- **Music**: Spotify Web API / Apple Music API

## Project Conventions

### Code Style

#### Dart/Flutter
- 使用 `very_good_analysis` 作為 linter
- 檔案命名：`snake_case.dart`
- 類別命名：`PascalCase`
- 變數/函數命名：`camelCase`
- 常數命名：`kConstantName` 或 `SCREAMING_SNAKE_CASE`
- 每個檔案不超過 300 行，超過則拆分

#### 目錄結構
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── home/
│   ├── journal/
│   ├── explore/
│   ├── calendar/
│   ├── profile/
│   └── entry/
├── models/
├── repositories/
└── services/
```

### Architecture Patterns

- **Feature-first 結構**：每個功能模組獨立，包含 UI、邏輯、測試
- **Repository Pattern**：資料存取層抽象化
- **Clean Architecture 簡化版**：
  - Presentation (UI + State Management)
  - Domain (Models + Use Cases)
  - Data (Repositories + Data Sources)

### Testing Strategy

- **Unit Tests**: Models, Repositories, Services
- **Widget Tests**: 核心 UI 元件
- **Integration Tests**: 關鍵使用者流程
- **Coverage Target**: 70%+

### Git Workflow

- **分支策略**: GitHub Flow
  - `main`: 生產版本
  - `develop`: 開發整合
  - `feature/*`: 功能開發
  - `fix/*`: Bug 修復
  - `release/*`: 發布準備

- **Commit 格式**: Conventional Commits
  ```
  type(scope): description
  
  feat(entry): add OCR text extraction
  fix(calendar): correct date picker timezone
  docs(readme): update installation guide
  ```

- **Pre-commit Hooks**:
  - `dart format`: 程式碼格式化
  - `dart analyze`: 靜態分析
  - `flutter test`: 單元測試
  - Commit message 格式驗證

## Domain Context

### 媒介類型 (Media Types)
| Type | 中文 | 封面來源 | 儲存策略 |
|------|------|----------|----------|
| book | 書籍 | Google Books API | 僅存 URL |
| movie | 電影 | TMDB API | 僅存 URL |
| tv | 影集 | TMDB API | 僅存 URL |
| music | 音樂 | Spotify/Apple Music | 僅存 URL |
| other | 其他 | 使用者上傳 | WebP 壓縮存 Storage |

### 紀錄狀態 (Entry Status)
| Status | 中文 | 說明 |
|--------|------|------|
| wishlist | 想看 | 加入清單但尚未開始 |
| in-progress | 進行中 | 正在閱讀/觀看 |
| completed | 已完成 | 完整體驗完畢 |
| dropped | 放棄 | 中途放棄 |
| recall | 重溫 | 再次體驗 |

### 評分系統
- 10 分制 (0.5 為最小單位，可選填)
- 視覺呈現：5 顆星，每顆星可半填

### Firebase 資料結構

```
users/{userId}/
├── profile/                    # 使用者資料 (單一文件)
│   ├── displayName: string
│   ├── email: string
│   ├── avatarUrl: string?
│   ├── geminiApiKey: string?   # 加密儲存
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── tags/{tagId}/               # 自訂標籤
│   ├── name: string
│   ├── color: string?
│   └── createdAt: timestamp
│
├── entries/{entryId}/          # 閱聽紀錄
│   ├── type: "book" | "movie" | "tv" | "music" | "other"
│   ├── title: string
│   ├── creator: string         # 作者/導演/藝人名稱
│   ├── creatorId: string?      # 外部 API 的 ID (用於推薦)
│   ├── coverUrl: string?       # 封面圖片 URL
│   ├── coverStoragePath: string? # 僅 "other" 類型使用
│   ├── externalId: string?     # Google Books ID / TMDB ID / Spotify ID
│   ├── status: "wishlist" | "in-progress" | "completed" | "dropped" | "recall"
│   ├── rating: number?         # 0-10, 0.5 為單位
│   ├── review: string?         # 文字心得
│   ├── tags: string[]          # tagId 陣列
│   ├── startDate: timestamp?   # 開始日期
│   ├── endDate: timestamp?     # 結束日期
│   ├── createdAt: timestamp    # 紀錄建立時間
│   ├── updatedAt: timestamp    # 最後更新時間
│   └── metadata: map           # 額外資訊 (頁數、片長、曲目數等)
│
└── entries/{entryId}/excerpts/{excerptId}/  # 精選段落 (子集合)
    ├── text: string            # OCR 辨識的文字
    ├── pageNumber: number?     # 頁碼
    ├── imageUrl: string?       # 原始圖片 (可選保留)
    ├── aiAnalysis: string?     # Gemini 分析結果
    ├── createdAt: timestamp
    └── updatedAt: timestamp
```

## Important Constraints

### Firebase 免費額度限制
- **Firestore**: 1GB 儲存 / 50K 讀取/日 / 20K 寫入/日
- **Storage**: 5GB 儲存 / 1GB 下載/日
- **Authentication**: 無限制

### App Store 發布要求
- 隱私政策必須完整
- 資料收集透明說明
- 支援 iOS 最近 2 個主要版本
- 無 crash 的穩定版本
- Apple Developer Program 會員資格 ($99 USD/年)

### 離線支援
- Firestore offline persistence 必須啟用
- 本地快取推薦結果
- 離線時可瀏覽和編輯，上線後自動同步

## External Dependencies

### 必須申請的 API Keys
| Service | 用途 | 費用 |
|---------|------|------|
| Firebase | 後端服務 | 免費額度內 |
| TMDB | 電影/影集資料 | 免費 |
| Google Books | 書籍資料 | 免費 |
| Spotify | 音樂資料 | 免費 (需 OAuth) |

### 使用者自備
| Service | 用途 | 說明 |
|---------|------|------|
| Google AI (Gemini) | AI 輔助功能 | 使用者在 Profile 設定中填入 |

### 發布相關
| Service | 用途 | 費用 |
|---------|------|------|
| Apple Developer Program | App Store 發布 | $99 USD/年 |
| Google Play Console | Play Store 發布 | $25 USD (一次性) |
