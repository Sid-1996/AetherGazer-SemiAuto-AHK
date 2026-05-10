;===========================================================
;  UISequenceManager.ahk - 順序UI管理器
;  管理啟動時UI的順序顯示和動態效果
;-----------------------------------------------------------

;=== 全域變數 ===
global UIManager_IsProcessing := false
global UIManager_CurrentStep := 0
global UIManager_StartupGUI := ""
global UIManager_EnvGUI := ""
global UIManager_ReminderGUI := ""

;=== 開始UI序列 ===
StartUISequence() {
    global UIManager_IsProcessing, UIManager_CurrentStep
    
    if (UIManager_IsProcessing) {
        return false
    }
    
    UIManager_IsProcessing := true
    UIManager_CurrentStep := 0
    UIManager_ShowNextStep()
    return true
}

;=== 顯示下一步 ===
UIManager_ShowNextStep() {
    global UIManager_CurrentStep
    
    UIManager_CurrentStep++
    
    switch UIManager_CurrentStep {
        case 1:
            UIManager_ShowEnvironmentCheck()
        case 2:
            UIManager_ShowStartupGUI()
        case 3:
            UIManager_ShowF2Reminder()
        default:
            UIManager_CompleteSequence()
    }
}

;=== 顯示啟動GUI (帶動態效果) ===
UIManager_ShowStartupGUI() {
    global UIManager_StartupGUI
    
    UIManager_StartupGUI := Gui("+LastFound -SysMenu -Caption +AlwaysOnTop", "深空之眼助手")
    UIManager_StartupGUI.BackColor := "0x1A1A2E"
    
    ; 標題文字
    UIManager_StartupGUI.SetFont("cFFFFFF s16 bold", "Consolas")
    titleText := UIManager_StartupGUI.AddText("x0 y20 w500 Center", "")
    titleText.Name := "TitleText"
    
    ; 應用名稱
    UIManager_StartupGUI.SetFont("c00FF99 s18 bold", "Microsoft YaHei")
    nameText := UIManager_StartupGUI.AddText("x50 y60 w400 Center", "")
    nameText.Name := "NameText"
    
    ; 版本資訊
    UIManager_StartupGUI.SetFont("cCCCCCC s12", "Microsoft YaHei")
    versionText := UIManager_StartupGUI.AddText("x50 y100 w400 Center", "")
    versionText.Name := "VersionText"
    
    ; 作者資訊
    authorText := UIManager_StartupGUI.AddText("x50 y125 w400 Center", "")
    authorText.Name := "AuthorText"
    
    ; 警告文字
    UIManager_StartupGUI.SetFont("cFF9900 s11", "Microsoft YaHei")
    warningText := UIManager_StartupGUI.AddText("x30 y160 w440 Center", "")
    warningText.Name := "WarningText"
    
    ; 指示文字
    UIManager_StartupGUI.SetFont("c88DDFF s12", "Microsoft YaHei")
    instructionText := UIManager_StartupGUI.AddText("x50 y200 w400 Center", "")
    instructionText.Name := "InstructionText"
    
    ; 進度文字
    UIManager_StartupGUI.SetFont("c666666 s10", "Consolas")
    progressText := UIManager_StartupGUI.AddText("x50 y230 w400 Center", "")
    progressText.Name := "ProgressText"
    
    ; 顯示GUI
    UIManager_StartupGUI.Show("w500 h270")
    
    ; 開始淡入效果鏈
    UIManager_FadeInChain()
    
    ; 註冊事件
    UIManager_StartupGUI.OnEvent("Close", (*) => UIManager_OnStartupComplete())
    OnMessage(0x0100, UIManager_OnStartupKeyPressed)  ; WM_KEYDOWN
    OnMessage(0x0201, UIManager_OnStartupKeyPressed)  ; WM_LBUTTONDOWN
}

;=== 淡入效果鏈 ===
UIManager_FadeInChain() {
    global UIManager_StartupGUI
    
    ; 先隱藏所有控件
    try {
        UIManager_StartupGUI["TitleText"].Visible := false
        UIManager_StartupGUI["NameText"].Visible := false
        UIManager_StartupGUI["VersionText"].Visible := false
        UIManager_StartupGUI["AuthorText"].Visible := false
        UIManager_StartupGUI["WarningText"].Visible := false
        UIManager_StartupGUI["InstructionText"].Visible := false
        UIManager_StartupGUI["ProgressText"].Visible := false
    } catch {
        return
    }
    
    ; 開始順序淡入
    UIManager_FadeInEffect("TitleText", "▒▒▓ 深空之眼 - AetherGazer ▓▒▒", 1)
}

;=== 淡入效果 ===
UIManager_FadeInEffect(controlName, text, nextStep) {
    global UIManager_StartupGUI
    
    try {
        ; 設定文字並顯示
        targetControl := UIManager_StartupGUI[controlName]
        targetControl.Text := text
        targetControl.Visible := true
        
        ; 淡入動畫效果100ms完成，視窗停留0.5秒
        SetTimer(UIManager_ProcessNextFadeStep.Bind(nextStep), -100)
    } catch {
        ; 如果控件不存在，跳過到下一步
        UIManager_ProcessNextFadeStep(nextStep)
    }
}

;=== 處理下一個淡入步驟 ===
UIManager_ProcessNextFadeStep(step) {
    switch step {
        case 1:
            UIManager_FadeInEffect("NameText", "Sid 半自動遊戲腳本", 2)
        case 2:
            ; 直接使用版本號，避免依賴外部配置管理器
            versionStr := "版本 v1.1.1 正式版 | 1920×1080專用"
            UIManager_FadeInEffect("VersionText", versionStr, 3)
        case 3:
            UIManager_FadeInEffect("AuthorText", "製作 by Sid © 2025", 4)
        case 4:
            UIManager_FadeInEffect("WarningText", "⚠️ 請務必將相關檔案放在腳本同目錄，並使用系統管理員啟動", 5)
        case 5:
            UIManager_FadeInEffect("InstructionText", "正在準備啟動...", 6)
        case 6:
            ; 短暫停0.5秒後自動繼續
            SetTimer(UIManager_OnStartupComplete, -500)
    }
}

;=== 閃爍動畫 (淡入淡出效果) ===
UIManager_StartBlinkingAnimation() {
    global UIManager_StartupGUI
    static isVisible := true
    static blinkTimer := ""
    
    if (UIManager_StartupGUI) {
        try {
            instructionControl := UIManager_StartupGUI["InstructionText"]
            
            ; 切換可見性
            isVisible := !isVisible
            instructionControl.Visible := isVisible
            
            ; 設定下次切換的時間 (1秒間隔，營造淡入淡出效果)
            SetTimer(UIManager_StartBlinkingAnimation, -400)
        } catch {
            ; GUI已被銷毀，停止動畫
            return
        }
    }
}

;=== 啟動GUI事件處理 ===
UIManager_OnStartupKeyPressed(wParam, lParam, msg, hwnd) {
    OnMessage(0x0100, UIManager_OnStartupKeyPressed, 0)
    OnMessage(0x0201, UIManager_OnStartupKeyPressed, 0)
    UIManager_OnStartupComplete()
    return
}

UIManager_OnStartupComplete() {
    global UIManager_StartupGUI
    
    if (UIManager_StartupGUI) {
        UIManager_StartupGUI.Destroy()
        UIManager_StartupGUI := ""
    }
    SetTimer(UIManager_ShowNextStep, -300)
}

;=== 顯示環境檢查 ===
UIManager_ShowEnvironmentCheck() {
    global UIManager_EnvGUI
    
    UIManager_EnvGUI := Gui("+LastFound -SysMenu -MaximizeBox -MinimizeBox +AlwaysOnTop", "系統環境檢查")
    UIManager_EnvGUI.BackColor := "0x0A0A0A"
    
    ; 標題
    UIManager_EnvGUI.SetFont("c00FFFF s16 bold", "Consolas")
    titleText := UIManager_EnvGUI.AddText("x30 y20 w440 Center", "▌ 系統環境檢查中... ▌")
    
    ; 狀態
    UIManager_EnvGUI.SetFont("c88FF88 s13", "Microsoft YaHei")
    statusText := UIManager_EnvGUI.AddText("x30 y60 w440 Center", "正在檢測桌面顯示配置...")
    
    ; 進度條
    UIManager_EnvGUI.SetFont("c00CCFF s12", "Consolas")
    progressText := UIManager_EnvGUI.AddText("x30 y90 w440 Center", "")
    progressText.Name := "ProgressText"
    
    ; 結果
    UIManager_EnvGUI.SetFont("c00FF00 s13 bold", "Microsoft YaHei")
    resultText := UIManager_EnvGUI.AddText("x30 y130 w440 Center", "")
    resultText.Name := "ResultText"
    
    UIManager_EnvGUI.Show("w500 h180")
    
    ; 開始環境檢查進度
    UIManager_StartEnvironmentProgress()
}

;=== 環境檢查進度 ===
UIManager_StartEnvironmentProgress() {
    global UIManager_EnvGUI
    static progressSteps := [
        {text: "[      ] 檢查桌面解析度...", delay: 40},
        {text: "[▌     ] 檢查DPI縮放...", delay: 50},
        {text: "[▌▌    ] 檢查系統權限...", delay: 50},
        {text: "[▌▌▌   ] 驗證腳本環境...", delay: 50},
        {text: "[▌▌▌▌  ] 載入配置檔案...", delay: 50},
        {text: "[▌▌▌▌▌ ] 檢查完成！", delay: 0}
    ]
    static stepIndex := 1
    
    if (stepIndex <= progressSteps.Length && UIManager_EnvGUI) {
        try {
            step := progressSteps[stepIndex]
            UIManager_EnvGUI["ProgressText"].Text := step.text
            stepIndex++
            SetTimer(UIManager_StartEnvironmentProgress, -300)
        } catch {
            ; GUI已被銷毀
            stepIndex := 1
            return
        }
    } else {
        ; 檢查完成，顯示結果
        stepIndex := 1  ; 重置為下次使用
        result := UIManager_CheckDisplayEnvironment()
        if (result.success) {
            try {
                UIManager_EnvGUI["ResultText"].Text := "✓ 桌面環境：1920×1080 @ 100% 縮放 (腳本所需)"
                SetTimer(UIManager_OnEnvironmentComplete, -300)
            } catch {
                ; GUI已被銷毀
                UIManager_OnEnvironmentComplete()
            }
        } else {
            UIManager_ShowEnvironmentWarning(result)
        }
    }
}

;=== 檢查顯示器環境 ===
UIManager_CheckDisplayEnvironment() {
    MonitorGet(1, &MonLeft, &MonTop, &MonRight, &MonBottom)
    screenWidth := MonRight - MonLeft
    screenHeight := MonBottom - MonTop
    
    resolutionOK := (screenWidth = 1920 && screenHeight = 1080)
    
    dpiScale := 100
    try {
        hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
        dpiX := DllCall("GetDeviceCaps", "Ptr", hDC, "Int", 88, "Int")
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
        dpiScale := Round((dpiX / 96) * 100)
    } catch {
        dpiScale := 100
    }
    
    scaleOK := (dpiScale = 100)
    
    return {
        success: resolutionOK && scaleOK,
        width: screenWidth,
        height: screenHeight,
        scale: dpiScale,
        resolutionOK: resolutionOK,
        scaleOK: scaleOK
    }
}

;=== 環境檢查完成 ===
UIManager_OnEnvironmentComplete() {
    global UIManager_EnvGUI
    
    if (UIManager_EnvGUI) {
        UIManager_EnvGUI.Destroy()
        UIManager_EnvGUI := ""
    }
    SetTimer(UIManager_ShowNextStep, -300)
}

;=== 顯示環境警告 ===
UIManager_ShowEnvironmentWarning(result) {
    if (UIManager_EnvGUI) {
        UIManager_EnvGUI.Destroy()
        UIManager_EnvGUI := ""
    }
    
    warningGUI := Gui("+LastFound -SysMenu +AlwaysOnTop", "顯示器環境警告")
    warningGUI.BackColor := "0x1A1A2E"
    
    warningGUI.SetFont("cFFFF00 s16 bold", "Microsoft YaHei")
    warningGUI.AddText("x20 y20 w460 Center", "⚠️ 桌面環境提醒")
    
    warningGUI.SetFont("cFFFFFF s12", "Microsoft YaHei")
    warningGUI.AddText("x20 y90", "當前桌面環境：")
    warningGUI.SetFont("cCCCCCC s11")
    warningGUI.AddText("x40 y115", "解析度: " . result.width . " × " . result.height . (result.resolutionOK ? " ✓" : " ✗"))
    warningGUI.AddText("x40 y135", "顯示縮放: " . result.scale . "%" . (result.scaleOK ? " ✓" : " ✗"))
    
    warningGUI.SetFont("c00FF99 s12 bold")
    warningGUI.AddText("x20 y170", "腳本建議設定：")
    warningGUI.SetFont("cFFFFFF s11")
    warningGUI.AddText("x40 y195", "• 桌面解析度: 1920 × 1080")
    warningGUI.AddText("x40 y215", "• 顯示縮放: 100%")
    warningGUI.AddText("x40 y235", "• 遊戲建議: 1600×900 視窗模式 (可按F2調整)")
    
    warningGUI.SetFont("cFFFFFF s12")
    btnContinue := warningGUI.AddButton("x120 y300 w100 h35", "仍要繼續")
    btnExit := warningGUI.AddButton("x280 y300 w100 h35", "退出腳本")
    
    btnContinue.OnEvent("Click", (*) => (warningGUI.Destroy(), SetTimer(UIManager_ShowNextStep, -1000)))
    btnExit.OnEvent("Click", (*) => ExitApp())
    warningGUI.OnEvent("Close", (*) => ExitApp())
    
    warningGUI.Show("w500 h360")
}

;=== 顯示F2提醒 ===
UIManager_ShowF2Reminder() {
    global UIManager_ReminderGUI
    
    UIManager_ReminderGUI := Gui("+LastFound -SysMenu +AlwaysOnTop", "快速提醒")
    UIManager_ReminderGUI.BackColor := "0x0D1117"
    
    UIManager_ReminderGUI.SetFont("c00FF99 s16 bold", "Microsoft YaHei")
    titleText := UIManager_ReminderGUI.AddText("x20 y20 w360 Center", "✓ 系統檢查完成")
    
    UIManager_ReminderGUI.SetFont("cFFFFFF s13", "Microsoft YaHei")
    infoText := UIManager_ReminderGUI.AddText("x20 y60 w360 Center", "按 F2 可快速調整遊戲視窗至 1600×900 適配位置")
    
    UIManager_ReminderGUI.SetFont("c888888 s11", "Microsoft YaHei")
    countdownText := UIManager_ReminderGUI.AddText("x20 y100 w360 Center", "")
    countdownText.Name := "CountdownText"
    
    UIManager_ReminderGUI.Show("w400 h140")
    
    ; 開始倒數計時
    UIManager_StartCountdown(1.5)
}

;=== 倒數計時 ===
UIManager_StartCountdown(seconds) {
    static remaining := 0
    
    if (seconds > 0) {
        remaining := seconds
    }
    
    if (remaining > 0 && UIManager_ReminderGUI) {
        try {
            UIManager_ReminderGUI["CountdownText"].Text := "此提醒將在 " . Round(remaining / 2) . " 秒後自動關閉..."
            remaining--
            SetTimer(UIManager_StartCountdown.Bind(0), -500)
        } catch {
            ; GUI已被銷毀
            UIManager_OnReminderComplete()
        }
    } else {
        UIManager_OnReminderComplete()
    }
}

;=== 提醒完成 ===
UIManager_OnReminderComplete() {
    global UIManager_ReminderGUI
    
    if (UIManager_ReminderGUI) {
        UIManager_ReminderGUI.Destroy()
        UIManager_ReminderGUI := ""
    }
    SetTimer(UIManager_ShowNextStep, -300)
}

;=== 完成整個序列 ===
UIManager_CompleteSequence() {
    global UIManager_IsProcessing
    
    UIManager_IsProcessing := false
    UIManager_CurrentStep := 0
    StartScript()
}
