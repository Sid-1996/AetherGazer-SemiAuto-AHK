;===========================================================
;  深空之眼 ‧ Sid半自動遊戲腳本 v3.1 
;-----------------------------------------------------------
;  修改重點：
;    - 完全移除技能就緒狀態顯示
;    - 強化實際動作偵測回報
;    - 即時顯示腳本發送的按鍵指令
;    - 簡化狀態介面只顯示關鍵資訊
;===========================================================

#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Pixel, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
#Persistent
#MaxThreadsPerHotkey 2
#MaxHotkeysPerInterval 200
#HotkeyInterval 1000

;=== 全局變量 ===
global isScriptPaused     := false
global isAutoAttack       := false
global isCastingSkill     := false
global isBBQMode          := false
global isInCombat         := false
global gameWindow         := "AetherGazer"
global QE_Priority        := 0
global LastSkillTime      := 0
global StatusText         := "等待戰鬥開始..."
global ToolTipDuration    := 1000
global LastHotkeyPress    := 0
global ColorVariation     := 15
global IsStatusGUICreated := false
global StartupGUI         := true
global StatusDisplayX     := 10
global StatusDisplayY     := 10
global CombatCheckImage   := A_ScriptDir . "\戰鬥判定.png"
global UserPaused         := false
global SkillLockTime      := 800
global LastDetectedSkill  := ""
global LastAction         := "尚未執行任何動作"
global HoldSkillTimes     := {"q":0,"e":0,"f":0,"r":0}
global MaxHoldAttempts    := 5
global HoldInterval       := 80

;-----------------------------------------------------------
;  起始 GUI
;-----------------------------------------------------------
CreateStartupGUI:
    Gui, Startup:New
    Gui, Startup:Color, 0x1A1A2E
    Gui, Startup:-SysMenu -Caption
    Gui, Startup:Font, cFFFFFF s12, Microsoft YaHei
    Gui, Startup:Add, Text, x0  y10  w400 Center, ░▒▓ 深空之眼 ▓▒░
    Gui, Startup:Font, c00FF99 s14 bold
    Gui, Startup:Add, Text, x20 y40  w360 Center, Sid半自動遊戲腳本
    Gui, Startup:Font, cCCCCCC s10 norm
    Gui, Startup:Add, Text, x20 y80  w360 Center, 版本 v3.1 | 1600×900專用
    Gui, Startup:Add, Text, x20 y110 w360 Center, 製作 by Sid
    Gui, Startup:Font, cFF9900 s9
    Gui, Startup:Add, Text, x20 y150 w360 Center, ⚠️ 請將「戰鬥判定.png」放在腳本同目錄
    Gui, Startup:Font, cFFFFFF s10
    Gui, Startup:Add, Text, x20 y190 w360 Center, 按任意鍵開始自動偵測...
    Gui, Startup:Show, w400 h230, 深空之眼助手
    OnMessage(0x0100, "StartupKeyPressed")
return

StartupKeyPressed(wParam, lParam, msg, hwnd) {
    global StartupGUI
    if (StartupGUI) {
        Gui, Startup:Destroy
        StartupGUI := false
        OnMessage(0x0100, "")
        ShowCenteredToolTip("腳本已加載`n正在初始化戰鬥偵測...", 2000)
        SetTimer, CombatDetection, 500
        SetTimer, CombatLoop, 20
        SetTimer, UpdateStatusDisplay, 50
    }
    return
}

;-----------------------------------------------------------
;  戰鬥狀態檢測
;-----------------------------------------------------------
CombatDetection:
    if (!WinActive(gameWindow)) {
        isInCombat := false
        StatusText := "遊戲視窗未激活"
        return
    }

    ImageSearch, FoundX, FoundY, 88, 853, 150, 888, *15 %CombatCheckImage%
    if (ErrorLevel = 0) {
        if (!isInCombat) {
            isInCombat := true
            isCastingSkill := false
            LastSkillTime  := 0
            HoldSkillTimes := {"q":0,"e":0,"f":0,"r":0}
            if (UserPaused && !isBBQMode) {
                isScriptPaused := false
                UserPaused     := false
                LastAction := "偵測到戰鬥開始 → 自動恢復戰鬥模式"
                ShowCenteredToolTip("偵測到戰鬥！自動恢復戰鬥模式", 1000)
            }
            StatusText := "戰鬥狀態：進行中"
        }
    } else if (isInCombat) {
        isInCombat := false
        LastAction := "偵測到戰鬥結束"
        StatusText := "戰鬥狀態：已結束"
    }
return

;-----------------------------------------------------------
;  戰鬥核心循環
;-----------------------------------------------------------
CombatLoop:
    if (isBBQMode) {
        StatusText := "烤肉模式運行中"
        return
    }

    isMoving := GetKeyState("w","P") || GetKeyState("a","P") || GetKeyState("s","P") || GetKeyState("d","P")

    if (!isInCombat || isScriptPaused || !WinActive(gameWindow) || isMoving)
        return

    isInProtection := (A_TickCount - LastSkillTime < SkillLockTime)

    if (!isCastingSkill || (A_TickCount - LastSkillTime > HoldInterval)) {
        ; (R) 最高優先
        if (CheckSkillArea(1480,690,1539,758,0xF1F18F)) {
            LastAction := "偵測到 R 技能亮起 → 已發送 R 鍵"
            CastSkill("r", 100)
            return
        }

        ; (F)
        else if (CheckSkillArea(1384,772,1462,851,0xF1F18F)) {
            LastAction := "偵測到 F 技能亮起 → 已發送 F 鍵"
            CastSkill("f", 100)
            return
        }

        ; (Q/E) 判定＋優先順序
        if (CheckSkillArea(1232,770,1304,850,0xF1F18F)) {
            LastAction := "偵測到 Q 技能亮起 → 已發送 Q 鍵"
            CastSkill("q", 100)
            return
        }
        else if (CheckSkillArea(1308,768,1386,866,0xF1F18F)) {
            LastAction := "偵測到 E 技能亮起 → 已發送 E 鍵"
            CastSkill("e", 100)
            return
        }
    }

    if (!isCastingSkill && !isInProtection && isAutoAttack && !GetKeyState("LButton","P")) {
        Click
        Sleep, 15
    }
return

;-----------------------------------------------------------
;  烤肉模式 (F6)
;-----------------------------------------------------------
F6::
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    if (isBBQMode) {
        isBBQMode := false
        return
    }

    isBBQMode     := true
    isScriptPaused := true
    LastAction := "進入烤肉模式"
    ShowCenteredToolTip("● 烤肉模式啟用 (ImageSearch)", 1200)

    CoordMode, Pixel, Window
    Loop {
        if (!isBBQMode)
            break

        if (!WinActive(gameWindow)) {
            Sleep, 50
            continue
        }

        ;── 烤肉「紅」判定 ──
        ImageSearch, FoundX, FoundY, 811, 188, 874, 237, *50 %A_ScriptDir%\烤肉紅判定.png
        if (ErrorLevel = 0) {
            LastAction := "偵測到紅色烤肉 → 已發送 E 鍵"
            Send, {e}
            Sleep, 100
            continue
        }

        ;── 烤肉「藍」判定 ──
        ImageSearch, FoundX, FoundY, 811, 188, 874, 237, *50 %A_ScriptDir%\烤肉藍判定.png
        if (ErrorLevel = 0) {
            LastAction := "偵測到藍色烤肉 → 已發送 Q 鍵"
            Send, {q}
            Sleep, 100
            continue
        }

        LastAction := "掃描烤肉顏色中...(如使用完，F6退出)"
        Sleep, 10
    }

    LastAction := "退出烤肉模式"
    ShowCenteredToolTip("○ 烤肉模式關閉", 1200)
    isScriptPaused := false
return

;-----------------------------------------------------------
;  熱鍵功能
;-----------------------------------------------------------
F2::
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    ; 只針對遊戲視窗操作
    if !WinExist(gameWindow)
    {
        ShowCenteredToolTip("找不到遊戲視窗!", 1500)
        return
    }
    
    ; 確保遊戲視窗是活動狀態
    WinActivate, %gameWindow%
    WinWaitActive, %gameWindow%, , 1
    
    ; 獲取當前視窗狀態和位置
    WinGet, windowState, MinMax, %gameWindow%
    WinGetPos, winX, winY, winWidth, winHeight, %gameWindow%
    
    ; 如果視窗已經是1600x900且位置正確，就不做任何操作
    SysGet, monitorWorkArea, MonitorWorkArea
    centerX := (monitorWorkAreaRight - monitorWorkAreaLeft - 1600) // 2
    centerY := (monitorWorkAreaBottom - monitorWorkAreaTop - 900) // 2
    
    if (winWidth = 1600 && winHeight = 900 && winX = centerX && winY = centerY && windowState != 1)
    {
        LastAction := "視窗已經是1600x900且已置中"
        ShowCenteredToolTip("視窗已經是1600x900且已置中", 1500)
        return
    }
    
    ; 調整視窗
    WinRestore, %gameWindow%  ; 先恢復視窗（如果是最小化或最大化）
    WinMove, %gameWindow%, , centerX, centerY, 1600, 900
    WinActivate, %gameWindow%
    
    LastAction := "已調整遊戲視窗至1600x900並置中"
    ShowCenteredToolTip("遊戲視窗已調整為1600x900並置中", 1500)
    
    ; 調試用：顯示實際位置信息
    ; WinGetPos, afterX, afterY, afterW, afterH, %gameWindow%
    ; MsgBox 調整後位置: X=%afterX% Y=%afterY% W=%afterW% H=%afterH%
return

F1::
    isAutoAttack := !isAutoAttack
    LastAction := "自動普攻: " . (isAutoAttack ? "● 開啟" : "○ 關閉")
    if (IsStatusGUICreated)
        GuiControl, StatusGUI:, AutoAttackCtrl, % "自動普攻: " (isAutoAttack ? "● 開啟" : "○ 關閉")
return

F4::
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    UserPaused := !UserPaused
    if (UserPaused) {
        isScriptPaused := true
        LastAction := "手動暫停腳本 (戰鬥時自動恢復)"
        ShowCenteredToolTip("手動暫停中（戰鬥時自動恢復）", 1200)
    } else {
        isScriptPaused := false
        isCastingSkill := false
        LastAction := "恢復自動模式"
        ShowCenteredToolTip("已恢復自動模式", 1200)
    }
return

~*F::
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount
    QE_Priority := !QE_Priority
    LastAction := "切換技能優先級: " . (QE_Priority ? "E > Q" : "Q > E")
return

F11::Reload
F12::ExitApp

;-----------------------------------------------------------
;  核心功能函數
;-----------------------------------------------------------
CheckSkillArea(x1,y1,x2,y2,color) {
    PixelSearch, FoundX, FoundY, x1, y1, x2, y2, color, %ColorVariation%, Fast RGB
    return (ErrorLevel==0)
}

CastSkill(key,duration) {
    global isCastingSkill, LastSkillTime, HoldSkillTimes, LastAction
    if !HoldSkillTimes.HasKey(key)
        HoldSkillTimes[key] := 0

    isCastingSkill := true
    LastSkillTime  := A_TickCount
    Send, {LButton Up}
    Send, {%key%}
    HoldSkillTimes[key]++

    SetTimer, CheckHold_%key%, %HoldInterval%
    SetTimer, ResetCasting, % -duration
}

CheckHold_q:
    if (CheckSkillArea(1232,770,1304,850,0xF1F18F) && HoldSkillTimes["q"]<MaxHoldAttempts){
        LastAction := "持續按住 Q 鍵 (" . (HoldSkillTimes["q"]+1) . "/" . MaxHoldAttempts . ")"
        Send, {q}
        HoldSkillTimes["q"]++
    } else {
        SetTimer, CheckHold_q, Off
        HoldSkillTimes["q"] := 0
    }
return

CheckHold_e:
    if (CheckSkillArea(1308,768,1386,866,0xF1F18F) && HoldSkillTimes["e"]<MaxHoldAttempts){
        LastAction := "持續按住 E 鍵 (" . (HoldSkillTimes["e"]+1) . "/" . MaxHoldAttempts . ")"
        Send, {e}
        HoldSkillTimes["e"]++
    } else {
        SetTimer, CheckHold_e, Off
        HoldSkillTimes["e"] := 0
    }
return

CheckHold_f:
    if (CheckSkillArea(1384,772,1462,851,0xF1F18F) && HoldSkillTimes["f"]<MaxHoldAttempts){
        LastAction := "持續按住 F 鍵 (" . (HoldSkillTimes["f"]+1) . "/" . MaxHoldAttempts . ")"
        Send, {f}
        HoldSkillTimes["f"]++
    } else {
        SetTimer, CheckHold_f, Off
        HoldSkillTimes["f"] := 0
    }
return

CheckHold_r:
    if (CheckSkillArea(1480,690,1539,758,0xF1F18F) && HoldSkillTimes["r"]<MaxHoldAttempts){
        LastAction := "持續按住 R 鍵 (" . (HoldSkillTimes["r"]+1) . "/" . MaxHoldAttempts . ")"
        Send, {r}
        HoldSkillTimes["r"]++
    } else {
        SetTimer, CheckHold_r, Off
        HoldSkillTimes["r"] := 0
    }
return

ResetCasting:
    isCastingSkill := false
return

ShowCenteredToolTip(text,duration:="") {
    global ToolTipDuration
    duration := (duration="") ? ToolTipDuration : duration
    ToolTip, %text%, 960, 540
    SetTimer, RemoveToolTip, % -duration
}

RemoveToolTip:
    ToolTip
return

;-----------------------------------------------------------
;  實時狀態 GUI (精簡版)
;-----------------------------------------------------------
UpdateStatusDisplay:
    combatStatus := isInCombat ? "●戰鬥中" : "○非戰鬥"
    pauseStatus  := UserPaused ? "●手動暫停" : "○自動模式"
    modeStatus   := isBBQMode ? "●烤肉模式" : (isScriptPaused ? "○戰鬥暫停" : "○戰鬥模式")

    if (!IsStatusGUICreated) {
        Gui, StatusGUI:New
        Gui, StatusGUI:-Caption +AlwaysOnTop +ToolWindow +E0x20
        Gui, StatusGUI:Color, 0x121212
        Gui, StatusGUI:Font, cFFFFFF s10, Microsoft YaHei

        Gui, StatusGUI:Add, Text, x10 y10 w300 vStatusTextCtrl, % "腳本狀態: 運行中"
        Gui, StatusGUI:Add, Text, x10 y+2 w300 vCombatStatusCtrl, % "戰鬥狀態: " combatStatus
        Gui, StatusGUI:Add, Text, x10 y+2 w300 vCurrentActionCtrl, % "最近動作: " LastAction
        Gui, StatusGUI:Add, Text, x10 y+2 w300 vModeCtrl, % "當前模式: " modeStatus
        Gui, StatusGUI:Add, Text, x10 y+2 w300 vAutoAttackCtrl, % "自動普攻: " (isAutoAttack ? "● 開啟" : "○ 關閉")

        Gui, StatusGUI:Show, x%StatusDisplayX% y%StatusDisplayY% NoActivate, StatusOverlay
        WinSet, Transparent, 200, StatusOverlay
        IsStatusGUICreated := true
    } else {
        GuiControl, StatusGUI:, StatusTextCtrl, % "腳本狀態: " . (WinActive(gameWindow) ? "運行中" : "視窗未激活")
        GuiControl, StatusGUI:, CombatStatusCtrl, % "戰鬥狀態: " . combatStatus
        GuiControl, StatusGUI:, CurrentActionCtrl, % "最近動作: " . LastAction
        GuiControl, StatusGUI:, ModeCtrl, % "當前模式: " . modeStatus
    }
return

;-----------------------------------------------------------
;  GUI 關閉
;-----------------------------------------------------------
StartupGuiClose:
StatusGUIGuiClose:
ExitApp
return
