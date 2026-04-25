@echo off
setlocal
set "AHK=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
if not exist "%AHK%" set "AHK=C:\Program Files\AutoHotkey\v2\AutoHotkey.exe"
if not exist "%AHK%" (
  echo AutoHotkey v2 executable not found under C:\Program Files\AutoHotkey\v2
  exit /b 1
)
"%AHK%" "%~dp0CoordinateAdjustmentTool.ahk"
