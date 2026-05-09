# 更新日誌 (Changelog)

## [v1.1.0] - 2026-05-09

### Added
- V技能偵測功能 (通用模式)
- 按鍵設置參考圖片 (Button settings.png)
- FindText轉換：BBQ紅/藍判定、庚辰Q/Q1、魂羽F1/E/F2技能

### Changed
- 刪除17個過時PNG文件，清理10個過時全域變數
- 更新CoordinateAdjustmentApp辨識項目為FindText模式
- 完成大部分角色的FindText轉換工作

### Fixed
- 修復V技能坐標範圍問題

---

## [v1.0.9] - 2026-05-09

### 🎯 巧构角色完成轉換
- ✅ **巧构Q**：從 ImageSearch 轉換為 FindText
- ✅ **巧构F**：從 ImageSearch 轉換為 FindText
- ✅ **巧构Q1**：從 ImageSearch 轉換為 FindText
- ✅ **巧构E1**：從 ImageSearch 轉換為 FindText
- ✅ **能量檢測**：從 PixelSearch 轉換為 FindText

### 🔧 巧构技能邏輯修正
- **修復F技能後無法釋放Q/E的問題**
  - 移除F技能執行後的return true
  - 讓F技能執行後繼續執行強化技能檢測邏輯
  - 形成正確的 F → Q1 → F → E1 循環

### 📝 版本更新
- sid-ag.ahk: v1.0.8 → v1.0.9
- 更新 README.md：巧构角色轉換狀態

---

## [v1.0.8] - 2026-05-08

### ✨ 新增功能 (Features)
- **FindText 圖像辨識整合**：大幅提升技能辨識準確性
  - 引入 FindText.ahk 函式庫，取代傳統 ImageSearch
  - 實現視窗座標到螢幕座標的自動轉換機制
  - 建立標準化的 FindText 工作流程文檔

### 🎯 緋染角色完成轉換
- ✅ **緋染Q**：從 ImageSearch 轉換為 FindText
- ✅ **緋染Q1**：從 ImageSearch 轉換為 FindText  
- ✅ **緋染E**：從 ImageSearch 轉換為 FindText
- ✅ **緋染E1**：從 ImageSearch 轉換為 FindText
- ✅ **緋染F**：從 ImageSearch 轉換為 FindText
- ✅ **緋染F End**：從 ImageSearch 轉換為 FindText

### 📚 文檔系統完善
- **新增 `docs/FINDTEXT_GUIDE.md`**：FindText 整合完整指南
  - 詳細的座標轉換機制說明
  - Agent 修改標準流程
  - 完整的實際案例參考
- **更新 `docs/AHK_MODULES.md`**：新增座標轉換功能說明
- **更新 `README.md`**：FindText 功能特色和進度說明

### 🔄 技術改進
- **座標轉換函數**：`WindowToScreen()` 和 `ScreenToWindow()`
- **向後相容**：保留所有原始 ImageSearch 變數
- **錯誤處理**：完善的 try-catch 結構
- **測試支援**：各技能獨立測試檔案

### ⚡ 啟動速度優化
- **啟動時間壓縮**：從13.25秒優化至4.8秒（節省64%時間）
  - 初始延時：1500ms → 300ms
  - 環境檢查進度：1000ms → 300ms間隔
  - 淡入動畫：250ms → 100ms
  - 步驟切換：1000ms → 300ms
  - F2提醒倒數：3秒 → 1.5秒
- **保持完整體驗**：所有過場動畫效果保留，僅加快節奏

### 📝 版本更新
- sid-ag.ahk: v1.0.7 → v1.0.8
- 新增 lib/FindText.ahk 核心函式庫
- 新增 docs/FINDTEXT_GUIDE.md 整合指南

---

## [v1.0.7] - 2026-01-22

### 🔧 修復 (Fixes)
- **座標系統修復**：恢復v1.0.5中的正確座標體系
  - 移除v1.0.6中破壞的 `GetCoordBounds()` 坐標讀取機制
  - 所有角色技能釋放座標已恢復為v1.0.5驗證的正確值
  - 修復了導致所有角色技能無法正常釋放的座標錯誤問題

- **UID遮擋層改進**：精確化視窗相對定位
  - 使用精確的窗口相對座標 (1275,864) 至 (1421,887)
  - UID遮擋層現可動態跟隨遊戲窗口移動
  - 遮擋層尺寸：146×23 像素

- **GUI動態跟隨**：狀態顯示窗口與大字報
  - 狀態顯示窗口動態跟隨窗口左上角 (gameX+10, gameY+10)
  - 中央大字報動態跟隨窗口正中央上方
  - 確保無論窗口位置在哪，GUI都能正確顯示

### ✨ 功能保留 (Features Retained)
- ✅ 快速角色切換 (Ctrl+Left/Right)
- ✅ 所有6個角色技能偵測模式
- ✅ 烤肉模式 (F6)
- ✅ 輸入監測調試模式 (F8)
- ✅ 中央狀態大字報顯示

### 🎯 驗證座標 (Verified Coordinates)
| 角色 | 座標範圍 | 用途 |
|------|--------|------|
| 魂羽 | 1045,684 ~ 1565,880 | F/E技能判定區 |
| 緋染 | 1162,764 ~ 1468,885 | Q/E技能判定區 |
| 巧構 | 1156,748 ~ 1558,883 | Q/E技能判定區 |
| 庚辰 | 1219,768 ~ 1462,881 | Q技能判定區 |
| 通用模式 | 各技能槽位 | 顏色型判定 |

### 📝 版本更新
- sid-ag.ahk: v1.0.5 → v1.0.7
- Config.ini: v1.0.6 → v1.0.7
- README.md: v1.0.6 → v1.0.7

---

## [v1.0.6] - 2025-XX-XX
- 新增快速角色切換功能 (Ctrl+Left/Right)
- 嘗試使用JSON座標配置（存在缺陷）
- 新增輸入監測調試模式

## [v1.0.5] - 2025-09-07
- 初始穩定版本
- 所有角色正確座標體系
- 核心自動戰鬥功能
