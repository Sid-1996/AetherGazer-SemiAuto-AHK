;===========================================================
; 通用遊戲窗口管理器 - GameWindowManager.ahk (完整安全版)
; 支持INI配置文件的遊戲窗口調整和進程監控
;===========================================================
#Requires AutoHotkey v2.0

;=== 全局變量 ===
global GameConfig := Map()
global GameWasRunning := false
global ConfigFile := ConfigPath("GameConfig.ini")
global OnGameExitCallback := ""
global OnGameStartCallback := ""

;=== 初始化函數 ===
InitializeGameManager(configFilePath := "") {
    global ConfigFile
    if (configFilePath != "")
        ConfigFile := configFilePath
    
    LoadGameConfig()
    SetTimer(CheckGameProcess, 3000)
    
    ; 註冊 F2 熱鍵，使用 ~ 保留原系統功能
    Hotkey("~F2", ConditionalF2Handler)
}

;=== 條件式F2處理器（安全版） ===
ConditionalF2Handler(*) {
    global GameConfig
    
    windowTitle := GameConfig["WindowTitle"]
    
    if (WinExist(windowTitle) && WinActive(windowTitle)) {
        ; 遊戲視窗活躍 → 執行遊戲視窗調整
        AdjustGameWindow()
    }
    ; 遊戲視窗不活躍 → 不做任何事，F2 原系統功能自動生效
}

;=== 載入遊戲配置 ===
LoadGameConfig() {
    global GameConfig, ConfigFile
    
    if (!FileExist(ConfigFile)) {
        CreateDefaultConfig()
    }
    
    GameConfig["ProcessName"] := IniRead(ConfigFile, "Game", "ProcessName", "AetherGazer.exe")
    GameConfig["WindowTitle"] := IniRead(ConfigFile, "Game", "WindowTitle", "AetherGazer")
    GameConfig["TargetWidth"] := Integer(IniRead(ConfigFile, "Window", "TargetWidth", "1600"))
    GameConfig["TargetHeight"] := Integer(IniRead(ConfigFile, "Window", "TargetHeight", "900"))
    GameConfig["CenterWindow"] := IniRead(ConfigFile, "Window", "CenterWindow", "true")
    GameConfig["AutoExitDelay"] := Integer(IniRead(ConfigFile, "Process", "AutoExitDelay", "3"))
    GameConfig["CheckInterval"] := Integer(IniRead(ConfigFile, "Process", "CheckInterval", "3000"))
    GameConfig["ShowExitMessage"] := IniRead(ConfigFile, "Process", "ShowExitMessage", "true")
}

;=== 創建默認配置文件 ===
CreateDefaultConfig() {
    global ConfigFile
    
    configContent := "
(
[Game]
ProcessName=AetherGazer.exe
WindowTitle=AetherGazer

[Window]
TargetWidth=1600
TargetHeight=900
CenterWindow=true

[Process]
AutoExitDelay=5
CheckInterval=3000
ShowExitMessage=true
)"
    
    FileAppend(configContent, ConfigFile, "UTF-8")
}

;=== 遊戲進程監控 ===
CheckGameProcess() {
    global GameConfig, GameWasRunning, OnGameExitCallback, OnGameStartCallback
    
    processName := GameConfig["ProcessName"]
    
    if (ProcessExist(processName)) {
        if (!GameWasRunning) {
            GameWasRunning := true
            if (OnGameStartCallback != "" && IsObject(OnGameStartCallback))
                OnGameStartCallback.Call()
        }
    } else if (GameWasRunning) {
        GameWasRunning := false
        SetTimer(CheckGameProcess, 0)
        if (OnGameExitCallback != "" && IsObject(OnGameExitCallback))
            OnGameExitCallback.Call()
        
        if (GameConfig["ShowExitMessage"] = "true") {
            autoExitDelay := GameConfig["AutoExitDelay"]
            result := MsgBox("檢測到遊戲已關閉，腳本將在 " . autoExitDelay . " 秒後自動結束。", "腳本提示", 0x40040 . " T" . autoExitDelay)
            SetTimer(AutoExit, -autoExitDelay * 1000)
        } else {
            SetTimer(AutoExit, -GameConfig["AutoExitDelay"] * 1000)
        }
    }
}

;=== 調整遊戲窗口功能 ===
AdjustGameWindow(*) {
    global GameConfig
    
    windowTitle := GameConfig["WindowTitle"]
    targetWidth := GameConfig["TargetWidth"]
    targetHeight := GameConfig["TargetHeight"]
    centerWindow := GameConfig["CenterWindow"]
    
    if (WinExist(windowTitle)) {
        if (centerWindow = "true") {
            MonitorGetWorkArea(1, &monLeft, &monTop, &monRight, &monBottom)
            centerX := (monRight - monLeft - targetWidth) // 2
            centerY := (monBottom - monTop - targetHeight) // 2
            WinRestore(windowTitle)
            WinMove(centerX, centerY, targetWidth, targetHeight, windowTitle)
        } else {
            WinRestore(windowTitle)
            WinGetPos(&currentX, &currentY, , , windowTitle)
            WinMove(currentX, currentY, targetWidth, targetHeight, windowTitle)
        }
        ShowGameToolTip("遊戲視窗已調整為" . targetWidth . "x" . targetHeight . (centerWindow = "true" ? "並置中" : ""), 1500)
    }
}

;=== 顯示遊戲提示 ===
ShowGameToolTip(text, duration := 1000) {
    global GameConfig
    windowTitle := GameConfig["WindowTitle"]
    x := 860
    y := 490
    
    if (WinExist(windowTitle)) {
        WinGetPos(&gx, &gy, &gw, &gh, windowTitle)
        if (gw && gh) {
            x := gx + (gw // 2) - 100
            y := gy + (gh // 2) - 10
        }
    }
    ToolTip(text, x, y)
    SetTimer(RemoveGameToolTip, -Abs(duration))
}

RemoveGameToolTip() {
    ToolTip()
}

;=== 設置回調函數 ===
SetGameExitCallback(callback) {
    global OnGameExitCallback
    OnGameExitCallback := callback
}

SetGameStartCallback(callback) {
    global OnGameStartCallback  
    OnGameStartCallback := callback
}

;=== 獲取配置信息 ===
GetGameConfig(key) {
    global GameConfig
    return GameConfig.Has(key) ? GameConfig[key] : ""
}

;=== 重新載入配置 ===
ReloadGameConfig() {
    LoadGameConfig()
    SetTimer(CheckGameProcess, GameConfig["CheckInterval"])
}

;=== 檢查遊戲是否運行 ===
IsGameRunning() {
    global GameConfig
    return ProcessExist(GameConfig["ProcessName"]) ? true : false
}

;=== 自動退出 ===
AutoExit() {
    ExitApp()
}
