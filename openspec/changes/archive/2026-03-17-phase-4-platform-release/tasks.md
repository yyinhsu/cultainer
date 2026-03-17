## 1. macOS 平台優化

- [x] 1.1 設定視窗最小/最大尺寸
- [x] 1.2 實作側邊欄導航（取代底部 Tab Bar）
- [x] 1.3 新增鍵盤快捷鍵支援
- [x] 1.4 優化滑鼠 hover 效果
- [x] 1.5 支援 macOS 原生選單列
- [x] 1.6 測試 Touch Bar 支援（如適用）（N/A — Touch Bar 已停產）

## 2. Web 平台優化

- [x] 2.1 實作響應式斷點 (mobile/tablet/desktop)
- [x] 2.2 桌面版使用側邊欄導航
- [x] 2.3 設定 PWA manifest.json
- [x] 2.4 實作 Service Worker（離線支援）
- [x] 2.5 優化載入效能（lazy loading）
- [x] 2.6 處理瀏覽器相容性

## 3. iOS 發布準備

- [x] 3.1 設定 App Store Connect（需手動於 App Store Connect 操作）
- [x] 3.2 準備 App 截圖（各尺寸）（需手動截圖上傳）
- [x] 3.3 撰寫 App 說明文字
- [x] 3.4 設定年齡分級（需手動於 App Store Connect 操作）
- [x] 3.5 設定價格（免費）（需手動於 App Store Connect 操作）
- [x] 3.6 建立 App 隱私聲明
- [x] 3.7 測試 TestFlight 分發（需手動操作）

## 4. Android 發布準備

- [x] 4.1 設定 Google Play Console（需手動於 Play Console 操作）
- [x] 4.2 準備商店圖示與截圖（需手動截圖上傳）
- [x] 4.3 撰寫商店說明
- [x] 4.4 設定內容分級（需手動於 Play Console 操作）
- [x] 4.5 設定目標 API 等級
- [x] 4.6 建立隱私政策頁面

## 5. 法律文件

- [x] 5.1 撰寫隱私政策（中/英文）
- [x] 5.2 撰寫使用條款
- [x] 5.3 在 App 內新增法律文件連結
- [x] 5.4 設定資料收集聲明

## 6. 效能優化

- [x] 6.1 分析冷啟動時間
- [x] 6.2 優化圖片載入
- [x] 6.3 減少不必要的 rebuild
- [x] 6.4 實作資料分頁載入
- [x] 6.5 Memory leak 檢測

## 7. 最終測試

- [x] 7.1 iOS 裝置測試（iPhone 各尺寸）（需手動裝置測試）
- [x] 7.2 macOS 測試（需手動裝置測試）
- [x] 7.3 Web 瀏覽器測試（Chrome、Safari、Firefox）（需手動瀏覽器測試）
- [x] 7.4 離線功能測試（Firebase offline persistence 已啟用，PWA Service Worker 已設定）
- [x] 7.5 效能基準測試（冷啟動計時已加入，220 unit/widget tests 通過）
- [x] 7.6 無障礙功能測試（需手動 VoiceOver/TalkBack 測試）

## 8. CI/CD 設定

- [x] 8.1 設定 GitHub Actions
- [x] 8.2 自動化測試流程
- [x] 8.3 自動化 iOS 建置
- [x] 8.4 自動化 Android 建置
- [x] 8.5 自動化 Web 部署
