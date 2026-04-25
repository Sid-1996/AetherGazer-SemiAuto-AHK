# 專案架構總覽

## 專案用途

這是一個以 AutoHotkey v2 撰寫的《深空之眼》半自動腳本專案。
核心能力包含：

- 自動普攻與技能循環
- 角色切換與角色專屬技能判定
- 遊戲視窗尺寸調整與進程監控
- 啟動畫面、提示 GUI 與狀態覆蓋
- GitHub 版本更新檢查
- 座標校正工具，用來調整圖片辨識與像素判定區域

## 目前的主要檔案

- `sid-ag.ahk`
  - 主程式入口。
  - 載入所有模組，初始化設定、註冊熱鍵、啟動戰鬥迴圈與更新檢查。

- `src/modules/ConfigManager.ahk`
  - 統一管理 `Config.ini`。
  - 提供預設值、讀寫設定與儲存功能。

- `src/modules/GameWindowManager.ahk`
  - 管理遊戲視窗尺寸、位置與遊戲進程狀態。
  - 目前也負責 F2 視窗調整。

- `src/modules/UISequenceManager.ahk`
  - 管理啟動流程 GUI、環境檢查畫面與提示流程。

- `src/modules/UpdateChecker.ahk`
  - 透過 GitHub Releases API 檢查新版本。

- `CoordinateAdjustmentTool.ahk`
  - 校正圖片辨識區域與像素檢查範圍。
  - 使用 `coordinates_config.json` 保存座標。

## 設定與資料

- `config/Config.ini`
  - 主腳本設定，包含版本、熱鍵、UI 與遊戲參數。

- `config/GameConfig.ini`
  - 遊戲視窗與進程監控設定。

- `config/coordinates_config.json`
  - 座標校正工具輸出的座標資料。

## 素材結構

- `assets/common/`
  - 共用判定素材，例如戰鬥判定、烤肉模式相關圖片。

- `assets/characters/魂羽/`、`assets/characters/緋染/`、`assets/characters/巧构/`、`assets/characters/庚辰/`
  - 各角色技能辨識素材。
  - 主腳本以相對路徑直接讀取這些圖片。

## 目前的整理判斷

現在不適合直接搬動原始碼與素材目錄，原因是：

- 主腳本與工具大量使用 `A_ScriptDir` 加相對路徑。
- 角色素材目錄名稱已被硬編碼在主程式內。
- `CoordinateAdjustmentTool.ahk` 同樣依賴目前的資料夾配置。

因此建議分兩階段整理：

1. 先整理版本管理與文件
   - 建立 git 倉庫
   - 補 `.gitignore`
   - 補專案結構文件

2. 再做程式內部重構後，才搬動目錄
   - 先把素材路徑集中為設定或常數表
   - 再把文件、發行產物、工具分區
   - 最後更新 README 與建置流程

## 建議後續目錄方向

在不破壞現況前提下，後續可以往這個方向收斂：

- `/docs`
  - 模組說明、工具說明、維護文件

- `/releases`
  - 編譯後的 `exe` 與打包檔

- `/assets`
  - 角色與共用辨識素材

- `/src`
  - 主腳本與模組

但要做到這一步，必須先把程式中的素材路徑與 include 路徑抽象化。
