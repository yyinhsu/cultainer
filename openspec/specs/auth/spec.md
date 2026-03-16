## ADDED Requirements

### Requirement: Google Sign-In Authentication
使用者 SHALL 能夠使用 Google 帳號進行身份驗證登入應用程式。

#### Scenario: 首次登入成功
- **WHEN** 使用者點擊「使用 Google 登入」按鈕
- **AND** 使用者在 Google 授權頁面授權應用程式
- **THEN** 系統建立使用者 profile 於 Firestore
- **AND** 導航至 Home 頁面

#### Scenario: 已登入使用者重啟 App
- **WHEN** 已登入的使用者開啟應用程式
- **THEN** 系統自動恢復登入狀態
- **AND** 直接顯示 Home 頁面

#### Scenario: 登出
- **WHEN** 使用者在 Profile 頁面點擊「登出」按鈕
- **THEN** 系統清除本地認證狀態
- **AND** 導航至登入頁面

### Requirement: Authentication State Guard
未登入的使用者 SHALL 被導向至登入頁面，無法存取應用程式主要功能。

#### Scenario: 未登入使用者嘗試存取主頁
- **WHEN** 未登入的使用者嘗試存取 Home 頁面
- **THEN** 系統自動重導向至登入頁面

#### Scenario: 登入狀態過期
- **WHEN** 使用者的認證 token 過期
- **THEN** 系統嘗試自動刷新 token
- **AND** 若刷新失敗，導向登入頁面
