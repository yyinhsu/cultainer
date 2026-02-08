# Change: Phase 4 - 平台擴展與發布準備

## Why

Cultainer 設計為跨平台應用程式。Phase 4 專注於：
- macOS 平台優化（視窗大小、鍵盤快捷鍵）
- Web 平台優化（響應式設計、PWA）
- App Store / Play Store 發布準備
- 效能優化與最終測試

## What Changes

### 新增功能
- macOS 專屬 UI 調整
- Web 響應式佈局
- PWA 支援（Web 版）
- App Store 發布設定
- Play Store 發布設定
- 完整隱私政策
- 使用條款

### 平台特定優化
| 平台 | 優化項目 |
|------|----------|
| macOS | 視窗大小調整、側邊欄導航、鍵盤快捷鍵 |
| Web | 響應式斷點、PWA manifest、Service Worker |
| iOS | App Store 審核資料、截圖準備 |

## Impact

- **Affected specs**: 
  - `specs/platform-macos/spec.md` (新增)
  - `specs/platform-web/spec.md` (新增)
  - `specs/release/spec.md` (新增)

- **Affected code**: 
  - 平台特定 UI 調整
  - Build 設定檔
  - 發布自動化腳本

## Dependencies

- Phase 1, 2, 3 完成
- Apple Developer Program 會員資格
- Google Play Console 帳號

## Success Criteria

- [ ] macOS App 可正常執行且 UI 適配
- [ ] Web 版在桌面和行動瀏覽器正常顯示
- [ ] iOS App 通過 App Store 審核
- [ ] Android App 通過 Play Store 審核
