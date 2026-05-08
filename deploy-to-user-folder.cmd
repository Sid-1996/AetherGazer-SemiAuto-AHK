@echo off
chcp 65001 >nul
echo Starting deployment to user folder...

set devFolder=c:\Code play first\AetherGazer ahk
set userFolder=c:\Code play first\AetherGazer ahk\releases\AetherGazer-AHK-v1.0.9

echo Creating target directories...
if not exist "%userFolder%" mkdir "%userFolder%"
if not exist "%userFolder%\modules" mkdir "%userFolder%\modules"
if not exist "%userFolder%\lib" mkdir "%userFolder%\lib"
if not exist "%userFolder%\config" mkdir "%userFolder%\config"
if not exist "%userFolder%\assets" mkdir "%userFolder%\assets"

echo Processing SidAgApp.ahk...
powershell -Command "(Get-Content '%devFolder%\src\apps\SidAgApp.ahk' -Raw -Encoding UTF8) -replace '#Include \.\.\\modules\\', '#Include modules\' -replace '#Include \.\.\\\.\.\\lib\\', '#Include lib\' | Set-Content '%userFolder%\SidAgApp.ahk' -NoNewline -Encoding UTF8"

echo Processing sid-ag.ahk...
powershell -Command "(Get-Content '%devFolder%\sid-ag.ahk' -Raw -Encoding UTF8) -replace '#Include src\\', '#Include ' -replace '#Include apps\\', '#Include ' | Set-Content '%userFolder%\sid-ag.ahk' -NoNewline -Encoding UTF8"

echo Copying main entry files...
copy "%devFolder%\run-sid-ag.cmd" "%userFolder%\run-sid-ag.cmd" /Y

echo Copying documentation files...
copy "%devFolder%\README.md" "%userFolder%\README.md" /Y
copy "%devFolder%\CHANGELOG.md" "%userFolder%\CHANGELOG.md" /Y
copy "%devFolder%\LICENSE" "%userFolder%\LICENSE" /Y

echo Copying module files...
copy "%devFolder%\src\modules\*.ahk" "%userFolder%\modules\" /Y

echo Copying lib files...
copy "%devFolder%\lib\*.ahk" "%userFolder%\lib\" /Y

echo Copying config files...
copy "%devFolder%\config\*.ini" "%userFolder%\config\" /Y
copy "%devFolder%\config\*.json" "%userFolder%\config\" /Y

echo Copying assets files...
if exist "%userFolder%\assets" rmdir /s /q "%userFolder%\assets"
xcopy "%devFolder%\assets" "%userFolder%\assets\" /E /I /Y

echo.
echo Deployment completed!
echo User folder: %userFolder%
pause
