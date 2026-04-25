;===========================================================
;  UpdateChecker.ahk - 更新檢查模組
;  適用於 AutoHotkey v2.0
;-----------------------------------------------------------
#Requires AutoHotkey v2.0

; === 更新檢查器類別 ===
class UpdateChecker {
    ; 建構子：傳入當前版本、GitHub使用者名稱和倉庫名稱
    __New(currentVersion, githubUser, githubRepo) {
        this.currentVersion := currentVersion
        this.githubUser := githubUser
        this.repoName := githubRepo
        this.apiUrl := "https://api.github.com/repos/" . githubUser . "/" . githubRepo . "/releases/latest"
        this.releasesUrl := "https://github.com/" . githubUser . "/" . githubRepo . "/releases"
        this.userAgent := "Sid-AG-AHK-Updater"
    }

    ; 執行更新檢查
    Check(silent := false) {
        try {
            ; 建立一個 HTTP 請求物件
            http := ComObject("WinHttp.WinHttpRequest.5.1")
            http.Open("GET", this.apiUrl, false) ; false 表示同步請求
            http.SetRequestHeader("User-Agent", this.userAgent)
            http.SetTimeouts(5000, 5000, 10000, 10000) ; 設定超時
            http.Send()

            ; 檢查請求是否成功
            if (http.Status != 200) {
                if (!silent) {
                    MsgBox("無法連接到 GitHub API 進行更新檢查。`n`n狀態碼: " . http.Status, "更新檢查失敗", 48)
                }
                return
            }

            ; 解析收到的 JSON 回應
            json := http.ResponseText
            
            ; 使用正則表達式從 JSON 中提取 'tag_name'
            if (RegExMatch(json, '"tag_name":\s*"v?([^"]+)"', &match)) {
                latestVersion := match[1]
            } else {
                if (!silent) {
                    MsgBox("無法從 GitHub 回應中解析版本號。", "解析錯誤", 48)
                }
                return
            }

            ; 比較版本號 (簡單比較，如果版本號格式複雜可能需要更完善的比較函數)
            if (this._IsNewer(latestVersion, this.currentVersion)) {
                ; 如果有新版本，提取更新日誌
                changelog := "沒有提供更新日誌。"
                if (RegExMatch(json, '"body":\s*"([^"]+)"', &bodyMatch)) {
                    ; 清理從 JSON 來的字串
                    cleanedBody := StrReplace(bodyMatch[1], "\r\n", "`n")
                    cleanedBody := StrReplace(cleanedBody, "\\n", "`n")
                    cleanedBody := StrReplace(cleanedBody, '\"', '"')
                    if (Trim(cleanedBody) != "") {
                        changelog := cleanedBody
                    }
                }
                ; 顯示更新提示 GUI
                this.ShowUpdateGUI(latestVersion, changelog)
            } else {
                if (!silent) {
                    MsgBox("您的腳本已是最新版本！`n`n當前版本: " . this.currentVersion, "無需更新", 64)
                }
            }
        } catch as e {
            if (!silent) {
                MsgBox("檢查更新時發生錯誤。`n請檢查您的網路連線。`n`n錯誤訊息: " . e.Message, "更新檢查失敗", 16)
            }
        }
    }

    ; 顯示更新提示視窗
    ShowUpdateGUI(newVersion, changelog) {
        updateGui := Gui("+AlwaysOnTop", "發現新版本！")
        updateGui.SetFont("s12", "Microsoft YaHei")
        updateGui.Add("Text", "w400 h30 Center", "發現新版本: v" . newVersion).SetFont("s14 bold")
        
        updateGui.Add("Text", "x20 y50", "當前版本: v" . this.currentVersion)
        
        updateGui.Add("GroupBox", "x15 y80 w420 h200", "更新內容")
        updateGui.Add("Edit", "x25 y100 w400 h170 ReadOnly -VScroll", changelog)

        btn := updateGui.Add("Button", "x125 y290 w200 h35 Default", "前往下載頁面")
        btn.OnEvent("Click", (*) => Run(this.releasesUrl))
        
        updateGui.OnEvent("Close", (*) => updateGui.Destroy())
        updateGui.Show("w450 h340")
    }

    ; 簡單的版本比較函數
    _IsNewer(v1, v2) {
        parts1 := StrSplit(v1, ".")
        parts2 := StrSplit(v2, ".")
        loopCount := Max(parts1.Length, parts2.Length)
        Loop loopCount {
            p1 := A_Index <= parts1.Length ? Integer(parts1[A_Index]) : 0
            p2 := A_Index <= parts2.Length ? Integer(parts2[A_Index]) : 0
            if (p1 > p2)
                return true
            if (p1 < p2)
                return false
        }
        return false
    }
}
