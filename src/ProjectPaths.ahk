#Requires AutoHotkey v2.0

; 檢測是否為編譯後的 EXE 執行
if (A_IsCompiled) {
    ; EXE 執行時，腳本位於根目錄
    global PROJECT_ROOT := RegExReplace(A_ScriptDir, "\\$")
} else {
    ; 檢查腳本位置：開發時在 src 目錄，發布時在根目錄
    if (InStr(A_LineFile, "\src\ProjectPaths.ahk")) {
        ; 開發時，腳本位於 src 目錄
        global PROJECT_ROOT := RegExReplace(A_LineFile, "\\src\\ProjectPaths\.ahk$")
    } else {
        ; 發布時，腳本位於根目錄
        global PROJECT_ROOT := RegExReplace(A_LineFile, "\\ProjectPaths\.ahk$")
    }
}

global SRC_DIR := PROJECT_ROOT . "\src"
global MODULE_DIR := SRC_DIR . "\modules"
global CONFIG_DIR := PROJECT_ROOT . "\config"
global ASSETS_DIR := PROJECT_ROOT . "\assets"
global COMMON_ASSETS_DIR := ASSETS_DIR . "\common"
global CHARACTER_ASSETS_DIR := ASSETS_DIR . "\characters"
global DOCS_DIR := PROJECT_ROOT . "\docs"
global RELEASES_DIR := PROJECT_ROOT . "\releases"

GetProjectPath(relativePath := "") {
    return relativePath = "" ? PROJECT_ROOT : PROJECT_ROOT . "\" . relativePath
}

GetConfigPath(fileName := "") {
    return fileName = "" ? CONFIG_DIR : CONFIG_DIR . "\" . fileName
}

GetAssetPath(relativePath := "") {
    return relativePath = "" ? ASSETS_DIR : ASSETS_DIR . "\" . relativePath
}

GetCommonAssetPath(fileName := "") {
    return fileName = "" ? COMMON_ASSETS_DIR : COMMON_ASSETS_DIR . "\" . fileName
}

GetCharacterAssetPath(characterName, fileName := "") {
    basePath := CHARACTER_ASSETS_DIR . "\" . characterName
    return fileName = "" ? basePath : basePath . "\" . fileName
}
