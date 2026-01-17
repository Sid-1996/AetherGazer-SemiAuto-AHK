;===========================================================
;  AetherGazer-emiAuto-AHK v1.0.6 - AutoHotkey v2版
;  深空之眼 ‧ Sid半自動遊戲腳本 v1.0.6 - 正式版
;-----------------------------------------------------------
#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)
CoordMode("Pixel", "Window")
SendMode("Input")
SetControlDelay(1)
SetWinDelay(0)
SetKeyDelay(-1)
SetMouseDelay(-1)

;=== 引入模組 ===
#Include GameWindowManager.ahk
#Include ConfigManager.ahk
#Include UpdateChecker.ahk
#Include UISequenceManager.ahk

;=== 初始化配置管理器 ===
InitializeConfig()

;=== 簡易JSON解析函數 ===
Jxon_Load(jsonStr) {
    ; 使用自定義JSON解析器
    return ParseSimpleJSON(jsonStr)
}

ParseSimpleJSON(jsonStr) {
    ; 解析數組格式的JSON配置
    result := Map()
    
    ; 移除空白字符
    jsonStr := RegExReplace(jsonStr, "\s+", "")
    
    ; 檢查是否為數組格式
    if !RegExMatch(jsonStr, "^\[.*\]$") {
        throw Error("無效的JSON格式：期望數組")
    }
    
    ; 移除外層的[]
    jsonStr := SubStr(jsonStr, 2, StrLen(jsonStr) - 2)
    
    ; 分割對象
    objects := StrSplit(jsonStr, "},{")
    
    for objStr in objects {
        ; 清理對象字符串
        objStr := StrReplace(objStr, "{", "")
        objStr := StrReplace(objStr, "}", "")
        
        ; 解析鍵值對
        objMap := Map()
        pairs := StrSplit(objStr, ",")
        
        for pair in pairs {
            if RegExMatch(pair, '"([^"]+)":(.+)', &match) {
                key := match[1]
                value := match[2]
                
                ; 移除引號
                if RegExMatch(value, '^"([^"]*)"$', &strMatch) {
                    value := strMatch[1]
                } else {
                    ; 轉換為數字
                    value := Integer(value)
                }
                
                objMap[key] := value
            }
        }
        
        ; 如果有coordId，添加到結果中
        if objMap.Has("coordId") {
            coordId := objMap["coordId"]
            coords := [objMap["x1"], objMap["y1"], objMap["x2"], objMap["y2"]]
            result[coordId] := coords
        }
    }
    
    return result
}

;=== 系統環境檢查 ===
; 任務1: 檢查系統管理員權限
if !A_IsAdmin {
    MsgBox("請以系統管理員身分執行此腳本！`n`n某些功能需要管理員權限才能正常運作。", "權限錯誤", "IconX 4096")
    ExitApp
}

; 任務2: 檢查顯示器環境
CheckSystemEnvironment()

;=== 腳本版本資訊 ===
global SCRIPT_VERSION := GetConfig("Script", "Version", "1.0.6")

;=== 從配置文件載入參數 ===
global ColorVariation     := GetConfig("Game", "ColorVariation", 15)
global ImageVariation     := GetConfig("Game", "ImageVariation", 80)
global SkillCooldown      := GetConfig("Game", "SkillCooldown", 150)
global SkillLockTime      := GetConfig("Game", "SkillLockTime", 300)

;=== 全域狀態變量 ===
global isScriptPaused     := false
global isAutoAttack       := false
global isCastingSkill     := false
global isBBQMode          := false
global isInCombat         := false
global LastSkillTime      := 0
global StatusText         := "等待戰鬥開始..."
global LastHotkeyPress    := 0
global IsStatusGUICreated := false
global StartupGUI         := GetConfig("UI", "ShowStartupGUI", true)
global StatusDisplayX     := GetConfig("UI", "StatusDisplayX", 10)
global StatusDisplayY     := GetConfig("UI", "StatusDisplayY", 10)
global CombatCheckImage   := A_ScriptDir . "\Setting\戰鬥判定.png"
global UserPaused         := false
global LastAction         := "尚未執行任何動作"
global CurrentCharacter   := "通用模式"
global IsCharacterGUIOpen := false
global IsBlackOverlayCreated := false
global StartupGUI         := true  ; 添加這行，初始化為 true

;=== 快速切換角色配置變數 ===
global CharacterList      := ["通用模式", "魂羽", "赤音", "緋染", "巧构", "庚辰"]
global CurrentCharacterIndex := 1

;=== 手動介入監測變數 ===
global IsManualIntervention := false
global LastUserInputTime := 0
global ManualInterventionTimeout := 1000  ; 3秒後恢復自動模式
global InputHookObj := ""
global EnableInputDebug := false  ; 設為true可以看到輸入監測調試信息

;=== GUI 對象引用 ===
global StartupGuiObj      := ""
global StatusGUIObj      := ""
global BlackOverlayObj   := ""
global CharacterSelectGuiObj := ""
global HelpGUIObj         := ""
global IsHelpGUICreated   := false
global CentralStatusGUIObj := ""
global IsCentralStatusGUICreated := false

;=== 角色專屬圖片路徑 ===
global HunYuF1Image       := A_ScriptDir . "\魂羽\魂羽F判定1.png"
global HunYuF2Image       := A_ScriptDir . "\魂羽\魂羽F判定2.png"
global HunYuEImage        := A_ScriptDir . "\魂羽\魂羽E判定.png"

global FeiRanQImage       := A_ScriptDir . "\緋染\緋染Q.png"
global FeiRanQ1Image      := A_ScriptDir . "\緋染\緋染Q1.png"
global FeiRanEImage       := A_ScriptDir . "\緋染\緋染E.png"
global FeiRanE1Image      := A_ScriptDir . "\緋染\緋染E1.png"
global FeiRanFImage       := A_ScriptDir . "\緋染\緋染F.png"
global FeiRanFEndImage    := A_ScriptDir . "\緋染\緋染F End.png"

global QiaoGouQImage      := A_ScriptDir . "\巧构\巧构Q.png"
global QiaoGouFImage      := A_ScriptDir . "\巧构\巧构F.png"
global QiaoGouQ1Image     := A_ScriptDir . "\巧构\巧构Q1.png"
global QiaoGouE1Image     := A_ScriptDir . "\巧构\巧构E1.png"
global QiaoGouEnhanceMode := "Q"

global GengChenQImage     := A_ScriptDir . "\庚辰\庚辰Q.png"
global GengChenQ1Image    := A_ScriptDir . "\庚辰\庚辰Q1.png"

;=== 初始化遊戲管理器 ===
InitializeGameManager()
SetGameExitCallback(OnGameExit)
SetGameStartCallback(OnGameStart)

;=== 啟動時檢查更新 ===
SetTimer(CheckForUpdates, -1000) ; 延遲1秒執行，避免阻塞啟動

CheckForUpdates() {
    ; 從配置中獲取版本號，如果沒有則使用預設值
    currentVersion := GetConfig("Script", "Version", "1.0.6") 
    updater := UpdateChecker(currentVersion, "Sid-1996", "AetherGazer-SemiAuto-AHK")
    updater.Check(true) ; true 表示靜默檢查，沒有新版本就不提示
}

;-----------------------------------------------------------
; 系統環境檢查函數 (簡化版 - 主要邏輯移至UISequenceManager)
;-----------------------------------------------------------
CheckSystemEnvironment() {
    ; 使用新的UI序列管理器
    if (GetConfig("UI", "ShowStartupGUI", true)) {
        StartUISequence()
    } else {
        ; 直接啟動腳本
        StartScript()
    }
}

;-----------------------------------------------------------
; 動態熱鍵註冊
;-----------------------------------------------------------
RegisterHotkeys() {
    try {
        ; 從配置讀取熱鍵設定並註冊
        HotKey(GetConfig("Hotkeys", "AutoAttack", "F1"), (*) => ToggleAutoAttack())
        ; F2 由遊戲管理器處理
        HotKey(GetConfig("Hotkeys", "Help", "F3"), (*) => ToggleHelpGUI())
        HotKey("~Esc", (*) => CloseHelpGUIIfOpen()) ; 新增ESC關閉幫助GUI，保持原功能
        HotKey(GetConfig("Hotkeys", "Pause", "F4"), (*) => TogglePause())
        HotKey(GetConfig("Hotkeys", "CharacterSelect", "F5"), (*) => ShowCharacterSelect())
        HotKey(GetConfig("Hotkeys", "BBQMode", "F6"), (*) => ToggleBBQMode())
        HotKey("F7", (*) => ManualCheckForUpdates()) ; 新增手動檢查更新熱鍵
        HotKey("F8", (*) => ToggleInputDebug()) ; 新增調試模式切換熱鍵
        HotKey(GetConfig("Hotkeys", "Reload", "F11"), (*) => ReloadScript())
        HotKey(GetConfig("Hotkeys", "Exit", "F12"), (*) => ExitScript())
        ; 新增快速切換角色熱鍵 - 主鍵盤方向鍵
        HotKey("^Left", (*) => CycleCharacterNext())  ; Ctrl+左方向鍵（向前/來）
        HotKey("^Right", (*) => CycleCharacterPrev())  ; Ctrl+右方向鍵（向後/回）
    } catch Error as e {
        ; 熱鍵註冊失敗時使用預設熱鍵
        MsgBox("熱鍵註冊部分失敗，將使用預設設定: " . e.Message, "警告", 48)
        RegisterDefaultHotkeys()
    }
}

RegisterDefaultHotkeys() {
    HotKey("F1", (*) => ToggleAutoAttack())
    HotKey("F3", (*) => ToggleHelpGUI())
    HotKey("~Esc", (*) => CloseHelpGUIIfOpen()) ; 新增ESC關閉幫助GUI，保持原功能
    HotKey("F4", (*) => TogglePause())
    HotKey("F5", (*) => ShowCharacterSelect())
    HotKey("F6", (*) => ToggleBBQMode())
    HotKey("F7", (*) => ManualCheckForUpdates()) ; 新增手動檢查更新熱鍵
    HotKey("F8", (*) => ToggleInputDebug()) ; 新增調試模式切換熱鍵
    HotKey("F11", (*) => ReloadScript())
    HotKey("F12", (*) => ExitScript())
    ; 新增快速切換角色熱鍵 - 主鍵盤方向鍵
    HotKey("^Left", (*) => CycleCharacterNext())  ; Ctrl+左方向鍵（向前/來）
    HotKey("^Right", (*) => CycleCharacterPrev())  ; Ctrl+右方向鍵（向後/回）
}

;-----------------------------------------------------------
; 熱鍵處理函數
;-----------------------------------------------------------
ToggleAutoAttack() {
    global isAutoAttack, LastAction, LastHotkeyPress
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount
    
    isAutoAttack := !isAutoAttack
    LastAction := "自動普攻: " . (isAutoAttack ? "開啟" : "關閉")
}

TogglePause() {
    global LastHotkeyPress, UserPaused, isScriptPaused, isCastingSkill, LastAction
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    UserPaused := !UserPaused
    isScriptPaused := UserPaused
    if (UserPaused) {
        LastAction := "手動暫停腳本 (戰鬥時自動恢復)"
        ShowCenteredToolTip("手動暫停中（戰鬥時自動恢復）", 1200)
    } else {
        isCastingSkill := false
        LastAction := "恢復自動模式"
        ShowCenteredToolTip("已恢復自動模式", 1200)
    }
}

ShowCharacterSelect() {
    global LastHotkeyPress
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount
    CreateCharacterSelectGUI()
}

ToggleBBQMode() {
    global LastHotkeyPress, isBBQMode, isScriptPaused, LastAction
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    isBBQMode := !isBBQMode
    isScriptPaused := isBBQMode

    if (isBBQMode) {
        LastAction := "進入烤肉模式"
        ShowCenteredToolTip("烤肉模式啟用", 1000)
        SetTimer(BBQLoop, 50)
    } else {
        SetTimer(BBQLoop, 0)
        LastAction := "退出烤肉模式"
        ShowCenteredToolTip("烤肉模式關閉", 1000)
    }
}

; 新增手動檢查更新的函數
ManualCheckForUpdates() {
    global LastHotkeyPress, LastAction
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount
    
    LastAction := "手動檢查更新中..."
    ShowCenteredToolTip("正在檢查更新...", 2000)
    
    currentVersion := GetConfig("Script", "Version", "1.0.6")
    updater := UpdateChecker(currentVersion, "Sid-1996", "AetherGazer-SemiAuto-AHK")
    updater.Check(false) ; false 表示非靜默，即使是最新版也會提示
}

; 新增輸入調試模式切換函數
ToggleInputDebug() {
    global EnableInputDebug, LastAction
    EnableInputDebug := !EnableInputDebug
    LastAction := "輸入調試模式: " . (EnableInputDebug ? "開啟" : "關閉")
    ShowCenteredToolTip("輸入調試模式" . (EnableInputDebug ? "已開啟" : "已關閉"), 1500)
}

; 快速切換角色 - 向前（Ctrl+小鍵盤←）
CycleCharacterNext() {
    global LastHotkeyPress, CurrentCharacter, CurrentCharacterIndex, CharacterList, LastAction
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount
    
    try {
        if (!IsSet(CharacterList) || CharacterList.Length = 0) {
            ShowCenteredToolTip("角色列表未初始化", 1500)
            return
        }
        
        ; 找到當前角色的索引
        CurrentCharacterIndex := 1
        Loop CharacterList.Length {
            if (CharacterList[A_Index] = CurrentCharacter) {
                CurrentCharacterIndex := A_Index
                break
            }
        }
        
        ; 向前循環
        CurrentCharacterIndex++
        if (CurrentCharacterIndex > CharacterList.Length)
            CurrentCharacterIndex := 1
        
        CurrentCharacter := CharacterList[CurrentCharacterIndex]
        LastAction := "切換角色: " . CurrentCharacter
        ShowCenteredToolTip("已切換到: " . CurrentCharacter, 1500)
    } catch Error as e {
        ShowCenteredToolTip("快速切換錯誤: " . e.Message, 1500)
    }
}

; 快速切換角色 - 向後（Ctrl+小鍵盤→）
CycleCharacterPrev() {
    global LastHotkeyPress, CurrentCharacter, CurrentCharacterIndex, CharacterList, LastAction
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount
    
    try {
        if (!IsSet(CharacterList) || CharacterList.Length = 0) {
            ShowCenteredToolTip("角色列表未初始化", 1500)
            return
        }
        
        ; 找到當前角色的索引
        CurrentCharacterIndex := 1
        Loop CharacterList.Length {
            if (CharacterList[A_Index] = CurrentCharacter) {
                CurrentCharacterIndex := A_Index
                break
            }
        }
        
        ; 向後循環
        CurrentCharacterIndex--
        if (CurrentCharacterIndex < 1)
            CurrentCharacterIndex := CharacterList.Length
        
        CurrentCharacter := CharacterList[CurrentCharacterIndex]
        LastAction := "切換角色: " . CurrentCharacter
        ShowCenteredToolTip("已切換到: " . CurrentCharacter, 1500)
    } catch Error as e {
        ShowCenteredToolTip("快速切換錯誤: " . e.Message, 1500)
    }
}

; 新增ESC關閉幫助GUI函數
CloseHelpGUIIfOpen() {
    global IsHelpGUICreated, HelpGUIObj
    if (IsHelpGUICreated) {
        try {
            HelpGUIObj.Destroy()
            IsHelpGUICreated := false
        } catch {
            ; GUI已經被銷毀
            IsHelpGUICreated := false
        }
    }
}

;-----------------------------------------------------------
; 手動介入監測函數
;-----------------------------------------------------------
RegisterInputHooks() {
    ; 使用雙重監測機制：熱鍵監測 + 輪詢檢查
    
    ; 方法1: 熱鍵監測 (主要方法)
    try {
        HotKey("~w", (*) => UserInputDetected("w"))
        HotKey("~a", (*) => UserInputDetected("a"))  
        HotKey("~s", (*) => UserInputDetected("s"))
        HotKey("~d", (*) => UserInputDetected("d"))
        HotKey("~LButton", (*) => UserInputDetected("LButton"))
        HotKey("~RButton", (*) => UserInputDetected("RButton"))
        HotKey("~MButton", (*) => UserInputDetected("MButton"))
        HotKey("~q", (*) => UserInputDetected("q"))
        HotKey("~e", (*) => UserInputDetected("e"))
        HotKey("~r", (*) => UserInputDetected("r"))
        HotKey("~f", (*) => UserInputDetected("f"))
        HotKey("~Space", (*) => UserInputDetected("Space"))
        HotKey("~Shift", (*) => UserInputDetected("Shift"))
        HotKey("~Ctrl", (*) => UserInputDetected("Ctrl"))
    } catch {
        ; 熱鍵註冊失敗時的備用方案
    }
    
    ; 方法2: 輪詢檢查 (備用方法，更可靠)
    SetTimer(PollUserInput, 50)  ; 每50ms檢查一次
}

; 輪詢檢查用戶輸入
PollUserInput() {
    global isInCombat
    
    ; 只在戰鬥中且遊戲窗口激活時檢查
    if (!isInCombat) {
        return
    }
    
    gameWindow := GetGameConfig("WindowTitle")
    if (!WinActive(gameWindow)) {
        return
    }
    
    ; 檢查常用的遊戲按鍵是否被按住
    keysToCheck := ["w", "a", "s", "d", "q", "e", "r", "f", "Space", "Shift", "Ctrl", "LButton", "RButton", "MButton"]
    
    for key in keysToCheck {
        if (GetKeyState(key, "P")) {
            UserInputDetected("Poll:" . key)
            break  ; 只要檢測到一個按鍵就夠了
        }
    }
}

UserInputDetected(inputType) {
    global LastUserInputTime, IsManualIntervention, isInCombat, EnableInputDebug
    
    ; 只有在戰鬥中才監測手動介入
    if (!isInCombat) {
        return
    }
    
    ; 獲取當前活動窗口
    gameWindow := GetGameConfig("WindowTitle")
    if (!WinActive(gameWindow)) {
        return
    }
    
    ; 記錄用戶輸入時間和類型
    LastUserInputTime := A_TickCount
    IsManualIntervention := true
    
    ; 調試輸出 (可通過EnableInputDebug變數啟用)
    if (EnableInputDebug) {
        ToolTip("偵測到輸入: " . inputType . "`n手動介入已啟動", 100, 100)
        SetTimer(() => ToolTip(), -1000)
    }
}

CheckManualIntervention() {
    global IsManualIntervention, LastUserInputTime, ManualInterventionTimeout
    
    ; 檢查是否超過超時時間
    if (IsManualIntervention && (A_TickCount - LastUserInputTime > ManualInterventionTimeout)) {
        IsManualIntervention := false
    }
}

ReloadScript() {
    Reload()
}

ExitScript() {
    ExitApp()
}

;-----------------------------------------------------------
; 遊戲管理器回調函數
;-----------------------------------------------------------
OnGameExit() {
    ; 遊戲關閉時保存配置
    global ConfigInstance
    if (ConfigInstance) {
        ConfigInstance.SaveConfig()
    }
}

OnGameStart() {
    ; 遊戲啟動時的處理邏輯
}

;-----------------------------------------------------------
; 主程序啟動 - 新版順序UI顯示
;-----------------------------------------------------------
Main() {
    ; 註冊熱鍵
    RegisterHotkeys()
    
    ; 直接調用系統環境檢查，內部會處理UI序列
    CheckSystemEnvironment()
}

StartScript() {
    ShowCenteredToolTip("腳本已載入`n正在初始化戰鬥偵測...", 2000)
    SetTimer(CombatDetection, 500)
    SetTimer(CombatLoop, 30)
    
    if (GetConfig("UI", "ShowStatusOverlay", true)) {
        SetTimer(UpdateStatusDisplay, 100)
    }
    
    ; 初始化中央狀態顯示
    SetTimer(UpdateCentralStatusDisplay, 100)
    
    ; 初始化手動介入監測
    RegisterInputHooks()
    SetTimer(CheckManualIntervention, 100)
    
    ; 顯示幫助GUI
    SetTimer(ShowHelpGUIDelayed, -1000)
}

;-----------------------------------------------------------
; 戰鬥狀態檢測
;-----------------------------------------------------------
CombatDetection() {
    global isInCombat, StatusText, UserPaused, isBBQMode, LastAction
    global CombatCheckImage, ImageVariation, isScriptPaused, isCastingSkill, LastSkillTime
    
    ; 使用遊戲管理器檢查窗口是否激活
    gameWindow := GetGameConfig("WindowTitle")
    if (!WinActive(gameWindow)) {
        isInCombat := false
        StatusText := "遊戲視窗未激活"
        return
    }

    try {
        if (ImageSearch(&FoundX, &FoundY, 88, 853, 150, 888, "*" . ImageVariation . " " . CombatCheckImage)) {
            if (!isInCombat) {
                isInCombat := true
                isCastingSkill := false
                LastSkillTime := 0
                if (UserPaused && !isBBQMode) {
                    isScriptPaused := false
                    UserPaused := false
                    LastAction := "偵測到戰鬥開始 → 自動恢復戰鬥模式"
                    ShowCenteredToolTip("偵測到戰鬥！自動恢復戰鬥模式", 1000)
                }
                StatusText := "戰鬥狀態：進行中"
            }
        } else if (isInCombat) {
            isInCombat := false
            isCastingSkill := false
            StatusText := "戰鬥狀態：已結束"
        }
    } catch {
        ; 圖片搜索失敗時的處理
    }
}

;-----------------------------------------------------------
; 戰鬥核心循環 - 並行運行版
;-----------------------------------------------------------
CombatLoop() {
    global isBBQMode, isInCombat, isScriptPaused
    global LastSkillTime, SkillLockTime, isAutoAttack, isCastingSkill, LastAction, CurrentCharacter
    
    gameWindow := GetGameConfig("WindowTitle")
    if (isBBQMode || !isInCombat || isScriptPaused || !WinActive(gameWindow))
        return

    isMoving := GetKeyState("w","P") || GetKeyState("a","P") || GetKeyState("s","P") || GetKeyState("d","P")
    if (isMoving)
        return

    currentTime := A_TickCount

    ; ╔══ 階段1: 角色專用模式優先檢查 (圖像識別) ══╗
    if (CurrentCharacter = "魂羽") {
        if (CheckHunYuSkills())
            return
    } else if (CurrentCharacter = "赤音") {
        if (CheckChiYinSkills())
            return
    } else if (CurrentCharacter = "緋染") {
        if (CheckFeiRanSkills())
            return
    } else if (CurrentCharacter = "巧构") {
        if (CheckQiaoGouSkills())
            return
    } else if (CurrentCharacter = "庚辰") {
        if (CheckGengChenSkills())
            return
    }

    ; ╔══ 階段2: 通用模式並行運行 (顏色識別) ══╗
    if (currentTime - LastSkillTime < SkillLockTime)
        return

    ; R技能 - 最高優先級
    if (CheckSkillReady(1480,690,1539,758)) {
        CastSkill("r")
        LastAction := "通用模式：偵測到 R 技能亮起 → 已發送 R 鍵"
        return
    }

    ; F技能 - 第二優先級 (庚辰模式時跳過)
    if (CurrentCharacter != "庚辰" && CheckSkillReady(1384,772,1462,851)) {
        CastSkill("f")
        LastAction := "通用模式：偵測到 F 技能亮起 → 已發送 F 鍵"
        return
    }

    ; Q技能 - 第三優先級 (巧构和庚辰模式時跳過)
    if (CurrentCharacter != "巧构" && CurrentCharacter != "庚辰" && CheckSkillReady(1232,770,1304,850)) {
        CastSkill("q")
        LastAction := "通用模式：偵測到 Q 技能亮起 → 已發送 Q 鍵"
        return
    }

    ; E技能 - 第四優先級 (巧构和庚辰模式時跳過)
    if (CurrentCharacter != "巧构" && CurrentCharacter != "庚辰" && CheckSkillReady(1308,768,1386,866)) {
        CastSkill("e")
        LastAction := "通用模式：偵測到 E 技能亮起 → 已發送 E 鍵"
        return
    }

    ; ╔══ 階段3: 自動普攻 ══╗
    if (isAutoAttack && !isCastingSkill && !GetKeyState("LButton","P")) {
        Click()
        Sleep(10)
    }
}

;-----------------------------------------------------------
; 烤肉模式循環
;-----------------------------------------------------------
BBQLoop() {
    global isBBQMode, LastAction, ImageVariation
    gameWindow := GetGameConfig("WindowTitle")
    if (!isBBQMode || !WinActive(gameWindow)) {
        SetTimer(BBQLoop, 0)
        return
    }

    ; 獲取烤肉區域座標
    bbqCoords := GetCoordBounds("bbq_red")
    if (!bbqCoords) {
        return
    }

    try {
        if (ImageSearch(&fx, &fy, bbqCoords[1], bbqCoords[2], bbqCoords[3], bbqCoords[4], "*" . ImageVariation . " " . A_ScriptDir . "\Setting\烤肉紅判定.png")) {
            Send("{e}")
            LastAction := "偵測到紅色烤肉 → 已發送 E 鍵"
            return
        }
    } catch {
        ; 圖片搜索失敗時的處理
    }

    try {
        if (ImageSearch(&fx, &fy, bbqCoords[1], bbqCoords[2], bbqCoords[3], bbqCoords[4], "*" . ImageVariation . " " . A_ScriptDir . "\Setting\烤肉藍判定.png")) {
            Send("{q}")
            LastAction := "偵測到藍色烤肉 → 已發送 Q 鍵"
            return
        }
    } catch {
        ; 圖片搜索失敗時的處理
    }
}

;-----------------------------------------------------------
; 熱鍵功能 (移除F2，由遊戲管理器處理)
;-----------------------------------------------------------
F1:: {
    global isAutoAttack, LastAction
    isAutoAttack := !isAutoAttack
    LastAction := "自動普攻: " . (isAutoAttack ? "開啟" : "關閉")
}

; F2 由遊戲管理器自動註冊，無需在這裡定義

F4:: {
    global LastHotkeyPress, UserPaused, isScriptPaused, isCastingSkill, LastAction
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    UserPaused := !UserPaused
    isScriptPaused := UserPaused
    if (UserPaused) {
        LastAction := "手動暫停腳本 (戰鬥時自動恢復)"
        ShowCenteredToolTip("手動暫停中（戰鬥時自動恢復）", 1200)
    } else {
        isCastingSkill := false
        LastAction := "恢復自動模式"
        ShowCenteredToolTip("已恢復自動模式", 1200)
    }
}

F5:: {
    global LastHotkeyPress
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount
    CreateCharacterSelectGUI()
}

F6:: {
    global LastHotkeyPress, isBBQMode, isScriptPaused, LastAction
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    isBBQMode := !isBBQMode
    isScriptPaused := isBBQMode

    if (isBBQMode) {
        LastAction := "進入烤肉模式"
        ShowCenteredToolTip("烤肉模式啟用", 1000)
        SetTimer(BBQLoop, 50)
    } else {
        SetTimer(BBQLoop, 0)
        LastAction := "退出烤肉模式"
        ShowCenteredToolTip("烤肉模式關閉", 1000)
    }
}

F11::Reload()
F12::ExitApp()

;-----------------------------------------------------------
;  核心功能函數 (保持原有功能不變)
;-----------------------------------------------------------
CheckSkillReady(x1, y1, x2, y2) {
    global ColorVariation
    try {
        return PixelSearch(&px, &py, x1, y1, x2, y2, 0xF1F18F, ColorVariation)
    } catch {
        return false
    }
}

CastSkill(key) {
    global isCastingSkill, LastSkillTime, SkillCooldown
    isCastingSkill := true
    LastSkillTime := A_TickCount
    Send("{LButton Up}")
    Send("{" . key . "}")
    SetTimer(ResetSkillCasting, -SkillCooldown)
}

ResetSkillCasting() {
    global isCastingSkill
    isCastingSkill := false
}

;-----------------------------------------------------------
; 座標讀取函數 (從配置文件讀取調整後的座標)
;-----------------------------------------------------------
GetCoordBounds(coordId) {
    static coordCache := Map()
    
    ; 如果已經快取過，直接返回
    if coordCache.Has(coordId) {
        return coordCache[coordId]
    }
    
    try {
        ; 讀取配置文件
        configFile := A_ScriptDir . "\coordinates_config.json"
        if !FileExist(configFile) {
            MsgBox("找不到座標配置文件: " . configFile, "錯誤", "Icon!")
            return false
        }
        
        ; 讀取JSON內容
        configText := FileRead(configFile, "UTF-8")
        config := Jxon_Load(configText)
        
        ; 檢查是否存在該座標ID
        if !config.Has(coordId) {
            MsgBox("配置文件中找不到座標ID: " . coordId, "錯誤", "Icon!")
            return false
        }
        
        ; 獲取座標數組 [x1, y1, x2, y2]
        coords := config[coordId]
        if coords.Length != 4 {
            MsgBox("座標ID " . coordId . " 的座標格式不正確", "錯誤", "Icon!")
            return false
        }
        
        ; 快取並返回
        coordCache[coordId] := coords
        return coords
        
    } catch Error as e {
        MsgBox("讀取座標配置時發生錯誤: " . e.Message, "錯誤", "Icon!")
        return false
    }
}

;-----------------------------------------------------------
; 角色專屬技能檢查函數 (保持原有不變)
;-----------------------------------------------------------
CheckHunYuSkills() {
    global HunYuF1Image, HunYuF2Image, HunYuEImage
    global ImageVariation, LastAction, LastSkillTime, isCastingSkill, SkillCooldown

    ; 檢查遊戲窗口是否為活動窗口
    gameWindow := GetGameConfig("WindowTitle")
    if (!WinActive(gameWindow)) {
        return false
    }

    ; 獲取魂羽F1判定區域座標
    hunyuF1Coords := GetCoordBounds("hunyu_f1")
    if (hunyuF1Coords) {
        try {
            if (ImageSearch(&FoundX, &FoundY, hunyuF1Coords[1], hunyuF1Coords[2], hunyuF1Coords[3], hunyuF1Coords[4], "*" . ImageVariation . " " . HunYuF1Image)) {
                Send("{f}")
                LastAction := "魂羽模式：偵測到F判定1 → 已發送 F 鍵"
                LastSkillTime := A_TickCount
                isCastingSkill := true
                SetTimer(ResetSkillCasting, -(SkillCooldown + 50))
                return true
            }
        } catch {
            ; 圖片搜索失敗
        }

        try {
            if (ImageSearch(&FoundX, &FoundY, hunyuF1Coords[1], hunyuF1Coords[2], hunyuF1Coords[3], hunyuF1Coords[4], "*" . ImageVariation . " " . HunYuEImage)) {
                Send("{e}")
                LastAction := "魂羽模式：偵測到E判定 → 已發送 E 鍵"
                LastSkillTime := A_TickCount
                isCastingSkill := true
                SetTimer(ResetSkillCasting, -(SkillCooldown + 50))
                return true
            }
        } catch {
            ; 圖片搜索失敗
        }
    }

    ; 獲取魂羽F2判定區域座標
    hunyuF2Coords := GetCoordBounds("hunyu_f2")
    if (hunyuF2Coords) {
        try {
            if (ImageSearch(&FoundX, &FoundY, hunyuF2Coords[1], hunyuF2Coords[2], hunyuF2Coords[3], hunyuF2Coords[4], "*" . ImageVariation . " " . HunYuF2Image)) {
                Send("{LButton}")
                LastAction := "魂羽模式：偵測到F判定2 → 已發送左鍵"
                Sleep(25)
                return true
            }
        } catch {
            ; 圖片搜索失敗
        }
    }
    
    return false
}

CheckChiYinSkills() {
    ; 赤音專用技能檢查 - 待開發
    return false
}

CheckFeiRanSkills() {
    global LastAction, LastSkillTime, isCastingSkill
    global FeiRanQImage, FeiRanQ1Image, FeiRanEImage, FeiRanE1Image, FeiRanFImage, FeiRanFEndImage

    ; 檢查遊戲窗口是否為活動窗口
    gameWindow := GetGameConfig("WindowTitle")
    if (!WinActive(gameWindow)) {
        return false
    }

    FeiRanVariationNormal := 70
    FeiRanVariationStrict := 40

    ; 獲取緋染Q技能區域座標
    faranQCoords := GetCoordBounds("faran_q")
    if (!faranQCoords) {
        return false
    }

    ; 獲取緋染F End區域座標
    faranFEndCoords := GetCoordBounds("faran_f_end")
    if (!faranFEndCoords) {
        faranFEndCoords := [688, 742, 917, 793]  ; 後備座標
    }

    try {
        if (ImageSearch(&fx, &fy, faranQCoords[1], faranQCoords[2], faranQCoords[3], faranQCoords[4], "*" . FeiRanVariationNormal . " " . FeiRanQImage)) {
            isCastingSkill := true
            LastSkillTime := A_TickCount
            Send("{q}")
            LastAction := "緋染模式：偵測到Q → 已發送 Q 鍵"
            SetTimer(ResetSkillCasting, -550)
            return true
        }
    } catch {
        ; 圖片搜索失敗
    }

    try {
        if (ImageSearch(&fx, &fy, faranQCoords[1], faranQCoords[2], faranQCoords[3], faranQCoords[4], "*" . FeiRanVariationNormal . " " . FeiRanQ1Image)) {
            isCastingSkill := true
            LastAction := "緋染模式：偵測到Q1 → 執行連段"
            Send("{q}")
            Sleep(500)
            Send("{q}")
            Sleep(500)
            Send("{q}")
            Sleep(500)
            Send("{LButton}")
            Sleep(300)
            Send("{LButton}")
            Sleep(300)
            Send("{LButton}")
            Sleep(300)
            Send("{LButton}")
            LastSkillTime := A_TickCount
            isCastingSkill := false
            return true
        }
    } catch {
        ; 圖片搜索失敗
    }

    try {
        if (ImageSearch(&fx, &fy, faranQCoords[1], faranQCoords[2], faranQCoords[3], faranQCoords[4], "*" . FeiRanVariationNormal . " " . FeiRanEImage)) {
            isCastingSkill := true
            LastSkillTime := A_TickCount
            Send("{e}")
            LastAction := "緋染模式：偵測到E → 已發送 E 鍵"
            SetTimer(ResetSkillCasting, -550)
            return true
        }
    } catch {
        ; 圖片搜索失敗
    }

    try {
        if (ImageSearch(&fx, &fy, faranQCoords[1], faranQCoords[2], faranQCoords[3], faranQCoords[4], "*" . FeiRanVariationNormal . " " . FeiRanE1Image)) {
            isCastingSkill := true
            LastAction := "緋染模式：偵測到E1 → 執行連段"
            Send("{e}")
            Sleep(500)
            Send("{e}")
            Sleep(500)
            Send("{e}")
            Sleep(500)
            Send("{LButton}")
            Sleep(300)
            Send("{LButton}")
            Sleep(300)
            Send("{LButton}")
            Sleep(300)
            Send("{LButton}")
            LastSkillTime := A_TickCount
            isCastingSkill := false
            return true
        }
    } catch {
        ; 圖片搜索失敗
    }

    try {
        if (ImageSearch(&fx, &fy, faranQCoords[1], faranQCoords[2], faranQCoords[3], faranQCoords[4], "*" . FeiRanVariationStrict . " " . FeiRanFImage)) {
            isCastingSkill := true
            LastSkillTime := A_TickCount
            Send("{f}")
            LastAction := "緋染模式：偵測到F → 已發送 F 鍵"
            SetTimer(ResetSkillCasting, -1200)
            return true
        }
    } catch {
        ; 圖片搜索失敗
    }

    try {
        if (ImageSearch(&fx, &fy, faranFEndCoords[1], faranFEndCoords[2], faranFEndCoords[3], faranFEndCoords[4], "*50 " . FeiRanFEndImage)) {
            isCastingSkill := true
            LastSkillTime := A_TickCount
            Send("{f}")
            LastAction := "緋染模式：偵測到F End → 已發送 F 鍵"
            SetTimer(ResetSkillCasting, -1200)
            return true
        }
    } catch {
        ; 圖片搜索失敗
    }
    
    return false
}

CheckQiaoGouSkills() {
    global LastAction, LastSkillTime, isCastingSkill
    global QiaoGouQImage, QiaoGouFImage, QiaoGouQ1Image, QiaoGouE1Image, QiaoGouEnhanceMode

    ; 檢查遊戲窗口是否為活動窗口
    gameWindow := GetGameConfig("WindowTitle")
    if (!WinActive(gameWindow)) {
        return false
    }

    QiaoGouVariationNormal := 100
    QiaoGouVariationStrict := 25

    ; 獲取巧構Q技能區域座標
    qiaoguQCoords := GetCoordBounds("qiaogu_q")
    if (!qiaoguQCoords) {
        return false
    }

    ; 獲取巧構能量檢測區域座標
    qiaoguEnergyCoords := GetCoordBounds("qiaogu_energy")
    if (!qiaoguEnergyCoords) {
        qiaoguEnergyCoords := [938, 840, 962, 847]  ; 後備座標
    }

    ; 檢測橘紅色像素點 (連段所需能量判定) - 使用配置座標
    try {
        if (PixelSearch(&FoundX, &FoundY, qiaoguEnergyCoords[1], qiaoguEnergyCoords[2], qiaoguEnergyCoords[3], qiaoguEnergyCoords[4], 0xEE821A, 25)) {
            ; 有橘紅色像素點時，能量充足，優先檢查Q技能圖片判定
            try {
                if (ImageSearch(&fx, &fy, qiaoguQCoords[1], qiaoguQCoords[2], qiaoguQCoords[3], qiaoguQCoords[4], "*" . QiaoGouVariationNormal . " " . QiaoGouQImage)) {
                    isCastingSkill := true
                    LastSkillTime := A_TickCount
                    LastAction := "巧构模式：偵測到能量充足 → 執行 Q-E-Q-E 連段"
                    Sleep(600)
                    Send("{q}")
                    Sleep(350)
                    Send("{e}")
                    Sleep(350)
                    Send("{q}")
                    Sleep(350)
                    Send("{e}")
                    Sleep(350)
                    isCastingSkill := false
                    return true
                }
            } catch {
                ; 圖片搜索失敗
            }
        }
    } catch {
        ; 像素搜索失敗
    }

    ; 檢測F技能
    try {
        if (ImageSearch(&fx, &fy, qiaoguQCoords[1], qiaoguQCoords[2], qiaoguQCoords[3], qiaoguQCoords[4], "*" . QiaoGouVariationNormal . " " . QiaoGouFImage)) {
            isCastingSkill := true
            LastSkillTime := A_TickCount
            Send("{f}")
            LastAction := "巧构模式：偵測到F → 已發送 F 鍵 (下次強化技能: " . QiaoGouEnhanceMode . ")"
            SetTimer(ResetSkillCasting, -300)
            return true
        }
    } catch {
        ; 圖片搜索失敗
    }

    ; 強化技能輪替邏輯 - 根據當前狀態只檢測對應的強化技能
    if (QiaoGouEnhanceMode = "Q") {
        ; 當前輪到強化Q，只檢測強化Q
        try {
            if (ImageSearch(&fx, &fy, qiaoguQCoords[1], qiaoguQCoords[2], qiaoguQCoords[3], qiaoguQCoords[4], "*" . QiaoGouVariationNormal . " " . QiaoGouQ1Image)) {
                isCastingSkill := true
                LastSkillTime := A_TickCount
                Send("{q}")
                Sleep(50)
                LastAction := "巧构模式：偵測到強化Q → 已發送 Q 鍵"
                QiaoGouEnhanceMode := "E"  ; 使用後切換到E
                SetTimer(ResetSkillCasting, -300)
                return true
            }
        } catch {
            ; 圖片搜索失敗
        }
    } else if (QiaoGouEnhanceMode = "E") {
        ; 當前輪到強化E，只檢測強化E
        try {
            if (ImageSearch(&fx, &fy, qiaoguQCoords[1], qiaoguQCoords[2], qiaoguQCoords[3], qiaoguQCoords[4], "*" . QiaoGouVariationNormal . " " . QiaoGouE1Image)) {
                isCastingSkill := true
                LastSkillTime := A_TickCount
                Send("{e}")
                Sleep(50)
                LastAction := "巧构模式：偵測到強化E → 已發送 E 鍵"
                QiaoGouEnhanceMode := "Q"  ; 使用後切換到Q
                SetTimer(ResetSkillCasting, -300)
                return true
            }
        } catch {
            ; 圖片搜索失敗
        }
    }

    return false
}

;-----------------------------------------------------------
; 庚辰角色技能檢查函數
;-----------------------------------------------------------
CheckGengChenSkills() {
    global LastAction, LastSkillTime, isCastingSkill
    global GengChenQImage, GengChenQ1Image

    ; 檢查遊戲窗口是否為活動窗口
    gameWindow := GetGameConfig("WindowTitle")
    if (!WinActive(gameWindow)) {
        return false
    }

    ; 獲取庚辰Q技能區域座標
    gengchenQCoords := GetCoordBounds("gengchen_q")
    if (!gengchenQCoords) {
        return false
    }

    ; 檢測紅色像素點 (怒氣充足判定) - 使用相對座標
    try {
        if (PixelSearch(&FoundX, &FoundY, 883, 837, 899, 853, 0xEE2727, 25)) {
            ; 有紅色像素點時，怒氣充足，檢查Q技能圖片判定
            try {
                ; 嘗試搜尋第一張圖片 (庚辰Q.png)
                if (ImageSearch(&FoundX, &FoundY, gengchenQCoords[1], gengchenQCoords[2], gengchenQCoords[3], gengchenQCoords[4], "*80 " . GengChenQImage)) {
                    LastAction := "庚辰模式：偵測到怒氣充足 → 執行技能連段"
                    ExecuteGengChenActions()
                    return true
                }
                ; 如果第一張圖片沒找到，嘗試搜尋第二張圖片 (庚辰Q1.png)
                else if (ImageSearch(&FoundX, &FoundY, gengchenQCoords[1], gengchenQCoords[2], gengchenQCoords[3], gengchenQCoords[4], "*80 " . GengChenQ1Image)) {
                    LastAction := "庚辰模式：偵測到怒氣充足 → 執行技能連段"
                    ExecuteGengChenActions()
                    return true
                }
            } catch {
                ; 圖片搜索失敗
            }
        }
    } catch {
        ; 像素搜索失敗
    }
    
    return false
}

;-----------------------------------------------------------
; 庚辰技能執行動作
;-----------------------------------------------------------
ExecuteGengChenActions() {
    global LastAction, LastSkillTime, isCastingSkill
    
    isCastingSkill := true
    LastSkillTime := A_TickCount
    Sleep(600)
    Send("{q}")
    Sleep(500)
    Send("{RButton}")
    Sleep(500)
    Send("{e}")
    Sleep(1000)
    Send("{f}")
    Sleep(500)
    
    LastAction := "庚辰模式：執行技能連段 Q→右鍵→E→F"
    SetTimer(ResetSkillCasting, -300)
}

;-----------------------------------------------------------
; GUI 相關函數 (使用遊戲管理器的配置)
;-----------------------------------------------------------
ShowCenteredToolTip(text, duration := 1000) {
    gameWindow := GetGameConfig("WindowTitle")
    x := 860 ; Default X
    y := 490 ; Default Y
    if (WinExist(gameWindow)) {
        WinGetPos(&gx, &gy, &gw, &gh, gameWindow)
        if (gw && gh) {
            x := gx + (gw // 2) - 100
            y := gy + (gh // 2) - 10
        }
    }
    ToolTip(text, x, y)
    SetTimer(RemoveToolTip, -Abs(duration))
}

RemoveToolTip() {
    ToolTip()
}

CreateCharacterSelectGUI() {
    global IsCharacterGUIOpen, CurrentCharacter, LastAction, CharacterSelectGuiObj
    if (IsCharacterGUIOpen) {
        CharacterSelectGuiObj.Destroy()
        IsCharacterGUIOpen := false
        return
    }

    IsCharacterGUIOpen := true
    CharacterSelectGuiObj := Gui("+LastFound +Owner +AlwaysOnTop -SysMenu", "角色選擇")
    CharacterSelectGuiObj.BackColor := "0x2D2D30"
    CharacterSelectGuiObj.SetFont("cFFFFFF s11 bold", "Microsoft YaHei")
    CharacterSelectGuiObj.AddText("x20 y15 w200 Center", "角色選擇")
    CharacterSelectGuiObj.SetFont("cCCCCCC s10 norm")
    CharacterSelectGuiObj.AddText("x20 y45 w80", "當前角色:")

    CharacterOptions := ["通用模式", "魂羽", "赤音", "緋染", "巧构", "庚辰"]
    ChoiceIndex := 1
    Loop CharacterOptions.Length {
        if (CharacterOptions[A_Index] = CurrentCharacter) {
            ChoiceIndex := A_Index
            break
        }
    }
    
    ddl := CharacterSelectGuiObj.AddDropDownList("x100 y42 w120 Choose" . ChoiceIndex, CharacterOptions)
    ddl.Name := "SelectedCharacter"
    CharacterSelectGuiObj.SetFont("cFFFFFF s9")
    btnConfirm := CharacterSelectGuiObj.AddButton("x60 y80 w50 h25", "確定")
    btnConfirm.OnEvent("Click", CharacterConfirm)
    btnCancel := CharacterSelectGuiObj.AddButton("x130 y80 w50 h25", "取消")
    btnCancel.OnEvent("Click", CharacterCancel)
    CharacterSelectGuiObj.SetFont("c888888 s8")
    CharacterSelectGuiObj.AddText("x20 y115 w200 Center", "赤音功能開發中")
    CharacterSelectGuiObj.OnEvent("Close", CharacterCancel)
    CharacterSelectGuiObj.Show("w240 h145")
}

CharacterConfirm(*) {
    global CharacterSelectGuiObj, CurrentCharacter, CurrentCharacterIndex, CharacterList, LastAction, IsCharacterGUIOpen
    try {
        SelectedCharacter := CharacterSelectGuiObj["SelectedCharacter"].Text
        if (SelectedCharacter = "")
            return
        OldCharacter := CurrentCharacter
        CurrentCharacter := SelectedCharacter
        
        ; 同步更新索引
        CurrentCharacterIndex := 1
        Loop CharacterList.Length {
            if (CharacterList[A_Index] = CurrentCharacter) {
                CurrentCharacterIndex := A_Index
                break
            }
        }
        
        if (OldCharacter != CurrentCharacter) {
            LastAction := "切換角色: " . OldCharacter . " → " . CurrentCharacter
            ShowCenteredToolTip("已切換到: " . CurrentCharacter, 1500)
        }
        CharacterSelectGuiObj.Destroy()
        IsCharacterGUIOpen := false
    } catch {
        ; GUI 操作錯誤處理
    }
}

CharacterCancel(*) {
    global CharacterSelectGuiObj, IsCharacterGUIOpen
    try {
        CharacterSelectGuiObj.Destroy()
        IsCharacterGUIOpen := false
    } catch {
        ; GUI 操作錯誤處理
    }
}

;-----------------------------------------------------------
; 狀態顯示與黑色遮擋 (使用遊戲管理器配置)
;-----------------------------------------------------------
UpdateStatusDisplay() {
    global IsStatusGUICreated, isInCombat, isBBQMode, isScriptPaused, LastAction, isAutoAttack, CurrentCharacter
    global StatusDisplayX, StatusDisplayY, IsBlackOverlayCreated, StatusGUIObj, BlackOverlayObj
    
    gameWindow := GetGameConfig("WindowTitle")
    combatStatus := isInCombat ? "戰鬥中" : "非戰鬥"
    modeStatus := isBBQMode ? "烤肉模式" : (isScriptPaused ? "暫停中" : "運行中")

    ; 創建狀態顯示GUI
    if (!IsStatusGUICreated) {
        StatusGUIObj := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow +E0x20", "StatusOverlay")
        StatusGUIObj.BackColor := "0x121212"
        StatusGUIObj.SetFont("cFFFFFF s9", "Microsoft YaHei")
        StatusGUIObj.AddText("x10 y5 w280", "腳本狀態: 運行中").Name := "StatusTextCtrl"
        StatusGUIObj.AddText("x10 y20 w280", "戰鬥: " . combatStatus).Name := "CombatStatusCtrl"
        StatusGUIObj.AddText("x10 y35 w280", "動作: " . LastAction).Name := "CurrentActionCtrl"
        StatusGUIObj.AddText("x10 y50 w280", "模式: " . modeStatus).Name := "ModeCtrl"
        StatusGUIObj.AddText("x10 y65 w280", "普攻: " . (isAutoAttack ? "開" : "關")).Name := "AutoAttackCtrl"
        StatusGUIObj.AddText("x10 y80 w280", "角色: " . CurrentCharacter).Name := "CharacterCtrl"
        StatusGUIObj.Show("x" . StatusDisplayX . " y" . StatusDisplayY . " w300 h95 NoActivate")
        WinSetTransparent(200, "StatusOverlay")
        IsStatusGUICreated := true
    } else {
        statusText := WinActive(gameWindow) ? "運行中" : "視窗未激活"
        try {
            StatusGUIObj["StatusTextCtrl"].Text := "腳本狀態: " . statusText
            StatusGUIObj["CombatStatusCtrl"].Text := "戰鬥: " . combatStatus
            StatusGUIObj["CurrentActionCtrl"].Text := "動作: " . LastAction
            StatusGUIObj["ModeCtrl"].Text := "模式: " . modeStatus
            StatusGUIObj["AutoAttackCtrl"].Text := "普攻: " . (isAutoAttack ? "開" : "關")
            StatusGUIObj["CharacterCtrl"].Text := "角色: " . CurrentCharacter
        } catch {
            ; GUI 更新錯誤處理
        }
    }

    ; 創建黑色遮擋窗口
    if (!IsBlackOverlayCreated) {
        overlayX := 1431
        overlayY := 931
        overlayWidth := 1579 - 1431    ; 148 像素寬
        overlayHeight := 953 - 931     ; 22 像素高
        
        BlackOverlayObj := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow +E0x20", "BlackOverlay")
        BlackOverlayObj.BackColor := "0x000000"  ; 純黑色
        BlackOverlayObj.AddText("x0 y0 w" . overlayWidth . " h" . overlayHeight . " BackgroundTrans", "")
        BlackOverlayObj.Show("x" . overlayX . " y" . overlayY . " w" . overlayWidth . " h" . overlayHeight . " NoActivate")
        WinSetTransparent(255, "BlackOverlay")
        IsBlackOverlayCreated := true
    }
}

;-----------------------------------------------------------
; 中央狀態顯示 - 大字報樣式
;-----------------------------------------------------------
UpdateCentralStatusDisplay() {
    global IsCentralStatusGUICreated, CentralStatusGUIObj
    global isInCombat, isScriptPaused, isBBQMode, UserPaused, IsManualIntervention
    
    gameWindow := GetGameConfig("WindowTitle")
    
    ; 只有當遊戲窗口激活時才顯示
    if (!WinActive(gameWindow)) {
        if (IsCentralStatusGUICreated) {
            try {
                CentralStatusGUIObj.Hide()
            } catch {
                ; GUI已被銷毀
            }
        }
        return
    }
    
    ; 根據當前狀態決定顯示的文字
    statusMessage := ""
    if (isBBQMode) {
        statusMessage := "烤肉模式運行中..."
    } else if (isInCombat) {
        if (IsManualIntervention) {
            statusMessage := "手動介入中..."
        } else if (isScriptPaused || UserPaused) {
            statusMessage := "手動介入中..."
        } else {
            statusMessage := "自動戰鬥中..."
        }
    } else {
        statusMessage := "非戰鬥狀態..."
    }
    
    ; 創建或更新中央狀態GUI
    if (!IsCentralStatusGUICreated) {
        ; 獲取遊戲窗口位置和大小
        try {
            WinGetPos(&gameX, &gameY, &gameW, &gameH, gameWindow)
            
            ; 計算中央位置
            centerX := gameX + (gameW // 2) - 150  ; GUI寬度約300，所以-150置中
            centerY := gameY + 50  ; 距離遊戲窗口頂部50像素
            
            CentralStatusGUIObj := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow +E0x20", "CentralStatus")
            CentralStatusGUIObj.BackColor := "0x000000"  ; 黑色背景
            CentralStatusGUIObj.SetFont("cFFFFFF s18 bold", "Microsoft YaHei")  ; 大字體
            CentralStatusGUIObj.AddText("x20 y10 w260 Center", statusMessage).Name := "CentralStatusText"
            CentralStatusGUIObj.Show("x" . centerX . " y" . centerY . " w300 h40 NoActivate")
            WinSetTransparent(180, "CentralStatus")  ; 半透明
            IsCentralStatusGUICreated := true
        } catch {
            ; 窗口操作失敗
        }
    } else {
        ; 更新現有GUI的文字
        try {
            CentralStatusGUIObj["CentralStatusText"].Text := statusMessage
            CentralStatusGUIObj.Show("NoActivate")  ; 確保顯示
        } catch {
            ; GUI更新失敗，重置狀態
            IsCentralStatusGUICreated := false
        }
    }
}

;-----------------------------------------------------------
; 熱鍵說明GUI相關函數
;-----------------------------------------------------------
ShowHelpGUIDelayed() {
    CreateHelpGUI()
}

ToggleHelpGUI() {
    global IsHelpGUICreated, HelpGUIObj
    if (IsHelpGUICreated) {
        try {
            HelpGUIObj.Destroy()
            IsHelpGUICreated := false
        } catch {
            ; GUI已經被銷毀
            IsHelpGUICreated := false
        }
    } else {
        CreateHelpGUI()
    }
}

CreateHelpGUI() {
    global IsHelpGUICreated, HelpGUIObj
    if (IsHelpGUICreated) {
        return
    }

    IsHelpGUICreated := true
    HelpGUIObj := Gui("+LastFound +AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox", "熱鍵說明")
    HelpGUIObj.BackColor := "0x2D2D30"
    
    ; 標題
    HelpGUIObj.SetFont("cFFFFFF s14 bold", "Microsoft YaHei")
    HelpGUIObj.AddText("x20 y15 w350 Center", "深空之眼 Sid半自動腳本 熱鍵說明")
    
    ; 分隔線
    HelpGUIObj.SetFont("c666666 s12")
    HelpGUIObj.AddText("x20 y45 w350 Center", "━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    ; 熱鍵說明內容
    HelpGUIObj.SetFont("c00FF99 s12 bold")
    HelpGUIObj.AddText("x20 y70", "功能熱鍵：")
    
    HelpGUIObj.SetFont("cFFFFFF s12 norm")
    HelpGUIObj.AddText("x30 y95", "F1  - 切換自動普攻 (開啟/關閉)")
    HelpGUIObj.AddText("x30 y115", "F2  - 調整遊戲視窗為設定大小並置中")
    HelpGUIObj.AddText("x30 y135", "F3  - 開啟/關閉此熱鍵說明面板 (ESC也可關閉)")
    HelpGUIObj.AddText("x30 y155", "F4  - 手動暫停腳本 (戰鬥時自動恢復)")
    HelpGUIObj.AddText("x30 y175", "F5  - 開啟角色選擇面板")
    HelpGUIObj.AddText("x30 y195", "F6  - 切換烤肉模式 (自動按E/Q)")
    HelpGUIObj.AddText("x30 y215", "F7  - 手動檢查版本更新")
    HelpGUIObj.AddText("x30 y235", "F8  - 切換輸入監測調試模式")
    
    HelpGUIObj.SetFont("c00FF99 s12 bold")
    HelpGUIObj.AddText("x20 y260", "快速切換快捷鍵 (新增):")
    
    HelpGUIObj.SetFont("cFFFFFF s12 norm")
    HelpGUIObj.AddText("x30 y285", "Ctrl+左方向鍵 ← - 下一個角色配置（向前）")
    HelpGUIObj.AddText("x30 y305", "Ctrl+右方向鍵 → - 上一個角色配置（向後）")
    
    HelpGUIObj.SetFont("cFF9900 s12 bold")
    HelpGUIObj.AddText("x20 y330", "系統熱鍵：")
    
    HelpGUIObj.SetFont("cFFFFFF s12 norm")
    HelpGUIObj.AddText("x30 y355", "F11 - 重新載入腳本")
    HelpGUIObj.AddText("x30 y375", "F12 - 結束腳本")
    
    ; 注意事項
    HelpGUIObj.SetFont("cFF6666 s12 bold")
    HelpGUIObj.AddText("x20 y405", "注意事項:")
    
    HelpGUIObj.SetFont("cFFFFFF s12 norm")
    HelpGUIObj.AddText("x30 y430", "• 腳本支持通過ini文件配置遊戲設定")
    HelpGUIObj.AddText("x30 y450", "• 需將Setting等資料夾放在腳本同目錄")
    HelpGUIObj.AddText("x30 y470", "• 此面板不影響腳本正常運行")
    HelpGUIObj.AddText("x30 y490", "• 快速切換時按反方向可輕鬆返回前一配置")
    
    ; 贊助資訊區塊
    HelpGUIObj.SetFont("c00CCFF s12 bold")
    HelpGUIObj.AddText("x20 y520", "快速連結：(下方可點擊前往)")
    
    ; 綠界科技贊助連結
    HelpGUIObj.SetFont("c28a745 s11 underline") ; 清新綠
    sponsorLink1 := HelpGUIObj.AddText("x30 y545", "💚 綠界科技贊助（支持作者）")
    sponsorLink1.OnEvent("Click", (*) => Run("https://p.ecpay.com.tw/E0E3A"))

    ; Buy Me a Coffee
    HelpGUIObj.SetFont("cf39c12 s11 underline") ; 活力橙
    sponsorLink2 := HelpGUIObj.AddText("x30 y565", "☕ [ ko-fi ] 請作者喝咖啡")
    sponsorLink2.OnEvent("Click", (*) => Run("https://ko-fi.com/sid1996"))

    ; 支持此專案 - PayPal
    HelpGUIObj.SetFont("c1f75fe s11 underline") ; 熱情紅
    sponsorLink3 := HelpGUIObj.AddText("x30 y585", "🔗 支持專案：PayPal 贊助")
    sponsorLink3.OnEvent("Click", (*) => Run("https://www.paypal.com/ncp/payment/GJS4D5VTSVWG4"))

    ; GitHub 連結 (放最下面)
    HelpGUIObj.SetFont("c3498db s11 underline") ; 科技藍
    githubLink := HelpGUIObj.AddText("x30 y605", "💻 GitHub：深空之眼 Sid 半自動腳本")
    githubLink.OnEvent("Click", (*) => Run("https://github.com/Sid-1996/AetherGazer-SemiAuto-AHK"))

    ; 版本信息
    HelpGUIObj.SetFont("c888888 s10")
    HelpGUIObj.AddText("x20 y630 w350 Center", "版本 v1.0.6 正式版 | 製作 by Sid 1996")
    
    ; 修正GUI位置 - 確保在螢幕範圍內
    x := 50   ; 距離螢幕左邊50像素  
    y := 50   ; 距離螢幕上方50像素  
    
    ; 調整GUI整體高度，避免文字擠壓
    guiWidth := 390
    guiHeight := 670  ; 增加高度以容納新的快速切換說明
    
    ; 獲取螢幕尺寸確保GUI不會跑出螢幕
    MonitorGet(1, &Left, &Top, &Right, &Bottom)
    screenWidth := Right - Left
    screenHeight := Bottom - Top
    
    if (x + guiWidth > screenWidth)
        x := screenWidth - guiWidth - 10
    if (y + guiHeight > screenHeight)
        y := screenHeight - guiHeight - 10
    
    HelpGUIObj.OnEvent("Close", (*) => ToggleHelpGUI())
    HelpGUIObj.Show("x" . x . " y" . y . " w" . guiWidth . " h" . guiHeight)
}

; === 程序入口 ===
Main()