## ADDED Requirements

### Requirement: Google Books Search
系統 SHALL 能夠透過 Google Books API 搜尋書籍資訊。

#### Scenario: 搜尋書籍
- **WHEN** 使用者在新增 Entry（類型：book）時輸入搜尋關鍵字
- **THEN** 系統呼叫 Google Books API
- **AND** 顯示搜尋結果列表（標題、作者、封面）

#### Scenario: 選擇書籍
- **WHEN** 使用者選擇搜尋結果中的一本書
- **THEN** 系統擷取以下資訊：
  - title: 書名
  - creator: 作者名稱
  - coverUrl: 封面圖片 URL
  - externalId: Google Books volume ID
  - metadata.pageCount: 頁數
  - metadata.publishedDate: 出版日期
  - metadata.isbn: ISBN

### Requirement: TMDB Search
系統 SHALL 能夠透過 TMDB API 搜尋電影和影集資訊。

#### Scenario: 搜尋電影
- **WHEN** 使用者在新增 Entry（類型：movie）時輸入搜尋關鍵字
- **THEN** 系統呼叫 TMDB Search Movies API
- **AND** 顯示搜尋結果列表（標題、導演、海報、年份）

#### Scenario: 選擇電影
- **WHEN** 使用者選擇搜尋結果中的一部電影
- **THEN** 系統擷取以下資訊：
  - title: 電影名稱
  - creator: 導演名稱
  - creatorId: TMDB person ID（導演）
  - coverUrl: 海報圖片 URL
  - externalId: TMDB movie ID
  - metadata.runtime: 片長（分鐘）
  - metadata.releaseDate: 上映日期
  - metadata.genres: 類型

#### Scenario: 搜尋影集
- **WHEN** 使用者在新增 Entry（類型：tv）時輸入搜尋關鍵字
- **THEN** 系統呼叫 TMDB Search TV API
- **AND** 顯示搜尋結果列表

#### Scenario: 選擇影集
- **WHEN** 使用者選擇搜尋結果中的一部影集
- **THEN** 系統擷取以下資訊：
  - title: 影集名稱
  - creator: 創作者名稱
  - creatorId: TMDB person ID
  - coverUrl: 海報圖片 URL
  - externalId: TMDB tv ID
  - metadata.seasons: 季數
  - metadata.episodes: 集數
  - metadata.firstAirDate: 首播日期

### Requirement: Spotify Search
系統 SHALL 能夠透過 Spotify Web API 搜尋音樂專輯資訊。

#### Scenario: 搜尋專輯
- **WHEN** 使用者在新增 Entry（類型：music）時輸入搜尋關鍵字
- **THEN** 系統呼叫 Spotify Search API（type=album）
- **AND** 顯示搜尋結果列表（專輯名稱、藝人、封面）

#### Scenario: 選擇專輯
- **WHEN** 使用者選擇搜尋結果中的一張專輯
- **THEN** 系統擷取以下資訊：
  - title: 專輯名稱
  - creator: 藝人名稱
  - creatorId: Spotify artist ID
  - coverUrl: 專輯封面 URL
  - externalId: Spotify album ID
  - metadata.trackCount: 曲目數
  - metadata.releaseDate: 發行日期

### Requirement: Creator ID Storage
系統 SHALL 儲存創作者的外部 API ID，用於後續推薦功能。

#### Scenario: 儲存導演 ID
- **WHEN** 使用者選擇一部 TMDB 電影
- **THEN** 系統額外呼叫 TMDB Movie Credits API
- **AND** 擷取導演的 person ID 存入 creatorId

#### Scenario: 儲存藝人 ID
- **WHEN** 使用者選擇一張 Spotify 專輯
- **THEN** 系統擷取主要藝人的 artist ID 存入 creatorId

### Requirement: Cover URL Fallback
當外部 API 封面 URL 無法載入時，系統 SHALL 顯示預設 placeholder 圖片。

#### Scenario: 封面載入失敗
- **WHEN** coverUrl 回傳 404 或載入超時
- **THEN** 系統顯示對應類型的 placeholder 圖示
- **AND** 不影響 Entry 的其他功能
