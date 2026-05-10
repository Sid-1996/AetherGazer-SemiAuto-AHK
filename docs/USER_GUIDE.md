# AetherGazer AHK 使用者指南

## 🎯 版本說明

### 📦 使用者版本（推薦）
**位置**：`releases/AetherGazer-AHK-v1.1.1/`

**特色**：
- ✅ 開箱即用，無需開發環境
- ✅ 包含所有必要檔案
- ✅ 路徑已修復，支援獨立執行
- ✅ 完整 FindText 整合功能

**適合**：一般使用者、遊戲玩家

### 🛠️ 開發者版本
**位置**：專案根目錄

**特色**：
- 🔧 完整原始碼
- 📚 開發文檔
- 🔍 調試工具
- 📝 版本控制支援

**適合**：開發者、進階使用者、想修改功能的使用者

---

## 🚀 使用者版本快速開始

### 方法 1：使用啟動腳本（推薦）
1. 解壓縮 `AetherGazer-AHK-v1.1.1.zip`
2. 雙擊 `run-sid-ag.cmd`
3. 腳本會自動偵測 AutoHotkey 並啟動

### 方法 2：直接執行
1. 確保已安裝 AutoHotkey v2
2. 雙擊 `sid-ag.ahk`

### ⚠️ 系統要求（必須滿足）

**硬體與系統設定**：
- **桌面螢幕解析度**：必須為 1920×1080
- **遊戲視窗模式解析度**：必須為 1600×900  
- **Windows DPI 縮放**：必須為 100%
- **遊戲視窗標題**：必須為 " AetherGazer"

**⚠️ 重要：遊戲內設定要求**

**必須開啟鍵位提示功能**：
- 腳本以鍵位提示中的 **ESC 按鈕** 作為戰鬥狀態判斷依據
- 如果未開啟鍵位提示，戰鬥偵測將無法正常工作

**設定路徑**：
```
遊戲內 → 設定 → 界面 → 鍵位提示 ✅
```

**設定參考圖**：
![鍵位提示設定](../assets/common/AetherGazer%20UI%20set.png)

---

## 📁 使用者版本檔案結構

```
AetherGazer-AHK-v1.1.1/
├── sid-ag.ahk              # 主程式（已修復路徑）
├── ProjectPaths.ahk         # 路徑管理模組
├── SidAgApp.ahk           # 主應用程式
├── run-sid-ag.cmd          # 啟動腳本
├── LICENSE                 # 授權檔案
├── config/               # 配置檔案
│   ├── Config.ini
│   ├── GameConfig.ini
│   └── coordinates_config.json
├── assets/               # 資源檔案
│   ├── common/          # 共用判定圖片
│   └── characters/      # 角色技能圖片
└── lib/                 # 函式庫
    └── FindText.ahk     # FindText 圖像辨識
```

---

## ⚙️ 配置說明

### 基本配置
- **`config\Config.ini`**：主配置檔案
  - 遊戲視窗標題
  - 顏色變化量
  - 技能冷卻時間

- **`config\GameConfig.ini`**：遊戲特定配置
  - 視窗尺寸設定
  - 角色特定參數

- **`config\coordinates_config.json`**：座標配置
  - 各角色技能偵測座標
  - 可自訂調整

---

## ✨ v1.0.8 新功能

### FindText 圖像辨識整合
- **緋染角色完成**：全部 6 個技能已轉換為 FindText
  - 緋染Q、緋染Q1、緋染E、緋染E1、緋染F、緋染F End
- **更準確的辨識**：比傳統 ImageSearch 更可靠

### 技術改進
- **座標轉換**：自動處理視窗/螢幕座標
- **向後相容**：保留所有原始 ImageSearch 變數
- **錯誤處理**：完善的 try-catch 結構
- **路徑修正**：支援 EXE 獨立執行

---

## 🎮 支援角色

| 角色 | 狀態 | 辨識方式 | 備註 |
|------|--------|----------|--------|
| 緋染 | ✅ 完成 | FindText | 6 個技能全部轉換 |
| 魂羽 | 🔄 開發中 | ImageSearch | 計劃轉換 |
| 巧构 | 🔄 開發中 | ImageSearch | 計劃轉換 |
| 庚辰 | 🔄 開發中 | ImageSearch | 計劃轉換 |

---

## 🔧 故障排除

### 常見問題

**Q1：執行時提示找不到檔案**
```
Error: #Include file "ProjectPaths.ahk" cannot be opened
```
**解決**：確保所有檔案都在同一目錄，不要移動任何檔案

**Q2：FindText 功能無效**
**解決**：
1. 確認 `lib\FindText.ahk` 存在
2. 檢查角色是否為「緋染」
3. 確認遊戲視窗標題正確

**Q3：AutoHotkey 路徑錯誤**
**解決**：
1. 使用 `run-sid-ag.cmd` 自動偵測
2. 或手動安裝 AutoHotkey v2

---

## 📞 支援

- **GitHub**：Sid-1996/AetherGazer-SemiAuto-AHK
- **文檔**：參考 `docs/FINDTEXT_GUIDE.md`
- **更新**：檢查 `releases/` 目錄最新版本

---

**版本**：v1.1.1  
**更新日期**：2026-05-09  
**製作**：Sid  
**特色**：巧构角色FindText轉換完成
