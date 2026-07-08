# AetherGazer AHK 使用者指南

## 取得套件

從 GitHub Releases 下載最新版的 `AetherGazer-AHK-vX.Y.Z.7z`:

<https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/releases/latest>

解壓縮後即可使用。

## 啟動方式

### 方法 1：啟動腳本（推薦）
1. 雙擊 `run-sid-ag.cmd`
2. 腳本會自動偵測 AutoHotkey 並啟動

### 方法 2：直接執行
1. 確保已安裝 AutoHotkey v2
2. 雙擊 `sid-ag.ahk`

### 方法 3：編譯版 EXE
1. 雙擊 `sid-ag.exe`
2. 無需安裝 AutoHotkey

## 系統要求

- **桌面螢幕解析度**：1920×1080
- **遊戲視窗解析度**：1600×900
- **Windows DPI 縮放**：100%
- **遊戲視窗標題**：" AetherGazer"
- **遊戲內必須開啟鍵位提示**（設定 → 界面 → 鍵位提示）

## 套件檔案結構

```
AetherGazer-AHK-vX.Y.Z/
├── sid-ag.exe              # 編譯版主程式
├── sid-ag.ahk              # 主程式入口
├── run-sid-ag.cmd          # 啟動腳本
├── src/
│   ├── ProjectPaths.ahk    # 路徑管理模組
│   ├── apps/
│   │   └── SidAgApp.ahk   # 主應用程式
│   └── modules/
│       ├── ConfigManager.ahk    # 設定管理
│       ├── GameWindowManager.ahk # 視窗/進程管理
│       ├── UISequenceManager.ahk # 啟動 UI 流程
│       └── UpdateChecker.ahk    # 版本更新檢查
├── lib/
│   └── FindText.ahk       # FindText 圖像辨識函式庫
├── config/
│   ├── Config.ini         # 主設定檔
│   └── GameConfig.ini     # 遊戲視窗設定
├── assets/
│   ├── common/            # 共用資源
│   └── characters/        # 角色素材
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## 配置說明

- **`config/Config.ini`**：主配置檔（腳本版本、按鍵設定、UI 選項）
- **`config/GameConfig.ini`**：遊戲視窗與進程設定

## 支援角色

| 角色 | 辨識方式 | 使用技能 |
|------|----------|----------|
| 緋染 | FindText | Q / Q1 / E / E1 / F / F End |
| 魂羽 | FindText | F1 / E / F2 |
| 巧构 | FindText | Q / F / Q1 / E1 / 能量檢測 |
| 庚辰 | FindText + PixelSearch | Q / Q1 / 怒氣判定 |
| 武羅 | FindText | Q1 / Q2 / E1 / E2 / F |
| 詩蔻蒂 | FindText | E1 / F1 / F2 / F3 / F4 / 自動 Q |

## 常見問題

**執行時提示 #Include 找不到檔案**
確認是從套件的根目錄啟動（`sid-ag.ahk` 或 `run-sid-ag.cmd`），不要移動或單獨取出檔案。

**FindText 無法命中**
1. 確認 `lib/FindText.ahk` 存在
2. 確認遊戲視窗標題與解析度符合系統要求
3. 確認有開啟鍵位提示

**AutoHotkey 路徑錯誤**
使用 `run-sid-ag.cmd` 自動偵測，或手動安裝 AutoHotkey v2。

## 支援

- GitHub 專案：<https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK>
- 回報問題：<https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK/issues>
- 技術文件：`docs/NEW_INTELLIGENT_DOCS.md`
- 更新日誌：`CHANGELOG.md`
