#Requires AutoHotkey v2.0

global PROJECT_ROOT := RegExReplace(A_LineFile, "\\src\\ProjectPaths\.ahk$")
global SRC_DIR := PROJECT_ROOT . "\src"
global MODULE_DIR := SRC_DIR . "\modules"
global CONFIG_DIR := PROJECT_ROOT . "\config"
global ASSETS_DIR := PROJECT_ROOT . "\assets"
global COMMON_ASSETS_DIR := ASSETS_DIR . "\common"
global CHARACTER_ASSETS_DIR := ASSETS_DIR . "\characters"
global DOCS_DIR := PROJECT_ROOT . "\docs"
global RELEASES_DIR := PROJECT_ROOT . "\releases"

ProjectPath(relativePath := "") {
    return relativePath = "" ? PROJECT_ROOT : PROJECT_ROOT . "\" . relativePath
}

ConfigPath(fileName := "") {
    return fileName = "" ? CONFIG_DIR : CONFIG_DIR . "\" . fileName
}

AssetPath(relativePath := "") {
    return relativePath = "" ? ASSETS_DIR : ASSETS_DIR . "\" . relativePath
}

CommonAssetPath(fileName := "") {
    return fileName = "" ? COMMON_ASSETS_DIR : COMMON_ASSETS_DIR . "\" . fileName
}

CharacterAssetPath(characterName, fileName := "") {
    basePath := CHARACTER_ASSETS_DIR . "\" . characterName
    return fileName = "" ? basePath : basePath . "\" . fileName
}
