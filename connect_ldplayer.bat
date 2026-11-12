@echo off
setlocal enabledelayedexpansion

:: Check if adb is available in PATH
where adb >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "ADB_CMD=adb"
    goto :connect
)

:: Check Android SDK default path
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set "ADB_CMD=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
    goto :connect
)

:: Check LDPlayer14 installation path
if exist "C:\LDPlayer\LDPlayer14\adb.exe" (
    set "ADB_CMD=C:\LDPlayer\LDPlayer14\adb.exe"
    goto :connect
)

:: Check LDPlayer9 installation path
if exist "C:\LDPlayer\LDPlayer9\adb.exe" (
    set "ADB_CMD=C:\LDPlayer\LDPlayer9\adb.exe"
    goto :connect
)

echo [ERROR] adb.exe not found. Please add Android SDK platform-tools to your PATH.
pause
exit /b 1

:connect
echo Using ADB from: !ADB_CMD!
echo.
echo Connecting to LDPlayer (port 5555)...
"!ADB_CMD!" connect 127.0.0.1:5555
echo.
echo Connected devices:
"!ADB_CMD!" devices
echo.
pause
