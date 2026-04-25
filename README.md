# 深空之眼 Sid 半自動腳本

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

## 目前版本管理狀態

已建立 git 倉庫並完成結構整理。

最近的整理重點：

- 建立 `main` 分支基線
- 關閉這個專案資料夾的 Google Drive 同步
- 整理成 `src / config / assets / docs / releases` 結構
- 加入固定 AutoHotkey 路徑的啟動批次檔
