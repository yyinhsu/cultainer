## Context

這是 Cultainer 專案的第一個開發階段，建立整個應用程式的技術基礎。需要在多平台（iOS、macOS、Web）運作，同時保持程式碼的可維護性和擴展性。

### 利害關係人
- 開發者：需要清晰的專案結構和開發規範
- 使用者：期待流暢的登入體驗和直覺的操作介面
- App Store 審核：需符合發布規範

### 技術限制
- Firebase 免費額度限制
- 需支援離線使用
- 需為 App Store 發布做準備

## Goals / Non-Goals

### Goals
- 建立可擴展的專案架構
- 實現完整的認證流程
- 完成 Entry CRUD 功能
- 整合外部媒體 API
- 建立一致的 UI 設計系統
- 設定自動化程式碼品質檢查

### Non-Goals
- OCR 和 AI 功能（Phase 2）
- 推薦系統（Phase 3）
- macOS / Web 特定優化（Phase 4）
- 社群功能（未規劃）

## Decisions

### 1. 狀態管理：Riverpod

**選擇**: `flutter_riverpod`

**原因**:
- 編譯時期安全，減少 runtime 錯誤
- 原生支援 async 狀態
- 易於測試
- 社群活躍，文件完善

**替代方案考慮**:
- `flutter_bloc`: 更多 boilerplate，適合大型團隊
- `provider`: Riverpod 的前身，功能較少

### 2. 路由：go_router

**選擇**: `go_router`

**原因**:
- 官方維護，與 Flutter 深度整合
- 支援 deep linking（App Store 要求）
- 支援路由守衛（認證檢查）
- URL-based routing 對 Web 友善

### 3. 外部 API 封面策略

**選擇**: 僅儲存 URL，不下載圖片

**原因**:
- 節省 Firebase Storage 空間
- 外部 CDN 通常更快
- 簡化程式碼

**風險與緩解**:
- 風險：外部 URL 可能失效
- 緩解：定期驗證 URL，失效時顯示 placeholder

### 4. 「其他」類型封面處理

**選擇**: WebP 格式，最大 1080p，品質 80%

**原因**:
- WebP 比 JPEG 小 25-35%
- 1080p 足夠高畫質顯示
- 平衡品質與儲存空間

**實作**:
```dart
final compressedImage = await FlutterImageCompress.compressWithList(
  imageBytes,
  format: CompressFormat.webp,
  quality: 80,
  minWidth: 1080,
  minHeight: 1080,
);
```

### 5. Pre-commit Hooks 工具

**選擇**: `lefthook` + Dart 原生工具

**原因**:
- `lefthook` 比 husky 更輕量
- 原生支援 parallel 執行
- 不依賴 npm

**設定內容**:
```yaml
# lefthook.yml
pre-commit:
  parallel: true
  commands:
    format:
      run: dart format --set-exit-if-changed lib test
    analyze:
      run: flutter analyze
    test:
      run: flutter test --no-pub
```

### 6. 離線支援策略

**選擇**: Firestore 原生離線持久化 + 手動快取策略

**原因**:
- Firestore 自動處理資料同步
- 減少開發複雜度

**設定**:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

## Risks / Trade-offs

| 風險 | 影響 | 機率 | 緩解策略 |
|------|------|------|----------|
| Spotify API OAuth 複雜度 | 延遲開發 | 中 | 優先實作 Books/TMDB，Spotify 可後置 |
| Firebase 免費額度不足 | 需付費或限制功能 | 低 | 監控用量，優化讀寫操作 |
| 外部 API 封面 URL 失效 | 顯示異常 | 低 | 使用 cached_network_image，顯示 placeholder |
| App Store 審核被拒 | 延遲發布 | 中 | 提前準備隱私政策，測試完整功能 |

## Migration Plan

不適用（全新專案）

## Open Questions

1. **Spotify vs Apple Music**: 是否同時支援兩者？還是只選其一？
   - 建議：優先 Spotify（API 較友善），Apple Music 列為 Phase 4

2. **影集 (TV) 的資料模型**: 需要支援單集紀錄嗎？還是只記錄整季？
   - 建議：Phase 1 只支援整部作品，單集支援列為未來功能

3. **評分是否必填**: 使用者可以不評分嗎？
   - 建議：評分選填，允許 null
