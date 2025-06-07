;===========================================================
;  深空之眼 ‧ Sid半自動遊戲腳本 v3.0 
;-----------------------------------------------------------
;  作者：Sid
;  版本：3.0
;  電腦螢幕解析度：1920*1080
;  遊戲視窗解析度：1600*900
;-----------------------------------------------------------
;  功能說明：
;    - 半自動戰鬥偵測與不智能的技能連招 (亮哪點哪)
;    - BBQ自動化功能（依圖像辨識切換）
;    - 戰鬥狀態即時顯示與操作介面
;    - 支援手動快速切換（F4鍵）
;-----------------------------------------------------------
;  按鍵功能說明：
;    F1  - 自動普攻開關（啟動或停止自動普攻）
;    F2  - 快速更換遊戲解析度至1600×900 並置中（符合腳本偵測環境）
;    F4  - 手動切換戰鬥偵測狀態（可靈活控制戰鬥）
;    F6  - 啟動或停止自動休閒烤肉功能（圖像辨識觸發）
;    F11 - 重啟腳本（遇到異常或錯誤時使用）
;    F12 - 退出並關閉腳本
;-----------------------------------------------------------
;  使用說明：
;    1. 啟動腳本後，請先確保遊戲解析度為1600×900（可按F2自動調整）
;    2. 於啟動畫面按任意鍵開始腳本運作
;    3. 使用F1開關自動普攻功能，F4可手動切換戰鬥狀態
;    4. 遇異常時，請按F11重啟腳本或遊戲
;    5. 使用F12安全退出腳本
;-----------------------------------------------------------
;  注意事項：
;    - 
;    -                                       謝謝你的注意!
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
global isScriptPaused     := false   ; 腳本是否暫停（手動切換狀態）
global isAutoAttack       := false   ; 是否啟用自動普攻（可擴展使用）
global isCastingSkill     := false   ; 是否正在施放技能（防止技能重疊觸發）
global isBBQMode          := false   ; BBQ 模式是否啟用（停用一般戰鬥邏輯）
global isInCombat         := false   ; 是否處於戰鬥狀態（由圖像判定）
global gameWindow         := "AetherGazer" ; 目標遊戲視窗標題
global QE_Priority        := 0       ; QE 技能優先級（數字越大代表優先）
global LastSkillTime      := 0       ; 上次施放技能的時間戳（毫秒）
global StatusText         := "等待戰鬥開始..." ; 狀態欄顯示的文字
global ToolTipDuration    := 1000    ; ToolTip 顯示時長（毫秒）
global LastHotkeyPress    := 0       ; 上次按下熱鍵（F4、F8等）的時間戳
global ColorVariation     := 15      ; 顏色容差（用於 Pixel/Color 偵測時的容錯）
global IsStatusGUICreated := false   ; 狀態 GUI 是否已建立（避免重複建立）
global StartupGUI         := true    ; 啟動時是否顯示 GUI
global StatusDisplayX     := 10      ; 狀態顯示 GUI 的 X 座標
global StatusDisplayY     := 10      ; 狀態顯示 GUI 的 Y 座標
global CombatCheckImage   := A_ScriptDir . "\戰鬥判定.png" ; 用於判定戰鬥的圖片路徑
global UserPaused         := false   ; 使用者手動暫停腳本的旗標
global SkillLockTime      := 800     ; 技能鎖定時間（施放後禁止再次施放，毫秒）
global LastDetectedSkill  := ""      ; 上次被判定的技能（用於去重與狀態控制）
global HoldSkillTimes     := {}      ; 技能長按時間記錄（字典結構，如 {q:0, e:0}）
global MaxHoldAttempts    := 5       ; 長按技能時的最大重試次數
global HoldInterval       := 80      ; 長按技能的嘗試間隔（毫秒）

;=== 技能狀態 ===
global Q_Ready := false
global E_Ready := false
global R_Ready := false
global F_Ready := false

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
    Gui, Startup:Add, Text, x20 y80  w360 Center, 版本 v3.0 | 1600×900專用
    Gui, Startup:Add, Text, x20 y110 w360 Center, 製作 by Sid
    Gui, Startup:Font, cFF9900 s9
    Gui, Startup:Add, Text, x20 y150 w360 Center, ⚠️ 請將「戰鬥判定.png」放在腳本同目錄
    Gui, Startup:Font, cFFFFFF s10
    Gui, Startup:Add, Text, x20 y190 w360 Center, 按任意鍵開始自動偵測...
    Gui, Startup:Show, w400 h230, 深空之眼助手
    ; 使用任何鍵啟動
OnMessage(0x0100, "StartupKeyPressed")  ; 0x0100 = WM_KEYDOWN
return

StartupKeyPressed(wParam, lParam, msg, hwnd) {
    global StartupGUI
    if (StartupGUI) {
        Gui, Startup:Destroy
        StartupGUI := false
        OnMessage(0x0100, "")  ; 停止監聽
        ShowCenteredToolTip("腳本已加載`n正在初始化戰鬥偵測...", 2000)
        SetTimer, CombatDetection, 500
        SetTimer, CombatLoop, 20
        SetTimer, UpdateStatusDisplay, 50
    }
    return
}


CloseStartupGUI:
    if (StartupGUI && (A_TimeIdle < 100)) {
        Gui, Startup:Destroy
        StartupGUI := false
        ShowCenteredToolTip("腳本已加載`n正在初始化戰鬥偵測...", 2000)
        SetTimer, CombatDetection, 500
        SetTimer, CombatLoop,      20
        SetTimer, UpdateStatusDisplay, 50
    }
return

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
                ShowCenteredToolTip("偵測到戰鬥！自動恢復戰鬥模式", 1000)
            }
            StatusText := "戰鬥狀態：進行中"
        }
    } else if (isInCombat) {
        isInCombat := false
        StatusText := "戰鬥狀態：已結束"
    }
return

;-----------------------------------------------------------
;  戰鬥核心循環
;-----------------------------------------------------------
CombatLoop:
    ; 1) 若在烤肉模式，停止一般戰鬥邏輯
    if (isBBQMode) {
        StatusText := "烤肉模式運行中"
        return
    }

    ; 2) 移動偵測
    isMoving := GetKeyState("w","P") || GetKeyState("a","P") || GetKeyState("s","P") || GetKeyState("d","P")

    ; 3) 戰鬥與暫停判定
    if (!isInCombat || isScriptPaused || !WinActive(gameWindow) || isMoving)
        return

    ; 4) 技能保護期
    isInProtection := (A_TickCount - LastSkillTime < SkillLockTime)

    ; 5) 技能連按
    if (!isCastingSkill || (A_TickCount - LastSkillTime > HoldInterval)) {

        ; (R) 最高優先
        if (CheckSkillArea(1480,690,1539,758,0xF1F18F)) {
            CastSkill("r", 100)
            StatusText := "R技能連按中 (" HoldSkillTimes["r"] "/" MaxHoldAttempts ")"
            return
        }

        ; (F)
        else if (CheckSkillArea(1384,772,1462,851,0xF1F18F)) {
            CastSkill("f", 100)
            StatusText := "F技能連按中 (" HoldSkillTimes["f"] "/" MaxHoldAttempts ")"
            return
        }

        ; (Q/E) 判定＋優先順序
        Q_Ready := CheckSkillArea(1232,770,1304,850,0xF1F18F)
        E_Ready := CheckSkillArea(1308,768,1386,866,0xF1F18F)

        if (Q_Ready && E_Ready) {
            skill := QE_Priority ? "e" : "q"
            CastSkill(skill, 100)
            StatusText := (QE_Priority ? "E" : "Q") "技能連按中 (" HoldSkillTimes[skill] "/" MaxHoldAttempts ")"
            return
        } else if (Q_Ready) {
            CastSkill("q", 100)
            StatusText := "Q技能連按中 (" HoldSkillTimes["q"] "/" MaxHoldAttempts ")"
            return
        } else if (E_Ready) {
            CastSkill("e", 100)
            StatusText := "E技能連按中 (" HoldSkillTimes["e"] "/" MaxHoldAttempts ")"
            return
        }
    }

    ; 6) 自動普攻
    if (!isCastingSkill && !isInProtection && isAutoAttack && !GetKeyState("LButton","P")) {
        Click
        Sleep, 15
        StatusText := "自動普攻中..."
    }
return

;-----------------------------------------------------------
;  新增 F6 - ImageSearch 烤肉模式（LOOP版，不用計時器）
;  - F6 首次按下：啟用迴圈烤肉
;  - F6 再次按下：立即退出烤肉迴圈並恢復一般戰鬥
;-----------------------------------------------------------
F6::
    ; 消抖
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    ; 若已在烤肉模式 → 退出
    if (isBBQMode) {
        isBBQMode := false             ; 讓下方迴圈偵測到並 break
        return
    }

    ; 啟用烤肉模式
    isBBQMode     := true
    isScriptPaused := true
    ShowCenteredToolTip("● 烤肉模式啟用 (ImageSearch)", 1200)
    StatusText := "烤肉模式運行中"

    CoordMode, Pixel, Window
    Loop
    {
        ; 檢查是否手動關閉
        if (!isBBQMode)
            break

        ; 確保遊戲視窗仍在前景
        if (!WinActive(gameWindow)) {
            Sleep, 50
            continue
        }

        ;── 烤肉「紅」判定 ─────────────────────────
        ImageSearch, FoundX, FoundY, 811, 188, 874, 237, *100 %A_ScriptDir%\烤肉紅判定.png
        if (ErrorLevel = 0) {
            Send, {e}
            Sleep, 100
            continue
        }

        ;── 烤肉「藍」判定 ─────────────────────────
        ImageSearch, FoundX, FoundY, 811, 188, 874, 237, *100 %A_ScriptDir%\烤肉藍判定.png
        if (ErrorLevel = 0) {
            Send, {q}
            Sleep, 100
            continue
        }

        Sleep, 10
    }

    ; 退出迴圈後：恢復一般模式
    ShowCenteredToolTip("○ 烤肉模式關閉", 1200)
    StatusText      := "等待指令..."
    isScriptPaused  := false
return

;-----------------------------------------------------------
;  其餘熱鍵（F1/F2/F4/F11/F12）與輔助函數維持原狀
;-----------------------------------------------------------

F2::
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount

    WinGet, activeWindow, ID, A
    if (!activeWindow) {
        ShowCenteredToolTip("找不到遊戲視窗!", 1500)
        return
    }
    SysGet, screenWorkArea, MonitorWorkArea
    posX := (screenWorkAreaRight  - screenWorkAreaLeft  - 1600)//2
    posY := (screenWorkAreaBottom - screenWorkAreaTop   - 900)//2
    WinRestore, ahk_id %activeWindow%
    WinMove,    ahk_id %activeWindow%, , posX, posY, 1600, 900
    WinActivate, ahk_id %activeWindow%
    ShowCenteredToolTip("視窗已重置為 1600x900 並置中", 1500)
return

F1::
    isAutoAttack := !isAutoAttack
    ; 若 GUI 已經建立則即時更新文字
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
        ShowCenteredToolTip("手動暫停中（戰鬥時自動恢復）", 1200)
        StatusText := "手動暫停中"
    } else {
        isScriptPaused := false
        isCastingSkill := false
        ShowCenteredToolTip("已恢復自動模式", 1200)
        StatusText := "等待戰鬥指令..."
    }
return

~*F::
    if (A_TickCount - LastHotkeyPress < 300)
        return
    LastHotkeyPress := A_TickCount
    QE_Priority := !QE_Priority
    ShowCenteredToolTip("技能優先級: " (QE_Priority ? "E > Q" : "Q > E"), 1200)
    StatusText := "切換優先級: " (QE_Priority ? "E技能優先" : "Q技能優先")
return

F11::Reload
F12::ExitApp

;-----------------------------------------------------------
;  輔助函數
;-----------------------------------------------------------
CheckSkillArea(x1,y1,x2,y2,color) {
    PixelSearch, FoundX, FoundY, x1, y1, x2, y2, color, %ColorVariation%, Fast RGB
    return (ErrorLevel==0)
}

CastSkill(key,duration) {
    global isCastingSkill, LastSkillTime, HoldSkillTimes
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
        Send, {q}
        HoldSkillTimes["q"]++
    } else {
        SetTimer, CheckHold_q, Off
        HoldSkillTimes["q"] := 0
    }
return

CheckHold_e:
    if (CheckSkillArea(1308,768,1386,866,0xF1F18F) && HoldSkillTimes["e"]<MaxHoldAttempts){
        Send, {e}
        HoldSkillTimes["e"]++
    } else {
        SetTimer, CheckHold_e, Off
        HoldSkillTimes["e"] := 0
    }
return

CheckHold_f:
    if (CheckSkillArea(1384,772,1462,851,0xF1F18F) && HoldSkillTimes["f"]<MaxHoldAttempts){
        Send, {f}
        HoldSkillTimes["f"]++
    } else {
        SetTimer, CheckHold_f, Off
        HoldSkillTimes["f"] := 0
    }
return

CheckHold_r:
    if (CheckSkillArea(1480,690,1539,758,0xF1F18F) && HoldSkillTimes["r"]<MaxHoldAttempts){
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
;  實時狀態 GUI
;-----------------------------------------------------------
UpdateStatusDisplay:
    combatStatus := isInCombat ? "●戰鬥中" : "○非戰鬥"
    pauseStatus  := UserPaused  ? "●手動暫停" : "○自動模式"

    R_Ready := CheckSkillArea(1480,690,1539,758,0xF1F18F)
    F_Ready := CheckSkillArea(1384,772,1462,851,0xF1F18F)
    Q_Ready := CheckSkillArea(1232,770,1304,850,0xF1F18F)
    E_Ready := CheckSkillArea(1308,768,1386,866,0xF1F18F)

    skillStatus := "技能就緒: "
    skillStatus .= Q_Ready ? "●Q " : "○Q "
    skillStatus .= E_Ready ? "●E " : "○E "
    skillStatus .= R_Ready ? "●R " : "○R "
    skillStatus .= F_Ready ? "●F"  : "○F"

    modeStatus := isBBQMode ? "●烤肉模式" : (isScriptPaused ? "○戰鬥暫停" : "○戰鬥模式")

    if (!IsStatusGUICreated) {
        Gui, StatusGUI:New
        Gui, StatusGUI:-Caption +AlwaysOnTop +ToolWindow +E0x20  ; +E0x20 = 點擊穿透
        Gui, StatusGUI:Color, 0x121212  ; 黑底
        Gui, StatusGUI:Font, cFFFFFF s10, Microsoft YaHei  ; 白字

        Gui, StatusGUI:Add, Text, x10 y10  w300 vStatusTextCtrl,    % "狀態: " StatusText
        Gui, StatusGUI:Add, Text, x10 y+2  w300 vCombatStatusCtrl,  % "戰鬥狀態: " combatStatus
        Gui, StatusGUI:Add, Text, x10 y+2  w300 vSkillStatusCtrl,   % skillStatus
        Gui, StatusGUI:Add, Text, x10 y+8  w300 vModeCtrl,          % "模式: " modeStatus
        Gui, StatusGUI:Add, Text, x10 y+2  w300 vPriorityCtrl,      % "優先級: " (QE_Priority ? "E技能 > Q技能" : "Q技能 > E技能")
        Gui, StatusGUI:Add, Text, x10 y+2  w300 vAutoAttackCtrl,    % "自動普攻: " (isAutoAttack ? "● 開啟" : "○ 關閉")
        Gui, StatusGUI:Show, x%StatusDisplayX% y%StatusDisplayY% NoActivate, StatusOverlay

        ; 設定半透明程度（可調整 0~255）
        WinSet, Transparent, 180, StatusOverlay

        IsStatusGUICreated := true
    } else {
        GuiControl, StatusGUI:, StatusTextCtrl,   % "狀態: " StatusText
        GuiControl, StatusGUI:, CombatStatusCtrl, % "戰鬥狀態: " combatStatus
        GuiControl, StatusGUI:, SkillStatusCtrl,  % skillStatus
        GuiControl, StatusGUI:, ModeCtrl,         % "模式: " modeStatus
        GuiControl, StatusGUI:, PriorityCtrl,     % "優先級: " (QE_Priority ? "E技能 > Q技能" : "Q技能 > E技能")
        GuiControl, StatusGUI:, AutoAttackCtrl,   % "自動普攻: " (isAutoAttack ? "● 開啟" : "○ 關閉")
    }
return

;-----------------------------------------------------------
;  GUI 關閉
;-----------------------------------------------------------
StartupGuiClose:
StatusGUIGuiClose:
ExitApp
return
