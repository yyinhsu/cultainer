# Change: Phase 3 - 探索與推薦系統

## Why

Cultainer 的「探索」功能幫助使用者發現新的閱聽內容。基於使用者已記錄的作品，推薦相關創作者的其他作品，形成有機的探索路徑。

例如：
- 使用者記錄了導演 A 的電影 → 推薦導演 A 的其他電影
- 使用者記錄了作者 B 的書 → 推薦作者 B 的其他著作

## What Changes

### 新增功能
- 推薦演算法（本地端處理）
- Explore 頁面完整實作
- 創作者其他作品查詢
- 推薦結果快取（離線支援）
- Calendar 頁面實作

### 涉及畫面
- Explore Page（完整實作）
- Calendar Page（完整實作）

## Impact

- **Affected specs**: 
  - `specs/explore/spec.md` (新增)
  - `specs/calendar/spec.md` (新增)

- **Affected code**: 
  - `lib/features/explore/`
  - `lib/features/calendar/`
  - `lib/services/recommendation_service.dart`

## Dependencies

- Phase 1 完成（Entry CRUD、外部 API 整合）
- TMDB API（導演其他作品）
- Google Books API（作者其他著作）
- Spotify API（藝人其他專輯）

## Success Criteria

- [ ] Explore 頁面顯示推薦內容
- [ ] 推薦基於最近紀錄的創作者
- [ ] 可快速將推薦項目加入 wishlist
- [ ] Calendar 頁面顯示月曆與當日紀錄
- [ ] 離線時可瀏覽已快取的推薦
