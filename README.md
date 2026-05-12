# 深空之眼 Sid 半自動腳本

[![Release](https://img.shields.io/github/release/Sid-1996/AetherGazer-SemiAuto-AHK.svg)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/Sid-1996/AetherGazer-SemiAuto-AHK/total.svg)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/releases)
[![License](https://img.shields.io/github/license/Sid-1996/AetherGazer-SemiAuto-AHK.svg)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/blob/main/LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/Sid-1996/AetherGazer-SemiAuto-AHK.svg)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/commits/main)
[![Issues](https://img.shields.io/github/issues/Sid-1996/AetherGazer-SemiAuto-AHK.svg)](https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/issues)

AutoHotkey v2 專案，用於《深空之眼》的半自動戰鬥、角色技能判定、視窗調整與座標校正。

## 目前結構

- `sid-ag.ahk`
  - 主程式入口 launcher
- `CoordinateAdjustmentTool.ahk`
  - 座標校正工具入口 launcher
- `src/`
  - 程式主體與共用路徑定義
- `config/`
  - `Config.ini`、`GameConfig.ini`、`coordinates_config.json`
- `assets/`
  - 共用判定圖片與角色技能素材
- `docs/`
  - 模組說明與工具文件
- `releases/`
  - 編譯後的 exe 與封裝檔

## 啟動方式

### 方式 1：直接執行 launcher

- `sid-ag.ahk`
- `CoordinateAdjustmentTool.ahk`

### 方式 2：使用固定 AutoHotkey 路徑的啟動批次檔

如果系統 PATH 常常抓不到 AutoHotkey，直接用這兩個：

- `run-sid-ag.cmd`
- `run-coordinate-tool.cmd`

它們會優先使用：

- `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
- 找不到時退回 `C:\Program Files\AutoHotkey\v2\AutoHotkey.exe`

## 已確認的 AutoHotkey 安裝位置

你的機器上有：

- `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
- `C:\Program Files\AutoHotkey\v2\AutoHotkey.exe`

先前「找不到 AutoHotkey」的原因，不是沒安裝，而是 `PATH` 沒有穩定指到這個位置。

### 🎮 使用方式

1. **啟動腳本**：
   - 雙擊 `run-sid-ag.cmd`（推薦）
   - 或直接執行 `sid-ag.ahk`

2. **⚠️ 系統要求（重要）**：
   - **桌面螢幕解析度**：必須為 1920×1080
   - **遊戲視窗模式解析度**：必須為 1600×900
   - **Windows DPI 縮放**：必須為 100%
   - **遊戲視窗標題**：必須為 " AetherGazer"

3. **⚠️ 重要：開啟鍵位提示**
   - **必須從遊戲設定中開啟「鍵位提示」功能**
   - 腳本以鍵位提示中的 **ESC 按鈕** 作為戰鬥狀態判斷依據
   - 如果未開啟鍵位提示，戰鬥偵測將無法正常工作

4. **操作說明**：
   - F1：自動攻擊開關
   - F2：視窗調整
   - F3：顯示說明
   - F4：暫停腳本
   - F5：角色選擇
   - F6：BBQ 模式
   - F7：檢查更新
   - F11：重新載入
   - F12：退出

  # 📹 Demo Showcase / 示範影片

Dailymotion:

[https://www.dailymotion.com/video/xa9cau2](https://www.dailymotion.com/video/xa9cyg0)

---

### 🖼️ 鍵位提示設定參考

![鍵位提示設定](https://raw.githubusercontent.com/Sid-1996/AetherGazer-SemiAuto-AHK/main/assets/common/AetherGazer%20UI%20set.png)

**設定路徑**：遊戲內 → 設定 → 界面 → 鍵位提示

### 🎮 按鍵設置參考

![按鍵設置](https://raw.githubusercontent.com/Sid-1996/AetherGazer-SemiAuto-AHK/main/assets/common/Button%20settings.png)

**說明**：此圖顯示遊戲中的按鍵設置，例如滑鼠右鍵是閃避。請確保您的遊戲設置與此圖一致，以獲得最佳的自動化體驗。

## 主要功能

- 自動普攻與戰鬥循環
- 角色技能圖片判定
- 烤肉模式判定
- 遊戲視窗調整
- 啟動畫面與狀態顯示
- GitHub 版本更新檢查
- 座標調整工具與座標保存

## 常用熱鍵

- `F1`：切換自動攻擊
- `F2`：調整遊戲視窗為 1600x900
- `F3`：開關說明畫面
- `F4`：暫停 / 恢復
- `F5`：角色選擇
- `F6`：烤肉模式
- `F7`：手動檢查更新
- `F11`：重載腳本
- `F12`：結束腳本

## 角色與素材

- 共用素材：`assets/common/`
- 角色素材：`assets/characters/魂羽/`、`assets/characters/緋染/`、`assets/characters/巧构/`、`assets/characters/庚辰/`

## 設定檔

- `config/Config.ini`
  - 主腳本設定
- `config/GameConfig.ini`
  - 遊戲視窗與進程設定
- `config/coordinates_config.json`
  - 座標校正工具輸出的區域資料

## 文件

- `docs/PROJECT_OVERVIEW.md`
- `docs/AHK_MODULES.md`
- `docs/CoordinateAdjustmentTool_README.md`
- `docs/FINDTEXT_GUIDE.md` - **FindText 整合指南（重要）**

## FindText 圖像辨識

本專案已整合 FindText 函式庫以提供更強大的圖像辨識能力：

### 特點
- 比傳統 ImageSearch 更可靠的辨識效果
- 支援容錯率和多種搜尋模式
- 文字化匹配，減少檔案依賴

### 座標系統
- **重要**：本專案使用特殊的座標轉換機制
- 所有 FindText 使用都必須遵循 `docs/FINDTEXT_GUIDE.md` 中的標準流程
- 已實現視窗座標到螢幕座標的自動轉換

### 已實現案例
- ✅ **緋染角色**：全部技能已轉換為 FindText
  - 緋染Q、緋染Q1、緋染E、緋染E1、緋染F、緋染F End
- ✅ **巧构角色**：全部技能已轉換為 FindText
  - 巧构Q、巧构F、巧构Q1、巧构E1、能量檢測
- ✅ **魂羽角色**：全部技能已轉換為 FindText
  - 魂羽F1、魂羽E、魂羽F2
- ✅ **庚辰角色**：全部技能已轉換為 FindText
  - 庚辰Q、庚辰Q1
- ✅ **BBQ模式**：紅/藍判定已轉換為 FindText

## 目前版本管理狀態

**當前版本：v1.1.1 (2026-05-10)**

已建立 git 倉庫並完成結構整理。

最近的整理重點：

- 建立 `main` 分支基線
- 關閉這個專案資料夾的 Google Drive 同步
- 整理成 `src / config / assets / docs / releases` 結構
- 加入固定 AutoHotkey 路徑的啟動批次檔
- **新增 FindText 圖像辨識整合 (緋染角色完成)**
- **v1.1.1 更新內容**：
  - 修複版本設置不一致問題 (v1.0.9 殘留在配置和預設值)
  - 完成 FindText 轉換：BBQ紅/藍判定、庚辰Q/Q1、魂羽F1/E/F2技能
  - 刪除17個過時PNG文件，清理10個過時全域變數
  - 更新CoordinateAdjustmentApp辨識項目為FindText模式
  - 新增V技能偵測功能
  - 新增按鍵設置參考圖片
