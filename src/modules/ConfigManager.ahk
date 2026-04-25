;===========================================================
;  ConfigManager.ahk - 配置管理器
;  適用於 AutoHotkey v2.0
;-----------------------------------------------------------
#Requires AutoHotkey v2.0

; === 配置管理器類別 ===
class ConfigManager {
    ; 建構子
    __New(configPath := "") {
        this.configPath := configPath ? configPath : ConfigPath("Config.ini")
        this.config := Map()
        this.LoadConfig()
    }
    
    ; 載入配置文件
    LoadConfig() {
        if (!FileExist(this.configPath)) {
            this.CreateDefaultConfig()
        }
        
        try {
            ; 讀取所有區段
            sections := ["Script", "UpdateChecker", "Game", "UI", "Hotkeys"]
            
            for section in sections {
                this.config[section] := Map()
                
                ; 讀取每個區段的鍵值
                switch section {
                    case "Script":
                        this.config[section]["Version"] := this._ReadIni(section, "Version", "1.0.0")
                        this.config[section]["Name"] := this._ReadIni(section, "Name", "sid-ag")
                    
                    case "UpdateChecker":
                        this.config[section]["GitHubUser"] := this._ReadIni(section, "GitHubUser", "")
                        this.config[section]["GitHubRepo"] := this._ReadIni(section, "GitHubRepo", "")
                        this.config[section]["CheckOnStart"] := this._ReadIniBool(section, "CheckOnStart", true)
                        this.config[section]["SilentCheck"] := this._ReadIniBool(section, "SilentCheck", true)
                        this.config[section]["AutoUpdate"] := this._ReadIniBool(section, "AutoUpdate", false)
                        this.config[section]["TimeoutSeconds"] := this._ReadIniInt(section, "TimeoutSeconds", 15)
                        this.config[section]["CheckInterval"] := this._ReadIniInt(section, "CheckInterval", 0)
                    
                    case "Game":
                        this.config[section]["WindowTitle"] := this._ReadIni(section, "WindowTitle", " AetherGazer")
                        this.config[section]["WindowWidth"] := this._ReadIniInt(section, "WindowWidth", 1600)
                        this.config[section]["WindowHeight"] := this._ReadIniInt(section, "WindowHeight", 900)
                        this.config[section]["SkillCooldown"] := this._ReadIniInt(section, "SkillCooldown", 150)
                        this.config[section]["SkillLockTime"] := this._ReadIniInt(section, "SkillLockTime", 300)
                        this.config[section]["ColorVariation"] := this._ReadIniInt(section, "ColorVariation", 15)
                        this.config[section]["ImageVariation"] := this._ReadIniInt(section, "ImageVariation", 80)
                    
                    case "UI":
                        this.config[section]["StatusDisplayX"] := this._ReadIniInt(section, "StatusDisplayX", 10)
                        this.config[section]["StatusDisplayY"] := this._ReadIniInt(section, "StatusDisplayY", 10)
                        this.config[section]["ShowStartupGUI"] := this._ReadIniBool(section, "ShowStartupGUI", true)
                        this.config[section]["ShowStatusOverlay"] := this._ReadIniBool(section, "ShowStatusOverlay", true)
                    
                    case "Hotkeys":
                        this.config[section]["AutoAttack"] := this._ReadIni(section, "AutoAttack", "F1")
                        this.config[section]["WindowResize"] := this._ReadIni(section, "WindowResize", "F2")
                        this.config[section]["Help"] := this._ReadIni(section, "Help", "F3")
                        this.config[section]["Pause"] := this._ReadIni(section, "Pause", "F4")
                        this.config[section]["CharacterSelect"] := this._ReadIni(section, "CharacterSelect", "F5")
                        this.config[section]["BBQMode"] := this._ReadIni(section, "BBQMode", "F6")
                        this.config[section]["CheckUpdate"] := this._ReadIni(section, "CheckUpdate", "F7")
                        this.config[section]["Reload"] := this._ReadIni(section, "Reload", "F11")
                        this.config[section]["Exit"] := this._ReadIni(section, "Exit", "F12")
                }
            }
        } catch Error as e {
            ; 配置載入失敗時使用預設值
            this.LoadDefaultValues()
        }
    }
    
    ; 創建預設配置文件
    CreateDefaultConfig() {
        try {
            defaultContent := "
(
[Script]
; 腳本基本資訊
Version=1.0.0
Name=sid-ag

[UpdateChecker]
; GitHub 設定
GitHubUser=Sid-1996
GitHubRepo=AetherGazer-SemiAuto-AHK

; 更新檢查設定
CheckOnStart=true
SilentCheck=true
AutoUpdate=false
TimeoutSeconds=15
CheckInterval=0

[Game]
; 遊戲視窗設定
WindowTitle= AetherGazer
WindowWidth=1600
WindowHeight=900

; 技能相關設定
SkillCooldown=150
SkillLockTime=300
ColorVariation=15
ImageVariation=80

[UI]
; 介面設定
StatusDisplayX=10
StatusDisplayY=10
ShowStartupGUI=true
ShowStatusOverlay=true

[Hotkeys]
; 熱鍵設定
AutoAttack=F1
WindowResize=F2
Help=F3
Pause=F4
CharacterSelect=F5
BBQMode=F6
CheckUpdate=F7
Reload=F11
Exit=F12
)"
            FileAppend(defaultContent, this.configPath, "UTF-8")
        } catch {
            ; 無法創建配置文件時載入預設值
            this.LoadDefaultValues()
        }
    }
    
    ; 載入預設值
    LoadDefaultValues() {
        this.config := Map()
        this.config["Script"] := Map("Version", "1.0.0", "Name", "sid-ag")
        this.config["UpdateChecker"] := Map(
            "GitHubUser", "",
            "GitHubRepo", "",
            "CheckOnStart", true,
            "SilentCheck", true,
            "AutoUpdate", false,
            "TimeoutSeconds", 15,
            "CheckInterval", 0
        )
        this.config["Game"] := Map(
            "WindowTitle", " AetherGazer",
            "WindowWidth", 1600,
            "WindowHeight", 900,
            "SkillCooldown", 150,
            "SkillLockTime", 300,
            "ColorVariation", 15,
            "ImageVariation", 80
        )
        this.config["UI"] := Map(
            "StatusDisplayX", 10,
            "StatusDisplayY", 10,
            "ShowStartupGUI", true,
            "ShowStatusOverlay", true
        )
        this.config["Hotkeys"] := Map(
            "AutoAttack", "F1",
            "WindowResize", "F2",
            "Help", "F3",
            "Pause", "F4",
            "CharacterSelect", "F5",
            "BBQMode", "F6",
            "CheckUpdate", "F7",
            "Reload", "F11",
            "Exit", "F12"
        )
    }
    
    ; 獲取配置值
    Get(section, key, defaultValue := "") {
        try {
            if (this.config.Has(section) && this.config[section].Has(key)) {
                return this.config[section][key]
            }
        } catch {
            ; 訪問失敗時返回預設值
        }
        return defaultValue
    }
    
    ; 設置配置值
    Set(section, key, value) {
        try {
            if (!this.config.Has(section)) {
                this.config[section] := Map()
            }
            this.config[section][key] := value
            return true
        } catch {
            return false
        }
    }
    
    ; 保存配置到文件
    SaveConfig() {
        try {
            content := ""
            for sectionName, sectionData in this.config {
                content .= "[" . sectionName . "]`n"
                for key, value in sectionData {
                    ; 處理布林值
                    if (Type(value) = "Integer" && (value = 0 || value = 1)) {
                        value := value ? "true" : "false"
                    }
                    content .= key . "=" . value . "`n"
                }
                content .= "`n"
            }
            
            ; 寫入文件
            if (FileExist(this.configPath)) {
                FileDelete(this.configPath)
            }
            FileAppend(content, this.configPath, "UTF-8")
            return true
        } catch {
            return false
        }
    }
    
    ; 獲取更新檢查器選項
    GetUpdateOptions() {
        return {
            checkOnStart: this.Get("UpdateChecker", "CheckOnStart", true),
            silentCheck: this.Get("UpdateChecker", "SilentCheck", true),
            autoUpdate: this.Get("UpdateChecker", "AutoUpdate", false),
            timeout: this.Get("UpdateChecker", "TimeoutSeconds", 15) * 1000,
            checkInterval: this.Get("UpdateChecker", "CheckInterval", 0)
        }
    }
    
    ; 驗證GitHub設定
    ValidateGitHubConfig() {
        user := this.Get("UpdateChecker", "GitHubUser", "")
        repo := this.Get("UpdateChecker", "GitHubRepo", "")
        return (user != "" && repo != "")
    }
    
    ; 內部輔助方法：讀取INI字串值
    _ReadIni(section, key, defaultValue := "") {
        try {
            return IniRead(this.configPath, section, key, defaultValue)
        } catch {
            return defaultValue
        }
    }
    
    ; 內部輔助方法：讀取INI整數值
    _ReadIniInt(section, key, defaultValue := 0) {
        try {
            value := IniRead(this.configPath, section, key, defaultValue)
            return Integer(value)
        } catch {
            return defaultValue
        }
    }
    
    ; 內部輔助方法：讀取INI布林值
    _ReadIniBool(section, key, defaultValue := false) {
        try {
            value := IniRead(this.configPath, section, key, defaultValue ? "true" : "false")
            return (value = "true" || value = "1")
        } catch {
            return defaultValue
        }
    }
}

; === 全域配置管理器實例 ===
global ConfigInstance := ""

; 初始化配置管理器
InitializeConfig(configPath := "") {
    global ConfigInstance
    ConfigInstance := ConfigManager(configPath)
    return ConfigInstance
}

; 獲取配置值（便捷函數）
GetConfig(section, key, defaultValue := "") {
    global ConfigInstance
    if (ConfigInstance) {
        return ConfigInstance.Get(section, key, defaultValue)
    }
    return defaultValue
}

; 設置配置值（便捷函數）
SetConfig(section, key, value) {
    global ConfigInstance
    if (ConfigInstance) {
        return ConfigInstance.Set(section, key, value)
    }
    return false
}
