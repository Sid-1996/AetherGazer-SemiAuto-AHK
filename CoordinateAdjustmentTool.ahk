#Requires AutoHotkey v2.0
#SingleInstance Force
#Include src\ProjectPaths.ahk
SetWorkingDir(PROJECT_ROOT)
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Window")

;===========================================================
;  深空之眼 - 座標調整工具 v1.0
;  Coordinate Adjustment Tool for Aether Gazer
;-----------------------------------------------------------
;  功能：視覺化調整圖片辨識座標範圍
;  快捷鍵：
;    F8  - 進入/退出調整模式
;    F9  - 保存調整後的座標
;    F10 - 載入已保存的座標配置
;    Esc - 退出工具
;===========================================================

; === 全域變數 ===
global targetTitle := "AetherGazer"
global isAdjustmentMode := false
global adjustmentGUI := ""
global currentRects := Map()
global overlayWindows := Map()
global imagePreviews := Map()
global selectedRect := ""
global currentSelectedCoordId := ""  ; 當前選擇項目的coordId
global dragStartX := 0
global dragStartY := 0
global isDragging := false
global dragOffsetX := 0
global dragOffsetY := 0

; === 座標配置數據結構 ===
; 座標數據：按ID分組，允許項目共享座標
global coordData := Map(
    "battle_check", [88, 853, 150, 888],
    "bbq_red", [811, 188, 874, 237],  ; 紅藍判定共享
    "hunyu_f1", [1045, 684, 1565, 880],  ; F1和E技能共享
    "hunyu_f2", [1043, 748, 1170, 868],
    "faran_q", [1162, 764, 1468, 885],   ; 多個緋染技能共享
    "faran_f_end", [688, 742, 917, 793],
    "qiaogu_q", [1156, 748, 1558, 883], ; 多個巧构技能共享
    "qiaogu_energy", [938, 840, 962, 847], ; 巧构能量像素檢測
    "gengchen_q", [1219, 768, 1462, 881] ; 庚辰Q和Q1共享
)

; 每個辨識項目的定義，包含：名稱、圖片路徑、座標ID、說明、類型
global recognitionItems := [
    {name: "戰鬥判定", image: CommonAssetPath("戰鬥判定.png"), coordId: "battle_check", desc: "戰鬥狀態判定區域", type: "image"},
    {name: "烤肉紅判定", image: CommonAssetPath("烤肉紅判定.png"), coordId: "bbq_red", desc: "烤肉模式紅色判定", type: "image"},
    {name: "烤肉藍判定", image: CommonAssetPath("烤肉藍判定.png"), coordId: "bbq_red", desc: "烤肉模式藍色判定", type: "image"},  ; 共享bbq_red座標

    ; 魂羽角色
    {name: "魂羽F1", image: CharacterAssetPath("魂羽", "魂羽F判定1.png"), coordId: "hunyu_f1", desc: "魂羽F技能判定1", type: "image"},
    {name: "魂羽E", image: CharacterAssetPath("魂羽", "魂羽E判定.png"), coordId: "hunyu_f1", desc: "魂羽E技能判定", type: "image"},  ; 共享hunyu_f1座標
    {name: "魂羽F2", image: CharacterAssetPath("魂羽", "魂羽F判定2.png"), coordId: "hunyu_f2", desc: "魂羽F技能判定2", type: "image"},

    ; 緋染角色
    {name: "緋染Q", image: CharacterAssetPath("緋染", "緋染Q.png"), coordId: "faran_q", desc: "緋染Q技能", type: "image"},
    {name: "緋染Q1", image: CharacterAssetPath("緋染", "緋染Q1.png"), coordId: "faran_q", desc: "緋染Q1技能", type: "image"},  ; 共享faran_q座標
    {name: "緋染E", image: CharacterAssetPath("緋染", "緋染E.png"), coordId: "faran_q", desc: "緋染E技能", type: "image"},   ; 共享faran_q座標
    {name: "緋染E1", image: CharacterAssetPath("緋染", "緋染E1.png"), coordId: "faran_q", desc: "緋染E1技能", type: "image"}, ; 共享faran_q座標
    {name: "緋染F", image: CharacterAssetPath("緋染", "緋染F.png"), coordId: "faran_q", desc: "緋染F技能", type: "image"},   ; 共享faran_q座標
    {name: "緋染F_End", image: CharacterAssetPath("緋染", "緋染F End.png"), coordId: "faran_f_end", desc: "緋染F結束判定", type: "image"},

    ; 巧构角色
    {name: "巧构Q", image: CharacterAssetPath("巧构", "巧构Q.png"), coordId: "qiaogu_q", desc: "巧构Q技能", type: "image"},
    {name: "巧构F", image: CharacterAssetPath("巧构", "巧构F.png"), coordId: "qiaogu_q", desc: "巧构F技能", type: "image"},   ; 共享qiaogu_q座標
    {name: "巧构Q1", image: CharacterAssetPath("巧构", "巧构Q1.png"), coordId: "qiaogu_q", desc: "巧构Q1技能", type: "image"}, ; 共享qiaogu_q座標
    {name: "巧构E1", image: CharacterAssetPath("巧构", "巧构E1.png"), coordId: "qiaogu_q", desc: "巧构E1技能", type: "image"}, ; 共享qiaogu_q座標
    {name: "巧构能量檢測", image: "", coordId: "qiaogu_energy", desc: "巧构連段所需能量判定區域", type: "pixel"}, ; 像素搜索

    ; 庚辰角色
    {name: "庚辰Q", image: CharacterAssetPath("庚辰", "庚辰Q.png"), coordId: "gengchen_q", desc: "庚辰Q技能", type: "image"},
    {name: "庚辰Q1", image: CharacterAssetPath("庚辰", "庚辰Q1.png"), coordId: "gengchen_q", desc: "庚辰Q1技能", type: "image"} ; 共享gengchen_q座標
]

; === 工具函數 ===

; 顯示提示訊息
ShowMsg(text, duration := 2000) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -duration)
}

; 檢查遊戲視窗標題
CheckGameWindowTitle() {
    windows := WinGetList()
    found := false
    for hwnd in windows {
        title := WinGetTitle("ahk_id " . hwnd)
        ; 排除我們的工具視窗
        if ((InStr(title, "Aether") || InStr(title, "深空") || InStr(title, "Gaz")) && !InStr(title, "座標調整工具")) {
            ShowMsg("找到遊戲視窗: " . title)
            found := true
        }
    }
    if (!found) {
        ShowMsg("未找到遊戲視窗，請確保遊戲已啟動")
    }
}

; 取得遊戲視窗資訊
GetGameWindowInfo() {
    ; 首先嘗試精確匹配遊戲視窗（排除我們的工具視窗）
    gameHwnd := 0
    windows := WinGetList()

    for hwnd in windows {
        title := WinGetTitle("ahk_id " . hwnd)
        ; 排除包含"座標調整工具"的視窗，這些是我們的工具視窗
        if (InStr(title, targetTitle) && !InStr(title, "座標調整工具")) {
            gameHwnd := hwnd
            break
        }
    }

    if (!gameHwnd) {
        ShowMsg("找不到遊戲視窗: " . targetTitle . "`n請確保遊戲已啟動且視窗標題正確")
        return false
    }

    ; 獲取視窗位置和大小
    WinGetPos(&winX, &winY, &winW, &winH, "ahk_id " . gameHwnd)

    ; 獲取客戶區資訊
    rect := Buffer(16)
    DllCall("user32.dll\GetClientRect", "Ptr", gameHwnd, "Ptr", rect)
    clientW := NumGet(rect, 8, "Int")
    clientH := NumGet(rect, 12, "Int")

    ; 計算客戶區原點（螢幕座標）
    pt := Buffer(8)
    NumPut("Int", 0, pt, 0)
    NumPut("Int", 0, pt, 4)
    DllCall("user32.dll\ClientToScreen", "Ptr", gameHwnd, "Ptr", pt)
    clientX := NumGet(pt, 0, "Int")
    clientY := NumGet(pt, 4, "Int")

    ; 調試信息 - 只在開發時啟用
    ; ShowMsg(Format("視窗資訊: 位置({},{}) 大小({}x{}) 客戶區({},{})", winX, winY, winW, winH, clientW, clientH))

    return {
        hwnd: gameHwnd,
        winX: winX, winY: winY, winW: winW, winH: winH,
        clientX: clientX, clientY: clientY, clientW: clientW, clientH: clientH
    }
}

; 螢幕座標轉客戶區座標
ScreenToClient(screenX, screenY) {
    info := GetGameWindowInfo()
    if (!info)
        return {x: 0, y: 0, error: true}  ; 返回錯誤標記

    clientX := screenX - info.clientX
    clientY := screenY - info.clientY

    return {x: clientX, y: clientY}
}

; 客戶區座標轉螢幕座標
ClientToScreen(clientX, clientY) {
    info := GetGameWindowInfo()
    if (!info)
        return {x: 0, y: 0, error: true}  ; 返回錯誤標記

    screenX := clientX + info.clientX
    screenY := clientY + info.clientY

    return {x: screenX, y: screenY}
}

; 創建覆蓋視窗（半透明紅色框）
CreateOverlay(name, x, y, w, h) {
    global overlayWindows
    local guiObj
    if (overlayWindows.Has(name)) {
        try overlayWindows[name].Destroy()
    }

    ; 獲取遊戲視窗資訊
    info := GetGameWindowInfo()
    if (!info)
        return 0

    ; 如果座標超出邊界，將覆蓋框放置在視窗中心
    if (x < 0 || y < 0 || x + w > info.clientW || y + h > info.clientH) {
        x := (info.clientW - w) // 2
        y := (info.clientH - h) // 2
        ; 確保不超出邊界
        if (x < 0) {
            x := 0
        }
        if (y < 0) {
            y := 0
        }
        if (x + w > info.clientW) {
            x := info.clientW - w
        }
        if (y + h > info.clientH) {
            y := info.clientH - h
        }
    }

    ; 將客戶區座標轉換為螢幕座標來顯示覆蓋框
    screenPos := {x: 0, y: 0, error: true}  ; 預設錯誤值
    screenPos := ClientToScreen(x, y)
    if (screenPos.HasOwnProp("error")) {
        ShowMsg("座標轉換失敗: " . name)
        return 0
    }

    ; 調試信息 - 只在開發時啟用
    ; ShowMsg(Format("創建覆蓋框 {}: 客戶區({},{}) -> 螢幕({},{}) 大小({}x{})", name, x, y, screenPos.x, screenPos.y, w, h))

    ; 創建GUI
    guiObj := Gui("+LastFound -Caption +AlwaysOnTop +ToolWindow")
    guiObj.BackColor := "Red"
    guiObj.Add("Text", "x0 y0 w" . w . " h" . h)

    ; 顯示視窗 - 使用螢幕座標
    guiObj.Show("x" . screenPos.x . " y" . screenPos.y . " w" . w . " h" . h . " NoActivate")

    ; 設置透明度（必須在Show之後）
    WinSetTransparent(100, "ahk_id " . guiObj.Hwnd)

    overlayWindows[name] := guiObj
    return true
}

; 銷毀所有覆蓋視窗
DestroyAllOverlays() {
    global overlayWindows
    for name, window in overlayWindows {
        try window.Destroy()
    }
    overlayWindows.Clear()
}

; 重新整理所有覆蓋視窗
RefreshOverlays() {
    global currentRects
    DestroyAllOverlays()

    for coordId, rect in currentRects {
        x := rect.x1
        y := rect.y1
        w := rect.x2 - rect.x1
        h := rect.y2 - rect.y1

        if (w > 0 && h > 0) {
            CreateOverlay(coordId, x, y, w, h)
        }
    }
}

; 顯示單個覆蓋視窗
ShowSingleOverlay(selectedItem) {
    global currentRects, recognitionItems, overlayWindows

    ; 找到對應的coordId
    selectedCoordId := ""
    for item in recognitionItems {
        if (item.name = selectedItem) {
            selectedCoordId := item.coordId
            break
        }
    }

    if (selectedCoordId = "" || !currentRects.Has(selectedCoordId)) {
        return
    }

    DestroyAllOverlays()

    rect := currentRects[selectedCoordId]
    x := rect.x1
    y := rect.y1
    w := rect.x2 - rect.x1
    h := rect.y2 - rect.y1

    if (w > 0 && h > 0) {
        CreateOverlay(selectedCoordId, x, y, w, h)
    }
}

; 載入座標配置
LoadCoordinates() {
    global currentRects, coordData, recognitionItems
    configFile := ConfigPath("coordinates_config.json")

    ; 舊coordId到新coordId的映射表（處理配置文件兼容性）
    coordIdMapping := Map(
        "bbq_blue", "bbq_red",
        "hunyu_e", "hunyu_f1",
        "faran_q1", "faran_q",
        "faran_e", "faran_q",
        "faran_e1", "faran_q",
        "faran_f", "faran_q",
        "qiaogu_f", "qiaogu_q",
        "qiaogu_q1", "qiaogu_q",
        "qiaogu_e1", "qiaogu_q",
        "gengchen_q1", "gengchen_q"
    )

    if (!FileExist(configFile)) {
        ; 使用預設座標
        for coordId, coords in coordData {
            currentRects[coordId] := {
                x1: coords[1],
                y1: coords[2],
                x2: coords[3],
                y2: coords[4]
            }
        }
        ShowMsg("使用預設座標配置")
        return true
    }

    try {
        file := FileOpen(configFile, "r", "UTF-8")
        jsonText := file.Read()
        file.Close()

        ; 簡單的JSON解析（只處理我們的格式）
        jsonText := RegExReplace(jsonText, '^\s*\[|\]\s*$', '')
        items := StrSplit(jsonText, '},{')

        for itemText in items {
            itemText := RegExReplace(itemText, '^\s*{\s*|\s*}\s*$', '')
            if (itemText = "")
                continue

            ; 提取coordId和座標
            coordIdMatch := RegExMatch(itemText, '"coordId"\s*:\s*"([^"]+)"', &coordId)
            x1Match := RegExMatch(itemText, '"x1"\s*:\s*(\d+)', &x1)
            y1Match := RegExMatch(itemText, '"y1"\s*:\s*(\d+)', &y1)
            x2Match := RegExMatch(itemText, '"x2"\s*:\s*(\d+)', &x2)
            y2Match := RegExMatch(itemText, '"y2"\s*:\s*(\d+)', &y2)

            if (coordIdMatch && x1Match && y1Match && x2Match && y2Match) {
                actualCoordId := coordId[1]

                ; 應用映射表，將舊的coordId映射到新的coordId
                if (coordIdMapping.Has(actualCoordId)) {
                    actualCoordId := coordIdMapping[actualCoordId]
                }

                ; 只載入我們認識的coordId
                if (coordData.Has(actualCoordId)) {
                    currentRects[actualCoordId] := {
                        x1: x1[1],
                        y1: y1[1],
                        x2: x2[1],
                        y2: y2[1]
                    }
                }
            }
        }

        ; 確保所有coordId都有數據
        for coordId, coords in coordData {
            if (!currentRects.Has(coordId)) {
                currentRects[coordId] := {
                    x1: coords[1],
                    y1: coords[2],
                    x2: coords[3],
                    y2: coords[4]
                }
            }
        }

        ShowMsg("成功載入座標配置")
        return true
    } catch {
        ShowMsg("載入配置失敗，使用預設座標")
        return false
    }
}

; 保存座標配置
SaveCoordinates() {
    global currentRects, coordData
    configFile := ConfigPath("coordinates_config.json")

    try {
        json := "["

        first := true
        for coordId, coords in coordData {
            if (!first)
                json .= ","
            json .= '{`n'
            json .= '  "coordId": "' . coordId . '",`n'

            ; 使用currentRects中的數據，如果有的話，否則使用預設值
            if (currentRects.Has(coordId)) {
                rect := currentRects[coordId]
                json .= '  "x1": ' . rect.x1 . ',`n'
                json .= '  "y1": ' . rect.y1 . ',`n'
                json .= '  "x2": ' . rect.x2 . ',`n'
                json .= '  "y2": ' . rect.y2 . '`n'
            } else {
                json .= '  "x1": ' . coords[1] . ',`n'
                json .= '  "y1": ' . coords[2] . ',`n'
                json .= '  "x2": ' . coords[3] . ',`n'
                json .= '  "y2": ' . coords[4] . '`n'
            }

            json .= '}'
            first := false
        }

        json .= "`n]"

        file := FileOpen(configFile, "w", "UTF-8")
        file.Write(json)
        file.Close()

        ShowMsg("座標配置已保存")
        return true
    } catch {
        ShowMsg("保存配置失敗")
        return false
    }
}

; 創建調整模式GUI
CreateAdjustmentGUI() {
    global adjustmentGUI

    if (adjustmentGUI != "") {
        try adjustmentGUI.Destroy()
    }

    adjustmentGUI := Gui("+AlwaysOnTop +ToolWindow", "座標調整工具 - " . targetTitle)

    ; 標題
    adjustmentGUI.Add("Text", "x10 y10 w380 h20", "🎯 座標調整工具 - 拖拽調整辨識區域")

    ; 列表框顯示所有項目
    adjustmentGUI.Add("Text", "x10 y35 w100 h20", "辨識項目:")
    itemList := adjustmentGUI.Add("ListBox", "x10 y55 w200 h200 vSelectedItem", [])

    ; 當前座標顯示
    adjustmentGUI.Add("Text", "x220 y35 w170 h20", "當前座標:")
    coordDisplay := adjustmentGUI.Add("Text", "x220 y55 w170 h60 vCoordDisplay", "尚未選擇項目")

    ; 圖片預覽區域
    adjustmentGUI.Add("Text", "x10 y270 w380 h20", "圖片預覽:")
    adjustmentGUI.Add("Picture", "x10 y290 w200 h150 vImagePreview")
    adjustmentGUI.Add("Text", "x10 y290 w200 h150 vPixelInfo Hidden", "像素搜索區域`n顏色: 0xEE821A`n公差: 25")

    ; 說明文字
    adjustmentGUI.Add("Text", "x220 y290 w170 h80", "操作說明:`n• 拖拽紅色框調整位置`n• 調整大小通過拖拽邊框`n• F9 保存配置`n• Esc 退出")

    ; 按鈕
    adjustmentGUI.Add("Button", "x10 y460 w80 h30", "重新載入").OnEvent("Click", (*) => LoadCoordinates())
    adjustmentGUI.Add("Button", "x100 y460 w80 h30", "保存配置").OnEvent("Click", (*) => SaveCoordinates())
    adjustmentGUI.Add("Button", "x190 y460 w80 h30", "刷新覆蓋").OnEvent("Click", (*) => RefreshOverlays())
    adjustmentGUI.Add("Button", "x280 y460 w80 h30", "退出").OnEvent("Click", (*) => ExitAdjustmentMode())

    ; 填充列表
    for item in recognitionItems {
        itemList.Add([item.name])
    }

    ; 列表選擇事件
    itemList.OnEvent("Change", (*) => UpdateItemDisplay(itemList, coordDisplay))

    adjustmentGUI.Show("w400 h500")
}

; 更新項目顯示
UpdateItemDisplay(itemList, coordDisplay) {
    global currentRects, recognitionItems, adjustmentGUI, currentSelectedCoordId
    selected := itemList.Text

    ; 找到對應的項目和coordId
    selectedCoordId := ""
    for item in recognitionItems {
        if (item.name = selected) {
            selectedCoordId := item.coordId
            break
        }
    }

    ; 更新當前選擇的coordId
    currentSelectedCoordId := selectedCoordId

    if (selectedCoordId != "" && currentRects.Has(selectedCoordId)) {
        rect := currentRects[selectedCoordId]
        coordDisplay.Text := Format("X1: {}`nY1: {}`nX2: {}`nY2: {}", rect.x1, rect.y1, rect.x2, rect.y2)

        ; 顯示對應的覆蓋框
        ShowSingleOverlay(selected)

        ; 顯示圖片預覽或像素搜索說明
        for item in recognitionItems {
            if (item.name = selected) {
                if (item.type = "pixel") {
                    ; 對於像素搜索項目，顯示說明文字，隱藏圖片
                    adjustmentGUI["ImagePreview"].Visible := false
                    adjustmentGUI["PixelInfo"].Visible := true
                } else {
                    ; 對於圖片搜索項目，顯示圖片，隱藏說明文字
                    adjustmentGUI["PixelInfo"].Visible := false
                    adjustmentGUI["ImagePreview"].Visible := true
                    if (FileExist(item.image)) {
                        try {
                            adjustmentGUI["ImagePreview"].Value := item.image
                        }
                    }
                }
                break
            }
        }
    }
}

; 更新當前選中項目的座標顯示
UpdateCoordDisplay() {
    global currentRects, selectedRect, adjustmentGUI
    if (selectedRect != "" && currentRects.Has(selectedRect) && adjustmentGUI != "") {
        rect := currentRects[selectedRect]
        try {
            adjustmentGUI["CoordDisplay"].Text := Format("X1: {}`nY1: {}`nX2: {}`nY2: {}", rect.x1, rect.y1, rect.x2, rect.y2)
        }
    }
}

; 進入調整模式
EnterAdjustmentMode() {
    global isAdjustmentMode

    if (!GetGameWindowInfo()) {
        ShowMsg("請先啟動遊戲並確保視窗存在")
        return
    }

    isAdjustmentMode := true
    LoadCoordinates()
    ; 移除自動顯示所有覆蓋框
    CreateAdjustmentGUI()

    ShowMsg("進入調整模式 - 請先在列表中選擇要調整的辨識項目")
}

; 退出調整模式
ExitAdjustmentMode() {
    global isAdjustmentMode, adjustmentGUI

    isAdjustmentMode := false
    DestroyAllOverlays()

    if (adjustmentGUI != "") {
        try adjustmentGUI.Destroy()
        adjustmentGUI := ""
    }

    ShowMsg("已退出調整模式")
}

; === 熱鍵定義 ===

; F8 - 進入/退出調整模式
F8:: {
    global isAdjustmentMode
    if (isAdjustmentMode) {
        ExitAdjustmentMode()
    } else {
        EnterAdjustmentMode()
    }
}

; F9 - 保存配置
F9:: {
    global isAdjustmentMode
    if (isAdjustmentMode) {
        SaveCoordinates()
    }
}

; F10 - 載入配置
F10:: {
    global isAdjustmentMode
    if (isAdjustmentMode) {
        LoadCoordinates()
        RefreshOverlays()
    }
}

; Esc - 退出
Esc:: {
    global isAdjustmentMode
    if (isAdjustmentMode) {
        ExitAdjustmentMode()
    } else {
        ExitApp()
    }
}

; === 滑鼠事件處理 ===

; 滑鼠左鍵按下 - 開始拖拽
~LButton:: {
    global isAdjustmentMode, currentRects, selectedRect, isDragging, dragStartX, dragStartY, dragOffsetX, dragOffsetY, overlayWindows
    if (!isAdjustmentMode)
        return

    MouseGetPos(&mouseX, &mouseY, &hwnd)

    ; 檢查是否點擊在覆蓋框視窗上
    for name, window in overlayWindows {
        if (hwnd = window.Hwnd) {
            ; 點擊在覆蓋框上，開始拖拽
            selectedRect := name
            isDragging := true

            ; 獲取覆蓋框的當前位置（螢幕座標）
            WinGetPos(&winX, &winY,,, "ahk_id " . hwnd)

            ; 計算滑鼠在覆蓋框內的偏移量
            dragOffsetX := mouseX - winX
            dragOffsetY := mouseY - winY

            ShowMsg("開始拖拽: " . name)
            break
        }
    }
}

; 滑鼠左鍵釋放 - 結束拖拽
~LButton Up:: {
    global isDragging, selectedRect
    if (!isDragging)
        return

    isDragging := false
    selectedRect := ""
    ShowMsg("拖拽完成")
}

; 滑鼠移動事件處理函數
OnMouseMove() {
    global isDragging, selectedRect, currentRects, dragOffsetX, dragOffsetY, overlayWindows, currentSelectedCoordId, adjustmentGUI
    if (!isDragging || selectedRect == "" || !overlayWindows.Has(selectedRect))
        return

    ; 獲取遊戲視窗資訊
    info := GetGameWindowInfo()
    if (!info)
        return

    ; 獲取當前滑鼠位置
    MouseGetPos(&mouseX, &mouseY)

    ; 計算新的覆蓋框位置（螢幕座標）
    newX := mouseX - dragOffsetX
    newY := mouseY - dragOffsetY

    ; 將螢幕座標轉換為客戶區座標來檢查邊界
    clientPos := {x: 0, y: 0, error: true}  ; 預設錯誤值
    clientPos := ScreenToClient(newX, newY)
    if (clientPos.HasOwnProp("error"))
        return

    ; 獲取覆蓋框大小
    WinGetPos(&overlayX, &overlayY, &overlayW, &overlayH, "ahk_id " . overlayWindows[selectedRect].Hwnd)

    ; 確保不超出客戶區邊界
    if (clientPos.x < 0) {
        clientPos.x := 0
        newX := info.clientX
    }
    if (clientPos.y < 0) {
        clientPos.y := 0
        newY := info.clientY
    }
    if (clientPos.x + overlayW > info.clientW) {
        clientPos.x := info.clientW - overlayW
        newX := info.clientX + clientPos.x
    }
    if (clientPos.y + overlayH > info.clientH) {
        clientPos.y := info.clientH - overlayH
        newY := info.clientY + clientPos.y
    }

    ; 移動覆蓋框視窗
    WinMove(newX, newY,,, "ahk_id " . overlayWindows[selectedRect].Hwnd)

    ; 更新座標
    currentRects[selectedRect] := {
        x1: clientPos.x,
        y1: clientPos.y,
        x2: clientPos.x + overlayW,
        y2: clientPos.y + overlayH
    }

    ; 如果拖拽的是當前選擇的項目，更新GUI顯示
    if (selectedRect == currentSelectedCoordId && adjustmentGUI != "") {
        rect := currentRects[selectedRect]
        try {
            adjustmentGUI["CoordDisplay"].Text := Format("X1: {}`nY1: {}`nX2: {}`nY2: {}", rect.x1, rect.y1, rect.x2, rect.y2)
        }
    }
}

; 設置滑鼠移動監聽
SetTimer(OnMouseMove, 50)

; === 初始化 ===
CheckGameWindowTitle()
ShowMsg("座標調整工具已啟動`n按 F8 進入調整模式")
